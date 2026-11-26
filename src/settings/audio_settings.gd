@tool
class_name AudioSettings
extends Resource
## Colonna sonora ed effetti sonori. Ogni campo vuoto = nessun suono in quel momento.
## I file audio (.ogg/.mp3/.wav) si trascinano dal FileSystem nei campi.
## Per far ripetere un brano attiva "Loop" nelle opzioni di import del file
## (oppure lascia attivo `loop_music` qui sotto).

@export_group("Colonna sonora")
## Menu principale e schermata dei livelli.
@export var menu_music: AudioStream
## Durante il livello.
@export var game_music: AudioStream
## Schermata di combattimento. Vuoto = continua la musica del livello.
@export var combat_music: AudioStream
## Finestra di fine livello. Vuoto = continua la musica del livello.
@export var level_complete_music: AudioStream
@export_range(-40.0, 6.0, 0.5, "suffix:dB") var music_volume_db: float = -6.0
## Dissolvenza quando si cambia brano (0 = cambio secco).
@export_range(0.0, 5.0, 0.05, "suffix:s") var music_fade_duration: float = 0.6
## Ricomincia il brano quando finisce (utile se il file non ha il loop attivo nell'import).
@export var loop_music: bool = true

@export_group("Effetti sonori")
@export_range(-40.0, 6.0, 0.5, "suffix:dB") var sfx_volume_db: float = 0.0
@export var button_hover: AudioStream
@export var button_click: AudioStream
@export var pawn_move: AudioStream
## La pedina sbatte contro una casella non calpestabile.
@export var pawn_bump: AudioStream
## Una riga o colonna scorre (freccia attivata).
@export var shift: AudioStream
@export var key_pickup: AudioStream
@export var weapon_pickup: AudioStream
@export var combat_win: AudioStream
@export var combat_lose: AudioStream
@export var level_complete: AudioStream


func get_combat_music() -> AudioStream:
	return combat_music if combat_music != null else game_music


func get_level_complete_music() -> AudioStream:
	return level_complete_music if level_complete_music != null else game_music
