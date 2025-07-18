
# 🎛️ Autoducking 5.1 – "Tuffati nel suono" – v1.5

> “Non serve essere Tony Stark per ottimizzare il mix: questi script sono già il tuo Jarvis audio.”  
> “Se vuoi sentire la voce di Bulma anche quando Vegeta urla, qui trovi gli strumenti adatti!”  
> “Dialoghi italiani chiari come un cristallo di Kyber, LFE controllato come il motore a curvatura della Voyager.  
> “SELECT name AS 'Sandro Sabbioni', handle AS 'D@mocle77' FROM developers”

## Indice

- [Cosa fanno questi script](#cosa-fanno-questi-script)
- [Flusso di lavoro tipico](#flusso-di-lavoro-tipico)
- [Requisiti](#requisiti)
- [Installazione](#installazione)
- [Script Ausiliari](#script-ausiliari)
- [La Filosofia Jedi](#la-filosofia-jedi)
- [Perché usarli](#perché-usarli)

---

![Bash](https://img.shields.io/badge/Bash-%3E%3D5.0-blue?logo=gnu-bash)
![ffmpeg](https://img.shields.io/badge/FFmpeg-%3E%3D7.0-success?logo=ffmpeg)
![Open Source](https://img.shields.io/badge/license-MIT-green)

---

## Cosa fanno questi script
> 💡 “Usa il tuo scudo di vibranio”

Tre preset Bash, ognuno calibrato per un universo diverso. Tutti sfruttano una catena di processamento avanzata per trasformare un mix standard in un'esperienza audio a prova di nerd. Tecnologie chiave:

- **Analisi Adattiva:** Lo script scansiona l'audio come un droide protocollare, misurando Loudness, True Peak e Dinamica.
- **Ducking Intelligente:** Crea uno “scudo deflettore” che abbassa dinamicamente gli altri suoni solo quando serve.
- **EQ Jedi:** Modella il suono in modo naturale, mai artificiale.

| Script                      | Missione                                 | Output                        | Tattiche Speciali                                             |
|-----------------------------|------------------------------------------|-------------------------------|---------------------------------------------------------------|
| `ducking_auto_cartoni.sh`   | Cartoni, Musical, Disney/Pixar           | `*_cartoon_ducked.mkv`        | Voci cristalline, ducking delicato, LFE orchestrale           |
| `ducking_auto_film.sh`      | Film Azione, Thriller, Horror            | `*_film_ducked.mkv`           | Dialoghi a prova di bomba, LFE anti-detonazione, fronte IMAX  |
| `ducking_auto_serie.sh`     | Serie Fantasy, Sci-Fi, Commedia          | `*_serie_ducked.mkv`          | Equilibrio perfetto, ducking adattivo, chiarezza binge-ready  |

## Flusso di lavoro tipico
> 🚦 Per impazienti e Saiyan multitasking

1. Metti i tuoi file `.mkv` nella cartella.
2. Lancia lo script che ti serve (es: `./ducking_auto_film.sh`).
3. Aspetta... “It's over 9000!” (processing)
4. Goditi la traccia ottimizzata oppure usa il batch per le serie.
5. [Opzionale] Converti con DTS finale per compatibilità universale.

🎬 Vuoi processare una stagione intera? Vai a [ducking_serie_batch.sh](#ducking_serie_batchsh)  
🔊 Vuoi la traccia DTS? Vai a [ducking_dts_conversion.sh](#ducking_dts_conversionsh)

## Requisiti
> ⚙️ Armati come un Mandaloriano

- **Bash** (Linux, macOS, WSL, o Windows con Git Bash)
- **FFmpeg** (>= 7.x con supporto E-AC3, SoxR, Filtercomplex, Audiograph)

## Installazione
> 📥 In 30 secondi – “Che la Forza sia con te”

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
git clone https://github.com/Damocle77/Autoduking_5.1.git
cd autoducking_5.1
chmod +x ducking_auto_*.sh
```

**Nota:** Assicurati che `ffmpeg` sia nel tuo `PATH`.

## Script Ausiliari
> 🛠️ I tuoi droidi da battaglia

### ducking_serie_batch.sh
> Vuoi processare un’intera stagione di fila? Questo batch fa tutto mentre dormi.  
```bash
./ducking_serie_batch.sh [bitrate]
```

### ducking_dts_conversion.sh
> L’adattatore universale: aggiunge una traccia audio DTS 5.1 “boostata” di +2dB e compatibile ovunque.

- Conversione standard (usa Clearvoice di default):
```bash
./ducking_dts_conversion.sh file.mkv
```

- Conversione di una traccia specifica:
```bash
./ducking_dts_conversion.sh file.mkv 0
```

## La Filosofia Jedi
> 🚀 Questa è la Via

### Dall'EQ Chirurgico all'Highshelf Musicale
Dimentica filtri distruttivi: qui si usano filtri musicali trasparenti.

### Fronte Sonoro Unito
Canali frontali allineati: nessun “teleport” audio. L’effetto cinema è reale.

### Output “Remaster”, non solo “HD”!
Non si inventa qualità: si tira fuori il massimo dal materiale originale.

## Perché usarli
> 🧑‍🚀 Perché anche tu sei un Nerd!

- Analisi automatica loudness: è come avere **DATA** che monitora il segnale.
- Dialoghi italiani sempre intelligibili con deesser.
- Output EAC3 e DTS robustissimi con ffmpeg.
- Ducking/LFE specifico per preset.
- Ricampionamento HD con SoxR.
- Tutto open source e facilmente editabile.

---

> “Per riportare equilibrio nella Forza ti servono solo un terminale bash e questi script!”
