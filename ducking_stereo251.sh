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

# ==============================================================================
# INIZIO DELLO SCRIPT PRINCIPALE
# ==============================================================================
# ducking_stereo251.sh v1.7 - Stereo to 5.1 Duplication Serie TV Enhancement
#
# + Analisi LUFS/True Peak con valutazione adattiva
# + Upmix intelligente da stereo a 5.1 con surround duplication
# + Estrazione vocale per canale centrale ottimizzato
# + Surround duplication senza spazialità artificiale (soundbar-friendly)
# + Boost vocale e controllo bassi per dialoghi chiari su LG SP7
# + Calibrato per serie sci-fi/fantasy preservando imaging naturale
# ==============================================================================

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.*}_stereo251_ducked.mkv"
BITRATE="384k"
[ ! -z "$2" ] && BITRATE="$2"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: ./ducking_stereo251.sh \"file.mkv\" [bitrate]"
    echo "Genera un mix 5.1 da sorgente stereo con surround duplication (soundbar-friendly)"
    exit 1
fi

# -------------------- ANALISI SPETTRALE --------------------
echo "===================== ANALISI SPETTRALE =========================="
echo "Avvio array di sensori... Calibrazione del flusso audio in corso."
echo "Acquisizione telemetria EBU R128: calcolo del Loudness Integrato."
echo "Scansione subspaziale per True Peak e Loudness Range (LRA)."
echo "Preparazione per upmix stereo → 5.1 con surround duplication..."
echo "ETA per decodifica del segnale: circa 10 min per ora di runtime."

# Avvia lo spinner in background
show_spinner &
SPIN_PID=$!

# Esegui l'analisi con ffmpeg
ANALYSIS=$(ffmpeg -nostdin -i "$INPUT_FILE" -af loudnorm=print_format=summary -f null - 2>&1)

# Termina lo spinner e pulisci la riga
kill $SPIN_PID 2>/dev/null
wait $SPIN_PID 2>/dev/null
printf "\rAnalisi completata!                        \n"

LUFS=$(echo "$ANALYSIS" | grep "Input Integrated" | awk '{print $3}' | sed 's/LUFS//')
PEAK=$(echo "$ANALYSIS" | grep "Input True Peak" | awk '{print $4}' | sed 's/dBTP//')
LRA=$(echo "$ANALYSIS" | grep "Input LRA" | awk '{print $3}' | sed 's/LU//')

echo "==================== RISULTATI ANALISI ========================="
echo "LOUDNESS INTEGRATO: $LUFS LUFS | TRUE PEAK: $PEAK dBTP | LRA: $LRA LU"
echo

# -------------------- PARAMETRI SURROUND DUPLICATION --------------------
echo "RACCOMANDAZIONI AUTOMATICHE STEREO TO 5.1:"

# Parametri base per surround duplication ottimizzati per upmix 5.1
VOICE_BOOST=3.3               # Allineato agli altri script della suite
LFE_REDUCTION=0.75            # Allineato alla suite per coerenza
LFE_HP_FREQ=35
MAKEUP_GAIN=5.0               # Standard della suite per coerenza
CENTER_EXTRACT_STRENGTH=0.65  # Estrazione vocale per canale centrale
SURROUND_LEVEL=0.35           # Livello duplicazione surround (contenuto per soundbar)
SURROUND_DELAY=3              # Delay minimo per evitare comb filtering

if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.1}")  # Incremento standard serie
    MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.2}")  # Incremento standard serie
    CENTER_EXTRACT_STRENGTH=$(awk "BEGIN {print $CENTER_EXTRACT_STRENGTH + 0.1}")
    echo "APPLICATO: Boost voce standard (+0.1dB) per centro estratto"
    echo "APPLICATO: Estrazione centrale potenziata per dialoghi chiari"
elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
    MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.8}")  # Incremento standard serie
    SURROUND_LEVEL=$(awk "BEGIN {print $SURROUND_LEVEL + 0.05}")
    LFE_REDUCTION=$(awk "BEGIN {print $LFE_REDUCTION - 0.1}")  # LFE più contenuto
    echo "APPLICATO: LFE più controllato per contenuto sovradimensionato"
    echo "APPLICATO: Surround leggermente più presenti per corpo"
