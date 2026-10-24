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
		"menu.album_btn": "Album",
		"menu.settings": "Settings",
		"menu.leave": "Leave",
		"hud.next": "Next",
		"hud.hint": "Drag to aim · release to drop",
		"hud.pause": "Paused",
		"hud.resume": "Resume",
		"over.title": "Overflow",
		"over.score": "Score  %d",
		"over.best": "Best  %d",
		"over.new_best": "New best  %d",
		"over.retry": "Again",
		"over.menu": "Menu",
		"coach.title": "How to play",
		"coach.1": "Drag to aim. Release to drop light.",
		"coach.2": "Same orbs touch → they merge brighter.",
		"coach.3": "Stay under the line. Overflow ends the run.",
		"coach.ok": "Begin",
		"settings.title": "Settings",
		"settings.language": "Language",
		"settings.mute": "Mute",
		"settings.back": "Back",
		"album.title": "Album",
		"album.locked": "?",
		"album.back": "Back",
	},
	"vi": {
		"game.title": "Solarium",
		"game.tag": "Thả ánh sáng. Hợp nhất.",
		"menu.play": "Chơi",
		"menu.best": "Cao nhất  %d",
		"menu.album": "Đã thấy  %d / %d",
		"menu.album_btn": "Album",
		"menu.settings": "Cài đặt",
		"menu.leave": "Thoát",
		"hud.next": "Tiếp",
		"hud.hint": "Kéo nhằm · thả để rơi",
		"hud.pause": "Tạm dừng",
		"hud.resume": "Tiếp",
		"over.title": "Tràn",
		"over.score": "Điểm  %d",
		"over.best": "Cao nhất  %d",
		"over.new_best": "Kỷ lục mới  %d",
		"over.retry": "Lại",
		"over.menu": "Menu",
		"coach.title": "Cách chơi",
		"coach.1": "Kéo để nhắm. Thả để rơi ánh sáng.",
		"coach.2": "Cùng loại chạm nhau → hợp nhất sáng hơn.",
		"coach.3": "Đừng vượt vạch. Tràn là hết ván.",
		"coach.ok": "Bắt đầu",
		"settings.title": "Cài đặt",
		"settings.language": "Ngôn ngữ",
		"settings.mute": "Tắt tiếng",
		"settings.back": "Quay lại",
		"album.title": "Album",
		"album.locked": "?",
		"album.back": "Quay lại",
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
