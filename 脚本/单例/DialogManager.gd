"""单列-对话系统"""
extends CanvasLayer

const AVATAR_PREFIX : Dictionary = {
	"琪露诺": "res://资产/图片/幻想人形演舞AP立絵/039_",
	"灵梦": "res://资产/图片/幻想人形演舞AP立絵/001_"
}

# 默认对话 stat是表情
var dialogs := [
	{chara="琪露诺", anchor="left", text="baka!", stat="00"},
	{chara="灵梦", anchor="right", text="哦哦哦哦哦哦哦哦妖怪治退!", stat="01"},
	{chara="琪露诺", anchor="left", text="QAQ啊我死了~", stat="02"},
	{chara="灵梦", anchor="right", text="好似喵~", stat="03"},
]
var pos : int = 0
var typing_tween : Tween

@onready var avatars = {"left": $AvatarLeft, "right": $AvatarRight}
@onready var name_box = $VBoxContainer/MarginContainer/Name
@onready var text_box = $VBoxContainer/Text

"""加载对话，还没想好咋存储"""
func loadDialogs(_data) -> void:
	dialogs = _data

func appendChar(char : String) -> void:
	text_box.text += char

"""显示对话"""
func showDialogs() -> void:
	if pos >= len(dialogs):
		self.hide()
		return
	
	self.show()
	var dialog = dialogs[pos]
	
	# ！！！这里要改，最好包装成新系统
	avatars[dialog.anchor].texture = load(AVATAR_PREFIX[dialog.chara] + dialog.stat + ".png")
	name_box.text = dialog.chara
	
	# 使用Tween类实现打字机效果
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		text_box.text = dialog.text
		pos += 1
	
	else:
		typing_tween = get_tree().create_tween()
		text_box.text = ""
		# typing_tween.tween_property(text_box, "text", dialog.text, 1)
		for char in dialog.text:
			typing_tween.tween_callback(appendChar.bind(char)).set_delay(0.05)
		typing_tween.tween_callback(func(): pos += 1)


func _ready() -> void:
	self.hide()
	

"""点击text_box进入下一个对话"""
func _on_text_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			showDialogs()
