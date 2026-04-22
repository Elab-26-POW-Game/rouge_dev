extends FSM

# 随机数发生器
var rng = RandomNumberGenerator.new()

func _init() -> void:
	_add_state("idle")
	_add_state("blink")
	_add_state("move")
	_add_state("attack")
	_add_state("hurt")
	_add_state("death")

func _ready() -> void:
	state = states.idle
	parent.attack.connect(func(): 
		parent.is_attacking = true
		state = states.attack
	)

## @override 状态机逻辑虚函数
func _state_logic(_delta : float) -> void:
	if parent.is_dead or parent.is_attacking:
		return
	parent.handleAttack()
	parent.handleMove()

## @override获取切换状态虚函数
func _get_transition() -> int:
	if Input.is_key_pressed(KEY_R):
		parent.is_dead = false
		parent.is_attacking = false
		parent.HP = 100.0
		return states.idle
	
	if Input.is_key_pressed(KEY_K) or parent.HP <= 0:
		if not parent.is_dead:
			parent.HP = 0.0
			return states.death
			
	match state:
		#states.hurt:
			#if not parent.is_hurting:
				#return states.idle
		states.attack:
			# 千万补药 await Anim.animation_finished
			# 会出各种诡异BUG
			if not Anim.is_playing():
				return states.idle
		states.blink:
			if not Anim.is_playing():
				return states.idle
		states.idle:
			if parent.velocity.length() > 10:
				return states.move
			if not Anim.is_playing():
				var _s : int = rng.randi_range(1, 5)
				if 1 <= _s and _s <= 4:
					return states.idle
				else:
					return states.blink
		states.move:
			# 速度足够小就停下来
			if parent.velocity.length() < 10:
				return states.idle
	return -1

## @override 进入状态虚函数
func _enter_state(_prev_stat : int, n_stat : int) -> void:
	match n_stat:
		states.death:
			parent.is_dead = true
			Anim.play("death")
			#parent.queue_free()
		states.hurt:
			parent.hurtVfx()
		states.attack:
			if parent.attack_time >= 3:
				parent.attack_time = 0
			parent.attack_time += 1
			if parent.attack_time <=2:
				# 轻击，第4帧震动
				Anim.play("attack1") 
			else:
				# 重击，第6帧震动
				Anim.play("attack2") 
		states.idle:
			Anim.play("idle")
		states.blink:
			Anim.play("blink")
		states.move:
			Anim.play("move")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"attack1", "attack2":
			parent.is_attacking = false
