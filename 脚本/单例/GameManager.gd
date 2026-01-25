"""单例-游戏系统"""
extends Node2D

"""预加载场景"""
var death_scene = preload("res://场景/ui/死亡.tscn").instantiate()


"""信号"""
signal camera_shake(amout : float) # 相机抖动


"""函数"""
func cameraShake(cnt : float) -> void:
	camera_shake.emit(cnt)
