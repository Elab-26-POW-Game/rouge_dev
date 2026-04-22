extends RoomBase

## 敌怪池
const ENEMY_POOL : Dictionary = {
	"SLIME": preload("res://Scenes/实体/史莱姆.tscn")
}

## 敌人计数
var enemy_num : int = 0
## 房间是否通关
var passed : bool = false

@onready var enemy_pos : Node2D = $"敌人点位"

## 在点位生成敌人
func genEnemies() -> void:
	for enemy : Marker2D in enemy_pos.get_children():
		var slime : Entity = ENEMY_POOL.SLIME.instantiate()
		slime.connect("tree_exited", _on_enemy_killed, CONNECT_DEFERRED)
		self.add_child(slime)
		slime.global_position = enemy.global_position

func _ready() -> void:
	super._ready()
	enemy_num = enemy_pos.get_child_count()

func _on_玩家检测_body_entered(body: Node2D) -> void:
	super._on_玩家检测_body_entered(body)
	if body.is_in_group("Player"):
		if enemy_num > 0:
			closeEntrance()
			# await get_tree().create_timer(3.0).timeout
			genEnemies()
		# 房间没怪算出生房/宝箱房
		else:
			openDoors()

func _on_enemy_killed() -> void:
	enemy_num -= 1
	print("剩余敌人数量：", enemy_num)
	if enemy_num <= 0:
		passed = true
		openDoors()
