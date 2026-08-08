extends CharacterBody2D


@export var speed = 300
@export var gravity =1350
@export var jump_force = -400
@export var min_x= 50
@export var max_x= 750

func _physics_process(delta):

	var direction = Input.get_axis("move_left","move_right")
	velocity.x = direction * speed
	velocity.y += gravity * delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
	
	move_and_slide()
	position.x = clamp(position.x, min_x, max_x)
	if Input.is_action_just_pressed("action"):
		print("golpe")
