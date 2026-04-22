extends CharacterBody2D
class_name Character

"""信号"""
signal hp_change(new_hp : float)

"""变量"""
@export_group("移动数值")
@export var ACCELERATION : float = 20.0
@export var BASE_SPEED : float = 100.0
@export var RUN_SPEED : float = 200.0

@export_group("战斗数值")
@export var HP : float = 100.0:
	set(new_hp):
		HP = new_hp
		hp_change.emit(new_hp)
	get:
		return HP
		
@export var ATK : float = 10.0 

var is_dead : bool = false
var is_attacking : bool = false
var is_hurting : bool = false
var move_dir : Vector2 = Vector2.ZERO

@onready var Sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var Anim : AnimationPlayer = $AnimationPlayer 
@onready var AttackHitbox : Hitbox = $Hitbox
@onready var StatMachine : FSM = $FSM

"""函数"""
func _ready() -> void:
	AttackHitbox.body_entered.connect(_on_hitbox_body_entered)

## 移动
func handleMove(speed_limit : float = BASE_SPEED) -> void:
	if move_dir:
		move_dir = move_dir.normalized()
		velocity += move_dir * ACCELERATION
		velocity = velocity.limit_length(speed_limit)
	else:
		velocity = velocity.move_toward(Vector2(0, 0), ACCELERATION)
	move_and_slide()

## 受伤
func takeDamage(dmg : float, dir : Vector2 = AttackHitbox.knockback_dir, force : int = AttackHitbox.knockback_force) -> void:
	if is_hurting or is_dead:
		return
	HP -= dmg
	velocity += dir * force
	if HP > 0.0:
		StatMachine.state = StatMachine.states.hurt
	else:
		is_dead = true
		StatMachine.state = StatMachine.states.death

"""@内置->初始化"""
func _init() -> void:
	pass
	
"""Hitbox"""
func _on_hitbox_body_entered(body : PhysicsBody2D):
	if body == self:
		return
	print(self.name + "攻击" + body.name)
	body.takeDamage(ATK, AttackHitbox.knockback_dir, AttackHitbox.knockback_force)
