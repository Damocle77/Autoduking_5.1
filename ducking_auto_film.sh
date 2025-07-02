#!/bin/bash

# Trap per gestire Ctrl+C
cleanup() {
    echo -e "\nAnalisi interrotta - tutti i processi terminati!"
    [ ! -z "$SPIN_PID" ] && kill $SPIN_PID 2>/dev/null
    pkill -f "ffmpeg.*loudnorm" 2>/dev/null
    exit 130
}
trap cleanup SIGINT

# ==============================================================================
# ducking_auto_film.sh - Audio Cinematografico Ottimizzato
# ==============================================================================
# Preset auto-adattivo per film con analisi intelligente del mix audio
# 
# + Analisi LUFS/True Peak completa con valutazione del contenuto
# + Ottimizzazione adattiva per dialoghi italiani perfettamente intellegibili
# + Ducking dinamico per bilanciare voce, effetti e LFE in tempo reale
# + Calibrato per film d'azione, thriller, drammatici e horror
# + EQ specializzato per voce italiana (200-3500Hz) e bassi cinematografici
# + Protezione anti-scoppio per LFE nei mix con ampia dinamica
# + Ideale per basso volume su soundbar LG Meridian SP7 + RPK8
# ==============================================================================

# Controllo argomenti
INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.*}_film_ducked.mkv"
BITRATE="768k"
[ ! -z "$2" ] && BITRATE="$2"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: ./ducking_auto_film.sh \"file.mkv\" [bitrate]"
    exit 1
fi

# Analisi loudness LUFS e True Peak con spin indicator
echo "==================== ANALISI LOUDNESS ===================="
echo "Avvio array di sensori... Calibrazione del flusso audio in corso."
echo "Acquisizione telemetria EBU R128: calcolo del Loudness Integrato."
echo "Scansione subspaziale per True Peak e Loudness Range (LRA)."
echo "ETA per la decodifica del segnale: circa 10 min per ora di runtime."

