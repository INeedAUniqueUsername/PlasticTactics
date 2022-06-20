extends Spatial
func make_splash():
	var hammer = Helper.get_actor(self)
	for c in Helper.get_world(self).get_misc_actors():
		if !c.is_in_group("Thunderstorm"):
			continue
		c.try_lightning_target(hammer)
