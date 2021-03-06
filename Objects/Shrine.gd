extends Node2D

var player_in_area = false

export var speed = Vector2(300, 300)
export var gravity = 1000
export var passThroughLayer = 3
export var modHex = "#ffffff"
export var story = "L1/Shrine"

var Dialog = preload("res://Dialog/Dialog.tscn")

var dialog

onready var player = get_tree().get_root().get_node("World/Player")
onready var camera = get_tree().get_root().get_node("World/Camera2D")

func dialog():
	player.get_node("AnimatedSprite").animation = "idle"
	player.get_node("AnimatedSprite").frame = 0
	if story == "none":
		get_tree().paused = true
		cutscene()
	else:
		dialog = Dialog.instance()
		add_child(dialog)
		dialog.get_node("Dialog_Box").visible = true
		dialog.play_dialog(story)
		get_tree().paused = true
		dialog.connect("dialogFinished", self, "cutscene")

func cutscene():
	player.soulLeft -= 1
	get_parent().get_node("UI/UI/MarginContainer/Soul/SoulIcon/Label").text = str(player.soulLeft)
	if player.soulLeft == 0:
		var dialog = Dialog.instance()
		add_child(dialog)
		dialog.play_dialog("Shrine/NoSoul")
		get_tree().paused = true
		return dialog.connect("dialogFinished", self, "restart")
	$Animation/Soul.global_position = Vector2(player.global_position.x, player.global_position.y - 40)
	$Animation/Soul.show()
	$Animation/Anim.play("ScaleIn")

func _physics_process(_delta):
	if Input.is_action_just_pressed("trade") and player_in_area:
		dialog()
	if player.global_position.x > global_position.x:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

func _on_Anim_animation_finished(anim_name):
	if anim_name == "ScaleIn":
		var streamPlayer = AudioStreamPlayer.new()
		streamPlayer.volume_db = 5
		add_child(streamPlayer)
		streamPlayer.stream = load("res://Assets/Sounds/boom.wav")
		streamPlayer.play()
		streamPlayer.connect("finished", Music, "free_body", [streamPlayer])
		camera.shake(0.7, 20, 40)
		$Animation/SoulParticles.global_position = Vector2(player.global_position.x, player.global_position.y - 40)
		$Animation/SoulParticles.restart()
		$Animation/Soul.hide()
		yield(get_tree().create_timer(2.6), "timeout")
		
		var statue = load("res://Objects/Statue.tscn").instance()
		get_parent().add_child(statue)
		statue.global_position = player.global_position
		statue.modulate = player.modulate
		statue.get_node("Sprite").flip_h = player.get_node("AnimatedSprite").flip_h
		statue.get_node("Sprite").flip_v = player.get_node("AnimatedSprite").flip_v
		player.modulate = modHex
		
		$Animation/Tween.interpolate_property(statue, "modulate", 
			statue.modulate, Color(statue.modulate.r, statue.modulate.b, statue.modulate.g, 0), 2.0, 
		$Animation/Tween.TRANS_LINEAR, $Animation/Tween.EASE_IN)
		$Animation/Tween.start()
		
		player.speed = speed
		player.gravity = gravity
		player.set_collision_mask(2 + passThroughLayer)
		
		yield(get_tree().create_timer(2), "timeout")
		if gravity < 0:
			player.rotation_degrees = 180
		else:
			player.rotation_degrees = 0
		get_tree().paused = false
		player.velocity = Vector2.ZERO
		$Animation/Anim.play("ScaleOut")


func _on_Area2D_body_entered(body):
	if body == player:
		player_in_area = true
		$Animation/EKey.show()


func _on_Area2D_body_exited(body):
	player_in_area = false
	$Animation/EKey.hide()

func restart():
	player.restart()
