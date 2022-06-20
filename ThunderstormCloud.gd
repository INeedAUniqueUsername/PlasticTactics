extends Spatial

var turnsLeft = 6
func start_turn():
	if turnsLeft > 0:
		turnsLeft -= 1
	else:
		destroy()
func end_turn():
	try_lightning()
const Lightning = preload("res://ThunderstormLightning.tscn")
func try_lightning():
	if destroyed:
		return
	if randi()%32 == 0:
		fire_lightning()
func try_lightning_target(hammer):
	if destroyed:
		return
	for area in $Area.get_overlapping_areas():
		if area.is_in_group("NoMove"):
			continue
		var actor = Helper.get_actor(area)
		if !actor:
			continue
		if actor == hammer or actor.is_in_group("Hedge") or actor.is_in_group("Tree") or actor.is_in_group("Player") or actor.is_in_group("Enemy"):
			fire_lightning()
func fire_lightning():
	Helper.add_to_world(self, Lightning.instance(), get_global_transform())
var destroyed = false
func destroy():
	if destroyed:
		return
	destroyed = true
	$Anim.play("Fade")
