# 宝箱.gd
extends Props

## 是否被开过，@todo 发出战利品生成信号
var looted : bool = false

## @override 探测到生物，预处理
func handleEnteredBody(body: Node2D) -> void:
	if body.is_in_group("Player") and not looted:
		looted = true
		# 处理战利品......

## @override 处理互动事件
func handleInput() -> void:
	anim.play("open")
	
"""内置虚函数"""
func _ready() -> void:
	## @override 精灵图
	anim = $AnimatedSprite2D
