class_name DNASpawner
extends Node2D

const DNA = preload("uid://clxqc1vdcnnui")

@onready var spawn_locations: Node2D = $SpawnLocations


var dna_parent: Node2D
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func spawn_dna(enemy_amount:int = 1) -> void:
	var amount = rng.randi_range(0,enemy_amount) # 50% chance to drop 1 dna. Enemy can provide a higher threshold
	for i in amount:
		var dna = DNA.instantiate()
		Constant.dna_root.call_deferred("add_child",dna)
		var spawn_marker = spawn_locations.get_children().pick_random()
		dna.global_position = spawn_marker.global_position
