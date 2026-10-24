extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("SMOKE: start")
	var scr = load("res://scripts/game/solarium_game.gd")
	if scr == null:
		push_error("SMOKE FAIL parse")
		quit(1)
		return
	print("SMOKE: parsed")
	change_scene_to_file("res://scenes/main_menu.tscn")
	await create_timer(0.3).timeout
	change_scene_to_file("res://scenes/game.tscn")
	await create_timer(0.6).timeout
	var root := current_scene
	if root == null or not root.has_method("_drop"):
		push_error("SMOKE FAIL game")
		quit(1)
		return
	# Force two same-tier orbs and merge
	var orb_sc = load("res://scenes/orb.tscn")
	var a = orb_sc.instantiate()
	var b = orb_sc.instantiate()
	root.get_node("World").add_child(a)
	root.get_node("World").add_child(b)
	a.setup(1)
	b.setup(1)
	a.global_position = Vector2(500, 1200)
	b.global_position = Vector2(560, 1200)
	a.merge_request.connect(root._on_merge)
	b.merge_request.connect(root._on_merge)
	a.freeze = false
	b.freeze = false
	await create_timer(0.8).timeout
	print("SMOKE: score ", root._score)
	print("SMOKE: PASS")
	quit(0)
