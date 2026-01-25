"""
================================
语法习惯：对象内置属性前必须加self
		自定义属性则不加
================================
"""
extends CharacterBody2D

@onready var animator = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

@export_group("属性")
@export var WALK_SPEED : float = 200.0
@export var RUN_SPEED : float = 400.0

"""处理角色移动"""
func handleMove() -> void:
	"""处理四方移动"""
	# 上负下正 左负右正
	var direction := Input.get_vector("向左移动", "向右移动", "向上移动", "向下移动")

	if direction:
		if direction.x:
			animator.play("walk_side")
			sprite.flip_h = true if direction.x < 0 else false
			
		self.velocity = (RUN_SPEED if Input.is_action_pressed("奔跑") else WALK_SPEED) * direction
		
	else:
		animator.play("idle_side")
		self.velocity = self.velocity.move_toward(Vector2(0, 0), WALK_SPEED)
	
	
"""@内置->初始化"""
func _init() -> void:
	self.position = Vector2(100, 100)
	self.add_to_group("玩家")


#func _ready() -> void:
	#for each in DialogManager.get_property_list():
		#print(each)


"""@内置->物理帧"""
func _physics_process(delta: float) -> void:
	handleMove()
	move_and_slide()
