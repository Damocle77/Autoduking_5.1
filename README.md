# 🎛️ Autoducking 5.1 – "Tuffati nel suono" – v1.3

> “Non serve essere Tony Stark per ottimizzare il mix: questi script sono già il tuo Jarvis audio.”
> “Se vuoi sentire la voce di Bulma anche quando Vegeta urla, qui trovi gli strumenti adatti!”
> “Dialoghi italiani chiari come un cristallo di Kyber, LFE controllato come il motore a curvatura della Voyager. By Sandro "D@mocle77" Sabbioni.”

## 📚 Indice
- [Cosa fanno questi script](#cosa-fanno-questi-script--usa-il-tuo-scudo-di-vibranio)
- [Flusso di lavoro tipico](#flusso-di-lavoro-tipico-per-impazienti)
- [Requisiti](#requisiti--armati-come-un-mandaloriano)
- [Installazione](#installazione-in-30-secondi--che-la-forza-sia-con-te)
- [Script Ausiliari](#script-ausiliari--i-tuoi-droidi-da-battaglia)
- [La Filosofia Jedi](#la-filosofia-jedi-dietro-gli-script--questa-è-la-via)
- [Perché usarli](#perché-usarli--perchè-anche-tu-sei-un-nerd)

---
![Bash](https://img.shields.io/badge/Bash-%3E%3D5.0-blue?logo=gnu-bash)
![ffmpeg](https://img.shields.io/badge/FFmpeg-%3E%3D7.0-success?logo=ffmpeg)
![Open Source](https://img.shields.io/badge/license-MIT-green)

---

## 💡 Cosa fanno questi script – “Usa il tuo scudo di vibranio”

Tre preset Bash, ognuno calibrato per un universo diverso. Tutti sfruttano una catena di processamento avanzata per trasformare un mix standard in un'esperienza audio a prova di nerd. Tecnologie chiave:

- **Analisi Adattiva:** Lo script scansiona l'audio come un droide protocollare, misurando Loudness, True Peak e Dinamica.
- **Ducking Intelligente:** Crea uno “scudo deflettore” che abbassa dinamicamente gli altri suoni solo quando serve.
- **EQ Jedi:** Modella il suono in modo naturale, mai artificiale.

| Script                      | Missione                                 | Output                        | Tattiche Speciali                                             |
|-----------------------------|------------------------------------------|-------------------------------|---------------------------------------------------------------|
| `ducking_auto_cartoni.sh`   | Cartoni, Musical, Disney/Pixar           | `*_cartoon_ducked.mkv`        | Voci cristalline, ducking delicato, LFE orchestrale           |
| `ducking_auto_film.sh`      | Film Azione, Thriller, Horror            | `*_film_ducked.mkv`           | Dialoghi a prova di bomba, LFE anti-detonazione, fronte IMAX  |
| `ducking_auto_serie.sh`     | Serie Fantasy, Sci-Fi, Commedia          | `*_serie_ducked.mkv`          | Equilibrio perfetto, ducking adattivo, chiarezza binge-ready  |

## 🚦 Flusso di lavoro tipico (per impazienti)

1. Metti i tuoi file .mkv nella cartella.
2. Lancia lo script che ti serve (es: `./ducking_auto_film.sh`).
3. Aspetta... “It's over 9000!” (processing)
4. Goditi la traccia ottimizzata oppure usa il batch per le serie.
5. [Opzionale] Converti con DTS finale per sicurezza su soundbar/cinema.

🎬 Vuoi processare una stagione intera? Vai a [ducking_serie_batch.sh](#ducking_serie_batchsh)  
🔊 Vuoi la traccia DTS? Vai a [ducking_dts_conversion.sh](#ducking_dts_conversionsh)

## ⚙️ Requisiti – "Armati come un Mandaloriano"

- **Bash** (Linux/macOS/WSL/Windows Git Bash)
- **FFmpeg** (>= 7.x con E-AC3, SoxR, Filtercomplex, Audiograph)

## 📥 Installazione in 30 secondi – “Che la Forza sia con te”

```
winget install ffmpeg -e && winget install Git.Git -e
sudo apt install ffmpeg
sudo yum install ffmpeg
brew install ffmpeg
```
```
git clone https://github.com/Damocle77/Autoduking_5.1.git
cd autoducking_5.1
chmod +x ducking_auto_*.sh
```
```
Assicurati che ffmpeg sia nel PATH.

## 🛠️ Script Ausiliari – “I tuoi droidi da battaglia”

### ducking_serie_batch.sh
> Vuoi processare un’intera stagione di fila? Questo batch fa tutto mentre dormi.  
`./ducking_serie_batch.sh [bitrate]`

### ducking_dts_conversion.sh
> L’adattatore universale: aggiunge una traccia audio DTS 5.1 “boostata” di +2dB e compatibile ovunque.

- Conversione standard (Clearvoice come default):
```

./ducking_dts_conversion.sh file.mkv

```
- Conversione di una traccia specifica:
```

./ducking_dts_conversion.sh file.mkv 0

```

## 🚀 La Filosofia Jedi dietro gli Script – “Questa è la Via”

### Dall'EQ Chirurgico all'Highshelf Musicale
Dimentica filtri distruttivi: qui si usano filtri musicali trasparenti.

### Fronte Sonoro Unito
Canali frontali allineati: nessun “teleport” audio. L’effetto cinema è reale.

### Output “Remaster”, non solo “HD”!
Non si inventa qualità, si tira fuori il massimo dal materiale originale.

## 🧑‍🚀 Perché usarli – “Perché anche tu sei un Nerd!”

- Analisi automatica loudness: è come avere DATA che ti monitora il segnale.
- Dialoghi italiani sempre intelligibili, anche nei mix più “lucasiani”.
- Output EAC3 e DTS robustissimi.
- Alchimie ducking/LFE dedicate a ogni genere.
- Tutto open source e facilmente editabile.

---

> Se ti perdi i dialoghi perché i bassi fanno a botte con l’Enterprise, questi script sono la tua alleanza ribelle.  
> “Per riportare equilibrio nella Forza ti servono solo un terminale bash e questi script!”

```


