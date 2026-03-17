class_name Player
extends CharacterBody2D

@onready var dna_siphon: Area2D = $DNASiphon

@export var health: StatPool
@export var dna: StatPool


func _on_dna_siphon_body_entered(body: Node2D) -> void:
	if body is DNAPickup and body.get_leader() == null:
		body.set_leader(self)





func increase_dna(amount:float) -> void:
	dna.increase(amount)
