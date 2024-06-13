extends Node

var player_upgrade_icon = preload("res://Assets/UI/skills/Upgrade_Player.png")
var weapon_upgrade_icon = preload("res://Assets/UI/skills/Upgrade_Weapon.png")
var heal_upgrade_icon = preload("res://Assets/UI/skills/heal.png")

enum UpgradeCategory {
	PLAYER,
	WEAPON,
	HEAL
}

enum UpgradeType {
	MORE_HP,
	GOLDEN_HEART,
	MOVEMENT_SPEED,
	DASH_COOLDOWN,
	DASH_SPEED,
	LUCK,
	
	ATTACK_SPEED,
	ATTACK_RANGE,
	CRIT_CHANCE,
	PROJECTILE_SPEED,
	PENETRATION,
	MORE_AMMO,
	
	HEAL
}

var upgrades_info = {
	UpgradeType.MORE_HP:
		[1, 1, "More Health", "Gain 1 additional heart", preload("res://Assets/UI/skills/more_hp.png")],
	UpgradeType.GOLDEN_HEART:
		[1, 1, "Golden Heart", "Gain half of golden heart", preload("res://Assets/UI/skills/golden_heart.png"), "Golden hearts regenerate at the start of new room"],
	UpgradeType.MOVEMENT_SPEED:
		[5, 15, "Movement Speed", "Increase movement speed by $%", preload("res://Assets/UI/skills/movement_speed.png")],
	UpgradeType.DASH_COOLDOWN:
		[5, 15, "Dash Cooldown", "Reduce dash cooldown by $%", preload("res://Assets/UI/skills/dash_cooldown.png")],
	UpgradeType.DASH_SPEED:
		[5, 15, "Dash Speed", "Increase dash speed boost by $%", preload("res://Assets/UI/skills/dash_speed.png")],
	UpgradeType.LUCK:
		[1, 10, "Luck", "Gain $% chance to get highest upgrade roll", preload("res://Assets/UI/skills/luck.png")],
	
	UpgradeType.ATTACK_SPEED:
		[5, 15, "Attack Speed", "Increase attack speed by $%", preload("res://Assets/UI/skills/attack_speed.png")],
	UpgradeType.ATTACK_RANGE:
		[5, 15, "Attack Range", "Increase attack range by $%", preload("res://Assets/UI/skills/attack_range.png")],
	UpgradeType.CRIT_CHANCE:
		[10, 20, "Crit Chance", "Gain $% critical strike chance", preload("res://Assets/UI/skills/crit_chance.png"), "Critical strikes deal double damage"],
	UpgradeType.PROJECTILE_SPEED:
		[10, 20, "Projectile Speed", "Increase bullets' speed by $%", preload("res://Assets/UI/skills/projectile_speed.png")],
	UpgradeType.PENETRATION:
		[1, 1, "Penetration", "Bullets can go through 1 additional target", preload("res://Assets/UI/skills/penetration.png")],
	UpgradeType.MORE_AMMO:
		[1, 1, "More ammo", "Increase magazine size by 1", preload("res://Assets/UI/skills/more_ammo.png")],
		
	UpgradeType.HEAL:
		[0, 0, "Heal", "Regenerate all your missing health", preload("res://Assets/UI/skills/heal.png")]
}

	
func get_random_upgrade_value(upgrade):
	var player = get_tree().get_first_node_in_group("Player") as Player
	
	var did_get_lucky = (randi() % 100) < player.luck
	var info = upgrades_info[upgrade]
	if did_get_lucky:
		return info[1]
	else:
		return randi_range(info[0], info[1])

func get_upgrade_description(upgrade, number):
	var upgrade_description = upgrades_info[upgrade][3] as String
	if upgrade_description.contains("$"):
		upgrade_description = upgrade_description.replace("$", str(number))
		
	return upgrade_description

func get_upgrade_chance_text(upgrade):
	var _min = upgrades_info[upgrade][0]
	var _max = upgrades_info[upgrade][1]
	var chances_text = ""
	
	if _max == 0:
		return chances_text
	
	if _min == _max:
		chances_text = str("(", _min, ")")
	else:
		chances_text = str("(", _min, "-", _max, "%)")
		
	
	if upgrades_info[upgrade].size() == 6:
		chances_text += str("\n", upgrades_info[upgrade][5])
		
	return chances_text

func get_upgrade_icon(upgrade):
	return upgrades_info[upgrade][4]

func get_random_player_upgrade():
	return randi_range(0, 5)
	
func get_random_weapon_upgrade():
	return randi_range(6, 11)
	
func get_heal_upgrade():
	return 12

func use_upgrade(upgrade: UpgradeType, value: int):
	var player = get_tree().get_first_node_in_group("Player") as Player
	var hud = get_tree().get_first_node_in_group("HUD") as HUD
	
	match upgrade:
		UpgradeType.MORE_HP:
			player.increase_health()
			hud.recalculate_health()
		UpgradeType.GOLDEN_HEART:
			player.increase_golden_health()
			hud.recalculate_golden_hearts()
		UpgradeType.MOVEMENT_SPEED:
			player.increase_movement_speed(value)
		UpgradeType.DASH_COOLDOWN:
			player.decrease_dash_cooldown(value)
		UpgradeType.DASH_SPEED:
			player.increase_dash_boost(value)
		UpgradeType.LUCK:
			player.increase_luck(value)
			
		UpgradeType.ATTACK_SPEED:
			player.increase_attack_speed(value)
		UpgradeType.ATTACK_RANGE:
			player.increase_attack_range(value)
		UpgradeType.CRIT_CHANCE:
			player.increase_crit_chance(value)
		UpgradeType.PROJECTILE_SPEED:
			player.increase_projectile_speed(value)
		UpgradeType.PENETRATION:
			player.increase_pen()
		UpgradeType.MORE_AMMO:
			player.increase_ammo()
			hud.recalculate_ammo()
			
		UpgradeType.HEAL:
			player.heal()
			hud.recalculate_health()
			hud.recalculate_golden_hearts()
