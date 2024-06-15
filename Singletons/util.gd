extends Node

var show_tutorial = true

var play_time = 0.0
var play_time_stopped = true

enum PlayerState {
	IDLE,
	WALK,
	SHOOT,
	RELOAD,
	DIE,
	DASH
}

var enemy_per_wave_odds = {
	1: {
		"melee": 0.8, # 80% chance for spawning melee enemy
		"melee_basic": 1.0, # 100% chance for melee enemy to be "very basic enemy"
		"ranged_basic": 1.0 # 100% chance for ranged enemy to be "basic shooting enemy"
	},
	2: {
		"melee": 0.6,
		"melee_basic": 0.5, # 50% chance for melee enemy to be "very basic enemy"
		"ranged_basic": 0.8 # 80% chance for melee enemy to be "very basic enemy"
	},
	3: {
		"melee": 0.5,
		"melee_basic": 0.4,
		"ranged_basic": 0.6
	},
	4: {
		"melee": 0.4,
		"melee_basic": 0.0, # 100% chance for melee enemy to be "dashing enemy"
		"ranged_basic": 0.5
	},
	5: {
		"melee": 0.3,
		"melee_basic": 0.0,
		"ranged_basic": 0.3
	},
}

var room_difficulty_multiplier = 1.5
var waves_per_room = [2, 3, 3, 3, 3, 4, 4, 4, 5, 5]
var base_enemy_count_per_wave = [3, 3, 4, 4, 5]

func reset_play_time():
	play_time = 0.0

func update_play_time(delta):
	if not play_time_stopped:
		play_time += delta * 1000

func get_formatted_time() -> String:
	var time = Util.play_time
	time = floor(time)
	var minutes = int(time / 1000 / 60)
	var seconds = int(time / 1000) % 60
	var ms = (int(time) % 1000) / 10.0
	
	var formatted_time = ("%02d" % minutes) + (":%02d" % seconds) + (":%02d" % ms)
	return str(formatted_time)
