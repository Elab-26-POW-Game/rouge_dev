extends Camera2D

@export var shake_str : float = 0.0 # 相机抖动强度
@export var shake_recover : float = 15.0 # 相机抖动回复强度


func _ready() -> void:
	GameManager.camera_shake.connect(func(cnt : float):
		shake_str += cnt	
	)


func _physics_process(delta: float) -> void:
	self.offset = Vector2(
		randf_range(-shake_str, +shake_str),
		randf_range(-shake_str, +shake_str)
	)
	shake_str = move_toward(shake_str, 0, shake_recover * delta)
