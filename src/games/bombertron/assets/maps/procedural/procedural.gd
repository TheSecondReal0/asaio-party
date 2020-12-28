extends Node2D

var wall = preload("res://assets/maps/procedural/wall.tscn")

var increment = 5

func _ready():
	print("procedural map loaded")
	createRaceTrack(mapGenerator.pastCoords, mapGenerator.pastAngles)

func createRaceTrack(trackArray, angleArray):
	print("creating racetrack")
	for i in range(0, (trackArray.size() / increment) - 1):
		var currentCoord = trackArray[i * increment]
		var currentAngle = angleArray[i * increment]
		createWallsAtPosAngle(currentCoord, currentAngle)

func createWallsAtPosAngle(pos, angle):
	createWall(pos + (Vector2(cos(angle - (PI/2)), sin(angle - (PI/2))) * mapGenerator.trackRadius), angle)
	createWall(pos + (Vector2(cos(angle + (PI/2)), sin(angle + (PI/2))) * mapGenerator.trackRadius), angle)

func createWall(pos, angle):
	var newWall = wall.instance()
	newWall.position = pos
	newWall.rotation = angle
	add_child(newWall)
