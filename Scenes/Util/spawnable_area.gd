extends Area2D
class_name SpawnableArea

@onready var doors = get_parent().get_node("Doors").get_children()

var basic_enemy_scene = preload("res://Scenes/Enemies/basic_enemy.tscn")
var dashing_enemy_scene = preload("res://Scenes/Enemies/dashing_enemy.tscn")
var basic_shooting_enemy_scene = preload("res://Scenes/Enemies/basic_shooting_enemy.tscn")
var advanced_shooting_enemy_scene = preload("res://Scenes/Enemies/advanced_shooting_enemy.tscn")

var upgrade_pickup_scene = preload("res://Scenes/Util/upgrade_pickup.tscn")

var enemies_per_wave = [1, 1, 1]

var upgrade_category: Upgrades.UpgradeCategory
var spawnable_polygon: CollisionPolygon2D
var enemies_spawned = 0
var current_wave = 1

var wave_spawning_ended = false

func _ready():
	for child in get_children():
		if child is CollisionPolygon2D:
			spawnable_polygon = child
			break
	
	upgrade_category = (get_parent() as BaseRoom).upgrade

func _process(_delta):
	if wave_spawning_ended and get_tree().get_nodes_in_group("Enemy").is_empty():
		if current_wave < enemies_per_wave.size():
			start_wave(current_wave + 1)
		else:
			if not started_room_cleared_procedure:
				room_cleared()

func start():
	start_wave(1)

func start_wave(wave_number):
	wave_spawning_ended = false
	current_wave = wave_number
	enemies_spawned = 0
	(get_tree().get_first_node_in_group("HUD") as HUD).display_wave_text(str("Wave ", current_wave))
	
	$BeforeFirstSpawnTimer.start()

func spawn_enemy():
	var polygon = spawnable_polygon.polygon
	var bounds = get_polygon_bounds(polygon)
	var spawn_point = get_random_point_in_polygon(polygon, bounds)
	
	var enemy_scene = get_enemy_scene_to_spawn()
	var enemy = enemy_scene.instantiate() as Node2D
		
	enemy.position = spawn_point
	get_tree().get_first_node_in_group("GameMain").get_node("Entities").add_child(enemy)
	enemies_spawned += 1

func get_polygon_bounds(polygon):
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for point in polygon:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
	
func get_random_point_in_polygon(polygon, bounds):
	while true:
		var rand_x = randf_range(bounds.position.x, bounds.position.x + bounds.size.x)
		var rand_y = randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		var rand_point = Vector2(rand_x, rand_y)
		if is_point_in_polygon(rand_point, polygon):
			return rand_point
	
func is_point_in_polygon(point, polygon):
	var count = 0
	for i in range(polygon.size()):
		var j = (i+1) % polygon.size()
		if (polygon[i].y > point.y) != (polygon[j].y > point.y):
			var at_x = (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x
			if point.x < at_x:
				count += 1
	return count % 2 == 1

func _on_before_first_spawn_timer_timeout():
	call_deferred("spawn_enemy")
	$BetweenSpawnsTimer.start()

func _on_between_spawns_timer_timeout():
	if enemies_spawned < enemies_per_wave[current_wave - 1]:
		call_deferred("spawn_enemy")
		$BetweenSpawnsTimer.start()
	else:
		wave_spawning_ended = true
#		
var started_room_cleared_procedure = false
func room_cleared():
	started_room_cleared_procedure = true
	(get_tree().get_first_node_in_group("HUD") as HUD).display_wave_text("Room Cleared")
	
	if upgrade_category != -1:
		var spawn_global_position = get_tree().get_first_node_in_group("Player").global_position
		var upgrade_pickup = upgrade_pickup_scene.instantiate()
		upgrade_pickup.global_position = spawn_global_position
		upgrade_pickup.upgrade_category = upgrade_category
		upgrade_pickup.doors = doors
		get_tree().get_first_node_in_group("GameMain").get_node("Entities").add_child(upgrade_pickup)
		
		var current_level_number = (get_tree().get_first_node_in_group("GameMain") as GameMain).current_room_number
		
		if current_level_number == 1 and Util.show_tutorial:
			(get_tree().get_first_node_in_group("TutorialScreen") as TutorialScreen).display_tutorial(4)
			var player = get_tree().get_first_node_in_group("Player") as Player
			player.allow_input = false
			player.direction = Vector2.ZERO
		
	queue_free()

func get_enemy_scene_to_spawn():
	var wave_odds = Util.enemy_per_wave_odds.get(current_wave)
	if not wave_odds:
		push_error("Wave number out of bounds")
		return null
	
	var enemy_type = get_enemy_type(wave_odds["melee"])
	var enemy_scene = get_enemy_scene_of_type(enemy_type, wave_odds)
	
	return enemy_scene
	
func get_enemy_type(melee_enemy_odds):
	var random_value = randf()
	if random_value < melee_enemy_odds:
		return "melee"
	else:
		return "ranged"
	
func get_enemy_scene_of_type(enemy_type, wave_odds):
	var basic_enemy_odds = wave_odds["%s_basic" % enemy_type]
	var random_value = randf()
	
	if random_value < basic_enemy_odds: # basic enemy of enemy type
		if enemy_type == "melee": 
			return basic_enemy_scene
		else:
			return basic_shooting_enemy_scene
	else: # harder enemy of enemy type
		if enemy_type == "melee":
			return dashing_enemy_scene
		else:
			return advanced_shooting_enemy_scene
