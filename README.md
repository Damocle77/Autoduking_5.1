# 🎛️ autoducking

> “Non serve essere Tony Stark per ottimizzare il mix: questi script sono il tuo Jarvis audio.”
> “Se vuoi sentire la voce di Eleven anche quando il Demogorgone urla, qui trovi gli strumenti.”
> “Dialoghi italiani chiari come un cristallo di Kyber, LFE controllato come il motore a curvatura della Voyager.”

## 💡 Cosa fanno questi script

Tre preset Bash, ognuno pensato per un diverso scenario multicanale 5.1.
Tutti sfruttano analisi loudness avanzata (LUFS, True Peak, LRA), ducking intelligente e filtri di equalizzazione specifici per la lingua italiana, con un occhio di riguardo a LFE e surround. Il tutto, ricampionato via soxr per una qualità da laboratorio SHIELD.


| Script | Target consigliato | Output generato | Focus tecnico principale |
| :-- | :-- | :-- | :-- |
| `ducking_auto_cartoni.sh` | Cartoni, musical, Disney/Pixar | `*_cartoon_ducked.mkv` | EQ voci cantate, ducking soft, LFE orchestrale arioso |
| `ducking_auto_film.sh` | Film d’azione, thriller, horror | `*_film_ducked.mkv` | EQ voce italiana, ducking dinamico, LFE anti-scoppio |
| `ducking_auto_serie.sh` | Serie fantasy, sci-fi, horror | `*_serie_ducked.mkv` | EQ voce italiana, ducking adattivo, LFE cinematografico |

## ⚙️ Requisiti

- **Bash** (Linux/macOS/WSL/Git Bash)
- **FFmpeg** (>= 7.x, con E-AC3, SoxR, Filtercomplex, Audiograph)


## 📥 Installazione

```bash
git clone https://github.com/Damocle77/Autoduking_5.1.git
cd autoducking_5.1
chmod +x ducking_auto_*.sh
```

Su Windows:

```bash
winget install ffmpeg -e && install gitbash -e
```


## 🚀 Come funzionano

### Equalizzazione Voce Italiana

- **Filtro centrale** ottimizzato tra 200 e 3500Hz, con highpass tra 60 e 80Hz: così ogni “Che c’è?” si sente anche se Godzilla pesta i piedi.
- Il boost sulle medie frequenze è adattivo: nei mix compressi (cartoni moderni, action rumorosi) la voce viene spinta in avanti, nei musical classici si preserva la dinamica naturale[^1][^2][^3].
- L’equalizzazione è pensata per il timbro italiano: niente voci nasali o sibilanti, solo chiarezza e presenza, come se stessi ascoltando un doppiaggio da Oscar.


### Ducking Dinamico

- **Sidechain**: quando la voce parla, effetti e LFE si abbassano in tempo reale, stile “scudo deflettore” di Star Trek che si attiva solo quando serve[^1][^2][^3].
- I parametri di attack/release sono adattivi: nei musical e cartoni il ducking è più morbido, nei film e serie più aggressivi è più deciso, così il dialogo resta sempre in primo piano senza snaturare il mix.


### LFE Arioso, Controllato ed Equalizzato

- **LFE** mai “scoppiettante”: taglio passa-alto (30-50Hz), lowpass (100-120Hz), equalizzazione selettiva per evitare saturazioni e distorsioni anche su subwoofer modesti.
- Nei musical, il LFE viene reso più “arioso” per non coprire archi e voci; nei film d’azione, la protezione anti-scoppio entra in gioco come un campo di forza di Wakanda[^1][^2][^3].
- Il boost sui bassi viene ridotto automaticamente in presenza di mix troppo dinamici o con picchi elevati.


### Ricampionamento soxr

- Tutto l’audio viene passato attraverso **soxr** con precisione 28 bit, cutoff 0.95, filtro chebyshev: aliasing sotto controllo, qualità da sala IMAX anche se ascolti su una soundbar entry-level[^1][^2][^3].
- Il resampling soxr è la “pietra filosofale” del processing: mantiene intatti i dettagli, elimina artefatti digitali, e garantisce compatibilità perfetta con qualsiasi player.


## 🧑‍🚀 Perché usarli

- Analisi loudness automatica, come avere un Data che ti monitora il segnale in tempo reale.
- Dialoghi italiani sempre chiari, anche quando il mix originale sembra uscito da una battaglia su Mustafar.
- Ducking e LFE ottimizzati per ogni scenario: nessun effetto speciale o basso fuori controllo ti farà più perdere una battuta.
- Ricampionamento soxr: la differenza tra un teletrasporto e una navetta vecchia scuola.

> “Non serve la Forza. Serve solo un terminale e questi script.”
