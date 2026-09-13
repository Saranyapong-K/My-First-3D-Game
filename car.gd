extends CharacterBody3D

@export var min_speed: float = 40.0
@export var max_speed: float = 80.0
@export var travel_distance: float = 300.0  # how far down the road before respawning/freeing

var speed: float
var start_z: float

func _ready():
	speed = randf_range(min_speed, max_speed)
	start_z = global_position.z
	$HitArea.body_entered.connect(_on_hit_area_body_entered)

func _physics_process(delta):
	velocity = transform.basis.z * speed  # assumes car's forward is +Z, flip sign if needed
	move_and_slide()

	# Optional: recycle the car once it's driven far enough
	if abs(global_position.z - start_z) > travel_distance:
		queue_free()

func _on_hit_area_body_entered(body):
	if body.is_in_group("player"):
		GameManager.game_over()



func _on_honk_area_body_entered(body):
	if body.is_in_group("player"):
		$AudioStreamPlayer3D.play()
