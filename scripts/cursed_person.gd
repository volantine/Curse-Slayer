extends CharacterBody2D

func set_animation(anim):
	$AnimationTree.get("parameters/playback").travel(anim)

func lift_curse():
	set_animation("CurseLifting")
	$PhysicsCollision.disabled = false
	$ActionDetectionBox/CollisionShape2D.disabled = true

func _on_action_box_area_entered(hitbox: Hitbox):
	if ( hitbox == null ):
		return
	
	if ( hitbox.owner.is_in_group("Enemies") ):
		return
	
	lift_curse()