# Spin indicator elegante
spin_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
{
    while true; do
        for (( i=0; i<${#spin_chars}; i++ )); do
            printf "\rScansione: %s " "${spin_chars:$i:1}"
            sleep 0.1
        done
    done
} &
SPIN_PID=$!

ANALYSIS=$(ffmpeg -i "$INPUT_FILE" -af loudnorm=print_format=summary -f null - 2>&1)

# Termina lo spin e pulisci la riga
kill $SPIN_PID 2>/dev/null
wait $SPIN_PID 2>/dev/null
printf "\rAnalisi completata!                    \n"

# Estrazione di TUTTI i valori disponibili
LUFS=$(echo "$ANALYSIS" | grep "Input Integrated" | awk '{print $3}' | sed 's/LUFS//')
PEAK=$(echo "$ANALYSIS" | grep "Input True Peak" | awk '{print $4}' | sed 's/dBTP//')
LRA=$(echo "$ANALYSIS" | grep "Input LRA" | awk '{print $3}' | sed 's/LU//')
THRESHOLD=$(echo "$ANALYSIS" | grep "Input Threshold" | awk '{print $3}' | sed 's/LUFS//')
TARGET_OFFSET=$(echo "$ANALYSIS" | grep "Target Offset" | awk '{print $3}' | sed 's/LU//')

echo "==================== RISULTATI ANALISI ===================="
echo
echo "LOUDNESS INTEGRATO (EBU R128):"
echo "Input Integrated: $LUFS LUFS"
if [ $(awk "BEGIN {print ($LUFS < -23) ? 1 : 0}") -eq 1 ]; then
    echo "Profilo Loudness: Mix conservativo, sotto gli standard di streaming."
elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
    echo "Profilo Loudness: Mix 'caldo', al limite dei protocolli di streaming (-16 LUFS)."
else
    echo "Profilo Loudness: Bilanciato. Entro le specifiche cinematografiche."
fi

echo
echo "TRUE PEAK ANALYSIS:"
echo "Input True Peak: $PEAK dBTP"
if [ $(awk "BEGIN {print ($PEAK > -1) ? 1 : 0}") -eq 1 ]; then
    echo "ALLARME ROSSO: Headroom esaurito. Rischio di clipping imminente su codec lossy."
elif [ $(awk "BEGIN {print ($PEAK > -3) ? 1 : 0}") -eq 1 ]; then
    echo "Allerta Gialla: Headroom limitato. Lo spazio di manovra di un X-Wing nella Morte Nera."
else
    echo "Condizione Verde: Headroom ottimale. Spazio di manovra abbondante."
fi

echo
echo "DINAMICA E CARATTERISTICHE FILMICHE:"
echo "Loudness Range: $LRA LU"
if [ $(awk "BEGIN {print ($LRA < 6) ? 1 : 0}") -eq 1 ]; then
    echo "Profilo Dinamico: Compressione elevata, stile 'Michael Bay'. Bum Bum Bay."
elif [ $(awk "BEGIN {print ($LRA > 20) ? 1 : 0}") -eq 1 ]; then
    echo "Profilo Dinamico: Ampio, da film d'autore o alla 'Nolan'. Silenzi e esplosioni."
else
    echo "Profilo Dinamico: Standard cinematografico. Un mix ben educato."
fi
echo "Input Threshold: $THRESHOLD LUFS"
echo "Target Offset: $TARGET_OFFSET LU"

echo
echo "RACCOMANDAZIONI AUTOMATICHE CINEMATOGRAFICHE:"

# Parametri base per film cinematografici
VOICE_BOOST=3.5
LFE_REDUCTION=0.74
LFE_DUCK_THRESHOLD=0.005
LFE_DUCK_RATIO=3.5
FX_DUCK_RATIO=2.5
FX_DUCK_THRESHOLD=0.009
FRONT_FX_REDUCTION=0.9
FX_ATTACK=15
FX_RELEASE=300
LFE_ATTACK=20
LFE_RELEASE=350

# ============================================================================
# ANALISI ADATTIVA E REGOLAZIONI (per mix cinematografici)
# ============================================================================

# Regole adattive per gestire al meglio i mix aggressivi
if [ $(awk "BEGIN {print ($LUFS > -14) ? 1 : 0}") -eq 1 ]; then
    # Per mix molto aggressivi come Alien Romulus: ducking ANCORA PIÙ forte
    LFE_DUCK_RATIO=$(awk "BEGIN {print $LFE_DUCK_RATIO + 0.8}")
    FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.5}")
    LFE_REDUCTION=$(awk "BEGIN {print $LFE_REDUCTION - 0.1}")
    echo "ATTIVO: Protocollo 'Mix Aggressivo'. Potenziati i campi di contenimento (ducking)."
    echo "APPLICATO: LFE/FX più controllati per mix equilibrato"
elif [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.4}")
    FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.7}")
    echo "APPLICATO: Audio conservativo - boost dialoghi aumentato"
    echo "APPLICATO: Ducking più decisivo per chiarezza dialoghi"
else
    echo "APPLICATO: Parametri cinema standard - mix bilanciato"
fi

# Regole adattive per LFE
if [ $(awk "BEGIN {print ($PEAK > -2) ? 1 : 0}") -eq 1 ]; then
    LFE_HP_FREQ=35
    echo "APPLICATO: LFE più profondo (${LFE_HP_FREQ}Hz) ma controllato"
else
    LFE_HP_FREQ=30
    echo "APPLICATO: LFE ultra-profondo (${LFE_HP_FREQ}Hz) per esperienza immersiva"
fi

# Controllo correlato al True Peak e LRA per LFE
if [ $(awk "BEGIN {print ($PEAK > -1.5 && $LRA > 13) ? 1 : 0}") -eq 1 ]; then
    # Mix con picchi molto alti E ampia dinamica: rischio "scoppio" LFE
    LFE_REDUCTION=$(awk "BEGIN {print $LFE_REDUCTION - 0.15}")
    echo "ENGAGE: Protocollo Anti-Detonazione LFE. Domati i sub-bassi per evitare danni strutturali."
fi

# Regole adattive per EQ voce
if [ $(awk "BEGIN {print ($LUFS < -18) ? 1 : 0}") -eq 1 ]; then
    VOICE_EQ="highpass=f=60,equalizer=f=250:width_type=q:w=2.0:g=1.8,equalizer=f=3500:width_type=q:w=1.8:g=1.6"
    echo "APPLICATO: EQ voce per mix conservativo (enfasi medie-acute)"
else
    VOICE_EQ="highpass=f=70,equalizer=f=200:width_type=q:w=2.0:g=1.5,equalizer=f=3000:width_type=q:w=1.6:g=1.4"
    echo "APPLICATO: EQ voce per mix aggressivo (tagli selettivi)"
fi

# Regole adattive per film drammatici con dialoghi sommessi
if [ $(awk "BEGIN {print ($LRA > 18 && $LUFS < -20) ? 1 : 0}") -eq 1 ]; then
    # Per film drammatici con ampia dinamica e dialoghi sommessi
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.6}")
    SIDECHAIN_PREP="highpass=f=100,lowpass=f=4000,volume=3.5,compand=${COMPAND_PARAMS},agate=threshold=-40dB:ratio=1.8:attack=2:release=6000"
    echo "APPLICATO: Boost extra dialoghi per mix molto dinamico con voci sommesse"
