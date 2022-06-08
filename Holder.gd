extends Spatial
export(NodePath) var subject
func _ready():
	if subject is NodePath:
		subject = get_node(subject)
func set_pos():
	set_global_transform($Char.get_global_transform())
	$Char.set_global_transform(get_global_transform())
func _on_animation_finished(anim_name):
	set_pos()
