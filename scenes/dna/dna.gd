class_name DNAPickup
extends CharacterBody2D

# -- OnReady Variables -- #
@onready var sprite: Sprite2D = $Sprite2D
@onready var player: Player = get_tree().get_first_node_in_group("player")

# -- Export Variables -- #
@export var spawn_speed: float = 900
@export var base_speed: float = 300
@export var max_speed: float = 1200
@export var magnetic_strength: float = 500
@export var collection_distance: float = 24.0

var speed: float = base_speed
var collecting: bool = false
var collection_time_elapsed: float = 1.0

func _ready() -> void:
	TweenFX.orbit(sprite,1,1,0)
	TweenFX.glow_pulse(sprite,1,.1,.5)
	## TODO Randomize sprite on spawn


func random_spawn() -> void:
	velocity = global_position.direction_to(get_random_direction_2d())


func get_random_direction_2d() -> Vector2:
	# Start with a base direction, e.g., Vector2.RIGHT or Vector2(1, 0)
	var base_direction := Vector2.RIGHT
	# Generate a random angle in radians (TAU is 360 degrees)
	var random_angle := randf_range(0, TAU)
	# Rotate the base direction by the random angle
	var random_direction := base_direction.rotated(random_angle)
	return random_direction


func _physics_process(delta: float) -> void:
	if not collecting:
		return
	
	var distance_to_target = global_position.distance_to(player.global_position)
	if distance_to_target <= collection_distance:
		collect_dna()
		return
	
	collection_time_elapsed += delta * 2
	var speed_multiplier = base_speed * collection_time_elapsed
	speed = base_speed + speed_multiplier
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	
	move_and_slide()


func collect_dna() -> void:
	player.increase_dna(1)
	
	queue_free()
