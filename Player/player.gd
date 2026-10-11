extends CharacterBody2D

const SPEED = 200
const MAX_SPEED = 300
const MAX_DODGE_SPEED = 600
const VELOCITY_DELTA = 50
const ACCELERATION = 7200
const DODGE_ACCELERATION = 14400
const DODGE_DURATION = 0.25
const DODGE_COOLDOWN_DURATION = 0.5
const FRICTION = 5400

# Weapon Stats

@export var shot_pattern: ShotPattern
@export var back_shot_pattern: ShotPattern
@export var bullet_scene: PackedScene

@onready var input_axis = Vector2.ZERO
@onready var axis = Vector2.UP
@onready var SpawnPos = $SpawnPos
@onready var SpawnPosBehind = $SpawnPosBehind
@onready var World = get_parent().get_node("World")
@onready var current_acceleration = 0
@onready var dodge: Dodge = null
@onready var dodge_cooldown: float = 0.0
var shooting_enabled = true

@export var health: int = 5


class Dodge:
	var remaining_duration: float
	var axis: Vector2


	func _init(p_remaining_duration: float, p_axis: Vector2) -> void:
		remaining_duration = p_remaining_duration
		axis = p_axis


	func decay(delta: float) -> Dodge:
		self.remaining_duration -= delta
		if self.remaining_duration <= 0:
			return null
		return self


	func is_accelerating() -> bool:
		return self.remaining_duration / DODGE_DURATION > 0.5


func _physics_process(delta: float) -> void:
	Globals.player_position = global_position

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move(delta)
	rotate_default(delta)
	move_and_slide()
		
	if global_position.x > World.map_size.x/2:
		global_position.x -= World.map_size.x
	elif global_position.x < -World.map_size.x/2:
		global_position.x += World.map_size.x

	if global_position.y > World.map_size.y/2:
		global_position.y -= World.map_size.y
	elif global_position.y < -World.map_size.y/2:
		global_position.y += World.map_size.y
	Globals.player_position = global_position


func is_orthogonal(axis_1: Vector2, axis_2: Vector2) -> bool:
	return is_zero_approx(axis_1.dot(axis_2))


func move(delta: float):
	dodge_cooldown = max(0, dodge_cooldown - delta)
	if dodge != null:
		move_dodge(delta)
	else:
		move_default(delta)


func move_dodge(delta: float):
	if dodge.is_accelerating():
		var accel = dodge.axis * DODGE_ACCELERATION * delta
		velocity += accel
	else:
		var vel_mult = clamp(1 - delta / 0.15, 0.0, 1.0)
		velocity *= vel_mult
	velocity = velocity.limit_length(MAX_DODGE_SPEED)
	dodge = dodge.decay(delta)


func move_default(delta: float):
	input_axis = get_input_axis()

	if input_axis != Vector2.ZERO:
		if get_dodge_pressed():
			if is_orthogonal(axis, input_axis) and dodge_cooldown == 0:
				dodge = Dodge.new(DODGE_DURATION, input_axis)
				dodge_cooldown = DODGE_COOLDOWN_DURATION
		else:
			axis = input_axis
			current_acceleration = ACCELERATION
	if snap_to_tenths(axis) == -snap_to_tenths(velocity.normalized()):
		current_acceleration = ACCELERATION - FRICTION
	var accel = axis * current_acceleration * delta
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)


func rotate_default(_delta: float):
	rotation_degrees = rad_to_deg(atan2(axis.y, axis.x))


func get_dodge_pressed() -> bool:
	return Input.is_action_pressed("Dodge")


func get_input_axis():
	return Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))


func apply_friction(amount: float):
	if velocity.length() > amount:
		velocity -= amount * velocity.normalized()
	else:
		velocity = Vector2.ZERO


func _process(_delta: float):
	if Input.is_action_pressed("Shoot") and shooting_enabled:
		shoot()


func _on_ShootSpeed_timeout():
	shooting_enabled = true


func shoot():
	# print("player: axis.angle() = ", rad_to_deg(axis.angle()))
	shot_pattern.fire(SpawnPos.global_position, rad_to_deg(axis.angle()), get_tree().current_scene)
	back_shot_pattern.fire(
		SpawnPosBehind.global_position,
		rad_to_deg((-axis).angle()),
		get_tree().current_scene,
	)
	$ShootSpeed.start(shot_pattern.firing_rate)
	shooting_enabled = false


func player_hit(damage):
	health -= damage
	if health <= 0:
		explode()


func explode():
	# Play animation
	queue_free()


func snap_to_tenths(vector: Vector2):
	# Rounds components of vector to tenths place
	return vector.snapped(Vector2(0.1, 0.1))
