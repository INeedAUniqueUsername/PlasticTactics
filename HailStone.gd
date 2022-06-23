extends Sprite3D
var damage = 20

var vel = Vector3(0, 0, 0)
var grav = Vector3(0, -9.8, 0)
func _physics_process(delta):
	global_translate(vel * delta)
	vel += grav * delta

const Stalagmite = preload("res://HailStalagmite.tscn")
func _on_area_entered(area):
	if area.is_in_group("Ground"):
		if destroyed:
			return
		destroyed = true
		var w = Helper.get_world(self)
		var tr = get_global_transform()
		tr.origin = w.get_ground_origin(tr.origin)
		Helper.add_to_world(self, Stalagmite.instance(), tr)
		queue_free()
var destroyed = false
