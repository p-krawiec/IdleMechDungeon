extends Control
class_name UpgradeScreen

@export var upgrade_category: Upgrades.UpgradeCategory

@onready var upgrades_container = $Panel/ScreenContainer/UpgradesContainer

var upgrade_button_scene = preload("res://Scenes/UI/upgrade_button.tscn")

var player: Player

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	prepare_upgrades_screen(upgrade_category)
	hide()

func hide_upgrades():
	player.allow_input = true
	get_tree().paused = false
	hide()
	
	queue_free()
	
func show_upgrades():
	player.allow_input = false
	get_tree().paused = true
	
	if upgrades_container.get_child_count() == 0:
		prepare_upgrades_screen(upgrade_category)
	
	$AnimationPlayer.play("Blur")
	

func prepare_upgrades_screen(category: Upgrades.UpgradeCategory):
	var number_of_upgrades: int
	var upgrades = []
	
	match category:
		Upgrades.UpgradeCategory.PLAYER:
			number_of_upgrades = 3
			upgrades = generate_random_player_upgrades(number_of_upgrades)
		Upgrades.UpgradeCategory.WEAPON:
			number_of_upgrades = 3
			upgrades = generate_random_weapon_upgrades(number_of_upgrades)
		Upgrades.UpgradeCategory.HEAL:
			number_of_upgrades = 1
			upgrades = generate_heal_upgrade()
	
	for i in range(number_of_upgrades):
		var upgrade_button = upgrade_button_scene.instantiate() as UpgradeButton
		upgrade_button.upgrade = upgrades[i]
		upgrade_button.setup_button()
		upgrades_container.add_child(upgrade_button)
		upgrade_button.connect("pressed", _on_button_pressed)
	
func _on_button_pressed():
	hide_upgrades()
	
	for child in upgrades_container.get_children():
		child.queue_free()
	
func generate_random_player_upgrades(number_of_upgrades):
	var upgrades = []
	
	while upgrades.size() < number_of_upgrades:
		var upgrade = Upgrades.get_random_player_upgrade()
		if upgrade not in upgrades:
			upgrades.append(upgrade)
	
	return upgrades

func generate_random_weapon_upgrades(number_of_upgrades):
	var upgrades = []
	
	while upgrades.size() < number_of_upgrades:
		var upgrade = Upgrades.get_random_weapon_upgrade()
		if upgrade not in upgrades:
			upgrades.append(upgrade)
	
	return upgrades
	
func generate_heal_upgrade():
	return [Upgrades.get_heal_upgrade()]
	
