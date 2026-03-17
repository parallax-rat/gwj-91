extends Control

@onready var enemies_in_range_container: VBoxContainer = $EnemiesInRangeDebug/EnemiesInRangeVertBox

func add_range_item(enemy:Enemy) -> void:
	var new_enemy_in_range = RangeItem.new(enemies_in_range_container.get_child_count(),enemy)
	enemies_in_range_container.add_child(new_enemy_in_range)


func remove_range_item(enemy:Enemy) -> void:
	var range_items = enemies_in_range_container.get_children()
	if range_items.is_empty():
		return
	if range_items.has(enemy):
		var _index = range_items.find(enemy)
		enemies_in_range_container.get_child(_index).queue_free()
