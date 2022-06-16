extends Node

class ItemType:
	var sprite
	func _init(sprite: Texture):
		self.sprite = sprite
var Oasisphere = ItemType.new(preload("res://Oasisphere.png"))
var Dynamite = ItemType.new(preload("res://Dynamite.png"))
