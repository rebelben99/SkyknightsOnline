extends Spatial

# these control the ship's handling
export var max_speed = 150
export var acceleration = 0.6

export var hover_thrust = 100
export var up_thrust = 300
export var down_thrust = 150
export var vertical_decay = 0.98

export var throttle_accel = 10
export var throttle_brake = 15
export var throttle_max = 200

export var pitch_speed = 100
export var roll_speed = 100
export var yaw_speed = 20

# internal use
var up = 0
var velocity = Vector3.ZERO
var torque = Vector3.ZERO
var throttle = 0
var pitch = 0.0
var yaw = 0.0
var roll = 0.0

func calculate_forces(input):
    var angle = global_transform.basis.get_euler()
    var attitude = max(abs(angle.x), abs(angle.z))
    var hover_factor = 1 - (attitude / 2)

    up = hover_thrust * hover_factor
    if input['vertical_thrust_up']:
        up += up_thrust
    if input['vertical_thrust_down']:
        up -= down_thrust
    up *= vertical_decay

    if input['throttle_up']:
        throttle = min(throttle + throttle_accel, throttle_max)
    if input['throttle_down']:
        throttle = max(throttle - throttle_brake, 0)

    velocity.x = 0
    velocity.y = up
    velocity.z = throttle

    pitch = clamp(input['pitch'], -1, 1)
    if input['pitch_up']:
        pitch += -1
    if input['pitch_down']:
        pitch += 1
    pitch = clamp(pitch, -1, 1)
    torque.x = pitch * pitch_speed

    yaw = clamp(input['yaw'], -1, 1)
    if input['yaw_left']:
        yaw += 1
    if input['yaw_right']:
        yaw += -1
    yaw = clamp(yaw, -1, 1)
    torque.y = yaw * yaw_speed

    roll = clamp(input['roll'], -1, 1)
    if input['roll_left']:
        roll += -1
    if input['roll_right']:
        roll += 1
    roll = clamp(roll, -1, 1)
    torque.z = roll * roll_speed

    torque = Quat(global_transform.basis).xform(torque)
    velocity = Quat(global_transform.basis).xform(velocity)
