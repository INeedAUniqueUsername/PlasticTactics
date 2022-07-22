extends Node


func tween_property(obj: Spatial, prop: String, start, end, dur: float, trans_type: int = 0, ease_type: int = 0):
	var t = Tween.new()
	
	var origin = obj.get_global_transform().origin
	t.interpolate_property(obj, prop, start, end, dur, trans_type, ease_type)
	obj.add_child(t)
	t.start()
	yield(t, "tween_all_completed")
	t.queue_free()

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
func get_world(node):
	while node and !node.is_in_group("World"):
		node = node.get_parent()
	return node
func add_to_world(node : Node, child : Node, tr = null):
	get_world(node).add_child(child)
	if tr:
		child.set_global_transform(tr)
func get_actor(node):
	while node and !node.is_in_group("Actor"):
		node = node.get_parent()
	return node
const directions = {
	'N': Vector3(0, 0, -1),
	'E': Vector3(1, 0, 0),
	'S': Vector3(0, 0, 1),
	'W': Vector3(-1, 0, 0),
}

func pos_to_region_code(pos):
	return "%s%s" % [["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"][pos.x], pos.y]
func flatten_3d(v : Vector3) -> Vector2:
	return Vector2(v.x, v.z)
func extrude_2d(v: Vector2, y: float) -> Vector3:
	return Vector3(v.x, y, v.y)

const MultiSignal = preload("res://MultiSignal.gd").MultiSignal
func multi_yield(signals):
	var m = MultiSignal.new(signals)
	yield(m, "done")
	
