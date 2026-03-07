## 主角控制脚本
## 语法习惯：对象内置属性前必须加self，自定义属性则不加
extends Entity

## Chracter新增：奔跑速度
var run_speed : float = 400.0
## 四个方向 -> up right left down
var facing : String = "down"

## 回血计时器
@onready var timer_regen = $"回血"

func _init() -> void:
	# self.position = Vector2(100, 100)
	hp = 100.0
	atk = 10.0
	base_speed = 200.0
	self.add_to_group("Player")

func _ready() -> void:
	super._ready()
	timer_regen.wait_time = 5.0
	timer_regen.autostart = true
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	handleMove()
	self.move_and_slide()
	
	"""
		for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
	
		if collider.name == "悬崖":
			HP = 0

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

## 处理四方移动
func handleMove() -> void:
	var direction := Input.get_vector("向左移动", "向右移动", "向上移动", "向下移动")

	if direction and !state.is_attacking and !state.is_dead:
		state.is_walking = true
		self.velocity = (run_speed if Input.is_action_pressed("奔跑") else base_speed) * direction
		
		if direction.y < 0:
			facing = "up"
		elif direction.y > 0:
			facing = "down"
			
		if direction.x < 0:
			facing = "left" 
		elif direction.x > 0:
			facing = "right"
		
	else:
		state.is_walking = false
		self.velocity = self.velocity.move_toward(Vector2(0, 0), base_speed)

## 处理动画状态
func handleAnim() -> void:
	if state.is_dead and animator.animation != "death":
		changeAnimation("death")
		
	elif !state.is_dead:
		if state.is_attacking:
			changeAction("attack")
		
		elif state.is_walking and !state.is_attacking:
			changeAction("walk")
		else:
			changeAction("idle")

## 处理攻击逻辑
func handleAttack() -> void:
	if Input.is_action_just_pressed("攻击") and !state.is_dead:
		if !state.is_attacking:
			GameManager.cameraShake(5.0)
		state.is_attacking = true
		if target and target.state.is_hurting == false:
			target.state.is_hurting = true
			target.received_damage = atk

## 处理受伤逻辑
func handleHurt() -> void:
	if state.is_hurting and !state.is_dead and animated_sprite.material.get_shader_parameter("is_hurting") == false:
		Debug.log("玩家剩余血量：" + String.num(hp))
		animated_sprite.material.set_shader_parameter("is_hurting", true)
		
		await get_tree().create_timer(0.1).timeout
		animated_sprite.material.set_shader_parameter("is_hurting", false)
		
		state.is_hurting = false

## 切换动画
## @param anim 动画名称
func changeAnimation(anim : String = "idle_down") -> void:
	var anim_list = animator.sprite_frames.get_animation_names()
	if anim in anim_list:
		animator.animation = anim
	else:
		Debug.warn("动画" + anim + "不在该角色的动画列表中！")
		animator.animation = "idle_down"

## 切换行动动画
## @param action 动作名称
func changeAction(action : String = "idle") -> void:
	animator.play()
	if facing in ["up", "down"]:
		changeAnimation(action + "_" + facing)
	else:
		animator.flip_h = true if facing == "left" else false
		changeAnimation(action + "_side")

## 处理死亡逻辑
func handleDeath() -> void:
	if hp <= 0:
		state.is_dead = true

func _on_animated_sprite_2d_animation_finished() -> void:
	state.is_attacking = false
	if animator.animation == "death":
		DialogManager.showDialogs()
		get_tree().root.add_child(GameManager.scene_death)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		target = body
		Debug.log("敌人进入玩家攻击范围内")

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		target = null
		Debug.log("敌人离开玩家攻击范围内")

func _on_回血_timeout() -> void:
	if hp > 0:
		if hp < 100:
			hp += 5
			Debug.log("玩家剩余血量：" + String.num(hp))
		else:
			hp = 100
