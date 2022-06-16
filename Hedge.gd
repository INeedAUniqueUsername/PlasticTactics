extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
