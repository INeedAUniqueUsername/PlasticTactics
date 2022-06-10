extends Sprite3D
var damage = 5

var vel = Vector3(0, 0, 0)
func _ready():
	var angle = randf() * PI * 2
	var hspeed = rand_range(1.0, 4.0)
	vel = Vector3(hspeed * cos(angle), rand_range(2, 7), hspeed * sin(angle))
var grav = Vector3(0, -9.8, 0)
func _physics_process(delta):
	global_translate(vel * delta)
	vel += grav * delta
