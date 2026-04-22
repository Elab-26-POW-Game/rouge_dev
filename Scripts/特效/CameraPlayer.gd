extends Camera2D

@export var shake_str : float = 0.0 # 相机抖动强度
@export var shake_recover : float = 15.0 # 相机抖动回复强度
const ZOOM_DELTA = Vector2(0.01, 0.01)

func _ready() -> void:
	zoom = 2.5 * Vector2.ONE
	EventBus.game_camera_shake.connect(func(cnt):
		shake_str += cnt	
	)
	
	EventBus.game_camera_limit.connect(func(xs, ys, xe, ye):
		self.limit_left = xs
		self.limit_top = ys
		self.limit_right = xe
		self.limit_bottom = ye	
	)

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_MINUS):
		self.zoom -= ZOOM_DELTA
	elif Input.is_key_pressed(KEY_EQUAL):
		self.zoom += ZOOM_DELTA
	zoom = zoom.clamp(1.25 * Vector2.ONE, 3 * Vector2.ONE)
		
	create_tween().tween_property(self, "offset", Vector2(
		randf_range(-shake_str, +shake_str),
		randf_range(-shake_str, +shake_str)
	), 0.1)
	
	shake_str = move_toward(shake_str, 0, shake_recover * delta)
