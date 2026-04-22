# RoomSpawn.gd
extends RoomBase

## 玩家场景
const PLAYER_SCENE : PackedScene = preload("res://Scenes/实体/主角.tscn")

@onready var player_pos : Marker2D = $"玩家出生点"

## 生成玩家
func genPlayer() -> void:
	var player : CharacterBody2D = PLAYER_SCENE.instantiate()
	player.global_position = player_pos.global_position
	player.collision_mask = 0
	player_pos.queue_free()
	get_parent().call_deferred("add_child", player)

func _ready() -> void:
	super._ready()
	genPlayer()
	await get_tree().create_timer(1.0).timeout
	DialogManager.dialogs = [
		{chara="琪露诺", anchor="left", text="开头对白占位", stat="00"},
		{chara="琪露诺", anchor="left", text="就是这样，喵~", stat="03"}
	]
	DialogManager.showDialogs()

func _on_玩家检测_body_entered(body: Node2D) -> void:
	super._on_玩家检测_body_entered(body)
	if body.is_in_group("Player"):
		openDoors()
