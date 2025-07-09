# 🎛️ Autoducking 5.1 - "Tuffati nel suono" - v1.0

> “Non serve essere Tony Stark per ottimizzare il mix: questi script sono già il tuo Jarvis audio.”
> “Se vuoi sentire la voce di Bulma anche quando il Vegeta urla, qui trovi gli strumenti adatti!”
> “Dialoghi italiani chiari come un cristallo di Kyber, LFE controllato come il motore a curvatura della Voyager.”

## 💡 Cosa fanno questi script - “Usa tuo scudo di vibranio”

Tre preset Bash, ognuno pensato per un diverso scenario multicanale 5.1.
Tutti sfruttano analisi loudness avanzata (LUFS, True Peak, LRA), ducking intelligente e filtri di equalizzazione specifici per la lingua italiana, con un occhio di riguardo a LFE e surround. Il tutto, ricampionato via soxr per una qualità da laboratorio SHIELD...questa è la via!


| Script | Target consigliato | Output generato | Focus tecnico principale |
| :-- | :-- | :-- | :-- |
| `ducking_auto_cartoni.sh` | Cartoni, Musical, Disney/Pixar | `*_cartoon_ducked.mkv` | EQ voci cantate, ducking soft, LFE orchestrale arioso |
*Hiccup e Astrid parlano sopra Sdentato che fa il matto: voce sempre chiara, LFE orchestrale, surround “alla Pixar”*.
| `ducking_auto_film.sh` | Film Azione, Thriller, Horror | `*_film_ducked.mkv` | EQ voce italiana, ducking dinamico, LFE anti-scoppio |
*Dialoghi italiani in primo piano, bassi profondi ma mai invadenti, ducking da sala IMAX anche se Godzilla e Kong si affrontano.*
| `ducking_auto_serie.sh` | Serie Fantasy, Sci-Fi, Commedia | `*_serie_ducked.mkv` | EQ voce italiana, ducking adattivo, LFE cinematografico |
*Daenerys e Jon discutono, draghi volano e fuoco ovunque, ma ogni parola arriva nitida come se fossi a Roccia del Drago.*

## ⚙️ Requisiti - "Armati come un Mandaloriano"

- **Bash** (Linux/macOS/WSL/Git Bash)
- **FFmpeg** (>= 7.x, con E-AC3, SoxR, Filtercomplex, Audiograph)


## 📥 Installazione in 30 secondi - “Che la Forza sia con te”

```bash
git clone https://github.com/Damocle77/Autoduking_5.1.git
cd autoducking_5.1
chmod +x ducking_auto_*.sh
```

```bash
winget install ffmpeg -e && winget install Git.Git -e
sudo apt install ffmpeg
sudo dnf install ffmpeg
brew install ffmpeg

NB. verificare che ffmpeg sia incluso nell'ambiente di sistema (ENV)
```
## 🛠️ Script Ausiliari - “I tuoi droidi da battaglia”

Oltre ai processori principali, il repository include due utility per automatizzare e finalizzare il tuo lavoro.

### ducking_serie_batch.sh
> "Attiva il protocollo 'Binge-Watching'. Jarvis, processa l'intera stagione mentre dormo."

Questo script è un **automatizzatore**. Lancialo in una cartella piena di episodi di una serie TV, e lui penserà a processarli uno dopo l'altro usando `ducking_auto_serie.sh`. Perfetto per preparare un'intera stagione in una sola mossa.

**Uso:**
`./ducking_serie_batch.sh *(Puoi anche impostare un bitrate custom per tutti i files)`

### ducking_dts_conversion.sh
> "L'adattatore universale della Flotta Stellare. Aggiunge una porta DTS a qualsiasi cosa."

Questo script è un **convertitore di alta qualità**. Prende un file (tipicamente uno già processato con i preset di ducking) e aggiunge una **nuova traccia audio in formato DTS 5.1 a 1536k**. È l'ideale se la tua soundbar o il tuo impianto home cinema applicano effetti speciali (come il Neural:X) solo su tracce DTS.

**Uso:**
`./ducking_dts_conversion.sh "MioFile_serie_ducked.mkv" *(crea una nuova traccia DTS-HD partendo dalla EAC3-Ducked)`

