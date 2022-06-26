extends Node

var region_pos = null
func _ready():
	register_regions()
func get_region(p: Vector2) -> PackedScene:
	return Regions[p.x][p.y] as PackedScene
var Regions = []
const rw = 12
const rh = 8
func register_regions():
	for x in range(rw):
		var row = []
		for y in range(rh):
			var p = Vector2(x, y)
			var s = "Region%s.tscn" % Helper.pos_to_region_code(p)
			if ResourceLoader.exists(s):
				s = load(s)
				print("loaded region at (", x, ", ", y, ")")
			else:
				s = null
				print("missing region at (", x, ", ", y, ")")
			row.append(s)
		Regions.append(row)
