extends Node

signal changed

const PATH := "user://solarium_settings.save"

var muted: bool = false
var volume: float = 0.85


func _ready() -> void:
	_load()
	_apply()


func set_muted(v: bool) -> void:
	muted = v
	_apply()
	_save()
	changed.emit()


func set_volume(v: float) -> void:
	volume = clampf(v, 0.0, 1.0)
	_apply()
	_save()
	changed.emit()


func _apply() -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_mute(bus, muted)
		AudioServer.set_bus_volume_db(bus, linear_to_db(volume if not muted else 0.0001))


func _save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_var({"muted": muted, "volume": volume, "lang": Loc.code})


func _load() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var data = f.get_var()
	if data is Dictionary:
		muted = bool(data.get("muted", false))
		volume = float(data.get("volume", 0.85))
		var lang: String = str(data.get("lang", "en"))
		if lang in Loc.SUPPORTED:
			Loc.code = lang
