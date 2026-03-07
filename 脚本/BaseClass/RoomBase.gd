extends Node2D

class_name RoomBase

@onready var tilemap : TileMapLayer = $"TileMap/地块"
@onready var doors : Node2D = $"出口"
@onready var entrances : Node2D = $"入口"
@onready var player_detector : Area2D = $"玩家检测"

## 打开进入下一地牢的门
func openDoors() -> void:
	for door in doors.get_children():
		door.open()

## 玩家进入房间，关门
func closeEntrance() -> void:
	for entry : Marker2D in entrances.get_children():
		# 瓦片当然是局部坐标
		var tile_coords: Vector2i = tilemap.local_to_map(entry.position)
		# 放特效，注意是全局坐标
		GameManager.tileFadeAnim(entry.global_position, tilemap.tile_set.tile_size)
		# 放墙
		# void set_cell(瓦片坐标, 图集id, 图集中的图块坐标, 备选图块id)
		tilemap.set_cell(tile_coords, 0, Vector2i(1, 0), 0)

func _ready() -> void:
	player_detector.connect("body_entered", _on_玩家检测_body_entered)
	#GameManager.cameraLimit(-96, -96, 672, 576)

func _on_玩家检测_body_entered(body: Node2D) -> void:
	# 一次性玩家检测
	if body.is_in_group("Player"):
		player_detector.queue_free()
