#!/bin/bash

# ==============================================================================
# DEFINIZIONE FUNZIONI & TRAP
# ==============================================================================

# Funzione di pulizia per gestire Ctrl+C
cleanup() {
    echo -e "\n\nScript interrotto. Eseguo pulizia processi..."
    [ ! -z "$SPIN_PID" ] && kill $SPIN_PID 2>/dev/null
    pkill -f "ffmpeg.*loudnorm" 2>/dev/null
    exit 130
}

trap cleanup SIGINT

# Funzione per lo spinner
show_spinner() {
    local spin_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏" # Spinner animato
    local fallback_chars="/-|\\*" # Fallback ASCII se i caratteri Unicode non funzionano
    
    # Test se supporta caratteri Unicode
    if ! printf "%s" "⠋" >/dev/null 2>&1; then
        spin_chars="$fallback_chars"
    fi
    
    while true; do
        for (( i=0; i<${#spin_chars}; i++ )); do
            printf "\rScansione in corso: %s " "${spin_chars:$i:1}"
            sleep 0.15
        done
    done
}

# ==================================================================================================
# INIZIO DELLO SCRIPT PRINCIPALE
# ==================================================================================================
# ducking_auto.sh v1.7 - Il Santo Graal dell'Audio Ottimizzato
# Unifica la Forza di Cartoni[1], Film[2], Serie[3] e Stereo[4] in un solo script!
# Auto-seleziona il preset perfetto con analisi LUFS/PEAK/LRA o rilevazione canali
# Potenziato per dialoghi cristallini, bassi controllati ed effetti da "May the Force be with you!"
# Ideale per soundbar LG Meridian SP7 + RPK8, da un sussurro a un'esplosione alla Michael Bay
# ==================================================================================================

# Controllo argomenti
INPUT_FILE="$1"
BITRATE="768k"  # Default, cambia per preset
[ ! -z "$2" ] && BITRATE="$2"
PRESET_OVERRIDE="$3"  # Opzionale: "cartoni", "film", "serie", "stereo"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: ./ducking_auto.sh \"file.mkv\" [bitrate] [preset_override]"
    exit 1
fi

# -------------------- RILEVAZIONE CHANNEL LAYOUT --------------------
CHANNELS=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")
echo "Canali rilevati: $CHANNELS"

# -------------------- ANALISI SPETTRALE --------------------
echo "===================== ANALISI SPETTRALE =========================="
echo "Avvio array di sensori... Calibrazione del flusso audio in corso."
echo "Acquisizione telemetria EBU R128: calcolo del Loudness Integrato."
echo "Scansione subspaziale per True Peak e Loudness Range (LRA)."
echo "ETA per decodifica del segnale: circa 10 min per ora di runtime."

show_spinner &
SPIN_PID=$!

ANALYSIS=$(ffmpeg -nostdin -i "$INPUT_FILE" -af loudnorm=print_format=summary -f null - 2>&1)

kill $SPIN_PID 2>/dev/null
wait $SPIN_PID 2>/dev/null
printf "\rAnalisi completata! \n"

# -------------------- ESTRAZIONE DATI --------------------
LUFS=$(echo "$ANALYSIS" | grep "Input Integrated" | awk '{print $3}' | sed 's/LUFS//')
PEAK=$(echo "$ANALYSIS" | grep "Input True Peak" | awk '{print $4}' | sed 's/dBTP//')
LRA=$(echo "$ANALYSIS" | grep "Input LRA" | awk '{print $3}' | sed 's/LU//')
THRESHOLD=$(echo "$ANALYSIS" | grep "Input Threshold" | awk '{print $3}' | sed 's/LUFS//')
TARGET_OFFSET=$(echo "$ANALYSIS" | grep "Target Offset" | awk '{print $3}' | sed 's/LU//')

echo "==================== RISULTATI ANALISI ========================="
echo "Input Integrated: $LUFS LUFS | True Peak: $PEAK dBTP | LRA: $LRA LU"
echo "Threshold: $THRESHOLD LUFS | Target Offset: $TARGET_OFFSET LU"

# -------------------- AUTO-SELEZIONE PRESET --------------------
if [ ! -z "$PRESET_OVERRIDE" ]; then
    PRESET="$PRESET_OVERRIDE"
    echo "Preset override: $PRESET"
else
    if [ "$CHANNELS" -eq 2 ]; then
        PRESET="stereo"
        echo "Auto-detect: Preset Stereo - Minimalista per 2 canali![4]"
    elif [ $(awk "BEGIN {print ($LRA > 12 && $LUFS < -20) ? 1 : 0}") -eq 1 ]; then
        PRESET="cartoni"
        echo "Auto-detect: Preset Cartoni - Dinamica da musical Disney![1]"
    elif [ $(awk "BEGIN {print ($LRA > 15 && $PEAK > -2) ? 1 : 0}") -eq 1 ]; then
        PRESET="film"
        echo "Auto-detect: Preset Film - Pronto per l'azione alla Michael Bay![2]"
    else
        PRESET="serie"
        echo "Auto-detect: Preset Serie - Binge-mode attivato![3]"
    fi
fi

# Output file personalizzato
OUTPUT_FILE="${INPUT_FILE%.*}_${PRESET}_ducked.mkv"

# -------------------- PARAMETRI BASE PER PRESET --------------------
case $PRESET in
    cartoni)
        VOICE_BOOST=3.3
        LFE_REDUCTION=0.79
        LFE_DUCK_THRESHOLD=0.008
        LFE_DUCK_RATIO=3.8
        FX_DUCK_THRESHOLD=0.008
        FRONT_FX_REDUCTION=0.90
        FX_DUCK_RATIO=2.8
        FX_ATTACK=25
        FX_RELEASE=650
        LFE_ATTACK=30
        LFE_RELEASE=700
        LFE_HP_FREQ=45
        LFE_LP_FREQ=100
        SURROUND_BOOST=2.0
        MAKEUP_GAIN=5.0
        BITRATE=${BITRATE:-"768k"}  # Default per cartoni[1]
        TITLE="Clearvoice EAC3 Cartoni"
        ;;
    film)
        VOICE_BOOST=3.3
        LFE_REDUCTION=0.76
        LFE_DUCK_THRESHOLD=0.003
        LFE_DUCK_RATIO=4.0
        FX_DUCK_RATIO=2.6
        FX_DUCK_THRESHOLD=0.006
        FRONT_FX_REDUCTION=0.90
        FX_ATTACK=20
        FX_RELEASE=600
        LFE_ATTACK=15
        LFE_RELEASE=550
        LFE_HP_FREQ=30 
        LFE_LP_FREQ=120
        SURROUND_BOOST=2.2
        MAKEUP_GAIN=5.2
        BITRATE=${BITRATE:-"768k"}  # Default per film[2]
        TITLE="Clearvoice EAC3 Film"
        ;;
    serie)
        VOICE_BOOST=3.3
        LFE_REDUCTION=0.75
        LFE_DUCK_THRESHOLD=0.004
        LFE_DUCK_RATIO=2.8
        FX_DUCK_THRESHOLD=0.007
        FX_DUCK_RATIO=2.0
        FX_ATTACK=20
        FX_RELEASE=650
        FRONT_FX_REDUCTION=0.90
        LFE_ATTACK=15
        LFE_RELEASE=600
        LFE_HP_FREQ=35
        LFE_LP_FREQ=100
        SURROUND_BOOST=2.0
        MAKEUP_GAIN=5.0
        BITRATE=${BITRATE:-"384k"}  # Default per serie[3]
        TITLE="Clearvoice EAC3 Serie"
        ;;
    stereo)
        VOICE_BOOST=3.4
        LFE_REDUCTION=0.80
        LFE_HP_FREQ=35
        SURROUND_BOOST=1.0  # Non utilizzato nel preset stereo
        MAKEUP_GAIN=5.2
        BITRATE=${BITRATE:-"320k"}  # Default per stereo[4]
        TITLE="Clearvoice EAC3 Stereo"
        ;;
