tool
extends Sprite3D
export(bool) var reload setget set_reload
func set_reload(r):
	if Engine.editor_hint:
		register_regions()
export(bool) var redraw setget set_redraw
func set_redraw(r):
	if Engine.editor_hint:
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
				print("loaded region at (", x, ", ", y, ")")
			else:
				s = null
				print("missing region at (", x, ", ", y, ")")
			Regions[p] = s
export(Color) var color_grass = Color.green setget set_color_grass
export(Color) var color_river = Color.blue setget set_color_river
func set_color_grass(c):
	color_grass = c
func set_color_river(c):
	color_river = c
var image : Image
const REGION_SIZE = 32
const Type = preload("res://Placeholder.gd").Type
func redraw():
	
	print("region count: ", len(Regions))
	image = Image.new()
	image.create(rw * REGION_SIZE, rh * REGION_SIZE, false, Image.FORMAT_RGBAF)
	image.lock()
	for x in range(rw):
		for y in range(rh):
			print("region at (", x, ", ", y, ")")
			var g = Regions[Vector2(x, y)]
			if !g:
				continue
			g = g.instance()
			for c in g.get_children():
				if !c.is_in_group("Placeholder"):
					continue
				if !(c is Spatial):
					continue
				var p = c.transform.origin
				c = {
					Type.Grass: color_grass,
					Type.River: color_river
				}[c.type]
				var px = x * REGION_SIZE + p.x
				var py = image.get_height() - (y * REGION_SIZE - p.z)
				print("pixel at (", px, ", ", py, ")")
				image.set_pixel(px, py, c)
	image.unlock()
	var t = ImageTexture.new()
	t.create_from_image(image, 7 ^ ImageTexture.FLAG_FILTER)
	texture = t
func pos_to_region_code(pos):
	return "%s%s" % [["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"][pos.x], pos.y]
