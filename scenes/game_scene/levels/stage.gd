extends Node2D

signal level_lost

var player: Player


func _ready() -> void:
	Constant.scene_root = self


func _on_player_died() -> void:
	level_lost.emit()
