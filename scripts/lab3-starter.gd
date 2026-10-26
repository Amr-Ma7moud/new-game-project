## New stats
#@export var damage_amount: int = 10
#@export var max_health: int = 100
#
## Node references
#@onready var damage_area: Area2D = $damage_area
#@onready var hurtbox: Area2D = $hurtbox
#@onready var damage_timer: Timer = $damage_timer
#
## Hitbox shapes inside damage_area
#@onready var side_collision: CollisionShape2D = $damage_area/side_collision
#@onready var front_collision: CollisionShape2D = $damage_area/front_collision
#@onready var back_collision: CollisionShape2D = $damage_area/back_collision
#
### State tracking
#var current_health: int = max_health
#var is_attacking: bool = false
#var is_invulnerable: bool = false
#
#func _ready() -> void:
	#disable_all_hitboxes()
	#animated_sprite.animation_finished.connect(_on_animation_finished)
	#damage_area.body_entered.connect(_on_damage_area_body_entered)
	#damage_timer.timeout.connect(_on_damage_timer_timeout)
#
#func disable_all_hitboxes() -> void:
	#side_collision.disabled = true
	#front_collision.disabled = true
	#back_collision.disabled = true
#
#func _on_animation_finished() -> void:
	#if is_attacking:
		#is_attacking = false
		#disable_all_hitboxes()
#
#func _on_damage_area_body_entered(body: Node2D) -> void:
	#if body.has_method("take_damage"):
		#body.take_damage(damage_amount)
#
#func _on_damage_timer_timeout() -> void:
	#is_invulnerable = false
