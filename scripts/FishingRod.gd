extends Node3D

signal rodPull(boolean)

@onready var player = get_node("/root/Main/Player/LaunchDirection")
@onready var rod_anim = $RodAnimations

@onready var main = get_tree().get_root()
@onready var joint = get_node("%Joint")

var direction = null
var active: bool = true

@onready var bobber = get_node("%Bobber")
@onready var point_1 = get_node("%Point_1")

var bobberIdle: bool = true
var bobberInAir: bool = false
var bobberInWater: bool = false
var bobberGrounded: bool = false

func _ready():
	active = false
	bobber.visible = false
	bobber.global_position = point_1.global_position - Vector3(0,0.5,0)
	joint.set_node_a(NodePath("%JointPoint"))
	joint.set_node_b(NodePath("%Bobber"))

func _input(event):

	if active:
		if event.is_action_pressed("left_click"):
			rod_anim.play("rod_pull")
			emit_signal("rodPull", true)
			
		if event.is_action_released("left_click") && !bobberInAir:
			rod_anim.play("rod_cast")
			bobberInAir = true
			joint.set_node_b(NodePath(""))
			emit_signal("rodPull", false)
			$RodSounds/LaunchWoosh.play()
			
		if event.is_action_pressed("right_click"):
			rod_anim.play("reel_in")
			#$RodSounds/ReelIn.play()

			
		if event.is_action_pressed("right_click"):
			#rod_anim.play("RESET")
			bobberInAir = false
			bobber.freeze = false
			bobber.global_position = point_1.global_position - Vector3(0,0.5,0)
			joint.set_node_b(NodePath("%Bobber"))

func _physics_process(delta) -> void:
	if(bobberInAir && !bobberGrounded):
		#direction = point_1.global_transform.basis.z
		direction = player.global_transform.basis.z
		bobber.apply_impulse(-direction * 0.2)

func _on_water_area_body_entered(body):
	if body.is_in_group("Bobber") && bobberInAir:
		bobberInAir = false
		bobberInWater = true
		body.freeze = true

func _on_bobber_body_entered(body):
	print("contact")
	bobberGrounded = true

#non water landing
func _on_bobber_area_body_entered(body):
	if bobberInAir:
		bobberInAir = false
		bobberInWater = false
		bobber.freeze = true
