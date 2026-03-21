class_name TCellEnemy
extends CharacterBody2D

@export var starting_health: int
var health: StatPool = StatPool.new()


func _ready() -> void:
	health.max_value = starting_health
	health.value = starting_health
	health.depleted.connect(_on_depleted)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func take_damage(amount:int) -> void:
	health.decrease(amount)


func _on_depleted(_stat:StatPool) -> void:
	queue_free()


func _on_damage_area_area_entered(area: AttackComponent) -> void:
	take_damage(area.full_damage)
