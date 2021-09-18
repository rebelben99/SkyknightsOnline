extends Area

var velocity = Vector3.FORWARD
var grav = Vector3.DOWN * 9.8
var fired_by = null
var lifetime = 0.0
var cull_time = 10.0
var prev_pos
var origin

func init(weapon, angle):
    fired_by = weapon
    global_transform = weapon.get_node('Muzzle').global_transform
    rotate(Vector3.FORWARD, angle.y)
    rotate(Vector3.UP, angle.x)
    velocity *= weapon.muzzle_velocity
    origin = transform.origin

func _physics_process(delta):
    lifetime += delta
    if lifetime > cull_time:
        queue_free()

    var v = Quat(global_transform.basis).xform(velocity)
    var pos = transform.origin - (v * delta)

    prev_pos = transform.origin
    transform.origin -= v * delta
    transform.origin += grav * delta

    var space_state = get_world().direct_space_state
    var result = space_state.intersect_ray(prev_pos, transform.origin, [self], collision_mask, true, true)
    if 'collider' in result:
        var target = result['collider'].get_parent()
        fired_by.on_impact(target, origin.distance_to(transform.origin))
        queue_free()
