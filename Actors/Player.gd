extends KinematicBody2D

var velocity = Vector2.ZERO

var speed = Vector2(150, 300)
var gravity = 1000
var soulLeft

onready var camera = get_parent().get_node("Camera2D")

func _ready():
	if get_parent().name != "WinScreen":
		soulLeft = get_tree().get_root().get_node("World").soulCount
		get_tree().paused = false
		get_parent().get_node("UI/UI/MarginContainer/Soul/SoulIcon/Label").text = str(soulLeft)

func _physics_process(_delta):
	if Input.is_action_just_pressed("move_jump") and ((is_on_floor() and gravity > 0) or (is_on_ceiling() and gravity < 0)):
		var streamPlayer = AudioStreamPlayer.new()
		add_child(streamPlayer)
		streamPlayer.stream = load("res://Assets/Music/Jump.wav")
		streamPlayer.play()
		streamPlayer.connect("finished", Music, "free_body", [streamPlayer])
	if camera != null and position.y > camera.limit_bottom + 30:
		restart()
	if Input.is_action_just_pressed("restart"):
		restart()
	var isJumpInterrupted = Input.is_action_just_released("move_jump") and velocity.y < 0.0
	var moveVector = getMoveVector()
	handleAnimations(moveVector)
	velocity = calculate_move_velocity(velocity, moveVector, speed, isJumpInterrupted)
	velocity = move_and_slide(velocity, Vector2.UP)

func getMoveVector():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("move_jump") and ((is_on_floor() and gravity > 0) or (is_on_ceiling() and gravity < 0)) else 1.0
		)

func calculate_move_velocity(
		linearVelocity: Vector2, moveVector: Vector2, moveSpeed: Vector2, isJumpInterrupted: bool
	) -> Vector2:
	var out = Vector2(moveSpeed.x * moveVector.x, linearVelocity.y + gravity * get_physics_process_delta_time())
	if moveVector.y < 0:
		out.y = moveSpeed.y * moveVector.y
	if isJumpInterrupted:
		out.y = 0
	return out

func handleAnimations(moveVector):
	var mod
	if gravity > 0:
		mod = -1
	else:
		mod = 1
	if moveVector.y != 0 and not ((is_on_floor() and gravity > 0) or (is_on_ceiling() and gravity < 0)):
		$AnimatedSprite.animation = "jump"
		if moveVector.x != 0:
			$AnimatedSprite.flip_h = clamp(moveVector.x * mod, 0, 1)
		return
	if moveVector.x == 0:
		$AnimatedSprite.animation = "idle"
	else:
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.flip_h = clamp(moveVector.x * mod, 0, 1)

func restart():
	get_parent().get_node("WinBox/AnimationPlayer").play("TransOut")
	get_parent().get_node("WinBox/AnimationPlayer").connect("animation_finished", self, "restartReload")
	set_physics_process(false)

func restartReload(anim_name):
	if anim_name == "TransOut":
		var reload = get_tree().reload_current_scene()
