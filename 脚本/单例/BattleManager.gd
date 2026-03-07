# BattleManager.gd
# 轻量化即时战斗管理器 - 适用于类似元气骑士的肉鸽游戏
class_name BattleManager
extends Node

#region 导出变量
## 战斗检测范围（米/像素）
@export var combat_detection_radius: float = 800.0
## 是否启用友军伤害
@export var friendly_fire: bool = false
## 最大同时追踪目标数
@export var max_targets: int = 20
#endregion

#region 成员变量
## 当前所有活跃的战斗实体
var active_entities: Array[Node] = []
## 当前在战斗范围内的敌人
var enemies_in_combat: Array[Node] = []
## 玩家实体引用
var player: Node
## 实体Buff数据存储 {entity: {buff_type: {"stacks": int, "time_left": float, "duration": float, "source": Node}}}
var entity_buffs: Dictionary = {}
## EventBus引用
@onready var event_bus = get_node("/root/EventBus")
#endregion

#region 基础战斗API

## 初始化战斗管理器
func initialize(p_player: Node) -> void:
	player = p_player

## 注册战斗实体（敌人、召唤物等）
func register_entity(entity: Node) -> void:
	if entity not in active_entities:
		active_entities.append(entity)
		_connect_entity_signals(entity)

## 注销战斗实体
func unregister_entity(entity: Node) -> void:
	active_entities.erase(entity)
	enemies_in_combat.erase(entity)
	# 清理实体的Buff数据
	if entity_buffs.has(entity):
		entity_buffs.erase(entity)
	_disconnect_entity_signals(entity)

## 清空所有实体（切换场景时使用）
func clear_all_entities() -> void:
	for entity in active_entities:
		_disconnect_entity_signals(entity)
	active_entities.clear()
	enemies_in_combat.clear()
	entity_buffs.clear()

## 处理伤害（核心战斗方法）
func apply_damage(target: Node, source: Node, base_damage: float, 
				 damage_type: String = "normal") -> Dictionary:
	# 检查是否可伤害
	if not _can_damage(target, source):
		return {"success": false, "reason": "invalid_target"}
	
	# 获取最终伤害值（经过Buff修正）
	var final_damage = _modify_damage(target, source, base_damage, damage_type)
	
	# 计算暴击
	var is_critical = _check_critical(source)
	if is_critical:
		final_damage *= _get_critical_multiplier(source)
	
	# 应用伤害到目标（调用目标的受伤方法）
	if target.has_method("take_damage"):
		var actual_damage = target.take_damage(final_damage, source, is_critical)
		
		# 发出信号
		event_bus.battle_entity_damaged.emit(target, source, actual_damage, is_critical)
		
		# 检查目标是否死亡
		if target.has_method("is_alive") and not target.is_alive():
			event_bus.battle_entity_died.emit(target, source)
			unregister_entity(target)
		
		return {"success": true, "damage": actual_damage, "critical": is_critical}
	
	return {"success": false, "reason": "no_take_damage_method"}

## 治疗实体
func apply_heal(target: Node, source: Node, amount: float) -> Dictionary:
	if not target.has_method("heal"):
		return {"success": false, "reason": "no_heal_method"}
	
	var final_heal = _modify_heal(target, source, amount)
	var actual_heal = target.heal(final_heal, source)
	
	return {"success": true, "heal": actual_heal}

## 获取攻击范围内所有敌人
func get_enemies_in_range(center: Vector2, range_radius: float) -> Array[Node]:
	var result: Array[Node] = []
	for enemy in enemies_in_combat:
		if is_instance_valid(enemy) and enemy.global_position.distance_to(center) <= range_radius:
			result.append(enemy)
	return result

