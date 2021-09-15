extends Spatial

var pos setget , get_pos

var yaw_limit = Vector2(-PI/2, PI/2)
var pitch_limit = Vector2(-PI/2, PI/5)

func get_pos():
    return $InnerGimbal/CameraPos

func reset():
    transform.basis = Basis()
    $InnerGimbal.transform.basis = Basis()

func freelook(pos):
    yaw(-pos.x)
    pitch(pos.y)

func yaw(value):
    rotate_object_local(Vector3.UP, value)
    rotation.y = clamp(rotation.y, yaw_limit.x, yaw_limit.y)

func pitch(value):
    $InnerGimbal.rotate_object_local(Vector3.RIGHT, value)
    $InnerGimbal.rotation.x = clamp($InnerGimbal.rotation.x, pitch_limit.x, pitch_limit.y)
