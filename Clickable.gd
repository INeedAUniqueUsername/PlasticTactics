extends Spatial
signal clicked(Spatial)
func _on_mouse_input(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("clicked", self)
