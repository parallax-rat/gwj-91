extends Control

@onready var player_hp_bar: HealthBarXControl = %PlayerHPBar
@onready var player_dna_bar: HealthBarXControl = %PlayerDNABar

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

func _ready() -> void:
	player.dna.value_changed.connect(_on_dna_changed)
	player.health.value_changed.connect(_on_hp_changed)


func _on_dna_changed(_old_value:int, new_value:int, _increased:bool) -> void:
	player_dna_bar.set_value(new_value,true)


func _on_hp_changed(_old_value:int, new_value:int, _increased:bool) -> void:
	player_hp_bar.set_value(new_value,true)
