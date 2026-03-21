class_name EnemyMovementComponent
extends Node2D


@export_category("Parameters")
@export var player_group_name: String
@export var speed: float = 180
@export_category("Need Node Assignment")
@export var enemy_node: TCellEnemy
@export_category("Self Assigned Nodes")
@export var navigation_agent_2d: NavigationAgent2D

var player: Player

func _ready() -> void:
	if !enemy_node and not get_parent() == null:
		enemy_node = get_parent()
	player = get_tree().get_first_node_in_group(player_group_name)


func _physics_process(_delta: float) -> void:
	navigation_agent_2d.target_position = player.global_position
	var next_path = navigation_agent_2d.get_next_path_position()
	enemy_node.velocity = enemy_node.global_position.direction_to(next_path) * speed
