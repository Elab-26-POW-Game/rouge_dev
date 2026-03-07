# 双开门.gd
extends Node2D

@onready var door0 = $AnimatedSprite2D
@onready var door1 = $Door1
@onready var collision = $CollisionShape2D

func _ready() -> void:
	door0.animation = "close"
	door1.animation = "close"

func open() -> void:
	door0.animation = "open"
	door1.animation = "open"
	collision.set_deferred("disabled", true)