esac

# -------------------- LOGICA ADATTIVA PER PRESET --------------------
echo "RACCOMANDAZIONI AUTOMATICHE PER $PRESET:"

case $PRESET in
    cartoni)
        # Logica da [1]
        if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
            VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.1}")
            FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.3}")
            MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.2}")
        elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
            FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.1}")
            MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.7}")
        fi
        if [ $(awk "BEGIN {print ($PEAK > -2) ? 1 : 0}") -eq 1 ]; then
            LFE_HP_FREQ=50
        fi
        ;;
    film)
        # Logica da [2]
        if [ $(awk "BEGIN {print ($LUFS > -14) ? 1 : 0}") -eq 1 ]; then
            LFE_DUCK_RATIO=$(awk "BEGIN {print $LFE_DUCK_RATIO + 0.6}")
            FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.4}")
            LFE_REDUCTION=$(awk "BEGIN {print $LFE_REDUCTION - 0.05}")
            MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.9}")
        elif [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
            VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.1}")
            FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.3}")
            LFE_DUCK_RATIO=$(awk "BEGIN {print $LFE_DUCK_RATIO + 0.4}")
            MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.2}")
        fi
        if [ $(awk "BEGIN {print ($PEAK > -2) ? 1 : 0}") -eq 1 ]; then
            LFE_HP_FREQ=35
        fi
        if [ $(awk "BEGIN {print ($PEAK > -1.5 && $LRA > 13) ? 1 : 0}") -eq 1 ]; then
            LFE_REDUCTION=$(awk "BEGIN {print $LFE_REDUCTION - 0.15}")
        fi
        if [ $(awk "BEGIN {print ($LRA > 18 && $LUFS < -20) ? 1 : 0}") -eq 1 ]; then
            VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.6}")
        fi
        ;;
    serie)
        # Logica da [3]
        if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
            VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.1}")
            FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.3}")
            LFE_DUCK_RATIO=$(awk "BEGIN {print $LFE_DUCK_RATIO + 0.3}")
            MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.2}")
        elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
            FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.3}")
            LFE_DUCK_RATIO=$(awk "BEGIN {print $LFE_DUCK_RATIO + 0.3}")
            MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.8}")
        fi
        if [ $(awk "BEGIN {print ($PEAK > -2) ? 1 : 0}") -eq 1 ]; then
            LFE_HP_FREQ=40
        fi
        if [ $(awk "BEGIN {print ($LRA < 5 && $LUFS > -18) ? 1 : 0}") -eq 1 ]; then
            FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.6}")
            FX_RELEASE=$(awk "BEGIN {print $FX_RELEASE - 25}")
        fi
        if [ $(awk "BEGIN {print ($PEAK > -1.5 && $LRA > 12) ? 1 : 0}") -eq 1 ]; then
            LFE_REDUCTION=$(awk "BEGIN {print $LFE_REDUCTION - 0.12}")
        fi
        # Filtro voce italiana ultra-conservativo - allineato agli altri script
        VOICE_EQ="highpass=f=70,deesser=i=0.03:m=0.15:f=0.16,aexciter=level_in=1:level_out=1:amount=1.0:drive=4.0:blend=0:freq=3000:ceil=10000:listen=0,compand=attacks=0.002:decays=0.01:points=-75/-75|-40/-38|-25/-18|-10/-6:soft-knee=5:gain=0.3"
        LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=65:width_type=q:w=1.8:g=0.4"
        COMPAND_PARAMS="attacks=0.02:decays=0.05:points=-60/-60|-25/-25|-12/-8:soft-knee=2:gain=0"
        SIDECHAIN_PREP="bandpass=f=2200:width_type=h:w=2800,volume=2.6,compand=${COMPAND_PARAMS},agate=threshold=-30dB:ratio=2.0:attack=0.5:release=4000"

        ;;
    stereo)
        # Logica da [4]
        if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
            VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.5}")
            MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.2}")
        fi
        # Filtro voce italiana ultra-conservativo - allineato agli altri script
        VOICE_EQ="highpass=f=70,deesser=i=0.03:m=0.15:f=0.16,aexciter=level_in=1:level_out=1:amount=1.0:drive=4.0:blend=0:freq=3000:ceil=10000:listen=0,compand=attacks=0.002:decays=0.01:points=-75/-75|-40/-38|-25/-18|-10/-6:soft-knee=5:gain=0.3"
        LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=65:width_type=q:w=1.8:g=0.4"
        ;;