fi

# Preparazione sidechain
COMPAND_PARAMS="attacks=0.02:decays=0.05:points=-60/-60|-25/-25|-12/-8:soft-knee=2:gain=0"
SIDECHAIN_PREP="highpass=f=100,lowpass=f=4000,volume=3.0,compand=${COMPAND_PARAMS},agate=threshold=-38dB:ratio=1.8:attack=2:release=5000"

# EQ LFE cinematografico (se non già definito dalla protezione anti-scoppio)
LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=65:width_type=q:w=1.8:g=0.4"

# Surround EQ per film d'azione e thriller
SURROUND_EQ="equalizer=f=180:width_type=q:w=1.8:g=1.1,equalizer=f=2500:width_type=q:w=2.0:g=1.4"

# EQ Front FX per pulizia e definizione
FRONT_FX_EQ="highpass=f=90"

# ============================================================================
# RIORGANIZZAZIONE DEI FILTRI (dopo analisi adattiva e regole)
# ============================================================================

# 1. Filtro per il canale centrale (dialoghi)
FC_FILTER="${VOICE_EQ},volume=${VOICE_BOOST},alimiter=level_in=1:level_out=0.99:limit=0.99"

# 2. Filtro per il canale LFE
LFE_FILTER="highpass=f=${LFE_HP_FREQ}:poles=2,lowpass=f=120:poles=2,${LFE_EQ},volume=${LFE_REDUCTION}"

# 3. Parametri per i compressori sidechain
LFE_SC_PARAMS="threshold=${LFE_DUCK_THRESHOLD}:ratio=${LFE_DUCK_RATIO}:attack=${LFE_ATTACK}:release=${LFE_RELEASE}:makeup=1.0"
FX_SC_PARAMS="threshold=${FX_DUCK_THRESHOLD}:ratio=${FX_DUCK_RATIO}:attack=${FX_ATTACK}:release=${FX_RELEASE}:makeup=1.0"


# 4. Filtro finale per tutti i canali
FINAL_FILTER="aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,aformat=channel_layouts=5.1"

echo
echo "=========================================================="
echo "Avvio elaborazione con parametri cinematografici ottimizzati..."
echo

# Esecuzione processing con filtri riorganizzati
start_time=$(date +%s)
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
[SL]volume=1.8,${SURROUND_EQ}[SLduck]; \
[SR]volume=1.8,${SURROUND_EQ}[SRduck]; \
[FLduck][FRduck][FCout][LFEduck][SLduck][SRduck]amerge=inputs=6,${FINAL_FILTER}" \
-map 0:v -c:v copy \
-c:a:0 eac3 -b:a:0 ${BITRATE} -metadata:s:a:0 language=ita -metadata:s:a:0 title="Clearvoice Film 5.1" \
-map 0:a -c:a:1 copy \
-map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy \
-map 0:s? -c:s copy \
-map 0:t? -c:t copy \
-disposition:a:0 default -disposition:a:1 0 \
-map_metadata 0 \
-map_chapters 0 \
"$OUTPUT_FILE"

# Controllo esito
ffmpeg_exit_code=$?
duration=$((($(date +%s) - start_time)))
minuti=$((duration / 60))
secondi=$((duration % 60))

# Output finale
if [ $ffmpeg_exit_code -eq 0 ]; then
    echo
    echo "==================== ELABORAZIONE COMPLETATA ===================="
    echo "SUCCESSO - ${minuti}m ${secondi}s"
    echo "Output: ${OUTPUT_FILE##*/}"
    echo "Preset: Film Ducking Auto (EAC3 ${BITRATE})"
    echo
    echo "PARAMETRI FINALI APPLICATI:"
    echo "Voice Boost: $VOICE_BOOST dB"
    echo "LFE Reduction: $LFE_REDUCTION"
    echo "FX Duck Ratio: $FX_DUCK_RATIO:1"
    echo "LFE Duck Ratio: $LFE_DUCK_RATIO:1"
    echo "LFE HPF: $LFE_HP_FREQ Hz"
    echo
    echo "MISURAZIONE ORIGINALE:"
    echo "LUFS: $LUFS | True Peak: $PEAK dBTP | LRA: $LRA LU"
    echo "=================================================================="
else
    echo "ERRORE - ${minuti}m ${secondi}s"
    exit 1
fi