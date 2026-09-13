extends Node3D

@export var car_scene: PackedScene
@export var min_interval: float = 1.5
@export var max_interval: float = 4.0

func _ready():
	spawn_loop()

func spawn_loop():
	while true:
		await get_tree().create_timer(randf_range(min_interval, max_interval)).timeout
		var car = car_scene.instantiate()
		get_tree().current_scene.add_child(car)   # add to tree
		car.global_position = global_position      # set transform
		car.global_transform.basis = global_transform.basis
