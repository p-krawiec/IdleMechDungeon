extends Button
class_name UpgradeButton

@export var upgrade: Upgrades.UpgradeType
@export var upgrade_value: int

func setup_button():
	upgrade_value = Upgrades.get_random_upgrade_value(upgrade)
	
	$ButtonContainer/UpgradeName.text = Upgrades.upgrades_info[upgrade][2]
	$ButtonContainer/UpgradeDescription.text = Upgrades.get_upgrade_description(upgrade, upgrade_value)
	$ButtonContainer/UpgradeChances.text = Upgrades.get_upgrade_chance_text(upgrade)
	$ButtonContainer/Icon.texture = Upgrades.get_upgrade_icon(upgrade)


func _on_pressed():
	Upgrades.use_upgrade(upgrade, upgrade_value)
