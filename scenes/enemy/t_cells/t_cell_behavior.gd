class_name TCellEnemy
extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var dna_spawner: DNASpawner = $DnaSpawner


@export var starting_health: int
var health: StatPool = StatPool.new()


func _ready() -> void:
	TweenFX.idle_rubber(sprite_2d)
	health.max_value = starting_health
	health.value = starting_health
	health.depleted.connect(_on_depleted)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func take_damage(amount:int) -> void:
	health.decrease(amount)


func _on_depleted(_stat:StatPool) -> void:
	await dna_spawner.spawn_dna(sprite_2d.global_position)
	await TweenFX.stop_all(sprite_2d)
	queue_free()


func _on_damage_area_area_entered(area: Area2D) -> void:
	take_damage(area.full_damage)
