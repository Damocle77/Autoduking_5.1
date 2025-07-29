#!/bin/bash
# ================================================================================
# ducking_dts_conversion.sh v1.7 – Conversione traccia audio in DTS 5.1 a 768k
# ================================================================================
# - Copia video e traccia audio originale.
# - Crea una nuova traccia audio DTS ad alta qualità con +2dB.
# - Mantiene sottotitoli e metadati del file originale.
# ================================================================================

# Controllo argomenti
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Uso: $0 file_input.mkv [traccia_audio]"
    echo "Esempi:"
    echo "  $0 file.mkv     # Usa traccia 1 (Clearvoice)"
    echo "  $0 file.mkv 0   # Usa traccia 0 (Originale)"
    echo "  $0 file.mkv 2   # Usa traccia 2 (Ulteriore)"
    exit 1
fi

# Controllo se il file di input esiste
INPUT="$1"
# ------------------------------------------------------------------
# AUTO-DETECT della traccia audio intitolata "Clearvoice"
# ------------------------------------------------------------------
if [ -z "$2" ]; then
  # Cerca tra i flussi audio un tag "title" che contenga "clearvoice"
  AUDIO_TRACK=$(ffprobe -v error -select_streams a \
    -show_entries stream=index:stream_tags=title,language \
    -of csv=p=0 "$INPUT" | \
    grep -i clearvoice | \
    cut -d',' -f1)

  # Se non trova nulla, ripiega elegantemente sulla traccia 1
  if [ -z "$AUDIO_TRACK" ]; then
    echo "⚠️  Nessuna traccia 'Clearvoice' trovata. Uso traccia 1 come fallback."
    AUDIO_TRACK=1
  else
    echo "✅  Trovata traccia Clearvoice: #$AUDIO_TRACK"
  fi
else
  # …altrimenti usa l’indice passato da riga di comando
  AUDIO_TRACK="$2"
fi

# ========================================
#       CONVERSIONE DTS 5.1
# ========================================

OUTPUT="${INPUT%.*}_DTS.mkv"

echo "🔄 Avvio conversione DTS 5.1..."

ffmpeg -hwaccel auto -threads 0 -i "$INPUT" \
    -map 0:v -c:v copy \
    -map 0:a -c:a copy \
    -map 0:$AUDIO_TRACK -c:a dts \
    -strict experimental \
    -ar:a:3 48000 \
    -b:a:3 768k \
    -filter:a:3 "volume=+2dB" \
    -metadata:s:a:3 title="Clearvoice DTS" \
    -map 0:s? -c:s copy \
    -y "$OUTPUT"

if [ $? -eq 0 ]; then
    echo "✅ Conversione completata: $OUTPUT"
else
    echo "❌ Errore durante la conversione"
    exit 1
fi
