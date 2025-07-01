#!/bin/bash
# ==============================================================================
# ducking_auto_serie.sh v1.0 - Audio Ottimizzato per Serie TV di Genere
# ==============================================================================
# Preset auto-adattivo per serie TV con analisi intelligente del mix audio
# 
# + Analisi LUFS/True Peak completa con valutazione del contenuto
# + Ottimizzazione adattiva per dialoghi italiani perfettamente intellegibili
# + Ducking dinamico per bilanciare voce, effetti e LFE in tempo reale
# + Calibrato per serie fantascienza, fantasy, horror e thriller
# + EQ specializzato per voce italiana e bassi cinematografici
# + Protezione anti-distorsione per mix con effetti intensi
# + Ideale per basso volume su soundbar LG Meridian SP7 + RPK8
# ==============================================================================

# Controllo argomenti
INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.*}_serie_ducked.mkv"
BITRATE="384k"
[ ! -z "$2" ] && BITRATE="$2"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: ./ducking_auto_serie.sh \"file.mkv\" [bitrate]"
    exit 1
fi

# Analisi loudness LUFS e True Peak con spin indicator
echo "==================== ANALISI LOUDNESS ===================="
echo "Scansione del contenuto audio in corso..."
echo "Misurazione EBU R128 integrated loudness..."
echo "Rilevamento true peak e loudness range..."
echo "L'analisi richiede circa 3-4 minuti per episodio..."

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
    echo "Valutazione: Audio sottodimensionato (broadcast standard: -23 LUFS)"
elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
    echo "Valutazione: Audio sovradimensionato (streaming standard: -16 LUFS)"
else
    echo "Valutazione: Livello loudness accettabile per contenuto misto"
fi

echo
echo "TRUE PEAK ANALYSIS:"
echo "Input True Peak: $PEAK dBTP"
if [ $(awk "BEGIN {print ($PEAK > -1) ? 1 : 0}") -eq 1 ]; then
    echo "ATTENZIONE: Picchi elevati - rischio clipping su codec lossy"
elif [ $(awk "BEGIN {print ($PEAK > -3) ? 1 : 0}") -eq 1 ]; then
    echo "Nota: Picchi moderati - headroom limitato"
else
    echo "Picchi sicuri - headroom adeguato per processing"
fi

echo
echo "DINAMICA E SOGLIE:"
echo "Loudness Range: $LRA LU"
if [ $(awk "BEGIN {print ($LRA < 5) ? 1 : 0}") -eq 1 ]; then
    echo "Dinamica: Contenuto altamente compresso (tipico serie TV moderna)"
elif [ $(awk "BEGIN {print ($LRA > 12) ? 1 : 0}") -eq 1 ]; then
    echo "Dinamica: Range elevato (tipico serie fantasy/sci-fi premium)"
else
    echo "Dinamica: Range standard per serie televisive"
fi
echo "Input Threshold: $THRESHOLD LUFS"
echo "Target Offset: $TARGET_OFFSET LU"

echo
echo "RACCOMANDAZIONI AUTOMATICHE SERIE TV:"

# Parametri base (preset serie genere)
VOICE_BOOST=3.6
LFE_REDUCTION=0.70
LFE_DUCK_THRESHOLD=0.006
LFE_DUCK_RATIO=4.3
FX_DUCK_THRESHOLD=0.009
FX_DUCK_RATIO=3.7
FX_ATTACK=15
FX_RELEASE=280
LFE_ATTACK=18
LFE_RELEASE=300
LFE_HP_FREQ=35
LFE_LP_FREQ=100
LFE_CROSS_POLES=2

# ============================================================================
# ANALISI ADATTIVA E REGOLAZIONI (per mix serie TV genere)
# ============================================================================

# Adattamento automatico in base a LUFS/Peak
if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.3}")
    FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.5}")
    LFE_DUCK_RATIO=$(awk "BEGIN {print $LFE_DUCK_RATIO + 0.4}")
    echo "APPLICATO: Boost dialogo (+0.3dB) per compensare audio debole"
    echo "APPLICATO: Ducking più aggressivo (FX +0.5, LFE +0.4) per chiarezza"
elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST - 0.2}")
    LFE_REDUCTION=$(awk "BEGIN {print $LFE_REDUCTION - 0.07}")
    echo "APPLICATO: Riduzione boost dialogo (-0.2dB) per audio già forte"
    echo "APPLICATO: LFE più ridotto (-0.07) per bilanciare il mix"
else
    echo "APPLICATO: Parametri standard - loudness nel range ottimale"
fi

# Regole adattive per LFE (più cinematografiche per generi sci-fi/horror)
if [ $(awk "BEGIN {print ($PEAK > -2) ? 1 : 0}") -eq 1 ]; then
    LFE_HP_FREQ=40
    echo "APPLICATO: Taglio LFE più alto (${LFE_HP_FREQ}Hz) per mix ad alto impatto"
else
    echo "APPLICATO: Taglio LFE profondo (${LFE_HP_FREQ}Hz) per ambientazioni fantasy/sci-fi"
fi

# Protezione anti-distorsione per serie con molto dialogo ma effetti intensi
if [ $(awk "BEGIN {print ($LRA < 5 && $LUFS > -18) ? 1 : 0}") -eq 1 ]; then
    # Per serie con dialogo continuo e dinamica compressa 
    FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.6}")
    FX_RELEASE=$(awk "BEGIN {print $FX_RELEASE - 25}")
    echo "APPLICATO: Protezione anti-affaticamento per serie con dialogo continuo"
    echo "APPLICATO: Rilascio ducking più rapido per transizioni fluide"
