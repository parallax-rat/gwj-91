class_name AttackComponent
extends Node2D

@onready var attack_area: Area2D = $AttackRange
@onready var attack_area_shape: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var cooldown_timer: Timer = $Cooldown
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var debug_ui: Control = get_tree().get_first_node_in_group("debug_ui")
@onready var attack_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cooldown_bar: HealthBarX2D = $CooldownBar


## How wide the attack ring is without any mutations
@export var base_range: float = 164
## How much damage the attack deals without any mutations
@export var base_damage: int = 5
## How long between each attack without any mutations
@export var base_cooldown: float = 1
## How many enemies it can hit at once without any mutations
@export var base_targets: int = 1


var enemies_in_range: Array[Enemy] = []
var current_target: Enemy = null
var cooldown: bool = false


func attack(repeat_attack:bool = false) -> void:
	if cooldown or enemies_in_range.is_empty():
		return
	if current_target:
		CLog.o("Attacking new target.")
		current_target = enemies_in_range[0]
	await attack_animation()
	current_target.take_damage(base_damage)
	
	## TODO Play SFX


func attack_animation() -> void:
	attack_sprite.look_at(current_target.global_position)
	attack_sprite.play("attack")
	await attack_sprite.animation_finished


func _on_attack_range_body_entered(body: Node2D) -> void:
	if not enemies_in_range.has(body):
		enemies_in_range.append(body)
		debug_ui.add_range_item(body)


func _on_attack_range_body_exited(body: Node2D) -> void:
	if enemies_in_range.has(body):
		var index = enemies_in_range.find(body)
		enemies_in_range.remove_at(index)
	if enemies_in_range.is_empty():
		current_target = null


func _on_cooldown_timeout() -> void:
	cooldown = false
