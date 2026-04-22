#@icon("s")
extends Character
class_name Enemy

var path : Array[Vector2] = []

#@onready var navigation : NavigationRegion2D = get_tree().current_scene.get_node("NavigationRegion2D")
@onready var player : Character = get_tree().current_scene.get_node("Player")
@onready var StateMachine : FSM = $FSM
@onready var NavAgent: NavigationAgent2D = $NavigationAgent2D
@onready var NavigationTimer : Timer = $NavigationTimer
@onready var AttackTimer : Timer = $AttackTimer

func _ready() -> void:
	add_to_group("Enemy")
	#print(get_tree()dw.current_scene.get_children())
	# 设置寻路和目标的相关参数
	NavAgent.target_desired_distance = 16.0
	NavAgent.path_desired_distance = 16.0

## 攻击
func handleAttack() -> void:
	if player.is_dead:
		return
	if position.distance_to(player.position) > 16.0:
		return
	if NavAgent.is_navigation_finished():
		AttackTimer.start()

## 追击
func handleChase() -> void:
	if not player:
		return
		
	if not NavAgent.is_target_reachable()\
		or NavAgent.is_navigation_finished():
		move_dir = Vector2.ZERO
		return
	
	var next_pos : Vector2 = NavAgent.get_next_path_position()
		
	#if NavAgent.is_navigation_finished():	
		#return
		
	move_dir = global_position.direction_to(next_pos)
	# 左/右转
	Sprite.flip_h = true if move_dir.x < 0 else false

## 不要每帧都更新导航，否则速度会一直正负抖动
## @ref https://forum.godotengine.org/t/pathfinding-agent-jitters-when-reaching-destination/80455
func _on_navigation_timer_timeout() -> void:
	if is_instance_valid(player):
		NavAgent.target_position = player.global_position

func _on_attack_timer_timeout() -> void:
	print("攻击")
	StateMachine.state = StateMachine.states.attack
