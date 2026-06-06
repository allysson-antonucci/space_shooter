extends CharacterBody2D
class_name Player

@export var max_speed: int
@export var acceleration: int
@export var deceleration: int

var mouse_position: Vector2
var direction: Vector2

# Shoot
@onready var shoot_marker_2d: Marker2D = $Shoot_Marker2D
@export var bullet_scene: PackedScene

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _physics_process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	rotation = direction.angle() + deg_to_rad(90)
	
	direction = (mouse_position - global_position).normalized()
	
	if Input.is_action_pressed("boost"):
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	move_and_slide()

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = shoot_marker_2d.global_position
	bullet.shoot_direction = direction
	
	get_tree().current_scene.add_child(bullet)
