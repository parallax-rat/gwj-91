extends Node2D

var player: Player



func _on_player_died() -> void:
	%WinLoseManager.game_lost()
