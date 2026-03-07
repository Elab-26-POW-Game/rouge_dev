extends CharacterBody2D

class_name Character

@export_group("属性")
@export var HP : float = 16.0
@export var SPEED : float = 100.0
@export var ATK : float = 10.0

# 状态处理
var STATE := {
	isAttacking = false, # 是否攻击
	isHurting = false, # 是否被攻击
	isDead = false, # 是否死亡
}

var received_damage : int = 0
var attack_cd : bool = false
var target = null

@onready var animator = $AnimatedSprite2D
