extends Node

@export var tween_animation: TweenFX.Animations
@export var tween_type: TweenFX.AnimationType
@export var sprite_2d: Sprite2D


func _ready() -> void:
	TweenFX.idle_rubber(sprite_2d,1,0.5)
