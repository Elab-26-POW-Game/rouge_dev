extends AnimatedSprite2D
class_name Vfx

func _ready() -> void:
	self.play()

func _on_animation_finished() -> void:
	self.queue_free()
