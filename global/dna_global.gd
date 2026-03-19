extends Node

signal subpub_message(channel, message)

var gedis = Gedis.new()

func _ready() -> void:
	self.subpub_message.connect(spawn_dna)
	gedis.subscribe("DNA",self)

func spawn_dna(channel, message) -> void:
	CLog.o("Spawn DNA Message Received")
