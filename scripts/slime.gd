extends CharacterBody2D

@export var speed: float = 40.0
@export var max_health: float = 40
@export var damage: float = 15.0
var current_health: float = max_health

var player: Node2D = null
var is_dying: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $detection_area

func take_damage(dmg: int) -> void :
	max_health -= dmg
	print("Slime Current Health:", max_health )
	if max_health <= 0 :
		is_dying = true
		velocity = Vector2.ZERO
		animated_sprite.play("death")
		await animated_sprite.animation_finished
		queue_free()


func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _physics_process(_delta: float) -> void:	
	if is_dying: 
		return
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		animated_sprite.play("side_walk")
		if direction.x < 0:
			animated_sprite.flip_h = true
		elif direction.x > 0:
			animated_sprite.flip_h = false
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("front_idle")

func give_damage() -> float:
	return damage
