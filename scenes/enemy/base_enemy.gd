class_name Enemy
extends CharacterBody2D

@onready var damage_area: Area2D = $DamageArea
@onready var damage_delay: Timer = $DamageDelay
@onready var damage_shape: CollisionShape2D = $DamageArea/DamageShape
@onready var health_component: HealthComponent = $HealthComponent
@onready var player: Player = get_tree().get_first_node_in_group("player")

@export var parameters: EnemyParameters
@export var dna_drop: PackedScene


func _ready() -> void:
	health_component.max_health = parameters.base_health
	health_component.current_health = health_component.max_health
	print(player)


func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * parameters.base_speed
	
	var distance_to_target = global_position.distance_to(player.global_position)
	if distance_to_target <= damage_shape.shape.radius:
		if damage_delay.is_stopped():
			damage_delay.start(parameters.base_attack_speed)
			player.health.decrease(parameters.base_damage)

	move_and_slide()


func take_damage(amount: int) -> void:
	health_component.take_damage(amount)
	print(name," damaged. ",health_component.current_health, " remaining.")


func _on_health_component_died() -> void:
	var dna_drop_quantity = randi_range(parameters.dna_drop_range.x, parameters.dna_drop_range.y)
	for i in dna_drop_quantity:
		var new_dna = dna_drop.instantiate()
		get_tree().root.add_child(new_dna)
		new_dna.global_position = get_random_direction() * 10


func get_random_direction() -> Vector2:
	var random_angle = randf() * TAU
	return Vector2.from_angle(random_angle)
