extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var turns_left = 2
func start_turn():
	turns_left -= 1
	if turns_left == 0:
		destroy()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var destroyed = false
func _on_area_entered(area):
	if area.is_in_group("Water"):
		print("Fire extinguished by " + Helper.get_actor(area).name)
		if destroyed:
			return
		destroyed = true
		destroy()		
func destroy():
	$Tile/Area.queue_free()
	$Anim.stop()
	var t = Tween.new()
	t.interpolate_property(self, "scale", scale, Vector3(0, 0, 0), 1, Tween.TRANS_QUAD, Tween.EASE_IN)
	add_child(t)
	t.start()
	yield(t, "tween_all_completed")
	queue_free()
