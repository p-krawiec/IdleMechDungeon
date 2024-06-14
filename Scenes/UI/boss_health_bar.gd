extends Control

func _ready():
	hide()
	$VBoxContainer/Control/ColorRect.color = Color.FIREBRICK
	
func _process(_delta):
	var boss = get_tree().get_first_node_in_group("Boss") as Boss
	if boss and boss.hostile:
		if not visible:
			show()
			$AnimationPlayer.play("Show")
		var boss_current_hp = float(boss.health_component.current_health)
		var boss_max_hp = float(boss.health_component.max_health)
		$VBoxContainer/Control/ColorRect.scale.x = boss_current_hp / boss_max_hp
	else:
		hide()
