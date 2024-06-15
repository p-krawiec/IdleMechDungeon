extends Control
class_name TutorialScreen

@onready var example_touch_ui = $ExampleTouchUI
@onready var example_hud = $ExampleHUD

@onready var basic_controls = $BasicControls
@onready var health_and_ammo = $HealthAndAmmo
@onready var prepare_to_fight = $PrepareToFight
@onready var upgrades = $Upgrades


func _ready():
	hide_all()
	
func hide_all():
	hide()
	example_hud.hide()
	example_touch_ui.hide()
	basic_controls.hide()
	health_and_ammo.hide()
	prepare_to_fight.hide()
	upgrades.hide()


#func display_tutorial(id):
#	if id == 1:
#		basic_controls.show()
#		example_touch_ui.show()
#	elif id == 2:
#		prepare_to_fight.show()

func display_tutorial(id):
	match id:
		1:
			example_touch_ui.show()
			basic_controls.show()
		2:
			example_hud.show()
			health_and_ammo.show()
		3:
			prepare_to_fight.show()
		4:
			upgrades.show()
	
	show()

func _on_button_pressed():
	$AudioStreamPlayer2D.play()
	hide_all()
	(get_tree().get_first_node_in_group("Player") as Player).allow_input = true
	Util.play_time_stopped = false
