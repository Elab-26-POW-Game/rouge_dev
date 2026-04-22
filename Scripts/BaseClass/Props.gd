# 宝箱.gd
extends StaticBody2D
class_name Props

## 精灵图
@onready var anim = $AnimatedSprite2D

## 对象是否在交互范围内
var target_in_range : bool = false

## 探测到生物，预处理
func handleEnteredBody(body: Node2D) -> void:
	pass

## 处理互动事件
func handleInput() -> void:
	pass

"""内置虚函数一般是不用重写的"""
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		target_in_range = true
	handleEnteredBody(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		target_in_range = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("互动") and target_in_range == true:
		handleInput()
