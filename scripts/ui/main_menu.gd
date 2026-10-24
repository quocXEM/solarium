extends Control

@onready var title: Label = %Title
@onready var tag: Label = %Tag
@onready var best: Label = %Best
@onready var album: Label = %Album
@onready var play_btn: Button = %PlayBtn
@onready var leave_btn: Button = %LeaveBtn
@onready var lang_btn: Button = %LangBtn
@onready var orbs: Node2D = %OrbDecor


func _ready() -> void:
	play_btn.pressed.connect(_play)
	leave_btn.pressed.connect(func() -> void: get_tree().quit())
	lang_btn.pressed.connect(_toggle_lang)
	_refresh()
	Loc.language_changed.connect(func(_c): _refresh())
	_spawn_decor()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)


func _spawn_decor() -> void:
	var vs := get_viewport_rect().size
	orbs.position = Vector2(vs.x * 0.5, vs.y * 0.28)
	for i in 5:
		var t := i + 1
		var p := Polygon2D.new()
		var r := OrbCatalog.radius(t) * 0.45
		var arr := PackedVector2Array()
		for k in 28:
			var a := TAU * float(k) / 28.0
			arr.append(Vector2(cos(a), sin(a)) * r)
		p.polygon = arr
		p.color = OrbCatalog.color(t)
		p.position = Vector2(sin(float(i) * 1.1) * 70.0, cos(float(i) * 0.9) * 40.0)
		orbs.add_child(p)


func _process(delta: float) -> void:
	orbs.rotation += delta * 0.12


func _refresh() -> void:
	title.text = Loc.tr_key("game.title")
	tag.text = Loc.tr_key("game.tag")
	best.text = Loc.tr_key("menu.best") % SaveData.best
	album.text = Loc.tr_key("menu.album") % [SaveData.discovered_count(), SaveData.TIER_COUNT]
	play_btn.text = Loc.tr_key("menu.play")
	leave_btn.text = Loc.tr_key("menu.leave")
	lang_btn.text = Loc.code.to_upper()


func _play() -> void:
	AudioBus.play_ui()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _toggle_lang() -> void:
	AudioBus.play_ui()
	Loc.set_language("vi" if Loc.code == "en" else "en")
