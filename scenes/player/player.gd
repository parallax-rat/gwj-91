class_name Player
extends CharacterBody2D

@onready var dna_siphon: Area2D = $DNASiphon

@export var health: StatPool
@export var dna: StatPool


func _on_dna_siphon_body_entered(body: Node2D) -> void:
	if body is DNAPickup:
		body.collecting = true


func increase_dna(amount:int) -> void:
	dna.increase(amount)
