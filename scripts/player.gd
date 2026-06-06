extends CharacterBody2D
class_name Player

@export var max_speed: int
@export var acceleration: int
@export var deceleration: int

var mouse_position: Vector2
var direction: Vector2

func _physics_process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	rotation += deg_to_rad(90)
	
	direction = (mouse_position - position).normalized()
	
	if Input.is_action_pressed("boost"):
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	move_and_slide()
