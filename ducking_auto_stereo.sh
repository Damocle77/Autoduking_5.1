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
# ducking_auto_serie_stereo.sh v1.6 Serie TV Stereo (No FX Ducking, No Surround)
#
# + Analisi LUFS/True Peak con valutazione adattiva
# + Boost vocale e controllo bassi morbido per dialoghi chiari
# + Calibrato per sci-fi/fantasy su soundbar LG
# ==============================================================================

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.*}_serie_ducked.mkv"
BITRATE="384k"
[ ! -z "$2" ] && BITRATE="$2"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: ./ducking_auto_serie_stereo_minimal.sh \"file.mkv\" [bitrate]"
    exit 1
fi

# -------------------- ANALISI SPETTRALE --------------------
echo "===================== ANALISI SPETTRALE =========================="
echo "Avvio array di sensori... Calibrazione del flusso audio in corso."
echo "Acquisizione telemetria EBU R128: calcolo del Loudness Integrato."
echo "Scansione subspaziale per True Peak e Loudness Range (LRA)."
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

# -------------------- LOGICA ADATTIVA SEMPLIFICATA --------------------
# NB. (LFE_REDUCTION -> Più ti avvicini a 1, meno riduzione stai applicando
VOICE_BOOST=3.4
LFE_REDUCTION=0.80
LFE_HP_FREQ=35
MAKEUP_GAIN=5.0
# NB. (MAKEUP_GAIN aumentato necessita di riduzione del limiter su FINAL_FILTER)

if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.5}")
    MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.6}")
fi

# Filtro voce italiana ultra-conservativo - solo processing essenziale
#VOICE_EQ="highpass=f=85,deesser=i=0.12:m=0.4:f=0.23"
VOICE_EQ="highpass=f=70,deesser=i=0.02:m=0.12:f=0.15,aexciter=level_in=1:level_out=1:amount=0.65:drive=2.25:blend=0:freq=2600:ceil=10000:listen=0,compand=attacks=0.0025:decays=0.015:points=-75/-75|-40/-39|-25/-20|-10/-7:soft-knee=5:gain=0.25"
FC_FILTER="${VOICE_EQ},volume=${VOICE_BOOST},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=70:asc=1"
LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=65:width_type=q:w=1.8:g=0.4"
FINAL_FILTER="aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,volume=${MAKEUP_GAIN},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=100:asc=1,aformat=channel_layouts=stereo"

# Preparazione filtri (anche se non utilizzati nel preset stereo)
COMPAND_PARAMS="attacks=0.005:decays=0.01:points=-60/-60|-30/-30|-15/-8:soft-knee=2:gain=0"
SIDECHAIN_PREP="bandpass=f=2200:width_type=h:w=2800,volume=2.6,compand=${COMPAND_PARAMS},agate=threshold=-30dB:ratio=2.0:attack=0.5:release=4000"

# -------------------- ESECUZIONE FFMPEG --------------------
echo "Avvio elaborazione minimalista stereo..."
start_time=$(date +%s)
#ffmpeg -y -nostdin -hwaccel auto -threads 0 -i "$INPUT_FILE" -filter_complex \
#"[0:a]${VOICE_EQ},volume=${VOICE_BOOST}[voiceboost]; \
#[voiceboost]highpass=f=${LFE_HP_FREQ}:poles=2,${LFE_EQ},volume=${LFE_REDUCTION}[final]; \
#[final]${FINAL_FILTER}[clearvoice]" \
# Filter_complex aggiornato con FC_FILTER
ffmpeg -y -nostdin -hwaccel auto -threads 0 -i "$INPUT_FILE" -filter_complex \
"[0:a]${FC_FILTER}[voiceboost]; \
[voiceboost]highpass=f=${LFE_HP_FREQ}:poles=2,${LFE_EQ},volume=${LFE_REDUCTION}[final]; \
[final]${FINAL_FILTER}[clearvoice]" \
-map 0:v -c:v copy \
-map "[clearvoice]" -c:a:0 eac3 -b:a:0 ${BITRATE} -metadata:s:a:0 title="Clearvoice EAC3 Stereo" \
-map 0:a:0? -c:a:1 copy \
-map 0:s? -c:s copy \
-map_metadata 0 \
-map_chapters 0 \
"$OUTPUT_FILE"

ffmpeg_exit_code=$?
duration=$(( $(date +%s) - start_time ))
minuti=$((duration / 60))
secondi=$((duration % 60))

if [ $ffmpeg_exit_code -eq 0 ]; then
    echo "==================== ELABORAZIONE COMPLETATA ====================="
    echo "SUCCESSO - Tempo: ${minuti}m ${secondi}s | Output: ${OUTPUT_FILE##*/}"
else
    echo "ERRORE - Codice: $ffmpeg_exit_code"
    exit 1
fi
