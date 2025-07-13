#!/bin/bash
# ================================================================================
# ducking_dts_conversion.sh – Conversione traccia audio in DTS 5.1 a 7566k
# ================================================================================
# - Copia video e traccia audio originale.
# - Crea una nuova traccia audio DTS ad alta qualità.
# - Mantiene sottotitoli e metadati del file originale.
# ================================================================================

# Controllo argomento
if [ $# -ne 1 ]; then
    echo "Uso: $0 file_input.mkv"
    exit 1
fi
# Controllo se il file di input esiste
INPUT="$1"
BASENAME="${INPUT%.*}"
OUTPUT="${BASENAME}_dts.mkv"

# Esecuzione di ffmpeg per la conversione
ffmpeg -y -nostdin -hwaccel auto -threads 0 -i "$INPUT" \
    -map 0:v -c:v copy \
    -map 0:a -c:a copy \
    -map 0:a:0 -c:a:1 dts -ar 48000 -channel_layout:a:1 "5.1(side)" -b:a:1 756k -strict -2 -disposition:a:1 default \
    -map 0:s? -c:s copy \
    -map_metadata 0 \
    -metadata:s:a:1 title="Clearvoice DTS 756k" \
    "$OUTPUT"

