extends Control

@export var player: Player
@export var player_hp_bar: HealthBarXControl
@export var player_dna_bar: HealthBarXControl


func _ready() -> void:
	player.dna.value_changed.connect(_on_dna_changed)
	player.health.value_changed.connect(_on_hp_changed)


func _on_dna_changed(_old_value:int, new_value:int, _increased:bool) -> void:
	player_dna_bar.set_value(new_value,true)


func _on_hp_changed(_old_value:int, new_value:int, _increased:bool) -> void:
	player_hp_bar.set_value(new_value,true)
