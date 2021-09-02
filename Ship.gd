extends KinematicBody

var max_speed = 50
var acceleration = 0.6
var input_response = 8.0

var hover_thrust = 10
var up_thrust = 200
var down_thrust = 150
var vertical_decay = 0.98
var up = 0

var velocity = Vector3.ZERO
var throttle = 0
var throttle_accel = 10
var throttle_brake = 15
var throttle_max = 100

var forward_speed = 0
var pitch_input = 0.0
var yaw_input = 0.0
var roll_input = 0.0

var pitch = 0.0
var yaw = 0.0
var roll = 0.0
var pitch_speed = 1.5
var roll_speed = 1.9
var yaw_speed = 1.25

var Bullet = load("res://Bullet.tscn")
# export (PackedScene) var Bullet

var input = {}

func _ready():
    pass

func _process(delta):

    if input['fire_primary']:
        var b = Bullet.instance()
        owner.add_child(b)
        b.transform = $Nosegun/Muzzle.global_transform
        b.velocity = -b.transform.basis.z * b.muzzle_velocity

    # calculate vertical thrust
    if input['vertical_thrust_up']:
        up += up_thrust * delta
    if input['vertical_thrust_down']:
        up -= down_thrust * delta
    up *= vertical_decay

    # calculate throttle
    if input['throttle_up']:
        throttle = min(throttle + (throttle_accel * delta), throttle_max)
    if input['throttle_down']:
        throttle = max(throttle - (throttle_brake * delta), 0)

    # calculate rotations
    pitch = clamp(pitch_input * 20 * delta, -1, 1)
    if input['pitch_up']:
        pitch += -1
    if input['pitch_down']:
        pitch += 1

    yaw = clamp(yaw_input * 20 * delta, -1, 1)
    if input['yaw_left']:
        yaw += 1
    if input['yaw_right']:
        yaw += -1

    roll = clamp(roll_input * 20 * delta, -1, 1)
    if input['roll_left']:
        roll += -1
    if input['roll_right']:
        roll += 1

    # what the hell is this
    transform.basis = transform.basis.rotated(transform.basis.z, roll * roll_speed * delta)
    transform.basis = transform.basis.rotated(transform.basis.x, pitch * pitch_speed * delta)
    transform.basis = transform.basis.rotated(transform.basis.y, yaw * yaw_speed * delta)
    transform.basis = transform.basis.orthonormalized()

    velocity = transform.basis * Vector3(0, up, throttle)

    move_and_collide(velocity * delta, false)
