extends Control

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var player_hp_bar: ProgressBar = %PlayerHPBar
@onready var player_dna_bar: ProgressBar = %PlayerDNABar


func _ready() -> void:
	call_deferred("connect_nodes")


func connect_nodes() -> void:
	player_hp_bar.set("value",player.health.value)
	player_hp_bar.set("max_value",player.health.max_value)
	player_dna_bar.set("value",player.dna.value)
	player_dna_bar.set("max_value",player.dna.max_value)
	
	player.health.value_changed.connect(_on_hp_changed)
	player.dna.value_changed.connect(_on_dna_changed)


func _on_dna_changed(_old_value:int, new_value:int, _increased:bool) -> void:
	player_dna_bar.set("value",new_value)


func _on_hp_changed(_old_value:int, new_value:int, _increased:bool) -> void:
	player_hp_bar.set("value",new_value)
