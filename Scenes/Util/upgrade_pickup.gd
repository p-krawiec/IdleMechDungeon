extends StaticBody2D

@onready var upgrade_type_sprite = $UpgradeTypeSprite

var upgrade_screen_scene = preload("res://Scenes/UI/upgrade_screen.tscn")

var player_upgrade_sprite = preload("res://Assets/UI/skills/Upgrade_Player.png")
var weapon_upgrade_sprite = preload("res://Assets/UI/skills/Upgrade_Weapon.png")
var heal_upgrade_sprite = preload("res://Assets/UI/skills/heal.png")

var heal_button_sprite = preload("res://Assets/UI/UseButtonSprites/HealButton.png")
var player_button_sprite = preload("res://Assets/UI/UseButtonSprites/PlayerButton.png")
var weapon_button_sprite = preload("res://Assets/UI/UseButtonSprites/WeaponButton.png")

var doors: Array
var upgrade_category: Upgrades.UpgradeCategory
var use_button: Control
var player_in_area = false

func _ready():
	use_button = get_tree().get_first_node_in_group("UseButton") as Control
	
	$OnScreenNotifierComponent.should_be_visible = false
	
	match upgrade_category:
		Upgrades.UpgradeCategory.HEAL:
			upgrade_type_sprite.texture = heal_upgrade_sprite
			$OnScreenNotifierComponent.color = Color.RED
		Upgrades.UpgradeCategory.PLAYER:
			upgrade_type_sprite.texture = player_upgrade_sprite
			$OnScreenNotifierComponent.color = Color.PALE_VIOLET_RED
		Upgrades.UpgradeCategory.WEAPON:
			upgrade_type_sprite.texture = weapon_upgrade_sprite
			$OnScreenNotifierComponent.color = Color.DEEP_SKY_BLUE
	
	scale = Vector2.ZERO
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.play("Spawn")

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("use"):
		show_upgrade_screen()

func show_upgrade_screen():
	var upgrade_screen = upgrade_screen_scene.instantiate()
	(upgrade_screen as UpgradeScreen).upgrade_category = upgrade_category
	get_tree().get_first_node_in_group("GameMain").get_node("CanvasLayer").add_child(upgrade_screen)
	(upgrade_screen as UpgradeScreen).show_upgrades()
	
	if not doors[0].boss_ahead:
		for door in doors:
			(door as Door).door_on()
	else:
		doors[[0,1].pick_random()].door_on()
	
	queue_free()

func _on_area_2d_body_entered(body):
	if body is Player:
		player_in_area = true
		use_button.show()
		
		match upgrade_category:
			Upgrades.UpgradeCategory.HEAL:
				use_button.get_node("UseButton").texture_normal = heal_button_sprite
			Upgrades.UpgradeCategory.PLAYER:
				use_button.get_node("UseButton").texture_normal = player_button_sprite
			Upgrades.UpgradeCategory.WEAPON:
				use_button.get_node("UseButton").texture_normal = weapon_button_sprite


func _on_area_2d_body_exited(body):
	if body is Player:
		player_in_area = false
		use_button.hide()
