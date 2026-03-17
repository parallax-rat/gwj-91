class_name SpawnComponent
extends Node2D

@onready var camera: PhantomCamera2D = get_tree().get_nodes_in_group("stage_camera")[0]
@onready var time_tick_label: Label = get_tree().get_nodes_in_group("tick_time_label")[0]

@export var scene_to_spawn: PackedScene
@export var number_to_spawn: int
@export var spawn_frequency: int = 5

var time_tick = TimeTick.new()

func _ready() -> void:
	time_tick.initialize()
	time_tick.connect("tick_updated", _on_tick_updated)


func _on_tick_updated(current_tick:int) -> void:
	if current_tick >= spawn_frequency:
		spawn_enemy()
		time_tick.reset()
	time_tick_label.text = str(current_tick)


func spawn_enemy() -> void:
	for enemy in number_to_spawn:
		var offscreen_location = get_random_offscreen_position(camera)
		var new_enemy = scene_to_spawn.instantiate()
		add_child(new_enemy)
		new_enemy.global_position = offscreen_location

func get_random_offscreen_position(camera: PhantomCamera2D, margin: float = 100.0) -> Vector2:
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
	
	var random_side = randi() % 4
	var spawn_position = Vector2.ZERO
	
	if random_side == 0: # Top Edge
		spawn_position.x = randf_range(left, right)
		spawn_position.y = top
	elif random_side == 1: # Right Edge
		spawn_position.x = right
		spawn_position.y = randf_range(top, bottom)
	elif random_side == 2: # Bottom Edge
		spawn_position.x = randf_range(left, right)
		spawn_position.y = bottom
	else: # Left Edge
		spawn_position.x = left
		spawn_position.y = randf_range(top, bottom)

	return spawn_position