else
    echo "APPLICATO: Parametri upmix 5.1 completamente allineati alla suite"
    echo "APPLICATO: Voice: ${VOICE_BOOST} | LFE: ${LFE_REDUCTION} | Makeup: ${MAKEUP_GAIN}"
fi

# Controllo True Peak e LRA per processing
if [ $(awk "BEGIN {print ($PEAK > -2) ? 1 : 0}") -eq 1 ]; then
    LFE_HP_FREQ=40
    SURROUND_LEVEL=$(awk "BEGIN {print $SURROUND_LEVEL - 0.05}")
    echo "APPLICATO: Taglio bassi conservativo (${LFE_HP_FREQ}Hz) per picchi elevati"
    echo "APPLICATO: Surround più contenuti per headroom sicuro"
else
    echo "APPLICATO: Duplicazione naturale per soundbar LG SP7"
fi

# Adattamento surround in base alla dinamica
if [ $(awk "BEGIN {print ($LRA > 10) ? 1 : 0}") -eq 1 ]; then
    SURROUND_DELAY=4
    SURROUND_LEVEL=$(awk "BEGIN {print $SURROUND_LEVEL + 0.08}")
    echo "APPLICATO: Surround più presenti per contenuto dinamico"
elif [ $(awk "BEGIN {print ($LRA < 6) ? 1 : 0}") -eq 1 ]; then
    SURROUND_DELAY=2
    echo "APPLICATO: Delay minimo per contenuto compresso"
fi

# -------------------- DEFINIZIONE FILTRI SURROUND DUPLICATION --------------------
echo
echo "CONFIGURAZIONE SURROUND DUPLICATION:"

# Filtro voce italiana ottimizzato per canale centrale
VOICE_EQ="highpass=f=70,deesser=i=0.02:m=0.12:f=0.15,aexciter=level_in=1:level_out=1:amount=0.45:drive=1.8:blend=0:freq=2600:ceil=10000:listen=0,compand=attacks=0.0025:decays=0.015:points=-75/-75|-40/-39|-25/-20|-10/-7:soft-knee=5:gain=0.25"
echo "• Canale Centrale: Estrazione vocale ottimizzata con de-esser chirurgico"

# Filtri front naturali per soundbar
echo "• Front L/R: Processing naturale preservando imaging soundbar"

# Filtro LFE sintetico dai bassi del mix stereo
LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=65:width_type=q:w=1.8:g=0.4"
echo "• Canale LFE: Estrazione bassi cinematografici con EQ ottimizzato"

# Filtri surround - duplicazione semplice con filtro passa-alto per evitare mud
SURROUND_DUPLICATE="highpass=f=80,adelay=${SURROUND_DELAY}|${SURROUND_DELAY}"
echo "• Surround L/R: Duplicazione front con delay ${SURROUND_DELAY}ms e HPF per pulizia"

# Preparazione sidechain per ducking (mantenuto dalla versione 5.1)
COMPAND_PARAMS="attacks=0.02:decays=0.05:points=-60/-60|-25/-25|-12/-8:soft-knee=2:gain=0"
SIDECHAIN_PREP="bandpass=f=2200:width_type=h:w=2800,volume=2.6,compand=${COMPAND_PARAMS},agate=threshold=-30dB:ratio=2.0:attack=0.5:release=4500"
echo "• Sidechain: Preparato per ducking intelligente sui canali sintetici"

# Filtri finali per ogni canale
FC_FILTER="${VOICE_EQ},volume=${VOICE_BOOST},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=70:asc=1"
LFE_FILTER="highpass=f=${LFE_HP_FREQ}:poles=2,lowpass=f=100:poles=2,${LFE_EQ},volume=${LFE_REDUCTION}"
SURROUND_FILTER="${SURROUND_DUPLICATE},volume=${SURROUND_LEVEL}"
FINAL_FILTER="aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,volume=${MAKEUP_GAIN},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=100:asc=1,aformat=channel_layouts=5.1"

echo
echo "================================================================"
echo "Avvio elaborazione surround duplication stereo → 5.1..."
echo "================================================================"

# -------------------- ESECUZIONE FFMPEG SURROUND DUPLICATION --------------------
echo
start_time=$(date +%s)

