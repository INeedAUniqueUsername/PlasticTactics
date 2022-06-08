extends Spatial
signal moved()
const Mirror = preload("res://VanitySpikeAttack.tscn")
func play_move():
	$Anim.play("Shake")
	yield($Anim, "animation_finished")
	var tr = get_global_transform()
	
	tr.origin += Vector3(-1, 0, 0)
	var mirrors = []
	for i in range(5):
		tr.origin += Vector3(-1, 0, 0)
		var m = Mirror.instance()
		get_parent().call_deferred("add_child", m)
		m.set_global_transform(tr)
		mirrors.append(m)
		
		var t = Timer.new()
		t.wait_time = 0.5
		add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
	for m in mirrors:
		yield(m, "tree_exited")
	emit_signal("moved")
