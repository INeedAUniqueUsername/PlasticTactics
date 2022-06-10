extends Sprite3D
var damage = 5

var vel = Vector3(0, 0, 0)
func _ready():
	var angle = randf() * PI * 2
	var hspeed = rand_range(1.0, 6.0)
	vel = Vector3(hspeed * cos(angle), rand_range(2, 6), hspeed * sin(angle))
var grav = Vector3(0, -9.8, 0)
func _physics_process(delta):
	global_translate(vel * delta)
	vel += grav * delta

const Splash = preload("res://SplashWaterTile.tscn")
func _on_area_entered(area):
	var actor = Helper.get_actor(area)
	if !actor:
		actor = area.get_parent()
	if actor and actor.is_in_group("Ground"):
		var s = Splash.instance()
		var world = Helper.get_world(self)
		world.add_child(s)
		s.set_global_transform(get_global_transform())
		s.scale = Vector3(0.5, 0.5, 0.5)
		queue_free()