ffmpeg -y -nostdin -hwaccel auto -threads 0 -i "$INPUT_FILE" -filter_complex \
"[0:a]asplit=3[stereo1][stereo2][stereo3]; \
[stereo1]channelsplit=channel_layout=stereo[FL_raw][FR_raw]; \
[stereo2]pan=mono|c0=0.5*c0+0.5*c1[center_raw]; \
[center_raw]${FC_FILTER}[FC_out]; \
[FC_out]asplit[FC_final][FC_sidechain]; \
[FC_sidechain]${SIDECHAIN_PREP},aformat=channel_layouts=mono[FCsc]; \
[stereo3]pan=mono|c0=0.5*c0+0.5*c1,${LFE_FILTER}[LFE_base]; \
[LFE_base][FCsc]sidechaincompress=threshold=0.004:ratio=2.8:attack=15:release=600:makeup=1.0[LFE_final]; \
[FL_raw]${SURROUND_FILTER}[SL_dup]; \
[FR_raw]${SURROUND_FILTER}[SR_dup]; \
[SL_dup][FCsc]sidechaincompress=threshold=0.012:ratio=1.8:attack=30:release=750:makeup=1.0[SL_final]; \
[SR_dup][FCsc]sidechaincompress=threshold=0.012:ratio=1.8:attack=30:release=750:makeup=1.0[SR_final]; \
[FL_raw][FCsc]sidechaincompress=threshold=0.012:ratio=1.8:attack=30:release=750:makeup=1.0[FL_duck]; \
[FR_raw][FCsc]sidechaincompress=threshold=0.012:ratio=1.8:attack=30:release=750:makeup=1.0[FR_duck]; \
[FL_duck]volume=0.92[FL_final]; \
[FR_duck]volume=0.92[FR_final]; \
[FL_final][FR_final][FC_final][LFE_final][SL_final][SR_final]amerge=inputs=6,${FINAL_FILTER}[spatial51]" \
-map 0:v -c:v copy \
-map "[spatial51]" -c:a:0 eac3 -b:a:0 ${BITRATE} -metadata:s:a:0 language=ita -metadata:s:a:0 title="Surround Duplication 5.1" \
-map 0:a:0? -c:a:1 copy \
-map 0:a:1? -c:a:2 copy \
-map 0:s? -c:s copy \
-map 0:t? -c:t copy \
-disposition:a:0 default -disposition:a:1 0 \
-map_metadata 0 \
-map_chapters 0 \
"$OUTPUT_FILE"

# -------------------- OUTPUT FINALE --------------------
ffmpeg_exit_code=$?
duration=$(( $(date +%s) - start_time ))
minuti=$((duration / 60))
secondi=$((duration % 60))

if [ $ffmpeg_exit_code -eq 0 ]; then
    echo
    echo "==================== ELABORAZIONE COMPLETATA ====================="
    echo "SUCCESSO - Tempo impiegato: ${minuti}m ${secondi}s"
    echo "Output: ${OUTPUT_FILE##*/}"
    echo "Preset: Stereo → 5.1 Duplication con Ducking (EAC3 ${BITRATE})"
    echo
    echo "CANALI GENERATI:"
    echo "• Front L/R: Stereo naturale preservando imaging soundbar + ducking voce"
    echo "• Center: Estrazione vocale intelligente + boost ${VOICE_BOOST}dB"
    echo "• LFE: Bassi cinematografici estratti + ducking dinamico"
    echo "• Surround L/R: Duplicazione front con delay ${SURROUND_DELAY}ms + ducking"
    echo
    echo "PARAMETRI FINALI APPLICATI:"
    echo "Voice Boost: $VOICE_BOOST dB | LFE Reduction: $LFE_REDUCTION"
    echo "Surround Level: $SURROUND_LEVEL | Delay: ${SURROUND_DELAY}ms (no spazialità)"
    echo "Makeup Gain: $MAKEUP_GAIN | Limiter finale: 0.95"
    echo
    echo "MISURAZIONE ORIGINALE:"
    echo "LUFS: $LUFS | True Peak: $PEAK dBTP | LRA: $LRA LU"
    echo "==================================================================="
else
    echo "ERRORE - Qualcosa è andato storto durante l'elaborazione di ffmpeg (Codice: $ffmpeg_exit_code)."
    echo "Tempo trascorso: ${minuti}m ${secondi}s"
    exit 1
fi
