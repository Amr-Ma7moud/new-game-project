extends CharacterBody2D

@export var speed: float = 40.0
@export var max_health: float = 40
@export var health: float = 40
@export var damage: float = 15.0

var player: Node2D = null
var is_dying: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $detection_area

func take_damage(dmg: int) -> void :
	health -= dmg
	print("Slime Current Health:", health )
	update_healthbar()
	if health <= 0 :
		is_dying = true
		velocity = Vector2.ZERO
		animated_sprite.play("death")
		await animated_sprite.animation_finished
		await get_tree().create_timer(2.5).timeout
		queue_free()

func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	update_healthbar()

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
	if is_dying:
		return 0
	else:
		return damage
func update_healthbar() -> void :
	$healthbar.value = health
	if health ==  $healthbar.max_value or health <= 0 :
		$healthbar.visible = false
	else :
		$healthbar.visible = true
