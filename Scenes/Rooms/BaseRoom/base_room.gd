extends Node2D
class_name BaseRoom

@export var spawn_point: Node2D
@export var spawnable_area: Area2D
@export var doors: Node2D
@export var upgrade: Upgrades.UpgradeCategory

signal teleport_request(next_upgrade)
var spawnable_area_entered = false
var boss_ahead = false

func _ready():
	spawnable_area.body_entered.connect(on_spawnable_area_body_entered)
	setup_doors()

func setup_doors():
	var door1 = doors.get_child(0) as Door
	var door2 = doors.get_child(1) as Door
	
	var first_random_upgrade = Upgrades.UpgradeCategory.values().pick_random()
	var second_random_upgrade = Upgrades.UpgradeCategory.values().pick_random()
	while second_random_upgrade == first_random_upgrade:
		second_random_upgrade = Upgrades.UpgradeCategory.values().pick_random()
	
	door1.setup_upgrade(first_random_upgrade, boss_ahead)
	door1.teleport.connect(on_teleport_request)
	
	door2.setup_upgrade(second_random_upgrade, boss_ahead)
	door2.teleport.connect(on_teleport_request)
	
func setup_waves(room_index):
	var enemies_per_wave = []
	var waves_count = Util.waves_per_room[room_index]
	var multiplier = pow(Util.room_difficulty_multiplier, room_index)
	
	for i in range(waves_count):
		enemies_per_wave.append(int(Util.base_enemy_count_per_wave[i] * multiplier))
	
	(spawnable_area as SpawnableArea).enemies_per_wave = enemies_per_wave

func get_spawn_global_position() -> Vector2:
	return $SpawnPoint.global_position


func on_spawnable_area_body_entered(body):
	if not spawnable_area_entered:
		if body is Player:
			spawnable_area_entered = true
			$SpawnableArea.start()


func on_teleport_request(next_upgrade: Upgrades.UpgradeCategory):
	emit_signal("teleport_request", next_upgrade)
