class_name Evolution extends Resource

@export_enum("Mutation", "Disease") var type
@export var evolution_name: String
@export var evolution_id: int
@export var current_level: int
@export var icon: Texture2D
@export var stat_to_modify: String
var base_value: float
var scaling_factor: float

func upgrade():
	pass
