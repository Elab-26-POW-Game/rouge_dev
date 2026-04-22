extends Enemy

## @override 追击
func handleChase() -> void:
	super.handleChase()
	AttackHitbox.knockback_dir = move_dir
