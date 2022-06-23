extends Spatial
signal clicked()
func _on_mouse_input(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("clicked")
var dismissed = false
signal dismissed()
func dismiss():
	if dismissed:
		return
	dismissed = true
	emit_signal("dismissed")
