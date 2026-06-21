extends CharacterBody2D
class_name Enemy_1

@export var enemy_data: ShipsData
var enemy_data_index_choose : int
@onready var sprite_2d: Sprite2D = $Sprite2D

# Atributos do Inimigo
var enemy_health: float
var enemy_max_speed: float
var enemy_acceleration: float
var enemy_deceleration: float

# Controle de Combate e Física
var target: CharacterBody2D
var direction: Vector2
@onready var health_progress_bar: ProgressBar = $Health_ProgressBar
@export var bullet_scene : PackedScene
var bullet: Bullet = null
@onready var shoot_marker_2d: Marker2D = $Shoot_Marker2D
var can_shoot : bool = true
@onready var cooldown_shoot_timer: Timer = $Cooldown_shoot_Timer
@onready var explosion_animated_sprite_2d: AnimatedSprite2D = $Explosion_AnimatedSprite2D
var hit_tween: Tween
var is_dead: bool = false

# Áudio
@onready var shoot_sfx: AudioStreamPlayer2D = $Shoot_sfx
@onready var explosion_sfx: AudioStreamPlayer2D = $explosion_sfx
@onready var shoot_hit_sfx: AudioStreamPlayer2D = $shoot_hit_sfx


func _ready() -> void:
	enemy_data_index_choose = randi() % enemy_data.ship.size()
	sprite_2d.texture = enemy_data.ship[enemy_data_index_choose]
	
	enemy_health = enemy_data.health
	enemy_max_speed =  enemy_data.max_speed
	enemy_acceleration = enemy_data.acceleration
	enemy_deceleration = enemy_data.deceleration
	
	health_progress_bar.max_value = enemy_data.health
	health_progress_bar.value = enemy_data.health
	health_progress_bar.visible = false
	
	explosion_animated_sprite_2d.visible = false
	explosion_animated_sprite_2d.sprite_frames = enemy_data.ship_explosion
	explosion_animated_sprite_2d.speed_scale = 1
	
	cooldown_shoot_timer.wait_time = enemy_data.shoot_cooldown

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if not is_instance_valid(target):
		target = get_tree().current_scene.player
	
	if target and is_instance_valid(target):
		var direction_to_target: Vector2 = target.global_position - global_position
		var distance_to_target: float = direction_to_target.length()
		
		direction = direction_to_target.normalized()
		
		velocity = velocity.move_toward(direction * enemy_max_speed, enemy_acceleration * delta)
		
		if distance_to_target < 450:
			velocity = velocity.move_toward(Vector2.ZERO, enemy_deceleration * delta)
			if can_shoot:
				enemy_shoot()
		
		rotation = direction.angle() + deg_to_rad(90)
	
	move_and_slide()

func enemy_shoot() -> void:
	bullet = bullet_scene.instantiate()
	
	bullet.global_position = shoot_marker_2d.global_position
	bullet.bullet_damage = enemy_data.shoot_damage
	bullet.bullet_speed = enemy_data.shoot_speed
	bullet.bullet_direction = direction
	bullet.bullet_texture_choose = enemy_data.laser[enemy_data_index_choose]
	bullet.shooter = self
	
	get_tree().current_scene.add_child(bullet)
	
	shoot_sfx.pitch_scale = randf_range(0.7, 1.2)
	shoot_sfx.play()
	
	cooldown_shoot_timer.start()
	can_shoot = false

func hit_animation() -> void:
	if hit_tween and hit_tween.is_valid(): # Cancela o flash anterior se o inimigo apanhar muito rápido
		hit_tween.kill()
		
	sprite_2d.modulate = Color.WHITE # Reseta a cor para o padrão antes de iniciar o novo efeito
		
	hit_tween = create_tween()
	hit_tween.tween_property(sprite_2d, "modulate", Color.YELLOW, 0.1)
	hit_tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)
	
	shoot_hit_sfx.play()

func trigger_dead() -> void:
	is_dead = true
	can_shoot = false
	
	if hit_tween and hit_tween.is_valid(): # Para o flash de dano imediatamente se o inimigo morrer
		hit_tween.kill()
	
	sprite_2d.visible = false
	health_progress_bar.visible = false
	
	$CollisionShape2D.set_deferred("disabled", true) # Evita colisão com inimigo depois de morto
	$Detect_Shoot_Area2D.set_deferred("monitoring", false) # Desliga o monitoramento para economizar processamento
	
	explosion_animated_sprite_2d.visible = true
	explosion_sfx.play()
	explosion_animated_sprite_2d.play("explosion")

func _on_detect_shoot_area_2d_area_entered(area: Area2D) -> void:
	if is_dead:
		return
	
	if area is Bullet:
		target = area.shooter
		
		enemy_health -= area.bullet_damage
		health_progress_bar.value = enemy_health
		health_progress_bar.visible = true
		
		if enemy_health <= 0:
			trigger_dead() 
		else:
			hit_animation()
		
		area.queue_free()

func _on_detect_ship_collision_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		trigger_dead() 

func _on_cooldown_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_explosion_animated_sprite_2d_animation_finished() -> void:
	queue_free() 
