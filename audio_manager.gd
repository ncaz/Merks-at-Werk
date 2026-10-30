extends Node

const BASE_VOLUME_DB = 0.0
const MIN_VOLUME_DB = -80.0

var bgm_player: AudioStreamPlayer
var fade_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Master"

func play(stream: AudioStream, force_reset: bool = false):
	if force_reset or (bgm_player.stream == stream and bgm_player.playing):
		return

	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	
	bgm_player.volume_db = BASE_VOLUME_DB
	bgm_player.stream = stream
	bgm_player.play()

func fade_out(duration: float = 1.5):
	if not bgm_player.playing:
		return
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(bgm_player, "volume_db", MIN_VOLUME_DB, duration).set_trans(Tween.TRANS_LINEAR)
	
	fade_tween.tween_callback(stop)

func stop(fade_out: bool = false):
	bgm_player.stop()
	bgm_player.volume_db = BASE_VOLUME_DB
