class_name EnemyParameters
extends Resource

@export var base_health: int = 5
@export var base_armor: int = 0
@export var base_speed: int = 100
@export var base_damage: int = 5
@export var base_attack_speed: int = 3
@export var sprite: Texture2D
@export_color_no_alpha var base_color: Color
@export_color_no_alpha var spotlight_color: Color
## The range of DNA that is able to drop from this enemy. X = minimum, Y = maximum.
@export var dna_drop_range: Vector2i
@export var abilities: Array[Ability]
@export var diseases: Array[Disease]
