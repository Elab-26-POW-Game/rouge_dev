extends Area2D

@export_group("刷怪冷却时间范围")
## 等待时间上界
@export var wait_time_upper = 5
## 等待时间下界
@export var wait_time_lower = 10

@export_group("刷怪距离范围")
## 等待时间上界
@export var gen_dist_upper = 50
## 等待时间下界
@export var gen_dist_lower = 100

@onready var spawn_timer : Timer = $SpawnTimer
@onready var base_cnt = get_parent().get_child_count()
var target : CharacterBody2D = null

# 获取当前史莱姆数量
func getSlimeCnt() -> int:
	return get_parent().get_child_count() - base_cnt

## 史莱姆生成函数，随机散布
func genSlime() -> void:
	# 检查当前史莱姆数量是否已达上限
	if getSlimeCnt() >= 5:
		return
		
	var slime : CharacterBody2D = preload("res://场景/实体/史莱姆.tscn").instantiate()
	
	# 随机偏移（圆形范围）
	var angle : float = randf_range(0, 2 * PI)
	var dist : float = randf_range(gen_dist_lower, gen_dist_upper)
	var offset : Vector2 = Vector2(cos(angle), sin(angle)) * dist
	
	get_parent().add_child(slime)
	# 一定要后面再改坐标，不然生成光束会偏移
	slime.position = self.global_position + offset
	#Debug.log("当前史莱姆数量: ", getSlimeCnt())

func _ready():
	# 初始化定时器
	spawn_timer.wait_time = 0.5   # 一开始马上窜出来
	spawn_timer.one_shot = false
	#spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _process(delta: float) -> void:
	#Debug.log("当前史莱姆数量: ", getSlimeCnt())
	pass

func _on_spawn_timer_timeout():
	if target:
		genSlime()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		target = body
		# 玩家进入范围，启动定时器
		if not spawn_timer.is_stopped():
			spawn_timer.stop()
		spawn_timer.start()
		print("玩家进入，开始生成史莱姆")
		spawn_timer.wait_time = randf_range(wait_time_upper, wait_time_lower)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		target = null
		# 玩家离开范围，暂停定时器
		spawn_timer.start
