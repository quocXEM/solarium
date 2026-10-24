extends RigidBody2D
## One luminous orb inside the glass.

signal merge_request(a: RigidBody2D, b: RigidBody2D)

var tier: int = 0
var merging: bool = false
var settled_timer: float = 0.0

@onready var visual: Node2D = $Visual
@onready var glow: Polygon2D = $Visual/Glow
@onready var body: Polygon2D = $Visual/Body
@onready var shine: Polygon2D = $Visual/Shine
@onready var collision: CollisionShape2D = $Collision


func setup(t: int) -> void:
	tier = t
	var r := OrbCatalog.radius(tier)
	var col := OrbCatalog.color(tier)
	var shape := CircleShape2D.new()
	shape.radius = r
	collision.shape = shape
	_build_polys(r, col)
	mass = 0.4 + float(tier) * 0.25
	gravity_scale = 1.0
	contact_monitor = true
	max_contacts_reported = 4
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.12
	physics_material_override.friction = 0.35
	body_entered.connect(_on_body_entered)
	SaveData.discover(tier)


func _build_polys(r: float, col: Color) -> void:
	glow.polygon = _circle(r * 1.35, 28)
	glow.color = Color(col.r, col.g, col.b, 0.22)
	body.polygon = _circle(r, 36)
	body.color = col
	shine.polygon = _circle(r * 0.35, 16)
	shine.position = Vector2(-r * 0.28, -r * 0.32)
	shine.color = Color(1, 1, 1, 0.45)


func _circle(radius: float, pts: int) -> PackedVector2Array:
	var arr := PackedVector2Array()
	for i in pts:
		var a := TAU * float(i) / float(pts)
		arr.append(Vector2(cos(a), sin(a)) * radius)
	return arr


func _on_body_entered(other: Node) -> void:
	if merging or not other is RigidBody2D:
		return
	var o := other as RigidBody2D
	if o.get_script() != get_script():
		return
	if bool(o.get("merging")):
		return
	if int(o.get("tier")) != tier:
		return
	# Only lower instance id requests merge (avoid double)
	if get_instance_id() < o.get_instance_id():
		merge_request.emit(self, o)


func mark_merging() -> void:
	merging = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
