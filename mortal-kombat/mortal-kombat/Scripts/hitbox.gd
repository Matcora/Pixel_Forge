extends Area2D

@export var damage = 10

@onready var forma = $CollisionShape2D

func _ready():
	# La hitbox arranca apagada: deshabilitar la forma la saca del motor de fisica.
	forma.disabled = true
	visible = false

func activar_golpe():
	# set_deferred porque esto se llama desde _physics_process:
	# el motor no deja tocar las formas mientras procesa colisiones.
	forma.set_deferred("disabled", false)
	visible = true
	await get_tree().create_timer(0.15).timeout
	forma.set_deferred("disabled", true)
	visible = false
