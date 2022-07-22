class MultiSignal:
	signal done()
	func _init(arg0, arg1 = null):
		if arg0 is Dictionary:
			for actor in arg0.keys():
				var value = arg0[actor]
				if value is Array:
					var signals = value
					for v in signals:
						actor.connect(v, self, "do")
				elif value is String:
					actor.connect(value, self, "do")
		elif arg0 is Node:
			var actor = arg0
			var signals = arg1
			for v in signals:
				actor.connect(v, self, "do")
	func do():
		emit_signal("done")
