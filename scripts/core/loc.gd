extends Node

signal language_changed(code: String)

const SUPPORTED := ["en", "vi"]
var code: String = "en"

var _t := {
	"en": {
		"game.title": "Solarium",
		"game.tag": "Drop light. Merge wonder.",
		"menu.play": "Play",
		"menu.best": "Best  %d",
		"menu.album": "Discovered  %d / %d",
		"menu.leave": "Leave",
		"hud.next": "Next",
		"over.title": "Overflow",
		"over.score": "Score  %d",
		"over.best": "Best  %d",
		"over.new_best": "New best  %d",
		"over.retry": "Again",
		"over.menu": "Menu",
		"flash.merge": "Merged",
	},
	"vi": {
		"game.title": "Solarium",
		"game.tag": "Thả ánh sáng. Hợp nhất.",
		"menu.play": "Chơi",
		"menu.best": "Cao nhất  %d",
		"menu.album": "Đã thấy  %d / %d",
		"menu.leave": "Thoát",
		"hud.next": "Tiếp",
		"over.title": "Tràn",
		"over.score": "Điểm  %d",
		"over.best": "Cao nhất  %d",
		"over.new_best": "Kỷ lục mới  %d",
		"over.retry": "Lại",
		"over.menu": "Menu",
		"flash.merge": "Hợp nhất",
	},
}


func tr_key(key: String) -> String:
	var table: Dictionary = _t.get(code, _t["en"])
	if table.has(key):
		return str(table[key])
	return str(_t["en"].get(key, key))


func set_language(new_code: String) -> void:
	if new_code not in SUPPORTED:
		return
	code = new_code
	language_changed.emit(code)
