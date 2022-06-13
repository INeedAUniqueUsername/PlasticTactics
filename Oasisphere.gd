extends Sprite3D
var damage = 4

var vel = Vector3(0, 0, 0)
var grav = Vector3(0, -9.8, 0)
func _physics_process(delta):
	global_translate(vel * delta)
	vel += grav * delta

const Pool = preload("res://OasisArea.tscn")
func _on_area_entered(area):
	var actor = Helper.get_actor(area)
	if !actor:
		actor = area.get_parent()
	if actor and actor.is_in_group("Ground"):
		var s = Pool.instance()
		s.set_global_transform(get_global_transform())
		Helper.get_world(self).add_child(s)
		queue_free()
