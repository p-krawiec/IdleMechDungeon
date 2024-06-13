extends StaticBody2D
class_name Door

@onready var enter_area = $EnterArea
@onready var closed_collision_shape = $ClosedCollisionShape
@onready var animation_player = $AnimationPlayer
@onready var upgrade_type_sprite = $UpgradeTypeSprite

var notifier_scene = preload("res://Scenes/Util/on_screen_notifier_component.tscn")

var player_upgrade_sprite = preload("res://Assets/UI/skills/Upgrade_Player.png")
var weapon_upgrade_sprite = preload("res://Assets/UI/skills/Upgrade_Weapon.png")
var heal_upgrade_sprite = preload("res://Assets/UI/skills/heal.png")
var boss_exit_sprite = preload("res://Assets/UI/skills/Boss_Exit.png")

var door_unlock_button_sprite = preload("res://Assets/UI/Skillicon5_38.png")

var upgrade_type: Upgrades.UpgradeCategory

signal teleport(upgrade)

var are_door_open = false
var player_in_area = false
var use_button: Control

var boss_ahead = false

func _ready():
	use_button = get_tree().get_first_node_in_group("UseButton") as Control
	use_button.hide()
	
	animation_player.play("door_off")
	animation_player.stop()
	closed_collision_shape.disabled = false
	enter_area.monitoring = false
	
	upgrade_type_sprite.visible = false
	
	$OnScreenNotifierComponent.color = Color.CADET_BLUE
	$OnScreenNotifierComponent.should_be_visible = false
	

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("use") and not are_door_open:
		open_door()
		
	if are_door_open:
		animation_player.play("door_open")

func setup_upgrade(upgrade: Upgrades.UpgradeCategory, is_boss_ahead):
	upgrade_type = upgrade
	boss_ahead = is_boss_ahead
	
	if boss_ahead:
		upgrade_type_sprite.texture = boss_exit_sprite
	else:
		match upgrade_type:
			Upgrades.UpgradeCategory.HEAL:
				upgrade_type_sprite.texture = heal_upgrade_sprite
			Upgrades.UpgradeCategory.PLAYER:
				upgrade_type_sprite.texture = player_upgrade_sprite
			Upgrades.UpgradeCategory.WEAPON:
				upgrade_type_sprite.texture = weapon_upgrade_sprite
			
	$UpgradeTypeSprite/AnimationPlayer.play("Basic")

func door_on():
	animation_player.play("door_on")
	upgrade_type_sprite.visible = true
	enter_area.monitoring = true
	$OnScreenNotifierComponent.should_be_visible = true

func open_door():
	animation_player.play("door_opening")
	
func door_animation_finished():
	are_door_open = true
	closed_collision_shape.disabled = true
	use_button.hide()

func _on_enter_area_body_entered(body):
	if body is Player:
		player_in_area = true
		if not are_door_open:
			use_button.show()
			use_button.get_node("UseButton").texture_normal = door_unlock_button_sprite

func _on_enter_area_body_exited(body):
	if body is Player:
		player_in_area = false
		use_button.hide()
	

func _on_teleport_area_body_entered(body):
	if body is Player:
		emit_signal("teleport", upgrade_type)