## 获取最近的敌人
func get_nearest_enemy(from_position: Vector2) -> Node:
	var nearest: Node
	var min_dist: float = INF
	
	for enemy in enemies_in_combat:
		if not is_instance_valid(enemy):
			continue
		var dist = enemy.global_position.distance_to(from_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
	
	return nearest

#endregion

#region Buff系统API

## 为实体添加Buff
func apply_buff(target: Node, buff_type: String, duration: float = -1.0, 
				stacks: int = 1, source: Node = null) -> bool:
	if not target in active_entities and target != player:
		return false
	
	if not entity_buffs.has(target):
		entity_buffs[target] = {}
	
	var target_buffs = entity_buffs[target]
	
	# 如果Buff已存在，刷新或叠加
	if target_buffs.has(buff_type):
		var buff = target_buffs[buff_type]
		buff.duration = max(buff.duration, duration)
		buff.stacks = min(buff.stacks + stacks, _get_max_stacks(buff_type))
		buff.time_left = buff.duration
		buff.source = source
	else:
		# 添加新Buff
		target_buffs[buff_type] = {
			"stacks": stacks,
			"duration": duration,
			"time_left": duration,
			"source": source
		}
	
	event_bus.battle_buff_applied.emit(target, {
		"type": buff_type,
		"duration": duration,
		"stacks": stacks,
		"source": source
	})
	return true

## 移除实体的Buff
func remove_buff(target: Node, buff_type: String) -> bool:
	if not entity_buffs.has(target) or not entity_buffs[target].has(buff_type):
		return false
	
	entity_buffs[target].erase(buff_type)
	
	# 如果实体没有Buff了，清理条目
	if entity_buffs[target].is_empty():
		entity_buffs.erase(target)
	
	event_bus.battle_buff_removed.emit(target, buff_type)
	return true

## 检查实体是否有指定Buff
func has_buff(entity: Node, buff_type: String) -> bool:
	return entity_buffs.has(entity) and entity_buffs[entity].has(buff_type)

## 获取实体指定Buff的层数
func get_buff_stacks(entity: Node, buff_type: String) -> int:
	if has_buff(entity, buff_type):
		return entity_buffs[entity][buff_type].stacks
	return 0

## 获取实体所有活跃Buff
func get_entity_buffs(entity: Node) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if entity_buffs.has(entity):
		for buff_type in entity_buffs[entity]:
			var buff = entity_buffs[entity][buff_type].duplicate()
			buff["type"] = buff_type
			result.append(buff)
	return result

## 更新所有Buff持续时间（通常在每帧调用）
func update_buffs(delta: float) -> void:
	var entities_to_remove: Array[Node] = []
	
	for entity in entity_buffs.keys():
		if not is_instance_valid(entity):
			entities_to_remove.append(entity)
			continue
			
		var buffs_to_remove: Array[String] = []
		var entity_buffs_data = entity_buffs[entity]
		
		for buff_type in entity_buffs_data:
			var buff = entity_buffs_data[buff_type]
			if buff.duration > 0:
				buff.time_left -= delta
				if buff.time_left <= 0:
					buffs_to_remove.append(buff_type)
		
		# 移除过期的Buff
		for buff_type in buffs_to_remove:
			entity_buffs_data.erase(buff_type)
			event_bus.battle_buff_removed.emit(entity, buff_type)
		
		# 如果实体没有Buff了，标记清理
		if entity_buffs_data.is_empty():
			entities_to_remove.append(entity)
	
	# 清理没有Buff的实体条目
	for entity in entities_to_remove:
		if entity_buffs.has(entity):
			entity_buffs.erase(entity)

#endregion

#region 区域检测API

## 更新战斗区域（通常在玩家移动时调用）
func update_combat_area(center: Vector2) -> void:
	var previously_in_combat = enemies_in_combat.duplicate()
	enemies_in_combat.clear()
	
	for entity in active_entities:
		if not is_instance_valid(entity):
			continue
			
		# 假设敌人有 is_enemy 方法或变量
		var is_enemy = entity.has_method("is_enemy") and entity.is_enemy()
		
		if is_enemy and entity.global_position.distance_to(center) <= combat_detection_radius:
			enemies_in_combat.append(entity)
			
			# 检测新进入战斗的敌人
			if entity not in previously_in_combat:
				event_bus.battle_enemy_entered_combat.emit(entity)
	
	# 检测离开战斗的敌人
	for entity in previously_in_combat:
		if entity not in enemies_in_combat and is_instance_valid(entity):
			event_bus.battle_enemy_exited_combat.emit(entity)

## 设置战斗检测范围
func set_detection_radius(radius: float) -> void:
	combat_detection_radius = radius

## 获取所有目标（敌人+可攻击物）
func get_all_targets() -> Array[Node]:
	var targets: Array[Node] = []
	targets.append_array(enemies_in_combat)
	
	# 添加可破坏物等
	for entity in active_entities:
		if entity.has_method("is_destructible") and entity.is_destructible():
			targets.append(entity)
	
	return targets

#endregion

#region 工具函数

## 检查两个实体之间的关系（敌对/友好）
func get_relationship(entity_a: Node, entity_b: Node) -> String:
	# 实现敌对关系判断逻辑
	# 返回 "hostile", "friendly", "neutral"
	if entity_a == player and entity_b.has_method("is_enemy") and entity_b.is_enemy():
		return "hostile"
	if entity_b == player and entity_a.has_method("is_enemy") and entity_a.is_enemy():
		return "hostile"
	return "friendly"

## 序列化战斗状态（用于保存游戏）
func serialize() -> Dictionary:
	# 简化版序列化
	return {
		"active_entities_count": active_entities.size(),
		"enemies_in_combat_count": enemies_in_combat.size()
	}

## 反序列化
func deserialize(data: Dictionary) -> void:
	pass

#endregion

#region 私有方法

func _can_damage(target: Node, source: Node) -> bool:
	if not is_instance_valid(target) or not is_instance_valid(source):
		return false
	
	# 不能伤害自己（除非特定Buff允许）
	if target == source:
		return false
	
	# 友军伤害检查
	if not friendly_fire:
		var relationship = get_relationship(source, target)
		if relationship == "friendly":
			return false
	
	return true

func _check_critical(source: Node) -> bool:
	# 根据来源的暴击率判断
	if source.has_method("get_critical_chance"):
		return randf() < source.get_critical_chance()
	return randf() < 0.1  # 默认10%暴击率

func _get_critical_multiplier(source: Node) -> float:
	if source.has_method("get_critical_multiplier"):
		return source.get_critical_multiplier()
	return 2.0  # 默认2倍暴击

func _modify_damage(target: Node, source: Node, base_damage: float, damage_type: String) -> float:
	var final_damage = base_damage
	
	# 应用目标身上的防御类Buff
	if entity_buffs.has(target):
		for buff_type in entity_buffs[target]:
			final_damage = _apply_damage_modifier(buff_type, final_damage, "defense", damage_type)
	
	# 应用来源身上的攻击类Buff
	if entity_buffs.has(source):
		for buff_type in entity_buffs[source]:
			final_damage = _apply_damage_modifier(buff_type, final_damage, "attack", damage_type)
	
	return max(0, final_damage)

func _modify_heal(target: Node, source: Node, base_heal: float) -> float:
	var final_heal = base_heal
	# 类似伤害修改逻辑...
	return final_heal

func _get_max_stacks(buff_type: String) -> int:
	match buff_type:
		"poison", "burn":
			return 5
		"shield", "strength":
			return 3
	return 1

func _apply_damage_modifier(buff_type: String, damage: float, 
							modifier_type: String, damage_type: String) -> float:
	# 这里根据具体的Buff类型实现伤害修正逻辑
	# 例如：如果buff是"weakness"，减少伤害；如果buff是"strength"，增加伤害
	match buff_type:
		"weakness":
			return damage * 0.8
		"strength":
			return damage * 1.2
		"vulnerable":
			return damage * 1.5
		"armor":
			return damage * 0.5
	return damage

func _connect_entity_signals(entity: Node) -> void:
	# 连接实体的相关信号（如死亡、受伤等）
	if entity.has_signal("died"):
		if not entity.is_connected("died", _on_entity_died):
			entity.connect("died", _on_entity_died.bind(entity))

func _disconnect_entity_signals(entity: Node) -> void:
	if entity.has_signal("died") and entity.is_connected("died", _on_entity_died):
		entity.disconnect("died", _on_entity_died)

func _on_entity_died(entity: Node) -> void:
	unregister_entity(entity)

#endregion
