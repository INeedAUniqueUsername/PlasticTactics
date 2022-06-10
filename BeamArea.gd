extends Node
export(NodePath) var area
export(float) var length
func _ready():
	area = get_node(area)
	var tr = get_parent().get_global_transform()
	
	var count = 10
	for i in range(count):
		yield(get_tree().create_timer(0.5 / count), "timeout")
		var a = area.duplicate()
		get_parent().add_child(a)
		a.set_global_transform(tr)
		Helper.tween_move(a, tr.basis.x * length, 0.3, Tween.TRANS_LINEAR, 0)
		
