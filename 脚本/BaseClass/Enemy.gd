extends Entity
## 监测区域
enum areas {DETECTION = 0, HITBOX = 1}

## 索敌范围
@onready var detection : CollisionShape2D = $"Areas/Detection"

## 初始化
func _init() -> void:
	# @override 基础属性
	hp = 30.0
	atk = 10.0
	base_speed = 50.0
	# @override Entity.state
	state.is_invoked = false
	self.platform_floor_layers = 0
	self.add_to_group("Enemy")

## 就绪
func _ready() -> void:
	super._ready()
	detection.set_deferred("disabled", true)
	# 刚出生等1s再行动
	await get_tree().create_timer(1.0).timeout
	detection.set_deferred("disabled", false)

## 物理帧更新
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# @fixed 会导致玩家头部接触史莱姆底部时，将玩家当做滑动面，导致史莱姆“黏”在玩家身上
	# 已解决，self.platform_floor_layers = 0即可
	self.move_and_slide()

## 处理动画状态
func handleAnim() -> void:
	if state.is_dead:
		# 先禁掉碰撞箱
		hurtbox.set_deferred("disabled", true)
		animator.animation = "death"
	
	elif state.is_hurting:
		animator.animation = "hurt"
		self.velocity = self.velocity.move_toward(Vector2(0, 0), base_speed)
	
	elif state.is_invoked and target and not state.is_attacking:
		animator.animation = "move"
		# 注意是全局定位
		var s = target.global_position - self.global_position
		s = s.normalized()
		if s.x < 0:
			animator.flip_h = true
		else:
			animator.flip_h = false
		# self.global_position += s
		self.velocity = s * base_speed
	
	else:
		animator.animation = "idle"

## 处理攻击逻辑
func handleAttack() -> void:
	if state.is_attacking and !state.is_dead and !state.is_hurting:
		if target and target.hp > 0 and !attack_cd:
			#hurtbox.set_deferred("disabled", true)
			target.state.is_hurting = true
			target.hp -= atk
			GameManager.cameraShake(4.0)
			self.set_deferred("attack_cd", true)
			$AttackCD.start()

## 处理受伤逻辑
func handleHurt() -> void:
	if state.is_hurting and !state.is_dead and animator.animation != "hurt":
		self.hp -= received_damage
		Debug.log("史莱姆剩余血量：" + String.num(self.hp))

## 处理死亡逻辑
func handleDeath() -> void:
	if hp <= 0:
		state.is_dead = true

func _on_attack_cd_timeout() -> void:
	self.set_deferred("attack_cd", false)

func _on_animation_finished() -> void:
	animator.play()
	if animator.animation == "death":
		# self.hide()
		self.queue_free()
		
	if animator.animation == "hurt":
		state.is_hurting = false

func _on_areas_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	match local_shape_index:
		areas.DETECTION:
			if body.is_in_group("Player"):
				target = body
				state.is_invoked = true
		areas.HITBOX:
			if body.is_in_group("Player"):
				state.is_attacking = true

func _on_areas_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	match local_shape_index:
		areas.DETECTION:
			if body.is_in_group("Player"):
				target = null
				state.is_invoked = false
				self.velocity = self.velocity.move_toward(Vector2(0, 0), base_speed)
		areas.HITBOX:
			if body.is_in_group("Player"):
				state.is_attacking = false
