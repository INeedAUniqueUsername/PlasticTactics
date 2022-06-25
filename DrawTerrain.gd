tool
extends Sprite3D
func _ready():
	pass

export(bool) var redraw setget set_redraw
func set_redraw(r):
	redraw()
var Regions = {}
const rw = 12
const rh = 8
func register_regions():
	for x in range(rw):
		for y in range(rh):
			var p = Vector2(x, y)
			var s = "Region%s.tscn" % pos_to_region_code(p)
			if ResourceLoader.exists(s):
				s = load(s)
			else:
				s = null
			Regions[p] = s
export(Color) var color_grass setget set_color_grass
export(Color) var color_river setget set_color_river
func set_color_grass(c):
	color_grass = c
func set_color_river(c):
	color_river = c
var image : Image
const REGION_SIZE = 32
const Type = preload("res://Placeholder.gd").Type
func redraw():
	
	image = Image.new()
	image.create(rw * REGION_SIZE, rh * REGION_SIZE, false, Image.FORMAT_RGBAF)
	if len(Regions) == 0:
		register_regions()
	for x in range(rw):
		for y in range(rh):
			var g = Regions[Vector2(x, y)]
			if !g:
				continue
			g = g.instance()
			for c in g.get_children():
				if !c.is_in_group("Placeholder"):
					continue
				c = {
					Type.Grass: color_grass,
					Type.River: color_river
				}[c]
				var p = c.transform.origin
				image.set_pixel(x * REGION_SIZE + p.x, y * REGION_SIZE + p.z, c)
	var t = ImageTexture.new()
	t.create_from_image(image, 7 ^ ImageTexture.FLAG_FILTER)
	texture = t
func register_regions():
	pass
func pos_to_region_code(pos):
	return "%s%s" % [["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"][pos.x], pos.y]
