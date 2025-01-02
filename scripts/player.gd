extends CharacterBody2D
class_name Player

@export var health: int = 100
@export var mana: int = 20
@export var attack_strength: int = 50 # Amount of damage player does to enemies
@export var speed:int = 100

@onready var anim_tree = get_node("AnimationTree")
@onready var hitbox = get_node("Hitbox").get_node("AttackZone")

var attacking = false
var healing = false
var alive = true

var knockback = false
var knockback_duration = 0.1
var knockback_timer = 0.0
var knockback_strength = 100

func set_blend_position(x_dir):
	anim_tree.set("parameters/Idle/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Walk/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Attack/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Die/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Take Damage/BlendSpace1D/blend_position", x_dir)
	anim_tree.set("parameters/Heal/BlendSpace1D/blend_position", x_dir)
	
func set_animation(anim):
	anim_tree.get("parameters/playback").travel(anim)

func update_boxes(vector):
	var x = 0
	var y = 0
	if ( vector[0] != 0 ):
		x = vector[0] * 13
		
	if ( vector[1] != 0 ):
		y = vector[1] * 13
		
	hitbox.set_position(Vector2(x, y))
	$ActionBox/CollisionShape2D.set_position(Vector2(x, y))
	
func _ready():
	Game.player = self
	$HealthBar.value = health
	$ManaBar.value = mana

func update_time_label():
	var time_left: int = floor($GameCountDown.time_left)
	var min = floor(time_left/60)
	var sec = floor(time_left % 60)
	var text = "%02d:%02d"
	text = text % [min, sec]
	$TimeLabel.text = text
	
func _process(delta):
	update_time_label()

func _physics_process(delta):
	if ( not alive ):
		return
	
	if ( knockback ):
		knockback_timer = knockback_timer - delta
		if ( knockback_timer <= 0 ):
			knockback = false
			velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if ( Input.is_action_just_pressed("lift_curse") ):
		$ActionBox/CollisionShape2D.disabled = false
	
	if ( Input.is_action_just_released("lift_curse") ):
		$ActionBox/CollisionShape2D.disabled = true
	
	if ( Input.is_action_just_pressed("attack") ):
		velocity = Vector2.ZERO
		attacking = true 
		set_animation("Attack")
		return
	
	elif ( Input.is_action_just_pressed("heal") ):
		if ( mana >= 10 and health < 100 ):
			health = 100
			mana -= 10
			update_healthbar()
			update_manabar()
			set_animation("Heal")
			healing = true
		else:
			print("Not enough mana or already full health!")

	if ( not attacking and not healing ):
		#hitbox.disabled = true
		hitbox.set_deferred("disabled", true)
		var input_vector = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
							Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
		
		velocity = input_vector * speed
		
		if ( input_vector == Vector2.ZERO ):
			set_animation("Idle")
		else:
			set_animation("Walk")
			set_blend_position(input_vector[0])
			update_boxes(input_vector)
	
		move_and_slide()

func take_damage(amount):
	#hitbox.disabled = true
	hitbox.set_deferred("disabled", true)
	attacking = false
	
	health -= amount
	update_healthbar()
	if ( health <= 0 ):
		die()
	else:
		set_animation("Take Damage")
	
func die():
	alive = false
	set_animation("Die")
	free_children()
	Game.player_dead = true

func set_knockback(enemy_pos):
	var direction = (position - enemy_pos).normalized()
	velocity = direction * knockback_strength
	
	knockback = true
	knockback_timer = knockback_duration

func _on_animation_tree_animation_finished(anim_name):
	if ( "Attack" in anim_name ):
		attacking = false
		return
	
	if ( "Heal" in anim_name ):
		healing = false
		return

func get_strength():
	return attack_strength

func knock_back(enemy_pos) -> void:
	pass

func free_children():
	$Hurtbox.queue_free()
	$Hitbox.queue_free()
	$PhysicsCollision.queue_free()

func replenish_mana():
	mana += 5
	if ( mana > 20 ):
		mana = 20
		
	update_manabar()
	
func update_healthbar():
	$HealthBar.value = health

func update_manabar():
	$ManaBar.value = mana

func _on_game_count_down_timeout():
	Game.time_out = true
