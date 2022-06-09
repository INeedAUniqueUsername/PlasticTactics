extends Node

func tween_move(obj: Spatial, inc: Vector3, dur: float, trans_type: int = 0, ease_type: int = 0):
	var t = Tween.new()
	
	var origin = obj.get_global_transform().origin
	t.interpolate_property(obj, "global_transform:origin", origin, origin + inc, dur, trans_type, ease_type)
	obj.add_child(t)
	t.start()
	yield(t, "tween_all_completed")
	t.queue_free()
func tween_rotate(obj: Spatial, inc: Vector3, dur: float, trans_type: int = 0, ease_type: int = 0):
	var t = Tween.new()
	var origin = obj.rotation
	t.interpolate_property(obj, "rotation", origin, origin + inc, dur, trans_type, ease_type)
	obj.add_child(t)
	t.start()
	yield(t, "tween_all_completed")
	t.queue_free()

func get_actor(node):
	while node and !node.is_in_group("Actor"):
		node = node.get_parent()
	return node
