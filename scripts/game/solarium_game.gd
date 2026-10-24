extends Node2D
## Solarium — drop & merge luminous orbs in a glass vessel.

const VESSEL_L := 180.0
const VESSEL_R := 900.0
const VESSEL_TOP := 420.0
const VESSEL_BOT := 1680.0
const DROP_Y := 480.0
const DANGER_Y := 560.0
const ORB_SCENE := preload("res://scenes/orb.tscn")

@onready var world: Node2D = $World
@onready var score_l: Label = $UI/Score
@onready var best_l: Label = $UI/Best
@onready var next_l: Label = $UI/NextLabel
@onready var flash_l: Label = $UI/Flash
@onready var over: PanelContainer = $UI/Over
@onready var over_title: Label = $UI/Over/VBox/Title
@onready var over_score: Label = $UI/Over/VBox/Score
@onready var over_best: Label = $UI/Over/VBox/Best
@onready var btn_retry: Button = $UI/Over/VBox/Retry
@onready var btn_menu: Button = $UI/Over/VBox/Menu
@onready var dim: ColorRect = $UI/Dim
@onready var next_preview: Node2D = $UI/NextPreview
@onready var aim_ghost: Node2D = $AimGhost

var _score := 0
var _alive := true
var _can_drop := true
var _current_tier := 0
var _next_tier := 0
var _holding: RigidBody2D = null
var _aim_x := 540.0
var _new_best := false
var _danger_t := 0.0
var _drop_cooldown := 0.0
var _max_seen := 0


func _ready() -> void:
	btn_retry.pressed.connect(_restart)
	btn_menu.pressed.connect(func() -> void:
		AudioBus.play_ui()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	over.visible = false
	dim.visible = false
	flash_l.modulate.a = 0.0
	_build_vessel()
	_refresh_loc()
	Loc.language_changed.connect(func(_c): _refresh_loc())
	_start()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.4)


func _refresh_loc() -> void:
	next_l.text = Loc.tr_key("hud.next")
	over_title.text = Loc.tr_key("over.title")
	btn_retry.text = Loc.tr_key("over.retry")
	btn_menu.text = Loc.tr_key("over.menu")
	_paint_hud()


func _build_vessel() -> void:
	# Floor + walls as StaticBody2D
	_add_wall(Vector2(540, VESSEL_BOT + 20), Vector2(760, 40))
	_add_wall(Vector2(VESSEL_L - 20, 1100), Vector2(40, 1200))
	_add_wall(Vector2(VESSEL_R + 20, 1100), Vector2(40, 1200))
	# Soft glass outline (visual only)
	var glass := Line2D.new()
	glass.width = 3.0
	glass.default_color = Color(0.85, 0.82, 0.9, 0.35)
	glass.z_index = 2
	glass.add_point(Vector2(VESSEL_L, VESSEL_TOP))
	glass.add_point(Vector2(VESSEL_L, VESSEL_BOT))
	glass.add_point(Vector2(VESSEL_R, VESSEL_BOT))
	glass.add_point(Vector2(VESSEL_R, VESSEL_TOP))
	world.add_child(glass)
	# Danger line
	var danger := Line2D.new()
	danger.name = "Danger"
	danger.width = 2.0
	danger.default_color = Color(0.95, 0.55, 0.6, 0.35)
	danger.z_index = 3
	danger.add_point(Vector2(VESSEL_L + 8, DANGER_Y))
	danger.add_point(Vector2(VESSEL_R - 8, DANGER_Y))
	world.add_child(danger)


