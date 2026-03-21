class_name EnemySpawnLocation
extends Marker2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


func get_visible() -> bool:
	if visible_on_screen_notifier_2d.is_on_screen():
		return true
	else:
		return false
