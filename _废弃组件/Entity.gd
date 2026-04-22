## 所有实体的基类
extends CharacterBody2D

class_name Entity

## 出生光束
const SPAWN_LIGHT_VFX : PackedScene = preload("res://Scenes/特效/出生光束.tscn")

@onready var animator = $AnimatedSprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox

@export_group("属性")
@export var hp : float = 100.0
@export var atk : float = 10.0
@export var base_speed : float = 200.0

## 状态字典
var state := {
	is_walking = false,
	is_attacking = false,
	is_hurting = false,
	is_dead = false
}

## 攻击判定
var attack_cd : bool = false
var target = null
var received_damage : int = 0

## 处理动画状态
func handleAnim() -> void:
	pass

## 处理攻击逻辑
func handleAttack() -> void:
	pass

## 处理受伤逻辑
func handleHurt() -> void:
	pass

## 处理死亡逻辑
func handleDeath() -> void:
	if hp <= 0:
		state.is_dead = true

## 就绪
func _ready() -> void:
	var summon_vfx = SPAWN_LIGHT_VFX.instantiate()
	summon_vfx.position = self.position
	self.call_deferred("add_child", summon_vfx)

## 物理帧更新
func _physics_process(_delta: float) -> void:
	handleDeath()
	handleHurt()
	handleAttack()
	handleAnim()

## 动画结束回调
func _on_animated_sprite_2d_animation_finished() -> void:
	state.is_attacking = false

## body进入hitbox回调
func _on_hitbox_body_entered(body: Node2D) -> void:
	pass

## body退出hitbox回调
func _on_hitbox_body_exited(body: Node2D) -> void:
	pass