func _add_wall(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	world.add_child(body)


func _start() -> void:
	for c in world.get_children():
		if c is RigidBody2D:
			c.queue_free()
	_score = 0
	_alive = true
	_can_drop = true
	_new_best = false
	_danger_t = 0.0
	_drop_cooldown = 0.0
	_max_seen = 0
	_current_tier = OrbCatalog.random_drop_tier(2)
	_next_tier = OrbCatalog.random_drop_tier(2)
	_aim_x = 540.0
	over.visible = false
	dim.visible = false
	_spawn_holding()
	_paint_hud()
	_paint_next()


func _restart() -> void:
	AudioBus.play_ui()
	_start()


func _paint_hud() -> void:
	score_l.text = str(_score)
	best_l.text = Loc.tr_key("menu.best") % SaveData.best
	over_score.text = Loc.tr_key("over.score") % _score
	over_best.text = Loc.tr_key("over.new_best") % SaveData.best if _new_best else Loc.tr_key("over.best") % SaveData.best


func _paint_next() -> void:
	for c in next_preview.get_children():
		c.queue_free()
	var r := OrbCatalog.radius(_next_tier) * 0.55
	var col := OrbCatalog.color(_next_tier)
	var p := Polygon2D.new()
	var arr := PackedVector2Array()
	for i in 24:
		var a := TAU * float(i) / 24.0
		arr.append(Vector2(cos(a), sin(a)) * r)
	p.polygon = arr
	p.color = col
	next_preview.add_child(p)


func _spawn_holding() -> void:
	if _holding and is_instance_valid(_holding):
		_holding.queue_free()
	_holding = ORB_SCENE.instantiate()
	world.add_child(_holding)
	_holding.setup(_current_tier)
	_holding.freeze = true
	_holding.gravity_scale = 0.0
	_holding.collision_layer = 0
	_holding.collision_mask = 0
	_holding.global_position = Vector2(_aim_x, DROP_Y)
	_holding.merge_request.connect(_on_merge)
	_max_seen = maxi(_max_seen, _current_tier)
	_update_aim_ghost()


func _update_aim_ghost() -> void:
	for c in aim_ghost.get_children():
		c.queue_free()
	var r := OrbCatalog.radius(_current_tier)
	var col := OrbCatalog.color(_current_tier)
	col.a = 0.15
	var p := Polygon2D.new()
	var arr := PackedVector2Array()
	for i in 28:
		var a := TAU * float(i) / 28.0
		arr.append(Vector2(cos(a), sin(a)) * r)
	p.polygon = arr
	p.color = col
	aim_ghost.add_child(p)
	aim_ghost.position = Vector2(_aim_x, DROP_Y)


func _clamp_aim(x: float) -> float:
	var r := OrbCatalog.radius(_current_tier)
	return clampf(x, VESSEL_L + r + 4.0, VESSEL_R - r - 4.0)


func _process(delta: float) -> void:
	if not _alive:
		return
	if _drop_cooldown > 0.0:
		_drop_cooldown -= delta
	if _holding and is_instance_valid(_holding) and _holding.freeze:
		_aim_x = _clamp_aim(_aim_x)
		_holding.global_position = Vector2(_aim_x, DROP_Y)
		aim_ghost.position = Vector2(_aim_x, DROP_Y)
	_check_danger(delta)


func _check_danger(delta: float) -> void:
	var threat := false
	for c in world.get_children():
		if c is RigidBody2D and not c.freeze and not c.get("merging"):
			if c.global_position.y < DANGER_Y and c.linear_velocity.length() < 40.0:
				threat = true
				break
	if threat:
		_danger_t += delta
		var danger: Line2D = world.get_node_or_null("Danger")
		if danger:
			danger.default_color = Color(0.95, 0.4, 0.45, 0.35 + 0.4 * absf(sin(_danger_t * 8.0)))
		if _danger_t > 1.4:
			_game_over()
	else:
		_danger_t = 0.0
		var danger2: Line2D = world.get_node_or_null("Danger")
		if danger2:
			danger2.default_color = Color(0.95, 0.55, 0.6, 0.35)


func _unhandled_input(event: InputEvent) -> void:
	if not _alive:
		return
	if event is InputEventScreenTouch:
		_aim_x = _clamp_aim(event.position.x)
		if event.pressed == false and _can_drop:
			_drop()
	elif event is InputEventScreenDrag:
		_aim_x = _clamp_aim(event.position.x)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_aim_x = _clamp_aim(event.position.x)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_aim_x = _clamp_aim(event.position.x)
		if not event.pressed and _can_drop:
			_drop()


func _drop() -> void:
	if not _alive or not _can_drop or _drop_cooldown > 0.0:
		return
	if _holding == null or not is_instance_valid(_holding):
		return
	_can_drop = false
	_holding.freeze = false
	_holding.gravity_scale = 1.0
	_holding.collision_layer = 1
	_holding.collision_mask = 1
	_holding.global_position = Vector2(_aim_x, DROP_Y)
	AudioBus.play_drop()
	if DisplayServer.is_touchscreen_available():
		Input.vibrate_handheld(10)
	_holding = null
	aim_ghost.visible = false
	_drop_cooldown = 0.45
	await get_tree().create_timer(0.45).timeout
	if not _alive:
		return
	_current_tier = _next_tier
	_next_tier = OrbCatalog.random_drop_tier(maxi(_max_seen, 2))
	_paint_next()
	aim_ghost.visible = true
	_spawn_holding()
	_can_drop = true


func _on_merge(a: RigidBody2D, b: RigidBody2D) -> void:
	# Defer out of physics flush
	call_deferred("_do_merge", a, b)


func _do_merge(a: RigidBody2D, b: RigidBody2D) -> void:
	if not _alive:
		return
	if not is_instance_valid(a) or not is_instance_valid(b):
		return
	if a.get("merging") or b.get("merging"):
		return
	var tier: int = int(a.get("tier"))
	a.mark_merging()
	b.mark_merging()
	var mid: Vector2 = (a.global_position + b.global_position) * 0.5
	_burst(mid, OrbCatalog.color(tier))
	a.queue_free()
	b.queue_free()
	var nt := tier + 1
	if nt >= OrbCatalog.tier_count():
		nt = OrbCatalog.tier_count() - 1
	var neu: RigidBody2D = ORB_SCENE.instantiate()
	world.add_child(neu)
	neu.global_position = mid
	neu.setup(nt)
	neu.merge_request.connect(_on_merge)
	_max_seen = maxi(_max_seen, nt)
	var pts := OrbCatalog.score(nt)
	_score += pts
	_paint_hud()
	_pop_score()
	_float_pts(mid, pts)
	AudioBus.play_merge(nt)
	if DisplayServer.is_touchscreen_available():
		Input.vibrate_handheld(18)
	flash_l.text = OrbCatalog.name_key(nt)
	flash_l.modulate = OrbCatalog.color(nt)
	create_tween().tween_property(flash_l, "modulate:a", 0.0, 0.7).from(1.0)


func _burst(at: Vector2, col: Color) -> void:
	for i in 12:
		var p := Polygon2D.new()
		var r := 3.0 + randf() * 5.0
		var arr := PackedVector2Array([Vector2(-r, -r), Vector2(r, -r), Vector2(r, r), Vector2(-r, r)])
		p.polygon = arr
		p.color = col
		p.global_position = at
		world.add_child(p)
		var dir := Vector2(randf_range(-1, 1), randf_range(-1, 0.2)).normalized() * randf_range(40, 140)
		var tw := create_tween()
		tw.tween_property(p, "position", p.position + dir, 0.4)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.4)
		tw.tween_callback(p.queue_free)


