extends CharacterBody2D
class_name Boss

@export_category("Boss Info")
@export var second_phase_threshold = 0.66
@export var third_phase_threshold = 0.33
@export var melee_damage: int = 1
@export var current_phase = 1

@export_category("Movement")
@export var walk_speed = 25.0
@export var fly_speed = 40.0
@export var is_following_player = true
@export var is_flying = false

@onready var body_animation_player = $BodyAnimationPlayer
@onready var legs_animation_player = $LegsAnimationPlayer

@onready var outline_sprite = $OutlineSprite
@onready var legs_sprite = $LegsSprite
@onready var shadows_sprite = $ShadowsSprite
@onready var body_sprite = $BodySprite

@onready var hitbox_component = $HitboxComponent
@onready var health_component = $HealthComponent
@onready var state_machine = $BossStateMachine as BossStateMachine

var notifier_scene = preload("res://Scenes/Util/on_screen_notifier_component.tscn") 
var notifier: OnScreenNotifierComponent

var direction: Vector2
var hostile = false

func _ready():
	notifier = notifier_scene.instantiate()
	notifier.color = Color.FIREBRICK
	add_child(notifier)
	
	change_to_flying()
	make_passive()

func _process(_delta):
	if not hostile:
		return
	
	var current_health = (health_component as HealthComponent).current_health
	var max_health = (health_component as HealthComponent).max_health
	
	if current_health <= max_health * third_phase_threshold:
		if current_phase != 3:
			current_phase = 3
			(state_machine as BossStateMachine).stop_performing_actions()
			state_machine.on_state_transition_to(state_machine.current_state, "BossIdle")
			is_following_player = false
			legs_animation_player.play("Show")
		
	elif current_health <= max_health * second_phase_threshold:
		if current_phase != 2:
			current_phase = 2
			(state_machine as BossStateMachine).stop_performing_actions()
			state_machine.on_state_transition_to(state_machine.current_state, "BossIdle")
			is_following_player = false
			legs_animation_player.play("Hide")
		
	else:
		current_phase = 1

func change_to_flying():
	is_flying = true
	$LegsSprite.visible = false
	$WalkingCollisionShape.set_deferred("disabled", true)
	$FlyingCollisionShape.set_deferred("disabled", false)
	$HitboxComponent/WalkingCollisionShape.set_deferred("disabled", true)
	$HitboxComponent/FlyingCollisionShape.set_deferred("disabled", false)
	$StepAudioPlayer.volume_db = -80
	set_collision_mask_value(2, false)

	make_hostile()

func change_to_walking():
	is_flying = false
	$LegsSprite.visible = true
	$WalkingCollisionShape.set_deferred("disabled", false)
	$FlyingCollisionShape.set_deferred("disabled", true)
	$HitboxComponent/WalkingCollisionShape.set_deferred("disabled", false)
	$HitboxComponent/FlyingCollisionShape.set_deferred("disabled", true)
	$StepAudioPlayer.volume_db = -5
	set_collision_mask_value(2, true)

	make_hostile()

func _on_legs_animation_player_animation_finished(anim_name):
	if anim_name == "Hide":
		change_to_flying()
	elif anim_name == "Show":
		change_to_walking()

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		area.damage(melee_damage)

func make_hostile():
	hostile = true
	is_following_player = true
	(state_machine as BossStateMachine).allow_performing_actions()
	set_collision_layer_value(4, true)
	notifier.should_be_visible = true

func make_passive():
	hostile = false
	is_following_player = false
	(state_machine as BossStateMachine).stop_performing_actions()
	set_collision_layer_value(4, false)
	notifier.should_be_visible = false
