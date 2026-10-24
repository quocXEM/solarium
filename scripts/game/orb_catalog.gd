class_name OrbCatalog
## Tiered luminous orbs — size + color + score.


static func tier_count() -> int:
	return 11


static func radius(tier: int) -> float:
	var base := 26.0
	return base + float(tier) * 11.5


static func score(tier: int) -> int:
	return int(pow(2.0, float(tier))) * 10


static func color(tier: int) -> Color:
	var palette: Array[Color] = [
		Color(0.75, 0.88, 0.95), # dew
		Color(0.7, 0.82, 0.98),
		Color(0.78, 0.72, 0.95),
		Color(0.92, 0.74, 0.88),
		Color(0.95, 0.78, 0.7),
		Color(0.95, 0.86, 0.62),
		Color(0.85, 0.92, 0.7),
		Color(0.7, 0.9, 0.85),
		Color(0.68, 0.78, 0.98),
		Color(0.9, 0.72, 0.95),
		Color(0.98, 0.9, 0.72), # sun
	]
	return palette[clampi(tier, 0, palette.size() - 1)]


static func name_key(tier: int) -> String:
	var names := ["Dew", "Pearl", "Lilac", "Rose", "Ember", "Honey", "Leaf", "Tide", "Sky", "Nova", "Sun"]
	return names[clampi(tier, 0, names.size() - 1)]


static func random_drop_tier(max_unlocked: int) -> int:
	# Early tiers more common; never spawn top tiers as drops
	var cap := mini(max_unlocked, 4)
	var weights := [10, 8, 5, 3, 2]
	var total := 0
	for i in cap + 1:
		total += weights[i]
	var roll := randi() % total
	var acc := 0
	for i in cap + 1:
		acc += weights[i]
		if roll < acc:
			return i
	return 0
