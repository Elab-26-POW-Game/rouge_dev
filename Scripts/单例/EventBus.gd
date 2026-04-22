"""事件总线使用教程
1. 命名规范
小写下划线命名法，由Manager调用，故需添加对应Manager的前缀，此后采用主语_谓语形式命名，示例：battle_entity_damage, ui_update_hud, audio_sound_play

2. 定义
在本文件内进行signal <信号名>即可

3. 激活
在Manager内通过执行EventBus.<信号名>.emit()激活信号

4. 监听
在相应脚本内通过定义func _on_Eventbus_storage_load() -> void函数即可
"""
extends Node

# 效果信号
## 相机抖动
signal game_camera_shake(amout : float)
## 限制相机位移
signal game_camera_limit(xs : float, 
	ys : float, xe : float, ye : float)
## 视觉特效播放完成
signal game_vfx_over(effect_name : String)

# 战斗信号
signal battle_entity_damaged(entity: Node, source: Node, damage: float, is_critical: bool)
signal battle_entity_died(entity: Node, killer: Node)
signal battle_buff_applied(entity: Node, buff_data: Dictionary)
signal battle_buff_removed(entity: Node, buff_type: String)
signal battle_enemy_entered_combat(enemy: Node)
signal battle_enemy_exited_combat(enemy: Node)

# 储存信号
signal storage_load_data(data: Dictionary)
signal storage_save_data(data: Dictionary)
signal storage_clear_data(data: Dictionary)
