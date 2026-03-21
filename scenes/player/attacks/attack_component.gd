class_name AttackComponent
extends Area2D

@onready var attack_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_enum("Contact", "Auto") var type
## How wide the attack ring is without any mutations
@export var base_range: float = 164
## How much damage the attack deals without any mutations
@export var base_damage: int = 5
## How long between each attack without any mutations
@export var base_cooldown: float = 1
## How many enemies it can hit at once without any mutations
@export var base_targets: int = 1
@export var evolutions: Array[Evolution]

var full_damage: float = base_damage


func evolve_attack(new_effect:Evolution) -> void:
	base_damage = base_damage * new_effect.damage_mult_modifier


func _on_movement_component_direction_changed(new_direction: Vector2) -> void:
	if new_direction.x < 0:
		attack_sprite.flip_h = true
	if new_direction.x > 0:
		attack_sprite.flip_h = false
