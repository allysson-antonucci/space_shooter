extends Node2D
class_name Space

@onready var player: Player = $Player
@export var enemy_1_scene: PackedScene
@onready var next_wave_timer: Timer = $Next_Wave_Timer

var enemy: CharacterBody2D

func spawn_enemy() -> void:
	if is_instance_valid(enemy): # Se ele existir, cancela o spawn para manter apenas um (Futuramente fazer waves de inimigos)
		return
	else:
		enemy = enemy_1_scene.instantiate()
		
		var random_sign_vector: Vector2 = Vector2([-1, 1].pick_random(), [-1, 1].pick_random())
		enemy.global_position = player.global_position + random_sign_vector * Vector2(500, 500)
		enemy.target = player
		add_child(enemy)

func _on_next_wave_timer_timeout() -> void:
	spawn_enemy()
