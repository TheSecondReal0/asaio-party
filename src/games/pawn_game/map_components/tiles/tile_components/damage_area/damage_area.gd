extends Area2D

onready var damage: int = get_parent().damage

func _physics_process(delta):
	var bodies: Array = get_overlapping_bodies()
	if bodies.empty():
		return
	for body in bodies:
		if not body.is_in_group("pawns"):
			#print("collider not pawn")
			return
		#print(body)
		body.damage(damage * delta)
