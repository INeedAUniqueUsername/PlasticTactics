extends Spatial
var damage = 10
func _ready():
	$Mirror/Area.connect("area_entered", self, "on_mirror_entered")
	$Spike/Area.connect("area_entered", self, "on_spike_entered")
func on_spike_entered(area):
	if area.is_in_group("Damage"):
		$Spike.queue_free()
func on_mirror_entered(area):
	if area.is_in_group("Damage") and area.get_parent() != $Spike:
		pass
		#$Spike.queue_free()
