"""
	由于部分细节仍需讨论，所以这里虚构了很多
		数据，以求脚本顺利编写
	仍需讨论的细节：
	1.何时保存数据
		比如战斗中间退出游戏，加载的是战斗
			开始前的数据，还是战斗时的数
			据，抑或是直接记为上一场游戏
			失败
	2.何时加载数据
		比如打开游戏时看到的是战斗页面，还是
			角色选择界面
	
	我目前实现了两个保存方式，一个是节点保存，
		一个是自动保存，之后再进行取舍
"""
## @experimental: 待完善
extends Node
class_name StorageManager

# 默认保存路径
const AUTO_SAVE_PATH = "user://auto_save.tres"
const MANUAL_SAVE_PATH = "user://manual_save.tres"

# 信号
signal save_completed(success: bool, path: String)
signal load_completed(success: bool, path: String)

# 游戏数据类 - 只保存角色的关键数据
class CharacterSaveData extends Resource:
	# 角色位置
	var position_x: float = 100.0
	var position_y: float = 100.0
	
	# 角色属性
	var hp: float = 100.0
	var atk: float = 10.0
	var walk_speed: float = 200.0
	var run_speed: float = 400.0
	
	# 角色状态
	var facing: String = "down"
	var is_dead: bool = false
	
	# 游戏进度相关（可以扩展）
	var game_time: float = 0.0
	
	# 保存时间戳
	var save_timestamp: int = Time.get_unix_time_from_system()

# 自动保存计时器
var auto_save_timer: Timer = null
var game_timer: Timer = null
var current_game_time: float = 0.0

func _ready():
	# 设置自动保存计时器
	auto_save_timer = Timer.new()
	# 设定成300s，之后改下
	auto_save_timer.wait_time = 300
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	auto_save_timer.start()
	
	# 游戏时间计时器（用于记录游戏时长）
	game_timer = Timer.new()
	game_timer.wait_time = 1.0  # 每秒触发
	game_timer.timeout.connect(_on_game_timer_timeout)
	add_child(game_timer)
	game_timer.start()

# 游戏时间更新
func _on_game_timer_timeout():
	current_game_time += 1.0

# ==================== 公开接口 ====================

# 手动保存游戏
func manual_save() -> void:
	Debug.log("节点保存")
	var success = _save_game(MANUAL_SAVE_PATH)
	save_completed.emit(success, MANUAL_SAVE_PATH)

# 自动保存游戏
func auto_save() -> void:
	Debug.log("自动保存")
	_save_game(AUTO_SAVE_PATH)

# 加载游戏
func load_game(save_path: String) -> bool:
	Debug.log("加载自：" + save_path)
	
	if not ResourceLoader.exists(save_path):
		Debug.warn("存档文件不存在: " + save_path)
		load_completed.emit(false, save_path)
		return false
	
	var success = _load_game(save_path)
	load_completed.emit(success, save_path)
	return success

# 加载最近的存档，这个功能得根据实际情况更改
func load_recent_save() -> bool:
	# 先检查手动存档
	if ResourceLoader.exists(MANUAL_SAVE_PATH):
		return load_game(MANUAL_SAVE_PATH)
	# 再检查自动存档
	elif ResourceLoader.exists(AUTO_SAVE_PATH):
		return load_game(AUTO_SAVE_PATH)
	else:
		Debug.log("没有找到任何存档文件")
		return false

# ==================== 私有接口 ====================

# 保存游戏到指定路径
func _save_game(save_path: String) -> bool:
	# 获取玩家角色
	var player = _get_player()
	if not player:
		Debug.log("保存失败：未找到玩家角色")
		return false
	
	# 创建保存数据
	var save_data = CharacterSaveData.new()
	
	# 保存角色位置
	save_data.position_x = player.position.x
	save_data.position_y = player.position.y
	
	# 保存角色属性
	save_data.hp = player.HP
	save_data.atk = player.ATK
	save_data.walk_speed = player.WALK_SPEED
	save_data.run_speed = player.RUN_SPEED
	
	# 保存角色状态
	save_data.facing = player.facing
	save_data.is_dead = player.isDead
	
	# 保存游戏时间
	save_data.game_time = current_game_time
	save_data.save_timestamp = Time.get_unix_time_from_system()
	
	# 保存到文件
	var error = ResourceSaver.save(save_data, save_path)
	
	if error == OK:
		Debug.log("游戏数据已保存到: " + save_path)
		return true
	else:
		Debug.log("保存失败，错误码: " + str(error))
		return false

# 从指定路径加载游戏
func _load_game(load_path: String) -> bool:
	# 加载数据
	var save_data = ResourceLoader.load(load_path, "", ResourceLoader.CACHE_MODE_IGNORE) as CharacterSaveData
	
	if not save_data:
		Debug.warn("加载失败：存档数据无效")
		return false
	
	# 获取玩家角色
	var player = _get_player()
	if not player:
		Debug.warn("加载失败：未找到玩家角色")
		return false
	
	# 应用角色位置
	player.position = Vector2(save_data.position_x, save_data.position_y)
	
	# 应用角色属性
	player.HP = save_data.hp
	player.ATK = save_data.atk
	player.WALK_SPEED = save_data.walk_speed
	player.RUN_SPEED = save_data.run_speed
	
	# 应用角色状态
	player.facing = save_data.facing
	player.isDead = save_data.is_dead
	
	# 如果角色已死亡，触发死亡逻辑
	if player.isDead:
		player.HP = 0
	
	# 恢复游戏时间
	current_game_time = save_data.game_time
	
	Debug.log("存档时间: " + _format_timestamp(save_data.save_timestamp))
	Debug.log("游戏时长: " + _format_time(current_game_time))
	
	return true

# 自动保存回调
func _on_auto_save_timeout():
	auto_save()

# 获取玩家角色
func _get_player():
	# 预先将角色放在"玩家"组中
	var players = get_tree().get_nodes_in_group("玩家")
	if players.size() > 0:
		return players[0] as CharacterBody2D
	return null

# 格式化时间戳
func _format_timestamp(timestamp: int) -> String:
	var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
	return "%d-%02d-%02d %02d:%02d:%02d" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute, datetime.second
	]

# 格式化游戏时间
func _format_time(seconds: float) -> String:
	var hours = int(seconds / 3600)
	var minutes = int(fmod(seconds / 60, 60))
	var secs = int(fmod(seconds, 60))
	return "%02d:%02d:%02d" % [hours, minutes, secs]
