extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("damaged", self, "on_parent_damaged")
func on_parent_damaged():
	var p = get_parent()
	var hp_max = 100.0
	if 'hp_max' in p:
		hp_max = p.hp_max
	var w = int(48 * p.hp / hp_max)
	$Back.region_rect.size.x = w
	$Front.region_rect.size.x = w