esac

# -------------------- PREPARAZIONE FILTRI COMUNI --------------------
# Filtri specifici per preset
case $PRESET in
    cartoni)
        VOICE_EQ="highpass=f=70,deesser=i=0.02:m=0.12:f=0.15,aexciter=level_in=1:level_out=1:amount=0.45:drive=1.8:blend=0:freq=2600:ceil=10000:listen=0,compand=attacks=0.0025:decays=0.015:points=-75/-75|-40/-39|-25/-20|-10/-7:soft-knee=5:gain=0.25"
        LFE_EQ="equalizer=f=35:width_type=q:w=1.6:g=0.6,equalizer=f=75:width_type=q:w=1.8:g=0.4"
        COMPAND_PARAMS="attacks=0.005:decays=0.01:points=-60/-60|-30/-30|-15/-8:soft-knee=2:gain=0"
        SURROUND_EQ="highpass=f=60,agate=threshold=-32dB:ratio=3.0:attack=2:release=150:makeup=1,volume=${SURROUND_BOOST}" # Gate Cartoni: pulizia e musicalità
        ;;
    film)
        VOICE_EQ="highpass=f=70,deesser=i=0.02:m=0.12:f=0.15,aexciter=level_in=1:level_out=1:amount=0.45:drive=1.8:blend=0:freq=2600:ceil=10000:listen=0,compand=attacks=0.0025:decays=0.015:points=-75/-75|-40/-39|-25/-20|-10/-7:soft-knee=5:gain=0.25"
        LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=70:width_type=q:w=1.8:g=0.5"
        COMPAND_PARAMS="attacks=0.01:decays=0.03:points=-60/-60|-25/-25|-12/-8:soft-knee=2:gain=0"
        SURROUND_EQ="highpass=f=60,agate=threshold=-38dB:ratio=2.0:attack=5:release=400:makeup=1,volume=${SURROUND_BOOST}" # Gate Film: preserva atmosfera cinematografica
        ;;
    serie)
        VOICE_EQ="highpass=f=70,deesser=i=0.02:m=0.12:f=0.15,aexciter=level_in=1:level_out=1:amount=0.45:drive=1.8:blend=0:freq=2600:ceil=10000:listen=0,compand=attacks=0.0025:decays=0.015:points=-75/-75|-40/-39|-25/-20|-10/-7:soft-knee=5:gain=0.25"
        LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=65:width_type=q:w=1.8:g=0.4"
        COMPAND_PARAMS="attacks=0.02:decays=0.05:points=-60/-60|-25/-25|-12/-8:soft-knee=2:gain=0"
        SURROUND_EQ="highpass=f=60,agate=threshold=-35dB:ratio=2.5:attack=3:release=250:makeup=1,volume=${SURROUND_BOOST}" # Gate Serie TV: bilanciato per dialoghi frequenti
        ;;
    stereo)
        VOICE_EQ="highpass=f=70,deesser=i=0.02:m=0.12:f=0.15,aexciter=level_in=1:level_out=1:amount=0.45:drive=1.8:blend=0:freq=2600:ceil=10000:listen=0,compand=attacks=0.0025:decays=0.015:points=-75/-75|-40/-39|-25/-20|-10/-7:soft-knee=5:gain=0.25"
        LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=65:width_type=q:w=1.8:g=0.4"
        SURROUND_EQ="highpass=f=60,volume=${SURROUND_BOOST}" # Non utilizzato nel preset stereo
        ;;
