extends Node
class_name GameMain

@export_category("Rooms")
@export var room_scenes: Array[PackedScene]

var tutorial_room = preload("res://Scenes/Rooms/FirstRoom/first_room.tscn")
var boss_room = preload("res://Scenes/Rooms/BossRoom/boss_room.tscn")

var player: Player
var current_room_number = 0

func _ready():
	Util.reset_play_time()
	
	MusicPlayer.fade_in_music(0.5)
	MusicPlayer.pick_random_track()
	
	player = get_tree().get_first_node_in_group("Player") as Player
	player.allow_input = false
	
	load_new_room(tutorial_room, [0,1].pick_random())
	room_scenes.shuffle()

func _process(delta):
	Util.update_play_time(delta)

func on_teleport_request(upgrade):
	clear_enemies()
	Util.play_time_stopped = true
	player.allow_input = false
	player.direction = Vector2.ZERO
	player.global_position = Vector2(-1000, -1000)
	
	var new_room_scene: PackedScene
	if not room_scenes.is_empty():
		new_room_scene = room_scenes.pop_front()
	else:
		new_room_scene = boss_room
	
	load_new_room(new_room_scene, upgrade)

func load_new_room(new_room_scene: PackedScene, upgrade):
	if not $CurrentRoom.get_children().is_empty():
		$CurrentRoom.get_child(0).queue_free()
	
	var new_room = new_room_scene.instantiate()
	$CurrentRoom.call_deferred("add_child", new_room)
	var spawn_global_position = new_room.get_spawn_global_position()
	
	if not new_room is BossRoom:
		(new_room as BaseRoom).boss_ahead = room_scenes.is_empty()
		(new_room as BaseRoom).teleport_request.connect(on_teleport_request)
		(new_room as BaseRoom).upgrade = upgrade
		(new_room as BaseRoom).setup_waves(current_room_number)
		current_room_number += 1
	
	player.regenerate_golden_health()
	($CanvasLayer/HUD as HUD).recalculate_golden_hearts()
	
	player.global_position = spawn_global_position
	player.allow_input = true
	Util.play_time_stopped = false

func clear_enemies():
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.queue_free()
	
	for indicator in get_tree().get_nodes_in_group("Indicator"):
		indicator.queue_free()
