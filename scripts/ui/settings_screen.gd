extends Control

@onready var title: Label = %Title
@onready var lang_l: Label = %LangLabel
@onready var lang_btn: Button = %LangBtn
@onready var mute_btn: Button = %MuteBtn
@onready var back_btn: Button = %BackBtn


func _ready() -> void:
	lang_btn.pressed.connect(_toggle_lang)
	mute_btn.pressed.connect(_toggle_mute)
	back_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		SceneRouter.go("res://scenes/main_menu.tscn")
	)
	_refresh()
	Loc.language_changed.connect(func(_c): _refresh())
	Settings.changed.connect(_refresh)


func _refresh() -> void:
	title.text = Loc.tr_key("settings.title")
	lang_l.text = Loc.tr_key("settings.language")
	lang_btn.text = Loc.code.to_upper()
	mute_btn.text = Loc.tr_key("settings.mute") + ("  ·  ON" if Settings.muted else "  ·  OFF")
	back_btn.text = Loc.tr_key("settings.back")


func _toggle_lang() -> void:
	AudioBus.play_ui()
	Loc.set_language("vi" if Loc.code == "en" else "en")
	Settings._save()


func _toggle_mute() -> void:
	AudioBus.play_ui()
	Settings.set_muted(not Settings.muted)
