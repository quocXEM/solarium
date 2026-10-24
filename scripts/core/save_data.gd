extends Node

const PATH := "user://solarium.save"
const TIER_COUNT := 11

var best: int = 0
var discovered: Array = []
var coach_seen: bool = false


func _ready() -> void:
	discovered.clear()
	for i in TIER_COUNT:
		discovered.append(false)
	_load()


func note_score(score: int) -> void:
	if score > best:
		best = score
	_save()


func discover(tier: int) -> void:
	if tier < 0 or tier >= TIER_COUNT:
		return
	if not bool(discovered[tier]):
		discovered[tier] = true
		_save()


func mark_coach_seen() -> void:
	coach_seen = true
	_save()


func discovered_count() -> int:
	var n := 0
	for d in discovered:
		if d:
			n += 1
	return n


func _save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_var({"best": best, "discovered": discovered, "coach_seen": coach_seen})


func _load() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var data = f.get_var()
	if data is Dictionary:
		best = int(data.get("best", 0))
		coach_seen = bool(data.get("coach_seen", false))
		var d = data.get("discovered", [])
		if d is Array:
			for i in mini(d.size(), TIER_COUNT):
				discovered[i] = bool(d[i])
