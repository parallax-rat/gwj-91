class_name Enemy
extends CharacterBody2D

@onready var damage_area: Area2D = $DamageArea
@onready var damage_delay: Timer = $DamageDelay
@onready var damage_shape: CollisionShape2D = $DamageArea/DamageShape
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSFX

@export var health: StatPool
@export var parameters: EnemyParameters

var valid_target: bool = false


func _on_spawned_successfully() -> void:
	TweenFX.idle_rubber(sprite_2d,1,0.1)
	health.max_value = parameters.base_health
	health.depleted.connect(_on_health_depleted)
	collision_layer = 4


func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * parameters.base_speed
	
	var distance_to_target = global_position.distance_to(player.global_position)
	if distance_to_target <= damage_shape.shape.radius:
		if damage_delay.is_stopped():
			attack()

	move_and_slide()


func attack() -> void:
	damage_delay.start(parameters.base_attack_speed)
	player.take_damage(parameters.base_damage)
	attack_sfx.play()
	TweenFX.stretch(sprite_2d)


func take_damage(amount: int) -> void:
	health.decrease(amount)
	TweenFX.shake(sprite_2d)
	if health.value <= 0:
		_on_health_depleted()


func _on_health_depleted(_unused_value: Variant = null) -> void:
	get_tree().get_first_node_in_group("spawn_component").spawn_dna_on_death(global_position)
	death_sfx.play()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	valid_target = true
