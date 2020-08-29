extends Node2D

var player_in_area = false


export var speed = Vector2(300, 300)
export var gravity = 1000
export var passThroughLayer = 3


var Statue = preload("res://Objects/Statue.tscn")

onready var player = get_tree().get_root().get_node("World/Player")

func cutscene():
	$Animation/Soul.global_position = Vector2(player.global_position.x, player.global_position.y - 40)
	$Animation/Soul.show()
	$Animation/Anim.play("ScaleIn")
	get_tree().paused = true

func _physics_process(_delta):
	if Input.is_action_just_pressed("trade") and player_in_area:
		cutscene()
	if player.global_position.x > global_position.x:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

func _on_Anim_animation_finished(anim_name):
	$Animation/SoulParticles.global_position = Vector2(player.global_position.x, player.global_position.y - 40)
	$Animation/SoulParticles.restart()
	$Animation/Soul.hide()
	yield(get_tree().create_timer(2.6), "timeout")
	var statue = Statue.instance()
	add_child(statue)
	statue.global_position = player.global_position
	statue.get_node("Sprite").flip_h = player.get_node("AnimatedSprite").flip_h
	player.get_node("AnimationPlayer").play("FadeOut")
	yield(get_tree().create_timer(0.3), "timeout")
	player.global_position = Vector2(position.x + 40, position.y - 30)
	player.get_node("AnimationPlayer").play("FadeIn")
	yield(get_tree().create_timer(0.3), "timeout")
	
	player.speed = speed
	player.gravity = gravity
	player.set_collision_mask(2 + passThroughLayer)
	
	get_tree().paused = false


func _on_Area2D_body_entered(body):
	player_in_area = true
	$Animation/EKey.show()


func _on_Area2D_body_exited(body):
	player_in_area = false
	$Animation/EKey.hide()