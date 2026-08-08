extends Area2D

func _on_area_entered(area):
	if area.is_in_group("hitbox"):
		var dano = area.get("damage")
		if dano == null:
			dano = 10
		get_parent().recibir_dano(dano)
