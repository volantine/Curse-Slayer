extends Area2D
class_name Hitbox

func _init() -> void:
	collision_layer = 2
	collision_mask = 0

func toggle_attack() -> void:
	if ( not owner.knockback ):
		#$AttackZone.disabled = not $AttackZone.disabled
		$AttackZone.set_deferred("disabled", (not $AttackZone.disabled))
