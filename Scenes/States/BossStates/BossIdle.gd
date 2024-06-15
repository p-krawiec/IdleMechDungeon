extends BossState
class_name BossIdle

@export_category("First Phase")
@export var perform_action_cooldown_1 = 2.0
@export var perform_action_range_1 = 350

@export_category("Second Phase")
@export var perform_action_cooldown_2 = 2.0
@export var perform_action_range_2 = 350

@export_category("Third Phase")
@export var perform_action_cooldown_3 = 2.0
@export var perform_action_range_3 = 350

@onready var perform_action_timer = $PerformActionTimer

var perform_action_range: float
var can_perform_actions = false
var perform_action = false

var big_shoot_range: float
var fast_shoot_range: float

func enter():
	perform_action = false
	match parent.current_phase:
		1:
			perform_action_timer.wait_time = perform_action_cooldown_1
			perform_action_range = perform_action_range_1
		2:
			perform_action_timer.wait_time = perform_action_cooldown_2
			perform_action_range = perform_action_range_2
		3:
			perform_action_timer.wait_time = perform_action_cooldown_3
			perform_action_range = perform_action_range_3
	
	if can_perform_actions:
		perform_action_timer.start()

func update(_delta):
	if not perform_action or player.is_dead:
		return
	
	distance_to_player = get_distance_to_player()
	if distance_to_player <= perform_action_range:
		var random_action = randi() % 3
		if random_action == 0:
			transition_to.emit(self, "BossBigShoot")
		elif random_action == 1:
			transition_to.emit(self, "BossFastShoot")
		elif random_action == 2:
			transition_to.emit(self, "BossDash")

func handle_animations():
	if parent.direction != Vector2.ZERO:
		play_walk_animation()
	else:
		parent.body_animation_player.play("Idle")

func play_walk_animation():
	if parent.is_flying:
		parent.body_animation_player.play("Fly")
	else:
		parent.body_animation_player.play("Walk")

func _on_perform_action_timer_timeout():
	if can_perform_actions:
		perform_action = true
	else:
		perform_action = false
