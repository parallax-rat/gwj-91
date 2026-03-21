class_name EnemyAttackComponent
extends Node2D

@export_category("Parameters")
@export var damage: int = 5
@export var cooldown_value: float = 2
@export_category("Need Node Assignment")
@export var enemy_node: TCellEnemy
@export var sprite_2d: Sprite2D
@export_category("Self Assigned Nodes")
@export var cooldown_timer: Timer
@export var attack_sfx: AudioStreamPlayer2D


func _ready() -> void:
	if !enemy_node and not get_parent() == null:
		enemy_node = get_parent()


func _on_player_in_attack_range(player: Node2D) -> void:
	if cooldown_timer.is_stopped():
		cooldown_timer.start(cooldown_value)
		player.take_damage(damage)
		attack_sfx.play()
		TweenFX.stretch(sprite_2d,0.2,0.3)