esac

SIDECHAIN_PREP="bandpass=f=2200:width_type=h:w=2800,volume=2.6,compand=${COMPAND_PARAMS},agate=threshold=-30dB:ratio=2.0:attack=0.5:release=4000"
FRONT_FX_EQ="highpass=f=80"

# Riorganizzazione filtri finali
FC_FILTER="${VOICE_EQ},volume=${VOICE_BOOST},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=70:asc=1"
LFE_FILTER="highpass=f=${LFE_HP_FREQ}:poles=2,lowpass=f=${LFE_LP_FREQ}:poles=2,${LFE_EQ},volume=${LFE_REDUCTION}"
LFE_SC_PARAMS="threshold=${LFE_DUCK_THRESHOLD}:ratio=${LFE_DUCK_RATIO}:attack=${LFE_ATTACK}:release=${LFE_RELEASE}:makeup=1.0"
FX_SC_PARAMS="threshold=${FX_DUCK_THRESHOLD}:ratio=${FX_DUCK_RATIO}:attack=${FX_ATTACK}:release=${FX_RELEASE}:makeup=1.0"
FINAL_FILTER="aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,volume=${MAKEUP_GAIN},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=100:asc=1,aformat=channel_layouts=5.1"

# -------------------- ESECUZIONE FFMPEG --------------------
echo "Avvio elaborazione con preset $PRESET..."
start_time=$(date +%s)

