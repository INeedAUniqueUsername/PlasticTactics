extends Sprite3D
var damage = 20

var vel = Vector3(0, 0, 0)
var grav = Vector3(0, -9.8, 0)
func _physics_process(delta):
	global_translate(vel * delta)
	vel += grav * delta
	
var destroyed = false

#const Stalagmite = preload("res://HailStalagmite.tscn")
const Splash = preload("res://SplashLavaTile.tscn")
const Explosion = preload("res://EruptExplosion.tscn")
func _on_area_entered(area):
	if area.is_in_group("Ground"):
		if destroyed:
			return
		destroyed = true
		
		#add an explosion
		var s = Splash.instance()
		var world = Helper.get_world(self)
		world.add_child(s)
		var tr = get_global_transform()
		tr.origin.y = area.get_parent().get_global_transform().origin.y
		s.set_global_transform(tr)
		s.scale = Vector3(0.5, 0.5, 0.5)

		Helper.add_to_world(self, Explosion.instance(), get_global_transform())
		queue_free()
		#var w = Helper.get_world(self)
		#var tr = get_global_transform()
		#tr.origin = w.get_ground_origin(tr.origin)
		#Helper.add_to_world(self, Stalagmite.instance(), tr)
		#queue_free()
