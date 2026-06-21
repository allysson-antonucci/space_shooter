extends CharacterBody2D
class_name Player

@export var ship_data: ShipsData

# Atributos do Player
var max_speed: int
var acceleration: int
var deceleration: int

var mouse_position: Vector2
var direction: Vector2

# Shoot
@onready var shoot_marker_2d: Marker2D = $Shoot_Marker2D
@export var bullet_scene: PackedScene
@onready var shoot_sfx: AudioStreamPlayer2D = $Shoot_sfx

func _ready() -> void:
	max_speed = ship_data.max_speed
	acceleration = ship_data.acceleration
	deceleration = ship_data.deceleration

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _physics_process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	direction = (mouse_position - global_position).normalized()
	
	rotation = direction.angle() + deg_to_rad(90)
	
	if Input.is_action_pressed("boost"):
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	move_and_slide()

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = shoot_marker_2d.global_position
	bullet.bullet_damage = ship_data.shoot_damage
	bullet.bullet_speed = ship_data.shoot_speed
	bullet.bullet_direction = direction
	bullet.bullet_texture_choose = ship_data.laser[2]
	bullet.shooter = self
	
	get_tree().current_scene.add_child(bullet)
	
	shoot_sfx.pitch_scale = randf_range(0.7, 1.2) 
	shoot_sfx.play()
