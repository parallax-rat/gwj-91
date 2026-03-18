extends Control

signal pubsub_message(pattern, channel, message)

@export var time_tick_label: Label

var gedis = Gedis.new()

func _ready() -> void:
	self.pubsub_message.connect(_on_time_tick)
	gedis.subscribe("time", self)


func _on_time_tick(_channel, message) -> void:
	CLog.o("Time tick")
	time_tick_label.text = str(message)
