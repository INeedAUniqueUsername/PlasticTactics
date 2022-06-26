tool
extends Sprite3D

enum Type {
	Grass,
	River
}

export(Type) var type setget set_type
var scene
func set_type(t):
	type = t
	self.texture = info[t].texture
	scene = info[t].scene

class Entry:
	var texture
	var scene
	func _init(texture: Texture, scene: PackedScene):
		self.texture = texture
		self.scene = scene
var info = {
	Type.Grass: Entry.new(
		preload("res://Sprites/Tiles/GrassTile.png"),
		preload("res://GrassTile.tscn")),
	Type.River: Entry.new(
		preload("res://Sprites/Tiles/RiverTile.png"),
		preload("res://RiverTile.tscn")
	)
}
func _ready():
	if Engine.editor_hint:
		return
	if !visible:
		queue_free()
		return
	var a = scene.instance()
	get_parent().call_deferred("add_child", a)
	a.transform.origin = transform.origin
	queue_free()