if [ "$PRESET" = "stereo" ]; then
    # Filtri semplificati per stereo [4]
    ffmpeg -y -nostdin -hwaccel auto -threads 0 -i "$INPUT_FILE" -filter_complex \
    "[0:a]${VOICE_EQ},volume=${VOICE_BOOST}[voiceboost]; \
    [voiceboost]highpass=f=${LFE_HP_FREQ}:poles=2,${LFE_EQ},volume=${LFE_REDUCTION}[final]; \
    [final]aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,volume=${MAKEUP_GAIN},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=100:asc=1,aformat=channel_layouts=stereo[clearvoice]" \
    -map 0:v -c:v copy \
    -map "[clearvoice]" -c:a:0 eac3 -b:a:0 ${BITRATE} -metadata:s:a:0 language=ita -metadata:s:a:0 title="$TITLE" \
    -map 0:a:0? -c:a:1 copy \
    -map 0:a:1? -c:a:2 copy \
    -map 0:s? -c:s copy \
    -map 0:t? -c:t copy \
    -disposition:a:0 default -disposition:a:1 0 \
    -map_metadata 0 \
    -map_chapters 0 \
    "$OUTPUT_FILE"
else
    # Filtri 5.1 per altri preset [1][2][3]
    ffmpeg -y -nostdin -hwaccel auto -threads 0 -i "$INPUT_FILE" -filter_complex \
    "[0:a]channelsplit=channel_layout=5.1[FL][FR][FC][LFE][SL][SR]; \
    [FC]${FC_FILTER}[FCboost]; \
    [FCboost]asplit[FCout][FCsc]; \
    [FCsc]${SIDECHAIN_PREP},aformat=channel_layouts=mono[FCsidechain]; \
    [LFE]${LFE_FILTER}[LFElow]; \
    [LFElow][FCsidechain]sidechaincompress=${LFE_SC_PARAMS}[LFEduck]; \
    [FL]${FRONT_FX_EQ}[FL_eq]; \
    [FL_eq][FCsidechain]sidechaincompress=${FX_SC_PARAMS}[FL_comp]; \
    [FL_comp]volume=${FRONT_FX_REDUCTION}[FLduck]; \
    [FR]${FRONT_FX_EQ}[FR_eq]; \
    [FR_eq][FCsidechain]sidechaincompress=${FX_SC_PARAMS}[FR_comp]; \
    [FR_comp]volume=${FRONT_FX_REDUCTION}[FRduck]; \
    [SL]${SURROUND_EQ}[SLduck]; \
    [SR]${SURROUND_EQ}[SRduck]; \
    [FLduck][FRduck][FCout][LFEduck][SLduck][SRduck]amerge=inputs=6,${FINAL_FILTER}[clearvoice]" \
    -map 0:v -c:v copy \
    -map "[clearvoice]" -c:a:0 eac3 -b:a:0 ${BITRATE} -metadata:s:a:0 language=ita -metadata:s:a:0 title="$TITLE" \
    -map 0:a:0? -c:a:1 copy \
    -map 0:a:1? -c:a:2 copy \
    -map 0:s? -c:s copy \
    -map 0:t? -c:t copy \
    -disposition:a:0 default -disposition:a:1 0 \
    -map_metadata 0 \
    -map_chapters 0 \
    "$OUTPUT_FILE"
fi

# -------------------- OUTPUT FINALE --------------------
ffmpeg_exit_code=$?
duration=$(( $(date +%s) - start_time ))
minuti=$((duration / 60))
secondi=$((duration % 60))

if [ $ffmpeg_exit_code -eq 0 ]; then
    echo "SUCCESSO - Tempo: ${minuti}m ${secondi}s | Output: ${OUTPUT_FILE##*/} | Preset: $PRESET (EAC3 ${BITRATE})"
    echo "Params: Voice Boost $VOICE_BOOST | LFE Reduction $LFE_REDUCTION | Makeup Gain $MAKEUP_GAIN"
    echo "Original: LUFS $LUFS | Peak $PEAK | LRA $LRA"
else
    echo "ERRORE (Codice: $ffmpeg_exit_code) - Tempo: ${minuti}m ${secondi}s"
    exit 1
fi
