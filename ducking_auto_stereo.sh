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
    local spin_chars="/-\|"
    while true; do
        for (( i=0; i<${#spin_chars}; i++ )); do
            printf "\rScansione in corso: %s " "${spin_chars:$i:1}"
            sleep 0.1
        done
    done
}

# ==============================================================================
# INIZIO DELLO SCRIPT PRINCIPALE
# ==============================================================================
# ducking_auto_serie_stereo.sh v1.5 Serie TV Stereo (No FX Ducking, No Surround)
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

# -------------------- ANALISI LOUDNESS --------------------
echo "===================== ANALISI LOUDNESS =========================="
show_spinner &
SPIN_PID=$!
ANALYSIS=$(ffmpeg -nostdin -i "$INPUT_FILE" -af loudnorm=print_format=summary -f null - 2>&1)
kill $SPIN_PID 2>/dev/null
wait $SPIN_PID 2>/dev/null
printf "\rAnalisi completata!                        \n"

LUFS=$(echo "$ANALYSIS" | grep "Input Integrated" | awk '{print $3}' | sed 's/LUFS//')
PEAK=$(echo "$ANALYSIS" | grep "Input True Peak" | awk '{print $4}' | sed 's/dBTP//')
LRA=$(echo "$ANALYSIS" | grep "Input LRA" | awk '{print $3}' | sed 's/LU//')

# -------------------- LOGICA ADATTIVA SEMPLIFICATA --------------------
# NB. (LFE_REDUCTION -> Più ti avvicini a 1, meno riduzione stai applicando
VOICE_BOOST=3.5
LFE_REDUCTION=0.77
LFE_HP_FREQ=35
MAKEUP_GAIN=5.3
# NB. (MAKUP_GAIN aumentato necessita di riduzione del limiter su FINAL_FILTER)

if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.5}")
    MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 1.0}")
fi

VOICE_EQ="highpass=f=85,deesser=i=0.12:m=0.4:f=0.23"
LFE_EQ="equalizer=f=30:width_type=q:w=1.5:g=0.6,equalizer=f=65:width_type=q:w=1.8:g=0.4"
FINAL_FILTER="aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,volume=${MAKEUP_GAIN},\
    alimiter=level_in=1:level_out=1:limit=0.94:attack=35:release=400:asc=1,aformat=channel_layouts=stereo"

# -------------------- ESECUZIONE FFMPEG --------------------
echo "Avvio elaborazione minimalista stereo..."
start_time=$(date +%s)
ffmpeg -y -nostdin -hwaccel auto -threads 0 -i "$INPUT_FILE" -filter_complex \
"[0:a]${VOICE_EQ},volume=${VOICE_BOOST}[voiceboost]; \
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
