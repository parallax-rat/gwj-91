class_name DNAPickup
extends CharacterBody2D

# -- Constants -- #
const BASE_COLLISION_RADIUS: float = 6.0
const BASE_SPRITE_SCALE: Vector2 = Vector2(0.063,0.063)

# -- OnReady Variables -- #
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var follower_component: EightDirFollowerComponent = $EightDirFollowerComponent
@onready var label: Label = $Label

# -- Export Variables -- #
@export var base_speed: float = 150.0
@export var max_speed: float = 1200.0
@export var magnetic_strength: float = 500.0
@export var collection_distance: float = 20.0

var collection_time_elapsed: float = 1.0

func _ready() -> void:
	call_deferred("randomize_size") # -- Randomize the size of the DNA shard when it's created, for some visual variety
	follower_component.speed = base_speed

func _physics_process(delta: float) -> void:
	if not follower_component.enabled or follower_component.leader == null:
		return
	
	var distance_to_target = global_position.distance_to(follower_component.leader.global_position)
	if distance_to_target <= collection_distance:
		collect_dna()
		return
	
	collection_time_elapsed += delta * 2
	var speed_multiplier = base_speed * collection_time_elapsed
	follower_component.speed = base_speed + speed_multiplier
	label.text = str(follower_component.speed).pad_decimals(2)


func get_leader() -> Variant:
	return follower_component.leader


func set_leader(new_leader: Node2D) -> void:
	follower_component.leader = new_leader
	follower_component.enabled = true


func randomize_size() -> void:
	var randomized_scalar = randf_range(0.75, 1.25)
	sprite.scale = BASE_SPRITE_SCALE * randomized_scalar
	collision_shape.shape.radius = BASE_COLLISION_RADIUS * randomized_scalar


func collect_dna() -> void:
	follower_component.leader.increase_dna(1)
	queue_free()
