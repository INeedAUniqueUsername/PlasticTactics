extends Spatial
func _ready():
	translate(Vector3(0, 0, round(rand_range(-4, 4))/10.0))
func end_turn():
	for area in $Center/Area.get_overlapping_areas():
		if area.is_in_group("Burning") and !area.is_in_group("Water"):
			if destroyed:
				return
			if burning:
				destroyed = true
				$Anim.play("Disappear")
				return
			burning = true
			$Anim.play("Burn")
			return
var destroyed = false
var burning = false
