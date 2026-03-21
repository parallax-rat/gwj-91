class_name DNASpawner
extends Node2D

const DNA = preload("uid://clxqc1vdcnnui")

var spawn_min: int = 0
var spawn_max: int = 3
var dna_parent: Node2D
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	dna_parent = get_tree().get_first_node_in_group("dna_node_parent")


func get_random_spawn_location() -> Vector2:
	var locations = get_tree().get_nodes_in_group("dna_spawn_location")
	return locations.pick_random().global_position


func spawn_dna(_location) -> void:
	var amount = rng.randi_range(1,100)
	if amount < 65:
		return
	var dna: DNAPickup = DNA.instantiate()
	dna_parent.call_deferred("add_child",dna)
	dna.global_position = _location
