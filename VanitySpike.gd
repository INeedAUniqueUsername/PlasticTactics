extends Sprite3D
func _ready():
	$Area.connect("area_entered", self, "on_area_entered")
func on_area_entered(area):
	if area.is_in_group("Damage"):
		queue_free()
		#Helper.tween_move(self, Vector3(0, -1, 0), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
func get_actor(node):
	while node and !node.is_in_group("Actor"):
		node = node.get_parent()
	return node
