extends Area2D
class_name HitboxComponent

@export var health_component: HealthComponent

func damage(attack_damage: int):
	if health_component:
		health_component.take_damage(attack_damage)
