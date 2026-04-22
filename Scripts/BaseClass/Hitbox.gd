extends Area2D
class_name Hitbox

@export var knockback_force : int = 300
var knockback_dir : Vector2 = Vector2.ZERO
@onready var Collision :CollisionShape2D  = get_child(0)

func _ready() -> void:
	assert(Collision != null)
	set_deferred("disabled", true)
