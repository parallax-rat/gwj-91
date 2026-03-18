class_name RangeItem
extends VBoxContainer

@export var index_label: Label
@export var closest_enemy_label: Label

func assign(index:int, enemy:Enemy) -> void:
	set_meta("enemy",enemy)
	index_label.text = str(index)
	closest_enemy_label.text = enemy.name
