"""单列-对话系统"""
extends CanvasLayer

## 立绘前缀
const AVATAR_PREFIX : Dictionary = {
	"琪露诺": "res://Assets/图片/幻想人形演舞AP立絵/039_",
	"灵梦": "res://Assets/图片/幻想人形演舞AP立絵/001_"
}

## 默认对话 stat是表情
var dialogs := [
	{chara="琪露诺", anchor="left", text="baka!", stat="00"},
	{chara="灵梦", anchor="right", text="哦哦哦哦哦哦哦哦妖怪治退!", stat="01"},
	{chara="琪露诺", anchor="left", text="QAQ啊我死了~", stat="02"},
	{chara="灵梦", anchor="right", text="好似喵~", stat="03"},
]
## 当前对话编号
var idx : int = 0
## 打字tween
var typing_tween : Tween
## 显/隐对话框tween
var show_toggle_tween : Tween

@onready var control_box = $Control
@onready var avatars = {"left": $Control/AvatarLeft, "right": $Control/AvatarRight}
@onready var name_box = $Control/VBoxContainer/MarginContainer/Name
@onready var text_box = $Control/VBoxContainer/Text

## 从现有文件加载对话
## @todo 还没想好咋存储
func loadDialogs(_data) -> void:
	dialogs = _data

## 打字效果
func _appendChar(char : String) -> void:
	text_box.text += char

## 显示对话框-动画
func showDialogAnim() -> void:
	if !self.visible:
		self.show()
		control_box.modulate.a = 0
		show_toggle_tween = get_tree().create_tween()
		show_toggle_tween.tween_property(control_box, "modulate:a", 1.0, 0.2)
		show_toggle_tween.set_trans(Tween.TRANS_SINE)
		show_toggle_tween.set_ease(Tween.EASE_OUT)
	
## 隐藏对话框-动画
func hideDialogAnim() -> void:
	# control_box.modulate.a = 100
	show_toggle_tween = get_tree().create_tween()
	show_toggle_tween.tween_property(control_box, "modulate:a", 0.0, 0.2)
	show_toggle_tween.set_trans(Tween.TRANS_SINE)
	show_toggle_tween.set_ease(Tween.EASE_OUT)
	show_toggle_tween.tween_callback(func(): self.hide())

## 显示对话框
func showDialogs() -> void:
	if idx >= len(dialogs):
		hideDialogAnim()
		return
	
	showDialogAnim()
	var dialog = dialogs[idx]
	
	# ！！！这里要改，最好包装成新系统
	avatars[dialog.anchor].texture = load(AVATAR_PREFIX[dialog.chara] + dialog.stat + ".png")
	name_box.text = dialog.chara
	
	# 使用Tween类实现打字机效果
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		text_box.text = dialog.text
		idx += 1
	
	else:
		typing_tween = get_tree().create_tween()
		text_box.text = ""
		# typing_tween.tween_property(text_box, "text", dialog.text, 1)
		for c in dialog.text:
			typing_tween.tween_callback(_appendChar.bind(c)).set_delay(0.05)
		typing_tween.tween_callback(func(): idx += 1)

func _ready() -> void:
	self.hide()

## 点击text_box进入下一个对话
func _on_text_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			showDialogs()
			
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("互动"):
		showDialogs()
