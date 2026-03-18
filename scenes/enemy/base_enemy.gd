class_name Enemy
extends CharacterBody2D

@onready var damage_area: Area2D = $DamageArea
@onready var damage_delay: Timer = $DamageDelay
@onready var damage_shape: CollisionShape2D = $DamageArea/DamageShape
@onready var health_component: HealthComponent = $HealthComponent
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var parameters: EnemyParameters
@export var dna_drop: PackedScene

var gedis = Gedis.new()

func _ready() -> void:
	#TweenFX.idle_rubber(sprite_2d,3,0.4)
	health_component.max_health = parameters.base_health


func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * parameters.base_speed
	
	var distance_to_target = global_position.distance_to(player.global_position)
	if distance_to_target <= damage_shape.shape.radius:
		if damage_delay.is_stopped():
			damage_delay.start(parameters.base_attack_speed)
			player.health.decrease(parameters.base_damage)

	move_and_slide()


func take_damage(amount: int) -> bool:
	health_component.take_damage(amount)
	if health_component.current_health <= 0:
		health_component.is_dead()
		return true
	print(name," damaged. ",health_component.current_health, " remaining.")
	return false


func _on_health_component_died() -> void:
	get_tree().get_first_node_in_group("spawn_component").spawn_dna_on_death(global_position)
	#TweenFX.stop_all(self)
	queue_free()
