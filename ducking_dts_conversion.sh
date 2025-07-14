#!/bin/bash
# ================================================================================
# ducking_dts_conversion.sh – Conversione traccia audio in DTS 5.1 a 7566k
# ================================================================================
# - Copia video e traccia audio originale.
# - Crea una nuova traccia audio DTS ad alta qualità.
# - Mantiene sottotitoli e metadati del file originale.
# ================================================================================

# Controllo argomenti
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Uso: $0 file_input.mkv [traccia_audio]"
    echo "Esempi:"
    echo "  $0 file.mkv     # Usa traccia 1 (Clearvoice EAC3)"
    echo "  $0 file.mkv 0   # Usa traccia 0 (Originale)"
    echo "  $0 file.mkv 2   # Usa traccia 2 (Ulteriore)"
    exit 1
fi

# Controllo se il file di input esiste
INPUT="$1"
AUDIO_TRACK="${2:-1}"  # Default alla traccia 1 (Clearvoice EAC3)
BASENAME="${INPUT%.*}"
OUTPUT="${BASENAME}_dts.mkv"

echo "Conversione traccia audio $AUDIO_TRACK in DTS..."


# Esecuzione di ffmpeg per la conversione
ffmpeg -y -nostdin -hwaccel auto -threads 0 -i "$INPUT" \
    -map 0:v -c:v copy \
    -map 0:a -c:a copy \
    -map 0:a:$AUDIO_TRACK -c:a:1 dts -ar 48000 -channel_layout:a:1 "5.1(side)" -b:a:1 756k -strict -2 -disposition:a:1 default \
    -map 0:s? -c:s copy \
    -map_metadata 0 \
    -metadata:s:a:1 title="Clearvoice DTS 756k" \
    "$OUTPUT"

