extends StaticBody2D

func _physics_process(delta):
	position.x += 1

var current_level

func _ready():
	var dir = Directory.new()
	if not dir.file_exists('res://Saves/save.tres'):
		$HBoxContainer/VBoxContainer/TextureButton3.disabled = true
	else:
		current_level = load('res://Saves/save.tres').Level

func _on_NewGame_pressed():
	$Camera2D/CanvasLayer/Transition.get_node("AnimationPlayer").play("TransOut")
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().change_scene("res://Levels/L1.tscn")

func _on_Continue_pressed():
	var file = "res://Levels/L" + str(current_level) + ".tscn"
	$Camera2D/CanvasLayer/Transition.get_node("AnimationPlayer").play("TransOut")
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().change_scene(file)
