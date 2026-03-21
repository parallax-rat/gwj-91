class_name Player
extends CharacterBody2D

@onready var dna_siphon: Area2D = $DNASiphon
@onready var collect_sfx: AudioStreamPlayer2D = $CollectSFX
@onready var sprite_2d: Sprite2D = $Sprite2D


@export var starting_health: int = 50
@export var base_dna_to_level:int = 8
@export var dna_to_level_growth_rate: float = 1.12

@export var evolutions: Array[Evolution]

var current_level: int = 1
var health: StatPool = StatPool.new()
var dna: StatPool = StatPool.new()


func _ready() -> void:
	health.max_value = starting_health
	CLog.o("Health: ",health.value)
	health.fill()
	CLog.o("Health(filled): ",health.value)
	dna.max_value = base_dna_to_level
	dna.deplete()


func _on_dna_siphon_body_entered(body: Node2D) -> void:
	if body is DNAPickup:
		body.collecting = true


func level_up() -> void:
	CLog.o("LEVEL UP")
	TweenFX.upgrade(sprite_2d,0.8,Color.GOLD,1.25)
	current_level += 1
	dna.deplete()
	dna.max_value = base_dna_to_level * dna_to_level_growth_rate


func increase_dna(amount:int) -> void:
	dna.increase(amount)
	
	if dna.is_filled():
		level_up()


func take_damage(amount:int) -> void:
	health.decrease(amount)
