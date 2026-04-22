extends RoomBase

func _on_玩家检测_body_entered(body: Node2D) -> void:
	super._on_玩家检测_body_entered(body)
	if body.is_in_group("Player"):
		DialogManager.dialogs = [
			{chara="琪露诺", anchor="left", text="哦咩得多~", stat="00"},
			{chara="灵梦", anchor="right", text="哦咩得多~!", stat="00"}
		]
		DialogManager.showDialogs()
