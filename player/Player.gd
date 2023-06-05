extends CharacterBody3D

signal toggle_inventory()

@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip
@export var rod_inventory_data: InventoryDataRod

@onready var speed: float
const ROD_WALK_SPEED = 5.0
const WALK_SPEED = 9.0
const SPRINT_SPEED = 14.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var gravity = 9.8
var health: int = 5

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/PlayerCam

@onready var interact_ray: RayCast3D = $Neck/PlayerCam/InteractRay
var lastCollision = null

@onready var ground_cam: Camera3D = get_node("%GroundCam")
@onready var ground_cam_positioner: Node3D = $GroundCamPositioner
var surface: String
var isMoving: bool
var state
var playFootstep: bool = false
var landing

@onready var step_player = $Sounds/step_player
@onready var walk_sand = load("res://assets/sounds/player/walking_sand.mp3")
@onready var walk_grass = load("res://assets/sounds/player/walking_grass.mp3")
@onready var jump_up = $Sounds/jump_up
@onready var sand_land = $Sounds/sand_land
@onready var grass_land = $Sounds/grass_land
@onready var pickup_sound = $Sounds/pickup_sound


func _ready():
	PlayerManager.player = self
	PlayerManager.rod = $Neck/Rod
	PlayerManager.bobber = get_node("/root/Main/Bobber")
	PlayerManager.fishing_line = get_node("/root/Main/Cast")
	#PlayerManager.pickup_sound = 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event):
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * SENSITIVITY)
			neck.rotate_x(-event.relative.y * SENSITIVITY)
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-80), deg_to_rad(80))
			
	if Input.is_action_just_pressed("interact"):
		interact()
	

func _physics_process(delta) -> void:
	
	if interact_ray.is_colliding():
		lastCollision = interact_ray.get_collider()
		if lastCollision != null:
			lastCollision.outlineVisible = true
	elif lastCollision != null:
		lastCollision.outlineVisible = false
	
	
	var r = $GroundMaterial/SubViewport.get_viewport().get_texture().get_image().get_pixel(12,12).r
	var g = $GroundMaterial/SubViewport.get_viewport().get_texture().get_image().get_pixel(12,12).g
	ground_cam.global_position = ground_cam_positioner.global_position
	
	if is_on_floor():
		if landing:
			if surface == "grass":
				grass_land.play()
			if surface == "sand":
				sand_land.play()
			landing = false
	else:
		if !landing:
			landing = true

	if surface == "sand":
		if state == "walking" && !step_player.is_playing():
			step_player.pitch_scale = randf_range(0.95, 1.05)
			step_player.set_stream(walk_sand)
			step_player.play()
		if state == "sprinting" && !step_player.is_playing():
			step_player.pitch_scale = randf_range(1.5, 1.6)
			step_player.set_stream(walk_sand)
			step_player.play()
	if surface == "grass":
		if state == "walking" && !step_player.is_playing():
			step_player.pitch_scale = randf_range(0.95, 1.05)
			step_player.set_stream(walk_grass)
			step_player.play()
		if state == "sprinting" && !step_player.is_playing():
			step_player.pitch_scale = randf_range(1.5, 1.6)
			step_player.set_stream(walk_grass)
			step_player.play()

		
	if state == "inAir":
		pass
	if state == "idle":
		pass
	
	if isMoving && is_on_floor():
		playFootstep = true
		state = "walking"
		
	
	if not is_on_floor():
		state = "inAir"
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_up.play()
	
	if Input.is_action_pressed("sprint") and is_on_floor():
		speed = SPRINT_SPEED
		state = "sprinting"
	else:
		speed = WALK_SPEED 
	
	var input_dir = Input.get_vector("move_left","move_right","move_forward","move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3(0,0,0):
		isMoving = true
	elif is_on_floor():
		isMoving = false
		state = "idle"
	
	if is_on_floor() || landing == true:
		if r > 0.01 && g < 0.01:
			surface = "grass"
		else:
			surface = "sand"
		
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _on_water_area_body_entered(body) -> void:
	if body.is_in_group("Player"):
		print("player feet in water")

func _on_rod_rod_pull(boolean) -> void:
	if(boolean):
		speed = ROD_WALK_SPEED

func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()

func get_drop_position() -> Vector3:
	var direction = -camera.global_transform.basis.z * 1.2
	return camera.global_position + direction

func heal(healValue) -> void:
	health += healValue

