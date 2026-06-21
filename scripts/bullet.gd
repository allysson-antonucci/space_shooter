extends Area2D
class_name Bullet

var bullet_speed: float
var bullet_direction: Vector2
var bullet_damage: float
var bullet_texture_choose: AtlasTexture

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var life_timer: Timer = $Life_Timer

var shooter: CharacterBody2D # Guarda a informação de quem atirou para passar para o enemy

func _ready() -> void:
	sprite_2d.texture = bullet_texture_choose
	rotation = bullet_direction.angle() + deg_to_rad(90)
	life_timer.start()

func _physics_process(delta: float) -> void:
	position += bullet_direction * bullet_speed * delta

func _on_life_timer_timeout() -> void:
	queue_free()
