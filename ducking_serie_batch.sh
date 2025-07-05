#!/bin/bash

# ================================================================================
# ducking_auto_serie_batch.sh – v3.0 "Protocollo Autodistruzione"
# Batch per lanciare ducking_auto_serie.sh.
# Premendo Ctrl+C si INTERROMPE TUTTO: batch e processo figlio.
# ================================================================================

# Funzione di pulizia da attivare con Ctrl+C
cleanup() {
    echo -e "\n\n** SEGNALE DI INTERRUZIONE RICEVUTO! **"
    echo "Avvio procedura di arresto totale... Addio e grazie per tutto il pesce."
    
    # Uccide tutti i processi che sono figli diretti di questo script.
    # Questo è il modo più robusto per assicurarsi che ffmpeg venga terminato.
    pkill -P $$
    
    # Aspetta un istante per dare tempo ai processi di terminare
    sleep 1
    
    echo "Tutti i sistemi sono offline. Il batch è terminato."
    exit 130 # Uscita standard per interruzione da Ctrl+C
}

# Intercetta il segnale Ctrl+C (SIGINT) e lancia la nostra funzione di pulizia [3][4][5]
trap cleanup SIGINT

# NOME DELLO SCRIPT DA ESEGUIRE
SCRIPT_DA_ESEGUIRE="./ducking_auto_serie.sh"

# ... il resto dello script rimane identico a prima ...

# Verifica che lo script principale esista e sia eseguibile
if [ ! -f "$SCRIPT_DA_ESEGUIRE" ] || [ ! -x "$SCRIPT_DA_ESEGUIRE" ]; then
    echo "Houston, abbiamo un problema! Lo script $SCRIPT_DA_ESEGUIRE non è stato trovato o non è eseguibile."
    exit 1
fi

# Accetta un bitrate opzionale come primo argomento del batch
BITRATE="$1"

# TIMER GLOBALE - START
batch_start_time=$(date +%s)
processed_files=0
total_files=0

# Crea un array con tutti i file MKV, escludendo quelli già processati
mapfile -t mkv_files < <(find . -maxdepth 1 -type f -name "*.mkv" ! -name "*_serie_ducked.mkv" -print0 | sort -zV | tr '\0' '\n')

total_files=${#mkv_files[@]}

if [ $total_files -eq 0 ]; then
    echo "Nessun file MKV da processare trovato. Missione annullata."
    exit 0
fi

echo "Trovati $total_files file da processare. Attivazione protocollo Clearvoice..."
echo "---------------------------------"

# Processa ogni file nell'array
for file in "${mkv_files[@]}"; do
    [ -z "$file" ] && continue # Salta righe vuote
    ((processed_files++))
    echo ">>> Inizio elaborazione file $processed_files di $total_files: ${file##*/}"
    
    # Esegue lo script principale
    "$SCRIPT_DA_ESEGUIRE" "$file" "$BITRATE"
    
    # Non serve più controllare l'exit code, il trap gestisce tutto
    
    echo ">>> Completato: ${file##*/}"
    echo "---------------------------------"
done

# TIMER GLOBALE - END
batch_duration=$((($(date +%s) - batch_start_time)))
batch_minuti=$((batch_duration / 60))
batch_secondi=$((batch_duration % 60))

echo "MISSIONE COMPIUTA!"
echo "Tempo totale della sessione: ${batch_minuti}m ${batch_secondi}s"
echo "File processati: ${processed_files}"
echo "File totali trovati: ${total_files}"
echo "Tutti i processi sono stati completati. Il batch è terminato."