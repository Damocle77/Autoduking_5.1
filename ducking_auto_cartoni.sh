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
# ducking_auto_cartoni.sh v1.0 - Audio Ottimizzato per Cartoni e Musical
# ==============================================================================
# Preset auto-adattivo per film d'animazione con analisi intelligente del mix audio
# 
# + Analisi LUFS/True Peak completa con valutazione del contenuto
# + Ottimizzazione adattiva per dialoghi e voci cantate perfettamente intellegibili
# + Ducking delicato per bilanciare voci, musica e effetti
# + Calibrato per cartoni Disney, Pixar, musical e film d'animazione
# + EQ specializzato per voci cantate e arrangiamenti orchestrali
# + Preservazione della dinamica musicale senza distorsioni
# + Ideale per basso volume su soundbar LG Meridian SP7 + RPK8
# ==============================================================================

# Controllo argomenti
INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.*}_cartoon_ducked.mkv"
BITRATE="640k"
[ ! -z "$2" ] && BITRATE="$2"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: ./ducking_auto_cartoni.sh \"file.mkv\" [bitrate]"
    exit 1
fi

# Analisi loudness LUFS e True Peak  con spin indicator
echo "==================== ANALISI LOUDNESS ===================="
echo "Avvio array di sensori... Calibrazione del flusso audio in corso."
echo "Acquisizione telemetria EBU R128: calcolo del Loudness Integrato."
echo "Scansione subspaziale per True Peak e Loudness Range (LRA)."
echo "ETA per la decodifica del segnale: circa 10 min per ora di runtime."

# Spin indicator elegante
show_spinner() {
    spin_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    while true; do
        for (( i=0; i<${#spin_chars}; i++ )); do
            printf "\rScansione: %s " "${spin_chars:$i:1}"
            sleep 0.1
        done
    done
}
# Avvia lo spinner in background
show_spinner &
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
    echo "Profilo Loudness: Mix delicato, da classico d'annata. Necessita di più energia."
elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
    echo "Profilo Loudness: Mix moderno e potente, tipico delle produzioni attuali."
else
    echo "Profilo Loudness: Bilanciato. L'orchestra è pronta a suonare."
fi

echo
echo "TRUE PEAK ANALYSIS:"
echo "Input True Peak: $PEAK dBTP"
if [ $(awk "BEGIN {print ($PEAK > -1) ? 1 : 0}") -eq 1 ]; then
    echo "ATTENZIONE: L'orchestra sta suonando forte! Rischio di saturazione armonica nei crescendo."
elif [ $(awk "BEGIN {print ($PEAK > -3) ? 1 : 0}") -eq 1 ]; then
    echo "Nota: Headroom limitato. I timpani stanno sfiorando il limite."
else
    echo "Condizione Verde: Palco sonoro pulito. C'è spazio per ogni strumento."
fi

echo
echo "DINAMICA E CARATTERISTICHE:"
echo "Loudness Range: $LRA LU"
if [ $(awk "BEGIN {print ($LRA < 7) ? 1 : 0}") -eq 1 ]; then
    echo "Profilo Dinamico: Compresso. Pensato per un ascolto facile e immediato."
elif [ $(awk "BEGIN {print ($LRA > 12) ? 1 : 0}") -eq 1 ]; then
    echo "Profilo Dinamico: Ampio, da classico musical Disney. Prepararsi a numeri cantati epici."
else
    echo "Profilo Dinamico: Standard Pixar/Dreamworks. Un buon equilibrio tra dialogo e azione."
fi
echo "Input Threshold: $THRESHOLD LUFS"
echo "Target Offset: $TARGET_OFFSET LU"

echo
echo "RACCOMANDAZIONI AUTOMATICHE PER CARTONI/MUSICAL:"

# Parametri base per cartoni animati e musical
#Per avere più punch devi aumentare il valore di LFE_REDUCTION, avvicinandoti a 1.0.
VOICE_BOOST=3.4
LFE_REDUCTION=0.82
LFE_DUCK_THRESHOLD=0.012
LFE_DUCK_RATIO=3.5
FX_DUCK_THRESHOLD=0.012
FRONT_FX_REDUCTION=0.92
FX_DUCK_RATIO=2.8
FX_ATTACK=40
FX_RELEASE=700
LFE_ATTACK=50
LFE_RELEASE=900
LFE_HP_FREQ=45
LFE_LP_FREQ=100
LFE_CROSS_POLES=4

# ============================================================================
# ANALISI ADATTIVA E REGOLAZIONI (per cartoni e musical)
# ============================================================================

# Adattamento automatico in base a LUFS/Peak
if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.4}")
    FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.3}")
    echo "APPLICATO: Boost voci (+0.4dB) per mix con audio debole"
    echo "APPLICATO: Ducking leggermente aumentato (+0.3) per chiarezza"
elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST - 0.2}")
    FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO - 0.2}")
    echo "APPLICATO: Boost voci ridotto (-0.2dB) per audio già forte"
    echo "APPLICATO: Ducking più leggero (-0.2) per preservare musica"