fi

# Regole adattive per EQ voce
if [ $(awk "BEGIN {print ($LUFS < -18) ? 1 : 0}") -eq 1 ]; then
    VOICE_EQ="highpass=f=65,equalizer=f=250:width_type=q:w=2.0:g=1.5,equalizer=f=1000:width_type=q:w=1.8:g=1.4,equalizer=f=3200:width_type=q:w=1.6:g=1.3"
    echo "APPLICATO: EQ voce per mix conservativo (enfasi medie-acute)"
else
    VOICE_EQ="highpass=f=75,equalizer=f=200:width_type=q:w=2.0:g=1.3,equalizer=f=1000:width_type=q:w=1.8:g=1.2,equalizer=f=3200:width_type=q:w=1.6:g=1.0"
    echo "APPLICATO: EQ voce per mix moderno (tagli selettivi)"
fi

# Ottimizzazione specifica per serie fantasy/sci-fi/horror
if [ $(awk "BEGIN {print ($LRA > 10) ? 1 : 0}") -eq 1 ]; then
    SURROUND_BOOST=2.2
    SURROUND_EQ="equalizer=f=180:width_type=q:w=2.0:g=1.3,equalizer=f=2200:width_type=q:w=2.2:g=1.5,equalizer=f=6800:width_type=q:w=2.0:g=1.7"
    LFE_EQ="equalizer=f=45:width_type=q:w=1.3:g=2.5,equalizer=f=70:width_type=q:w=1.6:g=1.8"
    echo "APPLICATO: Surround potenziato per serie fantasy/sci-fi con ampia dinamica"
    echo "APPLICATO: LFE più incisivo per effetti speciali e atmosfere immersive"
else
    SURROUND_BOOST=2.0
    SURROUND_EQ="equalizer=f=180:width_type=q:w=2.0:g=1.2,equalizer=f=2200:width_type=q:w=2.2:g=1.3,equalizer=f=6800:width_type=q:w=2.0:g=1.5"
    LFE_EQ="equalizer=f=55:width_type=q:w=1.4:g=2.0,equalizer=f=70:width_type=q:w=1.6:g=1.6"
    echo "APPLICATO: Surround standard per serie con dinamica media"
fi

# Protezione anti-scoppio LFE per serie horror/fantasy con picchi elevati
if [ $(awk "BEGIN {print ($PEAK > -1.5 && $LRA > 12) ? 1 : 0}") -eq 1 ]; then
    # Mix con picchi molto alti E ampia dinamica: rischio "scoppio" LFE
    LFE_REDUCTION=$(awk "BEGIN {print $LFE_REDUCTION - 0.12}")
    echo "APPLICATO: Protezione anti-scoppio LFE per serie con picchi elevati"
fi

# Preparazione sidechain (più vicina al preset film per migliore equilibrio)
COMPAND_PARAMS="attacks=0.02:decays=0.05:points=-60/-60|-25/-25|-12/-8:soft-knee=2:gain=0"
SIDECHAIN_PREP="highpass=f=110,lowpass=f=4000,volume=3.0,compand=${COMPAND_PARAMS},agate=threshold=-38dB:ratio=1.8:attack=2:release=5500"

# ============================================================================
# RIORGANIZZAZIONE DEI FILTRI (dopo analisi adattiva e regole)
# ============================================================================

# 1. Filtro per il canale centrale (dialoghi)
FC_FILTER="${VOICE_EQ},volume=${VOICE_BOOST},alimiter=level_in=1:level_out=0.99:limit=0.99"

# 2. Filtro per il canale LFE
LFE_FILTER="highpass=f=${LFE_HP_FREQ}:poles=${LFE_CROSS_POLES},lowpass=f=${LFE_LP_FREQ}:poles=${LFE_CROSS_POLES},${LFE_EQ},volume=${LFE_REDUCTION}"

# 3. Parametri per i compressori sidechain
LFE_SC_PARAMS="threshold=${LFE_DUCK_THRESHOLD}:ratio=${LFE_DUCK_RATIO}:attack=${LFE_ATTACK}:release=${LFE_RELEASE}:makeup=1.0"
FX_SC_PARAMS="threshold=${FX_DUCK_THRESHOLD}:ratio=${FX_DUCK_RATIO}:attack=${FX_ATTACK}:release=${FX_RELEASE}:makeup=1.0"

# 4. Filtro finale per tutti i canali
FINAL_FILTER="aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,aformat=channel_layouts=5.1"

echo
echo "=========================================================="
echo "Avvio elaborazione con parametri ottimizzati per serie genere..."
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
[FL][FCsidechain]sidechaincompress=${FX_SC_PARAMS}[FL_comp]; \
[FL_comp]volume=0.77[FLduck]; \
[FR][FCsidechain]sidechaincompress=${FX_SC_PARAMS}[FR_comp]; \
[FR_comp]volume=0.77[FRduck]; \
[SL]volume=${SURROUND_BOOST},${SURROUND_EQ}[SLduck]; \
[SR]volume=${SURROUND_BOOST},${SURROUND_EQ}[SRduck]; \
[FLduck][FRduck][FCout][LFEduck][SLduck][SRduck]amerge=inputs=6,${FINAL_FILTER}" \
-map 0:v -c:v copy \
-c:a:0 eac3 -b:a:0 ${BITRATE} -metadata:s:a:0 language=ita -metadata:s:a:0 title="Clearvoice Serie 5.1" \
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
    echo "Preset: Serie Genere Ducking Auto (EAC3 ${BITRATE})"
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