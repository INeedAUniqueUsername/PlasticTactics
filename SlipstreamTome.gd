extends Spatial
const Wind = preload("res://SlipstreamWind.tscn")
func cast():
	for n in range(16):
		for i in [-2, -1, 0, 1, 2]:
			cast_wind_particle(i)
		yield(get_tree().create_timer(0.1), "timeout")
func cast_wind_particle(z):
	var wind = Wind.instance()
	var world = Helper.get_world(self)
	world.add_child(wind)
	var tr = get_global_transform()
	tr.origin += z * tr.basis.z + 0.5 * tr.basis.x
	wind.set_global_transform(tr)
	var t = Tween.new()
	t.interpolate_property(wind, "global_transform:origin", tr.origin, tr.origin + tr.basis.x * 16, 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	t.interpolate_property(wind, "opacity", 1, 0, 2.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	world.add_child(t)
	t.start()
	yield(t, "tween_all_completed")
	t.queue_free()
	wind.queue_free()
