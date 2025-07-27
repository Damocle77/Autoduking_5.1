# 🎛️ Autoducking 5.1 – "Tuffati nel suono" – v1.6

> "Non serve essere Tony Stark per ottimizzare il mix: questi script sono già il tuo Jarvis audio."  
> "Se vuoi sentire la voce di Bulma anche quando Vegeta urla, qui trovi gli strumenti adatti!"  
> "Dialoghi chiari come un cristallo di Kyber, LFE controllato come la "curvatura" della Voyager."  
> "Per un mixaggio che neanche il Dr. Strange riesce ad alterare!"

![SELECT name AS 'Sandro Sabbioni', handle AS 'D@mocle77' FROM developers](https://img.shields.io/badge/SELECT%20name%20AS%20'Sandro%20Sabbioni'%2C%20handle%20AS%20'D%40mocle77'%20FROM%20developers-blue)

## Indice

- [Cosa fanno questi script](#cosa-fanno-questi-script)
- [Flusso di lavoro tipico](#flusso-di-lavoro-tipico)
- [Requisiti](#requisiti)
- [Installazione](#installazione)
- [Script Principali](#script-principali)
- [Script Batch](#script-batch)
- [Script Ausiliari](#script-ausiliari)
- [La Filosofia Jedi](#la-filosofia-jedi)
- [Perché usarli](#perché-usarli)

---

![Bash](https://img.shields.io/badge/Bash-%3E%3D5.0-blue?logo=gnu-bash)
![ffmpeg](https://img.shields.io/badge/FFmpeg-%3E%3D7.0-success?logo=ffmpeg)
![Open Source](https://img.shields.io/badge/license-MIT-green)

---

## Cosa fanno questi script
> 💡 "Usa il tuo scudo di vibranio"

Quattro preset Bash (più uno unificato), ognuno calibrato per un universo diverso. Tutti sfruttano una catena di processamento avanzata per trasformare un mix standard in un'esperienza audio a prova di nerd. Tecnologie chiave:

- **Analisi Adattiva:** Lo script scansiona l'audio come un droide protocollare della Federazione Galattica, misurando Loudness, True Peak e Dinamica proprio come uno scan di Tricorder su un pianeta ostile.
- **Ducking Intelligente:** Crea uno "scudo deflettore" alla Scotty che abbassa dinamicamente gli altri suoni solo quando serve, così la voce rimane sempre in primo piano come un monologo di Iron Man.
- **Ricampionamento SoxR:** Prende il flusso audio e lo teletrasporta a una nuova dimensione—ehm, frequenza! SoxR ricampiona segnali come il TARDIS viaggia tra epoche: viaggiando velocissimo, mantenendo sempre la qualità top.
- **Filtro Deesser:** Intercetta le "S" sibilanti come un cacciatore di taglie nell'iperspazio: elimina le frequenze fastidiose senza far fuori la voce umana, un po' come Han Solo abbatte solo gli stormtrooper giusti.
- **EQ Jedi:** Modella il suono con la grazia di un Maestro Jedi: l'equalizzazione non è mai forzata o artificiale, ma segue il naturale flusso della Forza, assicurando che ogni traccia suoni con equilibrio e naturalezza.

| Script                      | Missione                                 | Output                        | Tattiche Speciali                                             |
|-----------------------------|------------------------------------------|-------------------------------|---------------------------------------------------------------|
| `ducking_auto.sh`           | Script Unificato (Auto-detect)          | `*_[preset]_ducked.mkv`       | Selezione automatica del preset migliore                      |
| `ducking_auto_cartoni.sh`   | Cartoni, Musical, Disney/Pixar           | `*_cartoni_ducked.mkv`        | Voci cristalline, ducking delicato, LFE orchestrale           |
| `ducking_auto_film.sh`      | Film Azione, Thriller, Horror            | `*_film_ducked.mkv`           | Dialoghi a prova di bomba, LFE anti-detonazione, fronte IMAX  |
| `ducking_auto_serie.sh`     | Serie Fantasy, Sci-Fi, Commedia          | `*_serie_ducked.mkv`          | Equilibrio perfetto, ducking adattivo, chiarezza binge-ready  |
| `ducking_auto_stereo.sh`    | Audio Stereo (2.0)                       | `*_serie_ducked.mkv`          | Processing minimalista per contenuti stereo                   |

## Flusso di lavoro tipico
> 🚦 Per impazienti e Saiyan multitasking

### Uso base
```bash
# Script unificato (auto-rileva il preset migliore)
./ducking_auto.sh "file.mkv" [bitrate] [preset_override]

# Script specifici
./ducking_auto_film.sh "file.mkv" [bitrate]
./ducking_auto_serie.sh "file.mkv" [bitrate] 
./ducking_auto_cartoni.sh "file.mkv" [bitrate]
./ducking_auto_stereo.sh "file.mkv" [bitrate]
```

### Parametri
- **file.mkv**: File video di input (obbligatorio)
- **bitrate**: Bitrate audio di output (opzionale, default: 768k per film, 384k per serie/stereo)
- **preset_override**: Forza un preset specifico (solo per ducking_auto.sh)

### Processo automatico
1. Metti i tuoi file `.mkv` nella cartella degli script
2. Lancia lo script appropriato con il file tra virgolette
3. Aspetta l'analisi e il processing ("It's over 9000!")
4. Goditi la traccia ottimizzata con audio bilanciato

> **Nota**: Gli script includono analisi automatica del loudness e applicazione di parametri ottimali in base al contenuto rilevato.

### Per elaborazioni multiple
🎬 **Vuoi processare una stagione intera?** Usa i [script batch](#script-batch)  
🛠️ **Hai file in semplice Stereo?** Usa `ducking_batch_stereo.sh`  
🔊 **Vuoi anche una traccia DTS?** Usa `ducking_dts_conversion.sh`  

## Requisiti
> ⚙️ Armati come un Mandaloriano

- **Bash** (Linux, macOS, WSL, o Windows con Git Bash)
- **FFmpeg** (>= 7.x con supporto E-AC3, SoxR, Filtercomplex, Audiograph)

## Installazione
> 📥 In 30 secondi – "Che la Forza sia con te"

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

## Script Principali
> 🛠️ I tuoi droidi da battaglia

### ducking_auto.sh - Il Maestro Jedi
> Script unificato che auto-rileva il tipo di contenuto e applica il preset ottimale

```bash
./ducking_auto.sh "file.mkv" [bitrate] [preset_override]
```

Rileva automaticamente se il file è stereo (→ preset stereo), ha alta dinamica (→ cartoni), picchi elevati (→ film) o altro (→ serie).

### ducking_auto_stereo.sh - Il Minimalista
> Hai un file video con audio in stereo? Questo script lo tratta con un processing leggero e mirato.

```bash
./ducking_auto_stereo.sh "file.mkv" [bitrate]
```

Default bitrate: **384k**

### Scripts per contenuti 5.1
> Per audio surround completo con ducking avanzato

**ducking_auto_cartoni.sh** - Per Disney, Pixar, Musical
```bash
./ducking_auto_cartoni.sh "file.mkv" [bitrate]
```

**ducking_auto_film.sh** - Per Film d'Azione, Thriller, Horror  
```bash
./ducking_auto_film.sh "file.mkv" [bitrate]  
```
Default bitrate: **768k**

**ducking_auto_serie.sh** - Per Serie TV Fantasy, Sci-Fi, Commedia
```bash
./ducking_auto_serie.sh "file.mkv" [bitrate]
```
Default bitrate: **384k**

## Script Batch
> 🚀 Elaborazione di massa - "Libidine Batch Mode"

Per processare automaticamente tutti i file MKV in una cartella.

### ducking_batch_auto.sh - Il Comandante Supremo
> Batch unificato che applica ducking_auto.sh a tutti i file

```bash
./ducking_batch_auto.sh [bitrate] [preset_override]
```

**Esempio:**
```bash
# Processa tutti i file con auto-rilevamento
./ducking_batch_auto.sh

# Forza bitrate 512k su tutti i file
./ducking_batch_auto.sh 512k

# Forza preset "film" su tutti i file con bitrate 768k
./ducking_batch_auto.sh 768k film
```

### ducking_batch_serie.sh - Per Serie TV
> Batch specializzato per elaborare stagioni complete di serie TV

```bash
./ducking_batch_serie.sh [bitrate]
```

Processa tutti i file `.mkv` che non terminano con `*_serie_ducked.mkv`.

### ducking_batch_stereo.sh - Per Contenuti Stereo
> Batch ottimizzato per file audio stereo

```bash
./ducking_batch_stereo.sh [bitrate]
```

Processa tutti i file `.mkv` che non terminano con `*_stereo_ducked.mkv`.

### Gestione interruzioni
Tutti i batch supportano **Ctrl+C** per interrompere l'elaborazione e terminare pulitamente i processi ffmpeg in corso.

## Script Ausiliari
> 🔧 Strumenti specializzati

### ducking_dts_conversion.sh - L'Adattatore Universale
> Aggiunge una traccia audio DTS 5.1 "boostata" di +2dB e compatibile ovunque

**Auto-rilevamento traccia Clearvoice:**
```bash
./ducking_dts_conversion.sh "file.mkv"
```

**Conversione di una traccia specifica:**
```bash
./ducking_dts_conversion.sh "file.mkv" 0  # Usa traccia 0 (originale)
./ducking_dts_conversion.sh "file.mkv" 2  # Usa traccia 2
```

**Output:** `*_DTS.mkv` con:
- Video copiato identico
- Tutte le tracce audio originali preservate
- Nuova traccia DTS 5.1 a 768k con +2dB di volume
- Sottotitoli e metadati preservati

## La Filosofia Jedi
> 🚀 Questa è la Via

### Dall'EQ Chirurgico all'Highshelf Musicale
Dimentica filtri distruttivi: qui si usano filtri musicali trasparenti.

### Fronte Sonoro Unito
Canali frontali allineati: nessun "teleport" audio. L'effetto cinema è reale.

### Output "Remaster", non solo "HD"
Non si inventa qualità: si tira fuori il massimo dal materiale originale.

## Perché usarli
> 🧑‍🚀 Perché anche tu sei un Nerd!

- Analisi automatica loudness: è come avere **DATA** che monitora il segnale.
- Dialoghi italiani sempre intelligibili con deesser.
- Output EAC3 e DTS robustissimi con ffmpeg.
- Ducking/LFE specifico per preset.
- Ricampionamento HD con SoxR.
- Equalizzazione HD voce italiana con Aexciter.
- Elaborazione batch per stagioni complete.
- Conversione DTS per compatibilità universale.
- Tutto open source e facilmente editabile.

---

> "Per riportare equilibrio nella Forza ti servono solo un terminale bash e questi script!"
