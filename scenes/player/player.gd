class_name Player
extends CharacterBody2D

@onready var dna_siphon: Area2D = $DNASiphon
@onready var collect_sfx: AudioStreamPlayer2D = $CollectSFX
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var health: StatPool
@export var dna: StatPool


func _on_dna_siphon_body_entered(body: Node2D) -> void:
	if body is DNAPickup:
		body.collecting = true


func increase_dna(amount:int) -> void:
	dna.increase(amount)
	collect_sfx.play()


func take_damage(amount:int) -> void:
	health_component.take_damage(amount)
	TweenFX.shake(sprite_2d)
	TweenFX.blink(sprite_2d,1,4,0,1)
