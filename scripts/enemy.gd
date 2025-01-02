extends CharacterBody2D

@export var health: int = 100
@export var attack_strength: int = 20
@export var speed: int = 50

@onready var anim_tree = get_node("AnimationTree")
@onready var colour = get_node("AnimatedSprite2D/CanvasModulate")

var alive = true
var attacking = false
var player = null
var player_inrange = false

const knockback_strength = 200
const knockback_duration = 0.1

var knockback = false
var knockback_timer = 0.0

func get_strength() -> int:
	return attack_strength
	
func set_blend_position(x_dir):
	anim_tree.set("parameters/Idle/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Walk/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Attack/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Die/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Take Damage/BlendSpace1D/blend_position", x_dir)

func set_animation(anim):
	anim_tree.get("parameters/playback").travel(anim)

func _physics_process(delta):
	if ( not alive ):
		return
		
	if ( player != null ): # If player is in range, enemy becomes aggressive
		var delta_x = player.position.x - position.x
		var blend = delta_x / abs(delta_x)
		set_blend_position(blend)
		
		if ( knockback ):
			knockback_timer = knockback_timer - delta
			if ( knockback_timer <= 0 ):
				knockback = false
				velocity = Vector2.ZERO
			move_and_slide()
			return

		elif ( not attacking ):
			$Hitbox.look_at(player.position)
			
			var theta = position.angle_to_point(player.position)
			velocity.x = speed * cos(theta)
			velocity.y = speed * sin(theta)
			
			set_animation("Walk")
			move_and_slide()
		
		else:
			set_animation("Attack")
			
	else:
		velocity = Vector2(0, 0)
		set_animation("Idle")

func take_damage(amount: int) -> void:
	$Hitbox/AttackZone.set_deferred("disabled", true)
	health -= amount
	if ( health <= 0 ):
		die()
	else:
		set_animation("Take Damage")
	
func die() -> void:
	Game.replenish_player_mana()
	alive = false
	set_animation("Die")
	free_children()

func set_knockback(player_pos) -> void:
	var direction = (position - player_pos).normalized()
	velocity = direction * knockback_strength
	
	knockback = true
	knockback_timer = knockback_duration

func _on_detection_area_body_entered(object: Player) -> void:
	if ( object != null ):
		player = object

func _on_detection_area_body_exited(object: Player) -> void:
	if ( object != null ):
		player = null

func _on_attack_range_body_entered(object: Player) -> void:
	if ( object != null ):
		attacking = true

func _on_attack_range_body_exited(object: Player) -> void:
	if ( object != null ):
		attacking = false

func free_children() -> void: # Only gets rid of collision and detection
	$DetectionArea.queue_free()
	$Hurtbox.queue_free()
	$Hitbox.queue_free()
	$PhysicsCollision.queue_free()
