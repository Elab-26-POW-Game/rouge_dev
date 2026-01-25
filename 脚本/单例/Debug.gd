extends Node

func log(info : String = "") -> void:
	print(Time.get_datetime_string_from_system(false, true), " [DEBUG]", info)

func warn(info : String = "") -> void:
	push_warning(Time.get_datetime_string_from_system(false, true), " [WARN]", info)

func _ready() -> void:
	self.log("准备就绪")
