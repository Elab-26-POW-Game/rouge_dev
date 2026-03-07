# 门.gd
extends Node2D

@onready var door = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready() -> void:
	door.animation = "close"

func open() -> void:
	door.animation = "open"
	collision.set_deferred("disabled", true)
