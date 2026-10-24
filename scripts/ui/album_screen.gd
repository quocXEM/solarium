extends Control

@onready var title: Label = %Title
@onready var grid: GridContainer = %Grid
@onready var back_btn: Button = %BackBtn


func _ready() -> void:
	back_btn.pressed.connect(func() -> void:
		AudioBus.play_ui()
		SceneRouter.go("res://scenes/main_menu.tscn")
	)
	_refresh()
	Loc.language_changed.connect(func(_c): _refresh())


func _refresh() -> void:
	title.text = Loc.tr_key("album.title")
	back_btn.text = Loc.tr_key("album.back")
	for c in grid.get_children():
		c.queue_free()
	for i in SaveData.TIER_COUNT:
		var cell := VBoxContainer.new()
		cell.custom_minimum_size = Vector2(140, 160)
		cell.alignment = BoxContainer.ALIGNMENT_CENTER
		var known: bool = bool(SaveData.discovered[i])
		var orb := ColorRect.new()
		orb.custom_minimum_size = Vector2(72, 72)
		orb.color = OrbCatalog.color(i) if known else Color(0.2, 0.18, 0.22, 0.6)
		cell.add_child(orb)
		var name_l := Label.new()
		name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_l.add_theme_font_size_override("font_size", 16)
		name_l.text = OrbCatalog.name_key(i) if known else Loc.tr_key("album.locked")
		name_l.add_theme_color_override("font_color", Color(0.92, 0.88, 0.84, 0.85 if known else 0.35))
		cell.add_child(name_l)
		grid.add_child(cell)
