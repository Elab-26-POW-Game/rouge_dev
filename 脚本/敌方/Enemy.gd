extends CharacterBody2D

@export_group("属性")
@export var HP : float = 16.0
@export var SPEED : float = 100.0
@export var ATK : float = 10.0

# 状态处理
var STATE := {
	isAttacking = false, # 是否攻击
	isHurting = false, # 是否被攻击
	isDead = false, # 是否死亡
	isInvoked = false # 被唤醒	
}
var received_damage : int = 0
var attack_cd : bool = false
var target = null # 玩家

@onready var animator = $AnimatedSprite2D

"""动画"""
func handleAnim() -> void:
	if STATE.isDead:
		animator.animation = "death"
	
	elif STATE.isHurting:
		animator.animation = "hurt"
	
	elif STATE.isInvoked and target:
		animator.animation = "move"
		var s = (target.position - self.position) / SPEED
		if s.x < 0:
			animator.flip_h = true
		else:
			animator.flip_h = false
		# print(s)
		self.position += (target.position - self.position) / SPEED
	
	else:
		animator.animation = "idle"
		

"""攻击"""
func handleAttack() -> void:
	if STATE.isAttacking and !attack_cd and !STATE.isDead and !STATE.isHurting:
		if target and target.HP > 0:
			target.HP -= ATK
			GameManager.cameraShake(4.0)
			attack_cd = true
			$AttackCD.start()
			Debug.log("玩家剩余血量：" + String.num(target.HP))


"""受伤"""
func handleHurt() -> void:
	if STATE.isHurting and !STATE.isDead and animator.animation != "hurt":
		self.HP -= received_damage
		Debug.log("史莱姆剩余血量：" + String.num(self.HP))


"""死亡"""
func handleDeath() -> void:
	if HP <= 0:
		STATE.isDead = true
			

func _init() -> void:
	self.add_to_group("敌人")


func _physics_process(delta: float) -> void:
	handleDeath()
	handleHurt()
	handleAnim()
	handleAttack()
	# print(STATE.isHurting, " " ,STATE.isDead)
	

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("玩家"):
		target = body
		STATE.isInvoked = true


func _on_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("玩家"):
		target = null
		STATE.isInvoked = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("玩家"):
		STATE.isAttacking = true
	

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("玩家"):
		STATE.isAttacking = false


func _on_attack_cd_timeout() -> void:
	attack_cd = false


func _on_animation_finished() -> void:
	animator.play()
	if animator.animation == "death":
		$CollisionShape2D.set_deferred("disabled", true)
		self.hide()
	if animator.animation == "hurt":
		STATE.isHurting = false
