extends KinematicBody2D

onready var collision_shape = $CollisionShape2D
onready var poof_timer = $poof_timer

var dir: Vector2 = Vector2()

var speed = 20

var harvestable: bool = false
var harvested: bool = false

var time_safe: float = 1
var time_harvestable: float = 1

var time_until_harvestable: float = time_safe
var time_until_poof: float = time_harvestable

func _ready():
	dir = get_new_dir()

func _process(delta):
	if harvested:
		return
	if harvestable:
		time_until_poof -= delta
		if time_until_poof <= 0:
			poof(true)
	else:
		time_until_harvestable -= delta
		if time_until_harvestable <= 0:
			become_harvestable()
	
# warning-ignore:return_value_discarded
	move_and_collide(dir * speed * delta)

func harvest() -> float:
	print("harvested")
	poof()
	if harvestable:
		return 1.0
	return 0.0

func become_harvestable():
	harvestable = true

func poof(explode: bool = false):
	harvested = true
	$Polygon2D.hide()
	collision_shape.set_deferred("disabled", true)
	poof_timer.start()
	if explode:
		$CPUParticles2D.restart()

func get_new_dir() -> Vector2:
	return Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()

func _on_poof_timer_timeout():
	queue_free()
