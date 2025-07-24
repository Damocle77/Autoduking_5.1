#!/bin/bash
# ==============================================================================
# DEFINIZIONE FUNZIONI & TRAP
# ==============================================================================

# Funzione di pulizia per gestire Ctrl+C
cleanup() {
    echo -e "\n\nScript interrotto. Eseguo pulizia processi..."
    # Se lo spinner è attivo, lo killa
    [ ! -z "$SPIN_PID" ] && kill $SPIN_PID 2>/dev/null
    # Uccide qualsiasi processo ffmpeg di analisi loudnorm rimasto appeso
    pkill -f "ffmpeg.*loudnorm" 2>/dev/null
    exit 130
}

# Il trap va messo QUI, fuori e dopo la definizione della funzione.
trap cleanup SIGINT

# Funzione per lo spinner
show_spinner() {
    local spin_chars="/-\|" # Versione ASCII super compatibile
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
# ducking_auto_cartoni.sh v1.6 - Audio Ottimizzato per Cartoni e Musical
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
BITRATE="768k"
[ ! -z "$2" ] && BITRATE="$2"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: ./ducking_auto_cartoni.sh \"file.mkv\" [bitrate]"
    exit 1
fi

# -------------------- ANALISI LOUDNESS --------------------
echo "===================== ANALISI LOUDNESS =========================="
echo "Avvio array di sensori... Calibrazione del flusso audio in corso."
echo "Acquisizione telemetria EBU R128: calcolo del Loudness Integrato."
echo "Scansione subspaziale per True Peak e Loudness Range (LRA)."
echo "ETA per decodifica del segnale: circa 10 min per ora di runtime."

# Avvia lo spinner in background
show_spinner &
SPIN_PID=$!

# Esegui l'analisi di ffmpeg e cattura l'output
ANALYSIS=$(ffmpeg -nostdin -i "$INPUT_FILE" -af loudnorm=print_format=summary -f null - 2>&1)

# Termina lo spinner e pulisci la riga
kill $SPIN_PID 2>/dev/null
wait $SPIN_PID 2>/dev/null
printf "\rAnalisi completata!                        \n"

# -------------------- ESTRAZIONE DATI --------------------
LUFS=$(echo "$ANALYSIS" | grep "Input Integrated" | awk '{print $3}' | sed 's/LUFS//')
PEAK=$(echo "$ANALYSIS" | grep "Input True Peak" | awk '{print $4}' | sed 's/dBTP//')
LRA=$(echo "$ANALYSIS" | grep "Input LRA" | awk '{print $3}' | sed 's/LU//')
THRESHOLD=$(echo "$ANALYSIS" | grep "Input Threshold" | awk '{print $3}' | sed 's/LUFS//')
TARGET_OFFSET=$(echo "$ANALYSIS" | grep "Target Offset" | awk '{print $3}' | sed 's/LU//')

echo "==================== RISULTATI ANALISI ========================="
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
# Parametri base per cartoni animati e musical - VOICE BOOST POTENZIATO 
# NB. (LFE_REDUCTION=0.77 -> ridotto del 23%)
VOICE_BOOST=3.3
LFE_REDUCTION=0.78
LFE_DUCK_THRESHOLD=0.008
LFE_DUCK_RATIO=3.8
FX_DUCK_THRESHOLD=0.008
FRONT_FX_REDUCTION=0.96
FX_DUCK_RATIO=2.8
FX_ATTACK=25
FX_RELEASE=650
LFE_ATTACK=30
LFE_RELEASE=700
LFE_HP_FREQ=45
LFE_LP_FREQ=100
SURROUND_BOOST=1.75
MAKEUP_GAIN=5.0
# NB. (MAKUP_GAIN aumentato necessita di riduzione del limiter su FINAL_FILTER)

# -------------------- LOGICA ADATTIVA --------------------
if [ $(awk "BEGIN {print ($LUFS < -20) ? 1 : 0}") -eq 1 ]; then
    VOICE_BOOST=$(awk "BEGIN {print $VOICE_BOOST + 0.1}")
    FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.3}")
    MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.2}")
    echo "APPLICATO: Boost voci minimo (+0.1dB) per preservare bilanciamento stereo"
    echo "APPLICATO: Ducking leggermente aumentato (+0.3) per chiarezza"
    echo "APPLICATO: Makeup gain leggero (+0.2) per voci basse"
elif [ $(awk "BEGIN {print ($LUFS > -16) ? 1 : 0}") -eq 1 ]; then
    FX_DUCK_RATIO=$(awk "BEGIN {print $FX_DUCK_RATIO + 0.1}")
    MAKEUP_GAIN=$(awk "BEGIN {print $MAKEUP_GAIN + 0.7}")
    echo "APPLICATO: Voice boost invariato per preservare bilanciamento"
    echo "APPLICATO: Ducking più reattivo (+0.1) per preservare musica"
    echo "APPLICATO: Makeup gain potenziato (+0.7) per livello finale ottimale"
else
    echo "APPLICATO: Parametri standard bilanciati - loudness nel range ottimale"
    echo "APPLICATO: Makeup gain principale (${MAKEUP_GAIN}) per volume finale corretto"
