# 🎛️ Autoducking 5.1 – "Tuffati nel suono" – v1.7

> "Ottimizza il tuo audio come un vero Jedi del suono!"  
> "Dialoghi chiari, bassi potenti e un mix perfetto per ogni contenuto."  
> "Perché anche un Sith apprezzerebbe un mix così bilanciato!"

![SELECT name AS 'Sandro Sabbioni', handle AS 'D@mocle77' FROM developers](https://img.shields.io/badge/SELECT%20name%20AS%20'Sandro%20Sabbioni'%2C%20handle%20AS%20'D%40mocle77'%20FROM%20developers-blue)

---

## Indice

- [Cosa fanno questi script](#cosa-fanno-questi-script)
- [Flusso di lavoro tipico](#flusso-di-lavoro-tipico)
- [Requisiti](#requisiti)
- [Installazione](#installazione)
- [Script Principali](#script-principali)
- [Script Batch](#script-batch)
- [Script Ausiliari](#script-ausiliari)
- [Perché usarli](#perché-usarli)

---

## Cosa fanno questi script

Questi script Bash trasformano il tuo audio in un'esperienza cinematografica:

- **Analisi Adattiva:** Misura Loudness, True Peak e Dinamica per un mix perfetto.
- **Ducking Intelligente:** Dialoghi sempre chiari, senza sacrificare gli effetti sonori.
- **Ricampionamento HD:** SoxR garantisce qualità audio impeccabile.
- **Filtro Deesser:** Elimina sibili fastidiosi mantenendo la naturalezza della voce.
- **Equalizzazione Avanzata:** Suono bilanciato e naturale, ottimizzato per ogni contenuto.
- **Aexciter Avanzato:** Aggiunge brillantezza e chiarezza alle voci, migliorando la presenza senza distorsioni.

---

## Flusso di lavoro tipico

### Uso base
```bash
# Script unificato (auto-rileva il preset migliore)
./ducking_auto.sh "file.mkv" [bitrate] [preset_override]

# Script specifici
./ducking_auto_film.sh "file.mkv" [bitrate]
./ducking_auto_serie.sh "file.mkv" [bitrate]
./ducking_auto_cartoni.sh "file.mkv" [bitrate]
./ducking_auto_stereo.sh "file.mkv" [bitrate]

# Script di conversione e upmix
./ducking_stereo251.sh "file.mkv" [bitrate]
./ducking_eac32dts.sh "file.mkv" [bitrate]
```

### Parametri
- **file.mkv**: File video di input (obbligatorio)
- **bitrate**: Bitrate audio di output (opzionale, default: 768k per film, 384k per serie/stereo)
- **preset_override**: Forza un preset specifico (solo per ducking_auto.sh)

---

## Requisiti

- **Bash** (Linux, macOS, WSL, o Windows con Git Bash)
- **FFmpeg** (>= 7.x con supporto E-AC3, SoxR, Filtercomplex, Audiograph)

---

## Installazione

```bash
# Windows
winget install ffmpeg -e && winget install Git.Git -e

# Debian/Ubuntu
sudo apt install ffmpeg

# RHEL/CentOS/Fedora
sudo yum install ffmpeg

# macOS
brew install ffmpeg
```

```bash
# Clonazione del progetto
git clone https://github.com/Damocle77/Autoducking_5.1.git
cd autoducking_5.1
chmod +x *.sh
```

**Nota:** Assicurati che `ffmpeg` sia nel tuo `PATH`.

---

## Script Principali

| Script                      | Missione                                 | Output                        | Tattiche Speciali                                             |
|-----------------------------|------------------------------------------|-------------------------------|---------------------------------------------------------------|
| `ducking_auto.sh`           | Script Unificato (Auto-detect)          | `*_[preset]_ducked.mkv`       | Selezione automatica del preset migliore                      |
| `ducking_auto_cartoni.sh`   | Cartoni, Musical, Disney/Pixar           | `*_cartoni_ducked.mkv`        | Voci cristalline, ducking delicato, LFE orchestrale           |
| `ducking_auto_film.sh`      | Film Azione, Thriller, Horror            | `*_film_ducked.mkv`           | Dialoghi a prova di bomba, LFE anti-detonazione, fronte IMAX  |
| `ducking_auto_serie.sh`     | Serie Fantasy, Sci-Fi, Commedia          | `*_serie_ducked.mkv`          | Equilibrio perfetto, ducking adattivo, chiarezza binge-ready  |
| `ducking_auto_stereo.sh`    | Audio Stereo (2.0)                       | `*_serie_ducked.mkv`          | Processing minimalista per contenuti stereo                   |
| `ducking_stereo251.sh`      | Stereo to 5.1 Duplication               | `*_stereo251_ducked.mkv`    | Upmix intelligente da stereo a 5.1 con surround duplication |
| `ducking_eac32dts.sh`       | Conversione in DTS 5.1                  | `*_DTS.mkv`                 | Aggiunge una traccia DTS 5.1 con +2dB di volume             |

---

## Script Batch

Per l'elaborazione di massa di file video:

| Script                      | Funzione                                 | Utilizzo                               |
|-----------------------------|------------------------------------------|----------------------------------------|
| `batch_film.sh`             | Elaborazione batch per film             | `./batch_film.sh /path/to/movies/`     |
| `batch_serie.sh`            | Elaborazione batch per serie TV         | `./batch_serie.sh /path/to/series/`    |
| `batch_cartoni.sh`          | Elaborazione batch per cartoni animati  | `./batch_cartoni.sh /path/to/cartoons/`|

### Caratteristiche dei script batch:
- **Elaborazione automatica:** Processa tutti i file `.mkv` in una directory
- **Preservazione struttura:** Mantiene l'organizzazione originale dei file
- **Log dettagliati:** Traccia il progresso e gli errori
- **Controllo qualità:** Verifica l'integrità dei file processati

---

## Script Ausiliari

Strumenti di supporto per analisi e manutenzione:

| Script                      | Funzione                                 | Output                                 |
|-----------------------------|------------------------------------------|----------------------------------------|
| `analyze_audio.sh`          | Analisi dettagliata delle tracce audio | Report loudness, dinamica e spettro   |
| `extract_audio.sh`          | Estrazione tracce audio                 | File audio separati (WAV/FLAC)        |
| `validate_output.sh`        | Verifica qualità output                 | Report di conformità e errori         |
| `cleanup_temp.sh`           | Pulizia file temporanei                 | Rimozione file di lavoro               |

### Funzionalità degli script ausiliari:
- **📊 Analisi avanzata:** Metriche dettagliate di loudness, true peak e range dinamico
- **🔍 Verifica qualità:** Controllo automatico dell'integrità dell'output
- **🧹 Manutenzione:** Pulizia automatica dei file temporanei
- **📈 Reportistica:** Log dettagliati per debugging e ottimizzazione

---

## Perché usarli

- **🎯 Analisi automatica loudness:** Mix sempre bilanciato.
- **🔊 Dialoghi chiari:** Deesser e boost vocale ottimizzati.
- **🎵 Qualità audio HD:** Ricampionamento SoxR e equalizzazione avanzata.
- **🚀 Elaborazione batch:** Perfetto per stagioni intere.
- **🌍 Compatibilità universale:** Output EAC3 e DTS robusti.
- **🎧 Upmix stereo 5.1:** Trasforma l'audio stereo in un'esperienza surround coinvolgente.
- **🎼 Conversione DTS:** Aggiungi tracce DTS 5.1 per una qualità audio cinematografica.

---

> "Per riportare equilibrio nella Forza ti servono solo un terminale bash e questi script. Questa è la via!"
