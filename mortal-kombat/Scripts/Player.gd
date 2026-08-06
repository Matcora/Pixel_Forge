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

@export var rival_path: NodePath

# Distancia minima permitida entre los centros de los dos personajes.
# Si quedan mas cerca que esto (por ejemplo, al caer uno encima del
# otro tras un salto), se separan automaticamente.
@export var separacion_minima = 70.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sombra: AnimatedSprite2D = get_node_or_null("Sombra")
@onready var rival: Node2D = get_node_or_null(rival_path)

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

	# Evita que los dos personajes queden encimados o muy juntos
	# (por ejemplo, al caer uno sobre el otro tras un salto)
	if rival and is_on_floor() and rival.is_on_floor():
		var distancia = abs(global_position.x - rival.global_position.x)
		if distancia < separacion_minima:
			var direccion_empuje = sign(global_position.x - rival.global_position.x)
			if direccion_empuje == 0:
				direccion_empuje = 1.0
			var faltante = separacion_minima - distancia
			global_position.x += direccion_empuje * faltante * 0.5
			global_position.x = clamp(global_position.x, min_x, max_x)

	if rival:
		var mirar_izquierda = rival.global_position.x < global_position.x
		anim.flip_h = mirar_izquierda
		if sombra:
			sombra.flip_h = mirar_izquierda

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
