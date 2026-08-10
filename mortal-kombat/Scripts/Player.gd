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
@export var action_kick = "kick"
@export var action_crouch = "crouch"

@export var rival_path: NodePath
@export var separacion_minima = 70.0
@export var distancia_agarre = 100.0

@export var vida_maxima = 100

@export var barra_vida: Range

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sombra: AnimatedSprite2D = get_node_or_null("Sombra")
@onready var rival: Node2D = get_node_or_null(rival_path)
@onready var hitbox: Area2D = get_node_or_null("Hitbox")

var vida: float
var hitbox_offset_x: float = 0.0

var golpeando: bool = false

var punch_animations = ["punch1", "punch2", "punch3", "punch4"]
var punch_index = 0
var kick_animations = ["kick1", "kick2", "kick3", "kick4"]
var kick_index = 0
var bodytobody_animations = ["bodytobody1", "bodytobody2"]
var bodytobody_index = 0

var air_punch_animations = ["jump2", "jump8"]
var air_punch_index = 0
var air_roll_animations = ["jump7"]
var air_roll_index = 0

var mirar_izquierda: bool = false


func _ready():
	vida = vida_maxima
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida
	if hitbox:
		hitbox_offset_x = hitbox.position.x


func _physics_process(delta):
	var direction = Input.get_axis(action_move_left, action_move_right)
	velocity.x = direction * speed
	velocity.y += gravity * delta

	if is_on_floor() and Input.is_action_just_pressed(action_jump):
		velocity.y = jump_force
		air_roll_index = (air_roll_index + 1) % air_roll_animations.size()

	move_and_slide()

	global_position.x = clamp(global_position.x, min_x, max_x)

	if rival and is_on_floor() and rival.is_on_floor():
		var distancia_actual = abs(global_position.x - rival.global_position.x)
		if distancia_actual < separacion_minima:
			var direccion_empuje = sign(global_position.x - rival.global_position.x)
			if direccion_empuje == 0:
				direccion_empuje = 1.0
			var faltante = separacion_minima - distancia_actual
			global_position.x += direccion_empuje * faltante * 0.5
			global_position.x = clamp(global_position.x, min_x, max_x)

	if rival:
		mirar_izquierda = rival.global_position.x < global_position.x
		anim.flip_h = mirar_izquierda
		if sombra:
			sombra.flip_h = mirar_izquierda
		if hitbox:
			hitbox.position.x = -hitbox_offset_x if mirar_izquierda else hitbox_offset_x

	var agachado = Input.is_action_pressed(action_crouch)
	var en_aire = not is_on_floor()
	var distancia_rival = INF
	if rival:
		distancia_rival = abs(global_position.x - rival.global_position.x)

	# Boton de golpe
	if Input.is_action_just_pressed(action_attack):
		var nombre_golpe = ""

		if not agachado and not en_aire and distancia_rival < distancia_agarre:
			nombre_golpe = bodytobody_animations[bodytobody_index]
			bodytobody_index = (bodytobody_index + 1) % bodytobody_animations.size()
		elif agachado and not en_aire:
			nombre_golpe = "down2"
		elif en_aire:
			nombre_golpe = air_punch_animations[air_punch_index]
			air_punch_index = (air_punch_index + 1) % air_punch_animations.size()
		else:
			nombre_golpe = punch_animations[punch_index]
			punch_index = (punch_index + 1) % punch_animations.size()

		if anim.sprite_frames.has_animation(nombre_golpe):
			golpeando = true
			jugar_animacion(nombre_golpe)
			if hitbox:
				hitbox.activar_golpe()

	# Boton de patada
	elif Input.is_action_just_pressed(action_kick):
		var nombre_patada = ""

		if agachado and not en_aire:
			nombre_patada = "down3"
		elif en_aire:
			if direction == 0:
				nombre_patada = "jump3"
			else:
				nombre_patada = "jump9"
		else:
			nombre_patada = kick_animations[kick_index]
			kick_index = (kick_index + 1) % kick_animations.size()

		if anim.sprite_frames.has_animation(nombre_patada):
			golpeando = true
			jugar_animacion(nombre_patada)
			if hitbox:
				hitbox.activar_golpe()

	# Estado pasivo (cuando no esta golpeando/pateando)
	if golpeando:
		if not anim.is_playing():
			golpeando = false
			if agachado:
				mostrar_pose_agachada()
	else:
		if en_aire:
			if direction != 0:
				jugar_animacion(air_roll_animations[air_roll_index], false)
			else:
				jugar_animacion("jump4", false)
		elif agachado:
			jugar_animacion("down1", false)
		elif direction != 0:
			jugar_animacion("walk", false)
		else:
			jugar_animacion("stance", true)


func mostrar_pose_agachada() -> void:
	# Salta directo al ultimo frame de down1 (posicion ya agachada),
	# sin repetir la transicion de pararse a agacharse
	if anim.sprite_frames.has_animation("down1"):
		anim.animation = "down1"
		anim.frame = anim.sprite_frames.get_frame_count("down1") - 1
		anim.stop()
	if sombra and sombra.sprite_frames.has_animation("down1"):
		sombra.animation = "down1"
		sombra.frame = sombra.sprite_frames.get_frame_count("down1") - 1
		sombra.stop()


func jugar_animacion(nombre: String, reiniciar: bool = true) -> void:
	if anim.sprite_frames.has_animation(nombre):
		if reiniciar or anim.animation != nombre:
			anim.play(nombre)
	if sombra and sombra.sprite_frames.has_animation(nombre):
		if reiniciar or sombra.animation != nombre:
			sombra.play(nombre)


func recibir_dano(cantidad) -> void:
	vida = clamp(vida - cantidad, 0, vida_maxima)
	if barra_vida:
		barra_vida.value = vida
	print(name, " recibio ", cantidad, " de daño. Vida restante: ", vida)
	if vida <= 0:
		print(name, " fue derrotado")
