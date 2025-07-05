#!/bin/bash
# ================================================================================
# ducking_dts_conversion.sh – Conversione traccia audio in DTS 5.1 a 1536k
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

# Controllo se il file di input esiste
ffmpeg -i "$INPUT" \
    -map 0:v -c:v copy \
    -map 0:a:0 -c:a:0 copy \
    -map 0:a:0 -c:a:1 dts -ar 48000 -channel_layout:a:1 5.1\(side\) -compression_level:a:1 2 -b:a:1 1536k -strict -2 \
    -map 0:s -c:s copy \
    -map_metadata 0 \
    -metadata:s:a:0 language=ita \
    -metadata:s:a:1 language=ita -metadata:s:a:1 title="Ducked DTS 1536k" \
    "$OUTPUT"
