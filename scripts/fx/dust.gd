extends Node2D

var _bits: Array = []


func _ready() -> void:
	z_index = -8
	for i in 40:
		_bits.append({
			"p": Vector2(randf() * 1080.0, randf() * 1920.0),
			"r": randf_range(1.2, 2.8),
			"a": randf_range(0.03, 0.12),
			"s": randf_range(6.0, 18.0),
			"ph": randf() * TAU,
		})


func _process(delta: float) -> void:
	for b in _bits:
		b.ph += delta * 0.5
		b.p.y -= b.s * delta * 0.12
		b.p.x += sin(b.ph) * 7.0 * delta
		if b.p.y < -20.0:
			b.p.y = 1940.0
			b.p.x = randf() * 1080.0
	queue_redraw()


func _draw() -> void:
	for b in _bits:
		draw_circle(b.p, b.r, Color(0.95, 0.9, 0.88, b.a))
