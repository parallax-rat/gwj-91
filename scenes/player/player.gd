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
var time_tick: TimeTick = TimeTick.new()

func _ready() -> void:
	time_tick.initialize(0.5)
	#time_tick.tick_updated.connect(_on_time_tick)
	health.max_value = starting_health
	health.fill()
	dna.deplete()
	dna.max_value = base_dna_to_level
	print_hp()
	print_dna()
	
	health.depleted.connect(_on_health_depleted)
	dna.restored_fully.connect(_on_dna_filled)


func print_hp() -> void:
	CLog.c(Color.PURPLE,"Health: ",health.value)
	CLog.c(Color.PURPLE,"Max Health: ",health.max_value)


func print_dna() -> void:
	CLog.c(Color.GREEN,"DNA: ",dna.value)
	CLog.c(Color.GREEN,"Max DNA: ",dna.max_value)


func _on_dna_siphon_body_entered(body: Node2D) -> void:
	if body is DNAPickup:
		body.collecting = true


func level_up() -> void:
	current_level += 1
	CLog.o("LEVEL UP")
	TweenFX.upgrade(sprite_2d,1,Color.GOLD,1.5)
	dna.set("value",0)
	dna.set("max_value",(base_dna_to_level * dna_to_level_growth_rate))
	print_dna()


func collect_dna(amount) -> void:
	dna.increase(amount)
	print_dna()


func _on_dna_filled(_dna) -> void:
	level_up()


func take_damage(amount:int) -> void:
	health.decrease(amount)


func _on_movement_component_direction_changed(new_direction: Vector2) -> void:
	if new_direction.x < 0:
		sprite_2d.flip_h = true
	if new_direction.x > 0:
		sprite_2d.flip_h = false


func _on_health_depleted(_health) -> void:
	CLog.c(Color.RED,"Player died")
	await TweenFX.stop_all(sprite_2d)
	%WinLoseManager.game_lost()
