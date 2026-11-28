extends Node
## Autoload "AudioManager": suona colonna sonora ed effetti, con due interruttori indipendenti
## (musica / suoni) ricordati tra una sessione e l'altra.
## Musica ed effetti passano da due bus separati ("Music" e "SFX"): spegnere un canale
## significa silenziarne il bus, quindi i brani continuano a scorrere e riprendono al punto giusto.

signal music_enabled_changed(is_enabled: bool)
signal sfx_enabled_changed(is_enabled: bool)
## Emessi a ogni effetto suonato / brano avviato (utili per il debug dei trigger).
signal sfx_played(stream: AudioStream)
signal music_started(stream: AudioStream)

const MUSIC_BUS: StringName = &"Music"
const SFX_BUS: StringName = &"SFX"
const PREFERENCES_PATH: String = "user://audio_preferences.cfg"
const SFX_VOICES: int = 8
## Volume da cui parte/arriva la dissolvenza tra un brano e l'altro.
const SILENT_DB: float = -40.0

var music_enabled: bool = true
var sfx_enabled: bool = true

var _music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_voice: int = 0
var _music_tween: Tween
## Brano verso cui stiamo andando (può differire da quello che suona durante una dissolvenza).
var _target_music: AudioStream


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	_music_player.bus = MUSIC_BUS
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)
	for i: int in SFX_VOICES:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_sfx_players.append(player)
	_load_preferences()
	_apply_volumes()


func get_settings() -> AudioSettings:
	return RunManager.settings.get_audio()


## Avvia un brano con dissolvenza. Se è già quello in riproduzione non fa nulla;
## null = silenzio (dissolvenza in uscita).
func play_music(stream: AudioStream) -> void:
	if stream == _target_music and (_music_player.playing or stream == null):
		return
	_target_music = stream
	var fade: float = get_settings().music_fade_duration
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween()
	if _music_player.playing and fade > 0.0:
		_music_tween.tween_property(_music_player, "volume_db", SILENT_DB, fade * 0.5)
	_music_tween.tween_callback(_switch_music.bind(stream))
	if stream != null and fade > 0.0:
		_music_tween.tween_property(_music_player, "volume_db", 0.0, fade * 0.5).from(SILENT_DB)


## Suona un effetto (null = nessun suono). Più effetti possono sovrapporsi.
func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_players[_next_sfx_voice]
	_next_sfx_voice = (_next_sfx_voice + 1) % _sfx_players.size()
	player.stream = stream
	player.play()
	sfx_played.emit(stream)


func set_music_enabled(value: bool) -> void:
	music_enabled = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index(MUSIC_BUS), not value)
	_save_preferences()
	music_enabled_changed.emit(value)


func set_sfx_enabled(value: bool) -> void:
	sfx_enabled = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index(SFX_BUS), not value)
	_save_preferences()
	sfx_enabled_changed.emit(value)


func toggle_music() -> void:
	set_music_enabled(not music_enabled)


func toggle_sfx() -> void:
	set_sfx_enabled(not sfx_enabled)


func _switch_music(stream: AudioStream) -> void:
	_music_player.stop()
	_music_player.stream = stream
	_music_player.volume_db = 0.0
	if stream != null:
		_music_player.play()
	music_started.emit(stream)


func _on_music_finished() -> void:
	if get_settings().loop_music and _music_player.stream != null:
		_music_player.play()


## Il volume generale dei due canali si regola sui bus (il player resta a 0 dB per le dissolvenze).
func _apply_volumes() -> void:
	var settings: AudioSettings = get_settings()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), settings.music_volume_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), settings.sfx_volume_db)
	AudioServer.set_bus_mute(AudioServer.get_bus_index(MUSIC_BUS), not music_enabled)
	AudioServer.set_bus_mute(AudioServer.get_bus_index(SFX_BUS), not sfx_enabled)


## Crea il bus se il progetto non lo ha già (così non serve configurare l'Audio Bus Layout).
func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, &"Master")


func _load_preferences() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(PREFERENCES_PATH) != OK:
		return
	var music_value: Variant = config.get_value("audio", "music_enabled", true)
	var sfx_value: Variant = config.get_value("audio", "sfx_enabled", true)
	music_enabled = music_value == true
	sfx_enabled = sfx_value == true


func _save_preferences() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "music_enabled", music_enabled)
	config.set_value("audio", "sfx_enabled", sfx_enabled)
	var error: Error = config.save(PREFERENCES_PATH)
	if error != OK:
		push_warning("AudioManager: preferenze non salvate (errore %d)" % error)