else
    echo "APPLICATO: Parametri standard - loudness nel range ottimale"
fi

# Regole adattive per LFE
if [ $(awk "BEGIN {print ($PEAK > -2) ? 1 : 0}") -eq 1 ]; then
    LFE_HP_FREQ=50
    echo "ATTIVO: Filtro 'Anti-Fango' potenziato a ${LFE_HP_FREQ}Hz. Preservata la musicalità, rimosso il rimbombo."
else
    echo "APPLICATO: Taglio LFE standard (${LFE_HP_FREQ}Hz) per fondamenti orchestrali"
fi

# Regole adattive per FX Ducking
VOICE_EQ="highpass=f=80,equalizer=f=200:width_type=q:w=2.0:g=1.0,equalizer=f=1000:width_type=q:w=1.8:g=1.7,equalizer=f=4000:width_type=q:w=1.5:g=2.2"

# EQ LFE per orchestrali e musical
LFE_EQ="equalizer=f=35:width_type=q:w=1.6:g=0.6,equalizer=f=75:width_type=q:w=1.8:g=0.4"
echo "ATTIVO: Equalizzazione orchestrale. I bassi sono ora più definiti e musicali, non solo 'boom'."

# Surround per ambientazione e musica
SURROUND_EQ="equalizer=f=400:width_type=q:w=2.0:g=1.3,equalizer=f=1800:width_type=q:w=2.4:g=-1.8,equalizer=f=7000:width_type=q:w=2.0:g=2.0"

# Preparazione sidechain ottimizzata per musica
COMPAND_PARAMS="attacks=0.01:decays=0.02:points=-60/-60|-30/-30|-15/-10:soft-knee=3:gain=0"
SIDECHAIN_PREP="bandpass=f=2000:width_type=h:w=3600,volume=2.5,compand=${COMPAND_PARAMS},agate=threshold=-35dB:ratio=1.5:attack=1:release=7000"

# EQ Front FX per pulizia e definizione
FRONT_FX_EQ="highpass=f=90"

# ============================================================================
# RIORGANIZZAZIONE DEI FILTRI (dopo analisi adattiva e regole)
# ============================================================================

# 1. Filtro per il canale centrale (dialoghi e voci cantate)
FC_FILTER="${VOICE_EQ},volume=${VOICE_BOOST},alimiter=level_in=1:level_out=0.99:limit=0.99"

# 2. Filtro per il canale LFE
LFE_FILTER="highpass=f=${LFE_HP_FREQ}:poles=2,highpass=f=${LFE_HP_FREQ}:poles=2,lowpass=f=${LFE_LP_FREQ}:poles=2,lowpass=f=${LFE_LP_FREQ}:poles=2,${LFE_EQ},volume=${LFE_REDUCTION}"

# 3. Parametri per i compressori sidechain
LFE_SC_PARAMS="threshold=${LFE_DUCK_THRESHOLD}:ratio=${LFE_DUCK_RATIO}:attack=${LFE_ATTACK}:release=${LFE_RELEASE}:makeup=1.0"
FX_SC_PARAMS="threshold=${FX_DUCK_THRESHOLD}:ratio=${FX_DUCK_RATIO}:attack=${FX_ATTACK}:release=${FX_RELEASE}:makeup=1.0"

# 4. Filtro finale per tutti i canali
FINAL_FILTER="aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,aformat=channel_layouts=5.1"

echo
echo "=========================================================="
echo "Avvio elaborazione con parametri ottimizzati per cartoni/musical..."
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
[SL]volume=1.6,${SURROUND_EQ}[SLduck]; \
[SR]volume=1.6,${SURROUND_EQ}[SRduck]; \
[FLduck][FRduck][FCout][LFEduck][SLduck][SRduck]amerge=inputs=6,${FINAL_FILTER}" \
-map 0:v -c:v copy \
-c:a:0 eac3 -b:a:0 ${BITRATE} -metadata:s:a:0 language=ita -metadata:s:a:0 title="Clearvoice Film 5.1" \
-map 0:a:1 -c:a:1 copy \
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
    echo "Preset: Cartoon/Musical Ducking Auto (EAC3 ${BITRATE})"
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