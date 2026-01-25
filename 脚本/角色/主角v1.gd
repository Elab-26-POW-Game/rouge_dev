"""
================================
语法习惯：对象内置属性前必须加self
		自定义属性则不加
================================
"""
extends CharacterBody2D

@onready var animator = $AnimatedSprite2D

@export_group("属性")
@export var HP : float = 100.0
@export var ATK : float = 10.0
@export var WALK_SPEED : float = 200.0
@export var RUN_SPEED : float = 400.0

# 四个方向 -> up right left down
var facing : String = "down"	
var isWalking : bool = false
var isAttacking : bool = false
# var isHurting : bool = false
var isDead : bool = false

# 攻击判定
# var inAttackRange : bool = false
var attack_cd : bool = true
var enemy = null


"""处理角色动画"""
func changeAnimation(anim : String = "idle_down") -> void:
	var anim_list = animator.sprite_frames.get_animation_names()
	if anim in anim_list:
		animator.animation = anim
		# print(anim)
	else:
		Debug.warn("动画" + anim + "不在该角色的动画列表中！")
		animator.animation = "idle_down"
	
		
func changeAction(action : String = "idle") -> void:
	animator.play()
	if facing in ["up", "down"]:
		changeAnimation(action + "_" + facing)
	else:
		animator.flip_h = true if facing == "left" else false
		changeAnimation(action + "_side")


func handleAnim() -> void:
	if isDead and animator.animation != "death":
		# DialogManager.show()
		changeAnimation("death")
		
		
	elif !isDead:
		if isAttacking:
			changeAction("attack")
		
		elif isWalking and !isAttacking:
			changeAction("walk")
		else:
			changeAction("idle")
	
		
"""处理角色攻击"""
func handleAttack() -> void:
	if Input.is_action_just_pressed("攻击") and !isDead:
		if !isAttacking:
			GameManager.cameraShake(5.0)
		isAttacking = true
		if enemy and enemy.STATE.isHurting == false:
			enemy.STATE.isHurting = true
			enemy.received_damage = ATK
		

"""处理角色移动"""
func handleMove() -> void:
	"""处理四方移动"""
	# 上负下正 左负右正
	var direction := Input.get_vector("向左移动", "向右移动", "向上移动", "向下移动")

	# 上下优先度低于左右
	if direction and !isAttacking and !isDead:
		isWalking = true
		self.velocity = (RUN_SPEED if Input.is_action_pressed("奔跑") else WALK_SPEED) * direction
		
		if direction.y < 0:
			facing = "up"
		elif direction.y > 0:
			facing = "down"
			
		if direction.x < 0:
			facing = "left" 
		elif direction.x > 0:
			facing = "right"
		
	else:
		isWalking = false
		self.velocity = self.velocity.move_toward(Vector2(0, 0), WALK_SPEED)


func handleDeath() -> void:
	if HP <= 0:
		isDead = true
	
	
"""@内置->初始化"""
func _init() -> void:
	self.position = Vector2(100, 100)
	self.add_to_group("玩家")


#func _ready() -> void:
	#for each in DialogManager.get_property_list():
		#print(each)


"""@内置->物理帧"""
func _physics_process(delta: float) -> void:
	handleAttack()
	handleMove()
	handleDeath()
	handleAnim()
	move_and_slide()
	
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
	
		if collider.name == "悬崖":
			HP = 0

		
		"""
		if collider is TileMapLayer:
			var tile_map = collider
			var tile_pos = tile_map.local_to_map(collision.get_position() - collision.get_normal())
			var tile_data = tile_map.get_cell_tile_data(0, tile_pos)  # 0 是图层索引
			
			if tile_data:
				print("碰撞到 TileMap！位置：", tile_pos)
				# 可选：获取图块的自定义属性（如伤害区域）
				#if tile_data.get_custom_data("is_lava"):
					#take_damage()
		"""

"""
func _input(event):
	print(event)
	if event is InputEventKey:
		print("Action detected:", event.keycode, "Pressed:", event.pressed)
"""



func _on_animated_sprite_2d_animation_finished() -> void:
	isAttacking = false
	if animator.animation == "death":
		DialogManager.showDialogs()
		get_tree().root.add_child(GameManager.death_scene)
	# if animator.animation.find("attack") != -1:	


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("敌人"):
		# inAttackRange = true
		enemy = body
		Debug.log("敌人进入玩家攻击范围内")


# 目前仅处理对单
func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("敌人"):
		# inAttackRange = false
		enemy = null
		Debug.log("敌人离开玩家攻击范围内")
