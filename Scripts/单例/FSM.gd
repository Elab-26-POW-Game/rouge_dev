extends Node
## FiniteStateMachine 有限状态机
## 维护了状态机的增查改
## 开发规范：
class_name FSM

"""变量"""
var states : Dictionary = {}
var prev_state : int = -1
var state : int = -1:
	set(n_stat):
		_exit_state(state)
		prev_state = state
		state = n_stat
		_enter_state(prev_state, state)
	get:
		return state
		
@onready var parent : CharacterBody2D = get_parent()
@onready var Anim : AnimationPlayer = parent.get_node("AnimationPlayer")

"""函数"""
## 状态机逻辑虚函数
func _state_logic(_delta : float) -> void:
	pass

## 获取切换状态虚函数
func _get_transition() -> int:
	return -1
	
## 进入状态虚函数
func _enter_state(_prev_stat : int, n_stat : int) -> void:
	pass
	
## 退出状态虚函数
func _exit_state(_e_stat : int) -> void:
	pass

## 增加新状态虚函数
func _add_state(n_stat : String) -> void:
	states[n_stat] = states.size()

func _physics_process(delta: float) -> void:
	# 只要状态不为空就更新状态机逻辑
	if state != -1:
		_state_logic(delta)
		var trans : int = _get_transition()
		if trans != -1:
			state = trans
