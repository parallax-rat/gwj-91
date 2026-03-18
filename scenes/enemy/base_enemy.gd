class_name Enemy
extends CharacterBody2D

@onready var damage_area: Area2D = $DamageArea
@onready var damage_delay: Timer = $DamageDelay
@onready var damage_shape: CollisionShape2D = $DamageArea/DamageShape
@onready var health_component: HealthComponent = $HealthComponent
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSFX
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D


@export var parameters: EnemyParameters
@export var dna_drop: PackedScene

var gedis = Gedis.new()

func _ready() -> void:
	var tween = TweenFX.idle_rubber(sprite_2d,3,0.4)
	health_component.max_health = parameters.base_health


func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * parameters.base_speed
	
	var distance_to_target = global_position.distance_to(player.global_position)
	if distance_to_target <= damage_shape.shape.radius:
		if damage_delay.is_stopped():
			attack()
			recoil()

	move_and_slide()


func attack() -> void:
	damage_delay.start(parameters.base_attack_speed)
	player.health.decrease(parameters.base_damage)
	attack_sfx.play()
	TweenFX.stretch(sprite_2d)


func recoil() -> void:
	var direction = global_position.direction_to(player.global_position) * -1
	

func take_damage(amount: int) -> void:
	health_component.take_damage(amount)
	TweenFX.shake(sprite_2d)
	cpu_particles_2d.emitting = true
	#if health_component.current_health <= 0:
		#health_component.is_dead()
	#print(name," damaged. ",health_component.current_health, " remaining.")


func _on_health_component_died() -> void:
	get_tree().get_first_node_in_group("spawn_component").spawn_dna_on_death(global_position)
	death_sfx.play()
	cpu_particles_2d.emitting = true
	TweenFX.stop(sprite_2d, TweenFX.Animations.IDLE_RUBBER)
	queue_free()
