extends CharacterBody2D

@export var speed : float = 700.0
# New stats
@export var damage_amount: int = 10
@export var max_health: int = 100

# Node references
@onready var damage_area: Area2D = $damage_area
@onready var hurtbox: Area2D = $hurtbox
@onready var damage_timer: Timer = $damage_timer

# Hitbox shapes inside damage_area
@onready var side_collision: CollisionShape2D = $damage_area/side_collision
@onready var front_collision: CollisionShape2D = $damage_area/front_collision
@onready var back_collision: CollisionShape2D = $damage_area/back_collision

# Sounds
@onready var attack_sound: AudioStreamPlayer = $audio.get_child(1)
@onready var hurt_sound: AudioStreamPlayer = $audio.get_child(0)

@onready var animated_sprite = $AnimatedSprite2D

var is_dying: bool = false

var last_direction: String = "down"

func _physics_process(_2delta: float) -> void:
	
	var input_dir = Vector2.ZERO 
	
	if is_dying:
		return
	
	if is_attacking : 
		return
	
	if Input.is_action_just_pressed("attack"):
		start_attack()
		return
		
	if Input.is_action_pressed("ui_left"):
		input_dir.x = -1
		last_direction = "left"
	elif Input.is_action_pressed("ui_right"):
		input_dir.x = 1
		last_direction = "right"
	elif Input.is_action_pressed("ui_up"):
		input_dir.y = -1
		last_direction = "up"
	elif Input.is_action_pressed("ui_down"):
		input_dir.y = 1
		last_direction = "down"
		
	velocity = input_dir * speed
	
	if input_dir.x != 0:
		animated_sprite.play("side_walk")
		animated_sprite.flip_h = input_dir.x < 0
	elif  input_dir.y < 0:
		animated_sprite.play("back_walk")
	elif  input_dir.y > 0:
		animated_sprite.play("front_walk")
	else:
		if last_direction == "left" or last_direction == "right":
			animated_sprite.play("side_idle")
		elif last_direction == "up":
			animated_sprite.play("back_idle")
		elif last_direction == "down":
			animated_sprite.play("front_idle")
	move_and_slide()
	_check_hurtbox_overlaps()

var current_health: int = max_health
var is_attacking: bool = false
var is_invulnerable: bool = false

func _ready() -> void:
	disable_all_hitboxes()
	animated_sprite.animation_finished.connect(_on_animation_finished)
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_timer.timeout.connect(_on_damage_timer_timeout)

func disable_all_hitboxes() -> void:
	side_collision.disabled = true
	front_collision.disabled = true
	back_collision.disabled = true

func start_attack() -> void:
	is_attacking = true
	attack_sound.play()
	velocity = Vector2.ZERO
	disable_all_hitboxes()

	match last_direction:
		"right":
			animated_sprite.play("side_attack")
			animated_sprite.flip_h = false
			side_collision.position.x = abs(side_collision.position.x)
			side_collision.disabled = false

		"left":
			animated_sprite.play("side_attack")
			animated_sprite.flip_h = true
			side_collision.position.x = -abs(side_collision.position.x)
			side_collision.disabled = false

		"up":
			animated_sprite.play("back_attack")
			animated_sprite.flip_h = false
			back_collision.disabled = false

		"down":
			animated_sprite.play("front_attack")
			animated_sprite.flip_h = false
			front_collision.disabled = false

func _on_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		disable_all_hitboxes()

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage_amount)

func _on_damage_timer_timeout() -> void:
	is_invulnerable = false

func play_hurt_sound():
	if not hurt_sound.playing:
		hurt_sound.play()

func take_damage(dmg: int) -> void :
	print("Took Damage")
	if is_invulnerable:
		return
	
	damage_timer.start()
	is_invulnerable = true
	
	current_health -= dmg
	print("Current Health:", current_health )
	if current_health <= 0 :
		is_dying = true
		velocity = Vector2.ZERO
		animated_sprite.play("death")
		await animated_sprite.animation_finished


func _check_hurtbox_overlaps() -> void:
	if is_invulnerable:
		return
	for body in hurtbox.get_overlapping_bodies():
		if body.has_method("give_damage"):
			play_hurt_sound()
			take_damage(body.give_damage())
			break;


func _on_timer_timeout() -> void:
	print(current_health)
	current_health += 15
	if current_health > max_health:
		current_health = max_health
		print("current Health updated to:" ,current_health)
