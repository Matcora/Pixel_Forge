extends CharacterBody2D

@export var speed = 300
@export var gravity = 1350
@export var jump_force = -400

@export var min_x = 50
@export var max_x = 750

@export var action_move_left = "move_left"
@export var action_move_right = "move_right"
@export var action_jump = "jump"
@export var action_attack = "action"
@export var action_crouch = "crouch"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sombra: AnimatedSprite2D = get_node_or_null("Sombra")

var golpeando: bool = false
var punch_animations = ["punch1", "punch2", "punch3", "punch4"]
var punch_index = 0
var bodytobody_animations = ["bodytobody1", "bodytobody2"]
var bodytobody_index = 0


func _physics_process(delta):
	var direction = Input.get_axis(action_move_left, action_move_right)
	velocity.x = direction * speed
	velocity.y += gravity * delta

	if is_on_floor() and Input.is_action_just_pressed(action_jump):
		velocity.y = jump_force

	move_and_slide()

	global_position.x = clamp(global_position.x, min_x, max_x)

	if direction != 0:
		anim.flip_h = direction < 0
		if sombra:
			sombra.flip_h = direction < 0

	if Input.is_action_just_pressed(action_attack):
		print("golpe")
		var agachado = Input.is_action_pressed(action_crouch)
		var nombre_golpe

		if agachado:
			nombre_golpe = bodytobody_animations[bodytobody_index]
			bodytobody_index = (bodytobody_index + 1) % bodytobody_animations.size()
		else:
			nombre_golpe = punch_animations[punch_index]
			punch_index = (punch_index + 1) % punch_animations.size()

		if anim.sprite_frames.has_animation(nombre_golpe):
			golpeando = true
			jugar_animacion(nombre_golpe)

	if golpeando:
		if not anim.is_playing():
			golpeando = false
	else:
		if direction != 0:
			jugar_animacion("walk")
		else:
			jugar_animacion("stance")


func jugar_animacion(nombre: String) -> void:
	if anim.sprite_frames.has_animation(nombre):
		anim.play(nombre)
	if sombra and sombra.sprite_frames.has_animation(nombre):
		sombra.play(nombre)
