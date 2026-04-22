extends FSM

func _init() -> void:
	_add_state("chase")
	_add_state("attack")
	_add_state("hurt")
	_add_state("death")

func _ready() -> void:
	state = states.chase
	
## @override 状态机逻辑虚函数
func _state_logic(_delta : float) -> void:
	if state == states.chase:
		parent.handleChase()
	parent.handleAttack()
	parent.handleMove()
		
## @override 获取切换状态虚函数
func _get_transition() -> int:
	match state:
		states.chase:
			return states.chase
		states.attack:
			if not Anim.is_playing():
				return states.chase
		states.hurt:
			if not Anim.is_playing():
				return states.chase
		states.death:
			if not Anim.is_playing():
				parent.queue_free()
	return -1
	
## @override 进入状态虚函数
func _enter_state(_prev_stat : int, n_stat : int) -> void:
	match n_stat:
		states.attack:
			Anim.play("attack")
		states.chase:
			Anim.play("move")
		states.hurt:
			Anim.play("hurt")
		states.death:
			Anim.play("death")
			
