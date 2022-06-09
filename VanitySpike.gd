extends Sprite3D
func _ready():
	$Area.connect("area_entered", self, "on_area_entered")
func on_area_entered(area):
	if area.is_in_group("Damage"):
		queue_free()
