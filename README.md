# 🎛️ Autoducking 5.1 - "Tuffati nel suono" - v1.2

> “Non serve essere Tony Stark per ottimizzare il mix: questi script sono già il tuo Jarvis audio.”
> “Se vuoi sentire la voce di Bulma anche quando Vegeta urla, qui trovi gli strumenti adatti!”
> “Dialoghi italiani chiari come un cristallo di Kyber, LFE controllato come il motore a curvatura della Voyager. By Sandro "D@mocle77" Sabbioni“.

## 💡 Cosa fanno questi script - “Usa il tuo scudo di vibranio”

Tre preset Bash, ognuno calibrato per un diverso universo narrativo. Tutti sfruttano una catena di processamento avanzata per trasformare un mix standard in un'esperienza audio cinematografica su misura. Le tecnologie chiave sono:

* **Analisi Adattiva:** Lo script scansiona l'audio come un droide protocollare, misurando Loudness (LUFS), Picchi Reali (True Peak) e Dinamica (LRA) per capire con chi ha a che fare.
* **Ducking Intelligente:** Usa la traccia vocale per creare un "sidechain" che abbassa dinamicamente gli altri suoni. È come uno scudo deflettore che si attiva solo quando serve per proteggere i dialoghi.
* **EQ "Jedi":** Modella il suono con una combinazione di `de-esser` (per domare le sibilanti) e filtri `highshelf` (per dare chiarezza e aria), garantendo un risultato naturale e mai artificiale.

Questa è la via!


| Script | Missione | Output Generato | Tattiche Speciali |
| :-- | :-- | :-- | :-- |
| **`ducking_auto_cartoni.sh`** | Cartoni, Musical, Disney/Pixar | `*_cartoon_ducked.mkv` | **Voci cristalline e musicali:** EQ ottimizzato per canzoni e dialoghi veloci.<br>**Ducking delicato:** Abbassa la musica e gli effetti dolcemente per non rovinare la magia.<br>**LFE orchestrale:** Bassi ariosi che supportano l'orchestra, non la soffocano. |
| **`ducking_auto_film.sh`** | Film Azione, Thriller, Horror | `*_film_ducked.mkv` | **Dialoghi a prova di bomba:** Ducking aggressivo per far emergere la voce anche durante le esplosioni.<br>**LFE anti-detonazione:** Un high-pass dinamico doma i sub-bassi per proteggere il tuo subwoofer.<br>**Fronte sonoro IMAX:** Coerenza totale tra i canali frontali per un'immersione da cinema. |
| **`ducking_auto_serie.sh`** | Serie Fantasy, Sci-Fi, Commedia | `*_serie_ducked.mkv` | **Preset "tuttofare":** Il perfetto equilibrio tra il mondo dei film e quello dei cartoni.<br>**Ducking adattivo:** Si regola in base alla dinamica del mix: più aggressivo nelle scene d'azione, più soft nei dialoghi.<br>**Chiarezza da binge-watching:** Ottimizzato per lunghe sessioni d'ascolto senza affaticare l'orecchio. |

### In Pratica - Scenari dal Multiverso

* **Per `ducking_auto_cartoni.sh`:**
*Hiccup e Astrid parlano mentre Sdentato fa il matto: la loro voce resta sempre chiara, l'orchestra ha un LFE potente ma arioso e i surround ti portano dritto a Berk, in stile "Pixar".*
* **Per `ducking_auto_film.sh`:**
*Dialoghi italiani in primo piano con bassi profondi ma mai invadenti. Il ducking da sala IMAX garantisce che tu senta ogni parola anche se Godzilla e Kong si stanno affrontando in centro città.*
* **Per `ducking_auto_serie.sh`:**
*Daenerys e Jon discutono mentre i draghi volano e sputano fuoco ovunque. Ogni loro parola arriva nitida, come se fossi con loro a Roccia del Drago.*

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

Questo script è un **convertitore di alta qualità**. Prende un file (tipicamente uno già processato con i preset di ducking) e aggiunge una **nuova traccia audio in formato DTS 5.1 a 756k**. È l'ideale se la tua soundbar o l'impianto home cinema applicano effetti speciali (come il Neural:X) solo su tracce DTS.

**Uso:**
`./ducking_dts_conversion.sh "MioFile_serie_ducked.mkv" *(crea una nuova traccia DTS-HD partendo dalla EAC3-Ducked)`

## 🚀 La Filosofia Jedi dietro gli Script - "Questa è la Via"