## 🚀 Come funzionano - “Modula la frequenza del phaser"

### Equalizzazione voce italiana

- **Filtro centrale** ottimizzato tra 200 e 3500Hz, con highpass tra 60 e 80Hz: così ogni “Che c’è?” si sente anche se Godzilla pesta i piedi.
- Il boost sulle medie frequenze è adattivo: nei mix compressi (cartoni moderni, action rumorosi) la voce viene spinta in avanti, nei musical classici si preserva la dinamica naturale.
- L’equalizzazione è pensata per il timbro italiano: niente voci nasali o sibilanti, solo chiarezza e presenza, come se stessi ascoltando un doppiaggio da Oscar.


### Ducking Dinamico in tempo reale

- **Sidechain**: quando la voce parla, effetti e LFE si abbassano in tempo reale, stile “scudo deflettore” di Star Trek che si attiva solo quando serve.
- I parametri di attack/release sono adattivi: nei musical e cartoni il ducking è più morbido, nei film e serie più aggressivi è più deciso, così il dialogo resta sempre in primo piano senza snaturare il mix.


### LFE arioso, controllato ed equalizzato

- **LFE** mai “scoppiettante”: taglio passa-alto (30-50Hz), lowpass (100-120Hz), equalizzazione selettiva per evitare saturazioni e distorsioni anche su subwoofer modesti.
- Nei musical, il LFE viene reso più “arioso” per non coprire archi e voci; nei film d’azione, la protezione anti-scoppio entra in gioco come un campo di forza di Wakanda.
- Il boost sui bassi viene ridotto automaticamente in presenza di mix troppo dinamici o con picchi elevati.


### Ricampionamento SoxR

- Tutto l’audio viene passato attraverso **SoxR** con precisione 28 bit, cutoff 0.95, filtro chebyshev: aliasing sotto controllo, qualità da sala IMAX anche se usi un AVR entry-level.
- Il resampling soxr è la “pietra filosofale” del processing: mantiene intatti i dettagli, elimina artefatti digitali, e garantisce compatibilità perfetta con qualsiasi player.

## 🎛️ Verifica consigliata - "Radunatevi nella sala delle Necessità"

Prima di lanciare i tuoi potenti incantesimi audio/video con gli script di questo repository, è **consigliato** rimuovere contenuti inutili o indesiderati e sincerarsi che la traccia da modificare sia effettivaemnte la principale, effettuando una rapida verifica del file con:

- 🛠 **ffMediaMaster** (se ce l'hai, usalo come il Millenium Falcon in un inseguimento),
- 🌀 **HandBrake** (per domare i demoni multitraccia),
- 💀 o altri strumenti che non trasformano il tuo file in un *Frankenstein multimediale*.

### 🎯 Perché farlo?

Un controllo preliminare ti permette di:

- **Rimuovere tracce superflue**:  
  Via flussi audio dimenticati, sottotitoli in klingon, lingue perdute e commenti del regista in dialetto uzbeko.
  
- **Impostare correttamente la traccia audio principale**:  
  I preset lavorano sulla **prima traccia audio (tipicamente `0:a:0`)**. Impostare quella giusta come *default* aiuta ad evitare sorprese e rende il flusso di lavoro più lineare.

---

> ℹ️ **Nota bene, padawan**:  
> Anche se gli script sono abbastanza robusti da gestire la maggior parte dei file, una piccola pulizia iniziale può fare la differenza tra un risultato *scolpito nel cristallo* e un *grande giove!*.  
> Non è obbligatorio, ma è come mettere i calzini giusti prima di indossare l’armatura.

---

## 🧑‍🚀 Perché usarli - "Perchè sei un Nerd!"

- Analisi loudness automatica, come avere un Data che ti monitora il segnale in tempo reale.
- Dialoghi italiani sempre chiari, anche quando il mix originale sembra uscito da una battaglia su Mustafar.
- Ducking e LFE ottimizzati per ogni scenario: nessun effetto speciale o basso fuori controllo ti farà più perdere una battuta.
- Ricampionamento soxr: la differenza tra un teletrasporto e una navetta vecchia scuola.

>  “Per riportare equilibrio nella Forza ti servono solo un terminale e questi script.”
