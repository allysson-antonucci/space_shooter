extends Area2D
class_name Bullet

@export var bullet_speed: float
var shoot_direction: Vector2

func _ready() -> void:
	rotation = shoot_direction.angle() + deg_to_rad(90)

func _physics_process(delta: float) -> void:
	position += shoot_direction * bullet_speed * delta

func _on_life_timer_timeout() -> void:
	queue_free()
