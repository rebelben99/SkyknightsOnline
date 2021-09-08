extends Area

var velocity = Vector3.ZERO
var grav = Vector3.DOWN
var fired_by = null
var lifetime = 0.0
var cull_time = 10.0

func _ready():
    connect('area_entered', self, '_on_area_entered')
    connect('body_entered', self, '_on_body_entered')

func init(weapon):
    fired_by = weapon
    global_transform = weapon.get_node('Muzzle').global_transform
    velocity = -transform.basis.z * weapon.muzzle_velocity

func _on_area_entered(area):
    var target = area.get_parent()
    fired_by.on_impact(target)
    queue_free()

func _on_body_entered(body):
    queue_free()

func _physics_process(delta):
    lifetime += delta
    if lifetime > cull_time:
        print('bullet timing out')
        queue_free()

    transform.origin += -velocity * delta
    transform.origin += grav * delta
