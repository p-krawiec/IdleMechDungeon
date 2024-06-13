extends BossState
class_name BossIdle

@export var perform_action_cooldown = 2.0
@export var perform_action_range = 300

@onready var perform_action_timer = $PerformActionTimer

var can_perform_action = false

var big_shoot_range: float
var fast_shoot_range: float

func enter():
	can_perform_action = false
	perform_action_timer.wait_time = perform_action_cooldown
	perform_action_timer.start()

func update(_delta):
	if not can_perform_action:
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
	can_perform_action = true
