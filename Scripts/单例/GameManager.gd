"""单例-游戏顶层系统"""
extends Node2D

"""预加载场景"""
var scene_death = preload("res://Scenes/UI/死亡.tscn").instantiate()

"""一般场景"""
## 选出生点
var fst_spawn : bool = true
var scene_changing : bool = false
var scene_curr : String = "world"

## 改变当前场景
func changeScene(scene : String) -> void:
	Debug.log("正在切换场景：" + scene)
	scene_changing = true
	
	var res = get_tree().change_scene_to_file(scene)
	
	if res == OK:
		scene_curr = scene
		scene_changing = false
		Debug.log("场景切换成功")
	else:
		Debug.log("场景切换失败！")

"""函数"""
## 从池子里抽取场景并返回
## @todo 暂存GameManager以后迁移到工具单例里
func drawFromPool(pool : Array) -> Node2D:
	return pool[randi() % pool.size()].instantiate()

## 建议数值范围：0.0 ~ 10.0
func cameraShake(cnt : float) -> void:
	EventBus.game_camera_shake.emit(cnt)
	
func cameraLimit(xs : float, 
	ys : float, xe : float, ye : float) ->void:
	EventBus.game_camera_limit.emit(xs, ys, xe, ye)

## 创建tile淡入动画
## @param pos为全局坐标，而非单元格坐标
## @param siz为动画覆盖区域大小，一般是填入tileset.tile_size
## @author 互联网 deepseek
func tileFadeAnim(pos: Vector2i, siz: Vector2i):
	# 为这个格子创建一个唯一的CanvasLayer或ColorRect作为遮罩
	var tween = create_tween()
	var overlay = ColorRect.new()
	# 白色
	overlay.color = Color(1, 1, 1, 1)
	overlay.size = siz
	overlay.position = pos - siz / 2
	overlay.z_index = 1 # 防止特效被tile挡住
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(overlay)
	tween.tween_property(overlay, "color:a", 0.0, 0.3)
	tween.tween_callback(overlay.queue_free)

func _init() -> void:
	# 初始化居中窗口
	var screen_size : Vector2 = DisplayServer.screen_get_size()
	var window_size : Vector2 = DisplayServer.window_get_size()
	
	DisplayServer.window_set_position(screen_size * 0.5 - window_size * 0.5)
	
