extends Node

var _player: AudioStreamPlayer
var _gen: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback


func _ready() -> void:
	_gen = AudioStreamGenerator.new()
	_gen.mix_rate = 22050.0
	_gen.buffer_length = 0.3
	_player = AudioStreamPlayer.new()
	_player.stream = _gen
	_player.volume_db = -9.0
	add_child(_player)
	_player.play()
	call_deferred("_bind")


func _bind() -> void:
	if _player:
		_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback


func play_drop() -> void:
	_blip(380.0, 0.04, 0.12)


func play_merge(tier: int) -> void:
	var f := 480.0 + float(tier) * 55.0
	_blip(f, 0.05, 0.16)
	_blip(f * 1.5, 0.07, 0.1)


func play_fail() -> void:
	_blip(90.0, 0.18, 0.22)


func play_ui() -> void:
	_blip(520.0, 0.03, 0.09)


func _blip(freq: float, dur: float, amp: float) -> void:
	if _playback == null:
		_bind()
	if _playback == null:
		return
	var avail := _playback.get_frames_available()
	if avail < 64:
		return
	var rate := _gen.mix_rate
	var n := mini(int(dur * rate), avail)
	for i in n:
		var t := float(i) / rate
		var env := 1.0 - t / dur
		var s := sin(TAU * freq * t) * amp * env * env
		_playback.push_frame(Vector2(s, s))
