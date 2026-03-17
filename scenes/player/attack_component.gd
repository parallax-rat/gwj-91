class_name AttackComponent
extends Node2D

@onready var attack_area: Area2D = $AttackRange
@onready var attack_area_shape: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var cooldown: Timer = $Cooldown
@onready var player: Player = get_tree().get_first_node_in_group("player")


## How wide the attack ring is without any mutations
@export var base_range: float = 164
## How much damage the attack deals without any mutations
@export var base_damage: int = 5
## How long between each attack without any mutations
@export var base_cooldown: float = 2
## How many enemies it can hit at once without any mutations
@export var base_targets: int = 1


var enemies_in_range: Array[Enemy] = []


func _ready() -> void:
	cooldown.wait_time = base_cooldown
	attack_area_shape.shape.radius = base_range






func attack() -> void:
	print("Attacking")
	if enemies_in_range.is_empty():
		return
	var target = enemies_in_range[0]
	## TODO Play SFX & Animation


func _on_attack_range_body_entered(body: Node2D) -> void:
	if not enemies_in_range.has(body):
		enemies_in_range.append(body)


func _on_attack_range_body_exited(body: Node2D) -> void:
	if enemies_in_range.has(body):
		var index = enemies_in_range.find(body)
		enemies_in_range.remove_at(index)
