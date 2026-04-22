@icon("res://Assets/Images/UI/youmu_icon.png")
extends Character

var attack_time : int = 0
var Shadow : AnimatedSprite2D = null

var _flip_tween : Tween = null
var _mouse_dir : Vector2

signal attack

func animFlip(pos : float) -> void:
	_flip_tween = get_tree().create_tween()
	_flip_tween.tween_property(self, "transform:x", Vector2(pos, 0), 0.1)
	_flip_tween.set_ease(Tween.EASE_IN_OUT)
	_flip_tween.set_trans(Tween.TRANS_ELASTIC)

## AnimationPlayer调用
func _shakeCamera(val : float = 3.0) -> void:
	GameManager.cameraShake(val)

func _ready() -> void:
	print(material)
	add_to_group("Player")
	var mat : ShaderMaterial = null
	Shadow = Sprite.duplicate()
	mat = ShaderMaterial.new()
	mat.shader = preload("res://Assets/shader/shadow.gdshader")
	Shadow.material = mat
	Shadow.position.y = 16.0
	Shadow.flip_v = true
	Shadow.show_behind_parent = true
	add_child(Shadow)

func _physics_process(delta: float) -> void:
	_mouse_dir = (get_global_mouse_position() - global_position).normalized()

	Shadow.flip_h = Sprite.flip_h
	Shadow.animation = Sprite.animation
	Shadow.frame = Sprite.frame

	if is_dead or is_attacking:
		return
	
	if _mouse_dir.x > 0:
		animFlip(1.0)
		#Sprite.flip_h = false
	elif _mouse_dir.x < 0:
		animFlip(-1.0)
		#Sprite.flip_h = true

## 受伤，最终不打算做动画了，而是用shader
func hurtVfx() -> void:
	if is_dead or is_hurting:
		return
	is_hurting = true
	Sprite.material.set_shader_parameter("is_hurting", true)
	
	GameManager.cameraShake(5.0)
	await get_tree().create_timer(0.1).timeout
	is_hurting = false
	Sprite.material.set_shader_parameter("is_hurting", false)

## @note is_attacking = false的逻辑在fsm里面
func handleAttack() -> void:
	if Input.is_action_just_pressed("攻击"):
		if not is_attacking and not is_dead:
			# 更新击退方向
			AttackHitbox.knockback_dir = _mouse_dir
			attack.emit()

## @override 移动
func handleMove(_unused: float = BASE_SPEED) -> void:
	move_dir = Input.get_vector("向左移动", "向右移动", "向上移动", "向下移动")
	if is_attacking:
		# 急停
		velocity = velocity.move_toward(Vector2(0, 0), ACCELERATION)
		return
	if Input.is_action_pressed("奔跑"):
		super.handleMove(RUN_SPEED)
	else:
		super.handleMove(BASE_SPEED)
