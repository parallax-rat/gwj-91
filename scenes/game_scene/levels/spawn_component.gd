class_name SpawnComponent
extends Node2D

@onready var camera: PhantomCamera2D = get_tree().get_nodes_in_group("stage_camera")[0]
@export var spawn_area: Area2D
@export var enabled: bool = true:
	set(value):
		enabled = value
		if value == true:
			time_tick.resume()
		if value == false:
			time_tick.pause()

@export_category("Enemy")
@export var enemy_scene: PackedScene
@export var enemy_to_spawn: int
@export var enemy_spawn_frequency: int = 5


var time_tick = TimeTick.new()
var spawned_count:int = 0
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	time_tick.initialize()
	time_tick.connect("tick_updated", _on_tick_updated)
	spawn_enemy(enemy_to_spawn)


func get_random_direction_2d() -> Vector2:
	# Start with a base direction, e.g., Vector2.RIGHT or Vector2(1, 0)
	var base_direction := Vector2.RIGHT
	# Generate a random angle in radians (TAU is 360 degrees)
	var random_angle := rng.randf_range(0.0, TAU)
	# Rotate the base direction by the random angle
	var random_direction := base_direction.rotated(random_angle)
	return random_direction



func _on_tick_updated(current_tick:int) -> void:
	if current_tick >= enemy_spawn_frequency:
		spawn_enemy(enemy_to_spawn)
		time_tick.reset()


func spawn_enemy(amount:int) -> void:
	for enemy in amount:
		var spawn_location = get_random_offscreen_position(spawn_area)
		var new_enemy = enemy_scene.instantiate()
		add_child(new_enemy)
		new_enemy.global_position = spawn_location


func get_hidden_spawn_location() -> EnemySpawnLocation:
	var spawn_locations = get_tree().get_nodes_in_group("enemy_spawn_location")
	for location in spawn_locations.size():
		var enemy_spawn_location = spawn_locations.pick_random()
		if enemy_spawn_location.get_visible() == false:
			return enemy_spawn_location
	return spawn_locations.pick_random()


func get_random_offscreen_position(target_area: Area2D, margin: float = 200.0, max_attempts: int = 24):
	var viewport_size = get_viewport_rect().size / camera.zoom
	
	var center = camera.global_position
	var half_size = viewport_size / 2.0
	
	var left = center.x - half_size.x
	var right = center.x + half_size.x
	var top = center.y - half_size.y
	var bottom = center.y + half_size.y
	
	left -= margin
	right += margin
	top -= margin
	bottom += margin
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collision_mask = target_area.collision_mask
	
	for i in max_attempts:
		var random_side = rng.randi_range(0, 3)
		var spawn_position = Vector2.ZERO
		
		if random_side == 0: # Top Edge
			spawn_position.x = rng.randf_range(left, right)
			spawn_position.y = top
		elif random_side == 1: # Right Edge
			spawn_position.x = right
			spawn_position.y = rng.randf_range(top, bottom)
		elif random_side == 2: # Bottom Edge
			spawn_position.x = rng.randf_range(left, right)
			spawn_position.y = bottom
		else: # Left Edge
			spawn_position.x = left
			spawn_position.y = rng.randf_range(top, bottom)
		query.position = spawn_position
		var results = space_state.intersect_point(query)
		for result in results:
			if result.collider == target_area:
				return spawn_position
	
	push_warning("SpawnComponent.get_random_offscreen_position: No valid spawn point found within max_attempts; skipping spawn.")
	return null


func is_point_in_area(point_to_check: Vector2, target_area: Area2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = point_to_check
	query.collide_with_areas = true
	query.collision_mask = target_area.collision_mask
	
	var results = space_state.intersect_point(query)
	for result in results:
		if result.collider == target_area:
			return true
	
	return false
