@tool
class_name AudioSettings
extends Resource
## Colonna sonora ed effetti sonori. Ogni campo vuoto = nessun suono in quel momento.
## I file audio (.ogg/.mp3/.wav) si trascinano dal FileSystem nei campi; per il Web usare .ogg o .mp3.
## Per far ripetere un brano attiva "Loop" nelle opzioni di import del file
## (oppure lascia attivo `loop_music` qui sotto).
##
## Varianti degli effetti: ogni effetto è già una lista di varianti (AudioStreamRandomizer).
## Aprire il campo, aggiungere i file in "Streams": a ogni riproduzione ne viene scelto uno
## a caso (Playback Mode "Random No Repeats" = mai lo stesso due volte di fila).
## "Random Pitch" (es. 1.1 = fino a ±10%) e "Random Volume Offset dB" variano ogni riproduzione.
## Lista vuota = nessun suono. Si può anche trascinare un singolo file al posto della lista.

@export_group("Colonna sonora")
## Menu principale e schermata dei livelli.
@export var menu_music: AudioStream
## Durante il livello.
@export var game_music: AudioStream
## Combattimento (parte quando la board sparisce). Vuoto = continua la musica del livello.
@export var combat_music: AudioStream
## Cut scene di fine livello (la pecora scappa). Vuoto = continua la musica del livello.
@export var cutscene_music: AudioStream
## Finestra di fine livello. Vuoto = continua la musica del livello.
@export var level_complete_music: AudioStream
## Ultimo livello: dalla cattura della pecora alla finestra di vittoria.
## Vuoto = level_complete_music.
@export var victory_music: AudioStream
@export_range(-40.0, 6.0, 0.5, "suffix:dB") var music_volume_db: float = -6.0
## Dissolvenza quando si cambia brano (0 = cambio secco).
@export_range(0.0, 5.0, 0.05, "suffix:s") var music_fade_duration: float = 0.6
## Ricomincia il brano quando finisce (utile se il file non ha il loop attivo nell'import).
@export var loop_music: bool = true

@export_group("Effetti sonori")
@export_range(-40.0, 6.0, 0.5, "suffix:dB") var sfx_volume_db: float = 0.0

@export_subgroup("Interfaccia")
## Mouse sopra un pulsante abilitato.
@export var button_hover: AudioStream
## Clic su un pulsante.
@export var button_click: AudioStream

@export_subgroup("Board")
## Inizio di ogni livello (comparsa della board).
@export var level_start: AudioStream
## A ogni passo della pedina.
@export var pawn_move: AudioStream
## La pedina sbatte contro una casella non calpestabile.
@export var pawn_bump: AudioStream
## Una riga o colonna scorre (freccia attivata).
@export var shift: AudioStream
## Chiave raccolta (la pecora si sblocca).
@export var key_pickup: AudioStream
@export var weapon_pickup: AudioStream

@export_subgroup("Combattimento")
## I combattenti entrano in scena.
@export var combat_start: AudioStream
## Il vincitore (giocatore o nemico) scatta all'attacco.
@export var attack: AudioStream
## Il nemico viene sconfitto (parte insieme al suo lampeggio).
@export var combat_win: AudioStream
## Il giocatore viene sconfitto (parte insieme al suo lampeggio).
@export var combat_lose: AudioStream

@export_subgroup("Fine livello")
## La pecora corre via (livelli intermedi).
@export var sheep_escape: AudioStream
## Il giocatore prende la pecora (ultimo livello).
@export var sheep_caught: AudioStream
## Finestra di fine livello.
@export var level_complete: AudioStream
## Finestra di vittoria dopo l'ultimo livello. Vuoto = level_complete.
@export var victory: AudioStream


func get_combat_music() -> AudioStream:
	return combat_music if combat_music != null else game_music


func get_cutscene_music() -> AudioStream:
	return cutscene_music if cutscene_music != null else game_music


func get_level_complete_music() -> AudioStream:
	return level_complete_music if level_complete_music != null else game_music


func get_victory_music() -> AudioStream:
	return victory_music if victory_music != null else get_level_complete_music()


func get_victory_sfx() -> AudioStream:
	return victory if victory != null else level_complete
