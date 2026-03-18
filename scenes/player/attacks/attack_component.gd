class_name AttackComponent
extends Node2D

signal enemy_death(pattern, channel, message)

@onready var attack_area: Area2D = $AttackRange
@onready var attack_area_shape: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var cooldown_timer: Timer = $Cooldown
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var debug_ui: Control = get_tree().get_first_node_in_group("debug_ui")
@onready var attack_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cooldown_bar: HealthBarX2D = $CooldownBar
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSFX


## How wide the attack ring is without any mutations
@export var base_range: float = 164
## How much damage the attack deals without any mutations
@export var base_damage: int = 5
## How long between each attack without any mutations
@export var base_cooldown: float = 1
## How many enemies it can hit at once without any mutations
@export var base_targets: int = 1


var enemies_in_range: Array[Enemy] = []
var target: Enemy = null
var cooldown: bool = false
var gedis = Gedis.new()


func _ready() -> void:
	self.enemy_death.connect(_on_target_died)
	gedis.subscribe("enemy_death", self)


func _process(_delta: float) -> void:
	cooldown_bar.value = cooldown_timer.time_left
	
	if cooldown: ## Is the attack on cooldown?
		return # Do nothing
	
	if target: ## Do I have a target?
		if enemies_in_range.has(target): ## Is that target still in range?
			attack()
	
	if enemies_in_range.size() > 0: ## Are there enemies in range?
		target = enemies_in_range[0] # Set closest as the new target
		attack()
		## NOTE ---- If closest enemy not being attacked:
		## --------- might need to check for distance, and
		## --------- append to a new array on_body_entered 
		## --------- instead so the index stays ordered.


func attack() -> void:
	if target == null:
		return
	attack_sprite.look_at(target.global_position)
	attack_sprite.play("attack")
	target.take_damage(base_damage)
	cooldown_timer.start()
	cooldown = true
	attack_sfx.play()


func _on_attack_range_body_entered(body: Node2D) -> void:
	enemies_in_range.append(body)
	gedis.publish("enemy_enter_range", body)


func _on_attack_range_body_exited(body: Node2D) -> void:
	var index = enemies_in_range.find(body)
	enemies_in_range.remove_at(index)
	gedis.publish("enemy_exit_range", body)


func _on_cooldown_timeout() -> void:
	CLog.o("Cooldown done")
	cooldown = false
	gedis.publish("player:attack_cooldown", false)


func _on_target_died() -> void:
	CLog.o("Target killed.")
	target = null
