extends Sprite3D

func _ready():
	var select = $Select
	var area = $Area
	var start = area.transform.origin
	for x in range(12):
		for y in range(8):
			var a = area.duplicate()
			var pos = Vector2(x, y)
			add_child(a)
			a.show()
			a.transform.origin = start + Vector3(x, 0, -y)
			a.connect("mouse_entered", $Select, "show")
			a.connect("mouse_entered", self, "emit_signal", ["hovered", pos])
			a.connect("mouse_entered", $Select, "set_global_transform", [a.get_global_transform()])
			a.connect("mouse_exited", $Select, "hide")
			a.connect("input_event", self, "_on_mouse_input", [pos])
	area.queue_free()
signal hovered(pos)
signal clicked(pos)
func _on_mouse_input(camera, event, position, normal, shape_idx, pos):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("clicked", pos)