fi
# Controllo True Peak per LFE
if [ $(awk "BEGIN {print ($PEAK > -2) ? 1 : 0}") -eq 1 ]; then
    LFE_HP_FREQ=50
    echo "ATTIVO: Filtro 'Anti-Fango' potenziato a ${LFE_HP_FREQ}Hz. Preservata la musicalità, rimosso il rimbombo."
else
    echo "APPLICATO: Taglio LFE standard (${LFE_HP_FREQ}Hz) per fondamenti orchestrali"
fi

# Filtro voce italiana ultra-conservativo - solo processing essenziale
#VOICE_EQ="highpass=f=85,deesser=i=0.12:m=0.4:f=0.23"
VOICE_EQ="highpass=f=70,deesser=i=0.02:m=0.12:f=0.15,aexciter=level_in=1:level_out=1:amount=0.65:drive=2.25:blend=0:freq=2600:ceil=10000:listen=0,compand=attacks=0.0025:decays=0.015:points=-75/-75|-40/-39|-25/-20|-10/-7:soft-knee=5:gain=0.25"
echo "APPLICATO: Filtro voce ultra-conservativo: HP dolce 70Hz + Exciter sottile + De-Esser chirurgico + Compand trasparente."

# Filtro LFE per cartoni
LFE_EQ="equalizer=f=35:width_type=q:w=1.6:g=0.6,equalizer=f=75:width_type=q:w=1.8:g=0.4"
echo "ATTIVO: Equalizzazione orchestrale. I bassi sono ora più definiti e musicali, non solo 'boom'."

# Preparazione filtri
COMPAND_PARAMS="attacks=0.005:decays=0.01:points=-60/-60|-30/-30|-15/-8:soft-knee=2:gain=0"
# Cartoni/Film - release più veloce:
SIDECHAIN_PREP="bandpass=f=2200:width_type=h:w=2800,volume=2.6,compand=${COMPAND_PARAMS},agate=threshold=-30dB:ratio=2.0:attack=0.5:release=4000"
SURROUND_EQ="highpass=f=60,volume=1.06" # +0.5dB Boost
FRONT_FX_EQ="highpass=f=85" 

# Riorganizzazione filtri finali
FC_FILTER="${VOICE_EQ},volume=${VOICE_BOOST},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=70:asc=1"
LFE_FILTER="highpass=f=${LFE_HP_FREQ}:poles=2,lowpass=f=${LFE_LP_FREQ}:poles=2,${LFE_EQ},volume=${LFE_REDUCTION}"
LFE_SC_PARAMS="threshold=${LFE_DUCK_THRESHOLD}:ratio=${LFE_DUCK_RATIO}:attack=${LFE_ATTACK}:release=${LFE_RELEASE}:makeup=1.0"
FX_SC_PARAMS="threshold=${FX_DUCK_THRESHOLD}:ratio=${FX_DUCK_RATIO}:attack=${FX_ATTACK}:release=${FX_RELEASE}:makeup=1.0"
FINAL_FILTER="aresample=resampler=soxr:precision=28:cutoff=0.95:cheby=1,volume=${MAKEUP_GAIN},alimiter=level_in=1:level_out=1:limit=0.95:attack=2:release=100:asc=1,aformat=channel_layouts=5.1"

# -------------------- ESECUZIONE FFMPEG --------------------
echo
echo "==================================================================="
echo "Avvio elaborazione con parametri ottimizzati per cartoni/musical..."
echo "==================================================================="
echo
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
[SL]${SURROUND_EQ}[SLduck]; \
[SR]${SURROUND_EQ}[SRduck]; \
[FLduck][FRduck][FCout][LFEduck][SLduck][SRduck]amerge=inputs=6,${FINAL_FILTER}[clearvoice]" \
-map 0:v -c:v copy \
-map "[clearvoice]" -c:a:0 eac3 -b:a:0 ${BITRATE} -metadata:s:a:0 language=ita -metadata:s:a:0 title="Clearvoice EAC3 Cartoni" \
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
    echo "Preset: Cartoon/Musical Ducking Auto (EAC3 ${BITRATE})"
    echo
    echo "PARAMETRI FINALI APPLICATI:"
    echo "Voice Boost: $VOICE_BOOST dB | LFE Reduction: $LFE_REDUCTION"
    echo "FX Duck Ratio: $FX_DUCK_RATIO:1 | LFE Duck Ratio: $LFE_DUCK_RATIO:1"
    echo "Makeup Gain: $MAKEUP_GAIN | Limiter finale ottimizzato: 0.94"
    echo
    echo "MISURAZIONE ORIGINALE:"
    echo "LUFS: $LUFS | True Peak: $PEAK dBTP | LRA: $LRA LU"
    echo "==================================================================="
else
    echo "ERRORE - Qualcosa è andato storto durante l'elaborazione di ffmpeg (Codice: $ffmpeg_exit_code)."
    echo "Tempo trascorso: ${minuti}m ${secondi}s"
    exit 1
fi