Questi script non sono solo una catena di comandi, ma il risultato di una precisa filosofia audio. Se ti chiedi perché sono state fatte certe scelte (come l'abbandono degli EQ parametrici), qui trovi le risposte dal Consiglio Jedi dell'Audio.

### 1. Dall'EQ Chirurgico all'Highshelf Musicale: Abbraccia la Forza

Le versioni precedenti usavano `equalizer` parametrici per scolpire il suono. Potenti, ma rischiosi: come usare una spada laser con troppa foga, potevano suonare artificiali o "scavati".

**La nuova via:** Adesso vengono usati filtri `highshelf`. Invece di un picco innaturale, l'highshelf crea una "rampa" dolce che alza le alte frequenze in modo più musicale e trasparente. Il risultato è un suono più naturale, che migliora la chiarezza senza mai sembrare finto.

### 2. Fronte Sonoro Unito: Formazione a Testuggine!

Perché i canali frontali (Sinistro, Centro, Destro) usano lo stesso identico EQ? Per **coerenza**. Questo garantisce che un suono che si muove sullo schermo (un'astronave, un'auto, un proiettile) mantenga lo stesso "colore" timbrico per tutto il suo percorso. Si crea un fronte sonoro solido e credibile, non tre altoparlanti che fanno cose diverse.

### 3. Il De-Esser: L'Arma Segreta contro le Sibilanti

Aumentare la chiarezza con gli `highshelf` ha un effetto collaterale: può rendere le sibilanti ("s", "z", "f") un po' troppo aggressive. Qui entra in gioco il `deesser`. È un'arma di precisione che agisce come un cecchino: individua e attenua **solo** le sibilanti fastidiose, lasciando intatta tutta la brillantezza e l'aria che abbiamo aggiunto. È il tocco da professionista che rende l'ascolto piacevole anche per ore.

### 4. Audio "Remastered", non "HD": La Differenza che Conta

Dopo tutto questo lavoro, l'audio diventa "HD"? Tecnicamente, no. L'Audio ad Alta Risoluzione (Hi-Res) dipende dalla qualità della registrazione originale (es. 24-bit/96kHz).

Quello che fanno questi script è ancora più utile: eseguono un **remastering intelligente** del suono esistente. Migliorano drasticamente la **qualità percepita** bilanciando i livelli, aumentando la chiarezza e controllando i bassi. È la differenza tra un film girato nativamente in 8K e un vecchio classico restaurato a regola d'arte in 4K: il risultato finale è semplicemente... migliore.

## 🎛️ Verifica consigliata - "Radunatevi nella sala delle Necessità"

Prima di lanciare i tuoi potenti incantesimi audio/video con gli script di questo repository, è **consigliato** rimuovere contenuti inutili o indesiderati e sincerarsi che la traccia da modificare sia effettivamente la principale, effettuando una rapida verifica del file con:

- 🛠 **ffMediaMaster** (se ce l'hai, usalo come il Millenium Falcon in un inseguimento),
- 🌀 **HandBrake** (per domare i demoni multitraccia),
- 💀 o altri strumenti che non trasformano il tuo file in un *Frankenstein multimediale*.


### 🎯 Perché farlo?

Un controllo preliminare ti permette di:

- **Rimuovere tracce superflue**:
Via flussi audio dimenticati, sottotitoli in klingon, lingue perdute e commenti del regista in dialetto uzbeko.
- **Impostare correttamente la traccia audio principale**:
I preset lavorano sulla **prima traccia audio (tipicamente `0:a:0`)**. Impostare quella giusta come *default* aiuta ad evitare sorprese e rende il flusso di lavoro più lineare.

> ℹ️ **Nota bene, padawan**:
> Anche se gli script sono abbastanza robusti da gestire la maggior parte dei file, una piccola pulizia iniziale può fare la differenza tra un risultato *scolpito nel cristallo* e un *grande giove!*.
> Non è obbligatorio, ma è come mettere i calzini giusti prima di indossare l’armatura.

## 🧑‍🚀 Perché usarli - "Perchè anche tu sei Nerd!"

- Analisi loudness automatica, come avere un Data che ti monitora il segnale in tempo reale.
- Dialoghi italiani sempre chiari, anche quando il mix originale sembra uscito da una battaglia su Mustafar.
- Ducking e LFE ottimizzati per ogni scenario: nessun effetto speciale o basso fuori controllo ti farà più perdere una battuta.
- Ricampionamento soxr: la differenza tra un teletrasporto e una navetta vecchia scuola.
- Perchè gli strumenti utilizzati sono tutti open: ffmpeg, bash, AWK.

> “Per riportare equilibrio nella Forza ti servono solo un terminale bash e questi script!”

