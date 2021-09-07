extends Area

var velocity = Vector3.ZERO
var fired_by = null

func _ready():
    connect('area_entered', self, '_on_area_entered')

func init(weapon):
    fired_by = weapon
    global_transform = weapon.get_node('Muzzle').global_transform
    velocity = -transform.basis.z * weapon.muzzle_velocity

func _on_area_entered(area):
    var target = area.get_parent()
    fired_by.on_impact(target)
    queue_free()

func _physics_process(delta):
    transform.origin += -velocity * delta
