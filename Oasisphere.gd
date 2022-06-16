extends Sprite3D
var damage = 4

var vel = Vector3(0, 0, 0)
var grav = Vector3(0, -9.8, 0)
func _physics_process(delta):
	global_translate(vel * delta)
	vel += grav * delta

const Pool = preload("res://OasisArea.tscn")
func _on_area_entered(area):
	if area.is_in_group("Ground"):
		Helper.add_to_world(self, Pool.instance(), get_global_transform())
		queue_free()
