extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("damaged", self, "on_parent_damaged")
func on_parent_damaged():
	var w = int(48 * get_parent().hp / 100.0)
	$Back.region_rect.size.x = w
	$Front.region_rect.size.x = w
