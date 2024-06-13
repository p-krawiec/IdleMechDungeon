extends CharacterBody2D
class_name Boss

@export_category("Boss Info")
@export var second_phase_threshold = 0.5
@export var third_phase_threshold = 0.15
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
var notifier_scene = preload("res://Scenes/Util/on_screen_notifier_component.tscn") 

var direction: Vector2

func ready():
	var notifier = notifier_scene.instantiate()
	notifier.color = Color.FIREBRICK
	add_child(notifier)

func _physics_process(_delta):
	if Input.is_action_just_pressed("debug"):
		is_following_player = false
		if is_flying:
			legs_animation_player.play("Show")
		else:
			legs_animation_player.play("Hide")

func change_to_flying():
	is_flying = true
	$LegsSprite.visible = false
	$WalkingCollisionShape.set_deferred("disabled", true)
	$FlyingCollisionShape.set_deferred("disabled", false)
	$HitboxComponent/WalkingCollisionShape.set_deferred("disabled", true)
	$HitboxComponent/FlyingCollisionShape.set_deferred("disabled", false)
	set_collision_mask_value(2, false)

	is_following_player = true

func change_to_walking():
	is_flying = false
	$LegsSprite.visible = true
	$WalkingCollisionShape.set_deferred("disabled", false)
	$FlyingCollisionShape.set_deferred("disabled", true)
	$HitboxComponent/WalkingCollisionShape.set_deferred("disabled", false)
	$HitboxComponent/FlyingCollisionShape.set_deferred("disabled", true)
	set_collision_mask_value(2, true)

	is_following_player = true

func _on_legs_animation_player_animation_finished(anim_name):
	if anim_name == "Hide":
		change_to_flying()
	elif anim_name == "Show":
		change_to_walking()

func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		area.damage(melee_damage)
