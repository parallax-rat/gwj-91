class_name RangeItem
extends VBoxContainer

@onready var index_label: Label = $EnemyLabels/Label
@onready var enemy_name_label: Label = $EnemyLabels/ClosestEnemyLabel

func _init(index:int, enemy:Enemy) -> void:
	index_label.text = str(index)
	enemy_name_label.text = enemy.name
	set_meta("enemy",enemy)
