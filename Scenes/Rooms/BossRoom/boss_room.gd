extends Node2D
class_name BossRoom

# Boss Cutscene checks
var boss_cutscene_initiated = false
var boss_meetup_position_reached = false
var boss_start_position_reached = false
var boss_fight_started = false


@onready var boss_cutscene_start_area = $BossCutsceneStartArea
@onready var boss_cutscene_player_position = $BossCutscenePlayerPosition
@onready var arena_center = $ArenaCenter
@onready var tile_map = $TileMap

var player: Player
var boss: Boss

func _ready():
	Util.play_time_stopped = true
	player = get_tree().get_first_node_in_group("Player") as Player
	boss = get_tree().get_first_node_in_group("Boss") as Boss

func get_spawn_global_position() -> Vector2:
	return $SpawnPoint.global_position


func _on_boss_cutscene_start_area_body_entered(body):
	if body is Player:
		boss_cutscene_initiated = true
		player.allow_input = false
		boss_cutscene_start_area.queue_free()
	
func _physics_process(_delta):
	if boss_fight_started:
		return
		
	if boss_cutscene_initiated and not boss_meetup_position_reached:
		move_player_towards_boss()
	if boss_meetup_position_reached:
		move_boss_towards_player()
	
func move_player_towards_boss():
	var distance_to_point = player.position.distance_to(boss_cutscene_player_position.position)
	if distance_to_point > 1:
		player.direction = (boss_cutscene_player_position.position - player.position).normalized()
	else:
		player.direction = Vector2.ZERO
		boss_meetup_position_reached = true
	

func move_boss_towards_player():
	var distance_to_point = boss.position.distance_to(arena_center.position)
	if distance_to_point > 1:
		boss.direction = (arena_center.position - boss.position).normalized()
		boss.velocity = boss.fly_speed * boss.direction
		boss.move_and_slide()
	else:
		if not boss_fight_started:
			boss.direction = Vector2.ZERO
			boss.is_following_player = false
			(boss.state_machine as BossStateMachine).stop_performing_actions()
			boss.legs_animation_player.play("Show")
			
			boss_fight_started = true
			player.allow_input = true
			(get_tree().get_first_node_in_group("HUD") as HUD).display_wave_text("FIGHT!")
			Util.play_time_stopped = false
	
