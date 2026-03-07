# Rooms.gd
extends Node2D

"""常量"""
## 出生房池子
const SPAWN_ROOMS : Array = [
	preload("res://场景/地图/地牢_第一层_出生房1.tscn")
]

## 中间房，包括战斗、商店池子
const INTER_ROOMS : Array = [
	preload("res://场景/地图/地牢_第一层_战斗房1.tscn"),
	preload("res://场景/地图/地牢_第一层_战斗房2.tscn")
]

## 结束房池子
const END_ROOMS : Array = [
	preload("res://场景/地图/地牢_第一层_结束房.tscn")
]

## 瓦片大小
const TILE_SIZE : int = 32

## Godot4中，取消了原来瓦片ID的概念，改为图集ID + 瓦片坐标进行定位
## 地板瓦片，图集0，坐标范围(1, 1) ~ (4, 3)
## @todo 也许我该添加地形区分了
#const FLOOR_TILE_INDEX : int = 14

"""导出配置"""
@export_group("层级配置")
## 地牢房间数
@export var num_rooms : int = 5

"""节点"""
@onready var player : CharacterBody2D = get_parent().get_node("玩家")

"""函数"""
## 地牢种子

## 程序化生成地牢房间
func spawnRooms() -> void:
	var pre_room : Node2D
	
	for idx in num_rooms:
		var room : Node2D
		if idx == 0:
			room = GameManager.drawFromPool(SPAWN_ROOMS)
		else:
			if idx == num_rooms - 1:
				room = GameManager.drawFromPool(END_ROOMS)
			else:
				room = GameManager.drawFromPool(INTER_ROOMS)
				
			var pre_room_tilemap : TileMapLayer = pre_room.get_node("TileMap/地块")
			var pre_room_door : StaticBody2D = pre_room.get_node("出口/门")
			# 出口单元格坐标
			var exit_tile_pos : Vector2i = pre_room_tilemap.local_to_map(pre_room_door.position)+ Vector2i.UP * 2
			
			# 中间道路长度为2 ~ 5
			var corridor_len : int = randi() % 4 + 2
			print(corridor_len)
			# 生成到下一房间的通道
			for len in corridor_len:
				# void set_cell(瓦片坐标, 图集id, 图集中的图块坐标, 备选图块id)
				# 放置左墙
				pre_room_tilemap.set_cell(exit_tile_pos + Vector2i(-2, -len), 0, Vector2i(8, 1), 0)
				# 放置地板1
				pre_room_tilemap.set_cell(exit_tile_pos + Vector2i(-1, -len), 0, Vector2i(1, 1), 0)
				# 放置地板2
				pre_room_tilemap.set_cell(exit_tile_pos + Vector2i(0, -len), 0, Vector2i(2, 1), 0)
				# 放置右墙
				pre_room_tilemap.set_cell(exit_tile_pos + Vector2i(1, -len), 0, Vector2i(6, 1), 0)
				
				var room_tilemap : TileMapLayer = room.get_node("TileMap/地块")
				room.position = pre_room_door.global_position + Vector2.UP * room_tilemap.get_used_rect().size.y * TILE_SIZE + Vector2.UP * corridor_len * TILE_SIZE + Vector2.LEFT * room_tilemap.local_to_map(room.get_node("入口/Marker2D2").position).x * TILE_SIZE
		
		self.add_child(room)
		pre_room = room

"""虚函数"""
func _init() -> void:
	# 初始化
	randomize()

func _ready() -> void:
	spawnRooms()
