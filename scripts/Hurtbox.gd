extends Area2D
class_name Hurtbox

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", _on_area_entered)
	
func _on_area_entered(hitbox: Hitbox) -> void:
	if ( hitbox != null and hitbox.owner != self.owner ):
		# To prevent enemies from being able to hurt other enemies
		if ( self.owner.is_in_group("Enemies") and hitbox.owner.is_in_group("Enemies") ):
			return
			
		if ( not hitbox.get_node("AttackZone").disabled and owner.has_method("take_damage") ):
			owner.take_damage(hitbox.owner.get_strength())
			owner.set_knockback(hitbox.owner.position)
