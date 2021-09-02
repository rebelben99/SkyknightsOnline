extends Spatial

func _ready():
    pass

func _process(_delta):
    pass

func set_current():
    $InnerGimbal/Camera.current = true

func reset():
    transform.basis = Basis()
    $InnerGimbal.transform.basis = Basis()

func yaw(value):
    rotate_object_local(Vector3.UP, value)
    rotation.y = clamp(rotation.y, -PI/2, PI/2)

func pitch(value):
    $InnerGimbal.rotate_object_local(Vector3.RIGHT, value)
    $InnerGimbal.rotation.x = clamp($InnerGimbal.rotation.x, -PI/2, PI/5)