func _float_pts(at: Vector2, pts: int) -> void:
	var lab := Label.new()
	lab.text = "+%d" % pts
	lab.add_theme_font_size_override("font_size", 28)
	lab.add_theme_color_override("font_color", Color(0.96, 0.92, 0.85, 1))
	lab.global_position = at + Vector2(-30, -40)
	$UI.add_child(lab)
	var tw := create_tween()
	tw.tween_property(lab, "position:y", lab.position.y - 70.0, 0.6)
	tw.parallel().tween_property(lab, "modulate:a", 0.0, 0.6)
	tw.tween_callback(lab.queue_free)


func _pop_score() -> void:
	score_l.pivot_offset = score_l.size * 0.5
	score_l.scale = Vector2(1.12, 1.12)
	create_tween().tween_property(score_l, "scale", Vector2.ONE, 0.18)


func _game_over() -> void:
	if not _alive:
		return
	_alive = false
	_can_drop = false
	AudioBus.play_fail()
	_new_best = _score > SaveData.best
	SaveData.note_score(_score)
	_paint_hud()
	dim.visible = true
	dim.modulate.a = 0.0
	over.visible = true
	over.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(dim, "modulate:a", 1.0, 0.3)
	tw.parallel().tween_property(over, "modulate:a", 1.0, 0.35)
