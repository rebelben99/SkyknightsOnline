extends Spatial

var ship = null
var seat = null
var first_person = true
var freelook = false
var capture_mouse = false

func _ready():
    InputManager.connect('input_event', self, '_handle_input_event')
    update_mouse_capture()
    update_camera_mode()

func update_mouse_capture():
    if capture_mouse:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func toggle_mouse_capture(state=1):
    if state:
        capture_mouse = !capture_mouse
        update_mouse_capture()

func update_camera_mode():
    if seat:
        seat.set_camera(first_person)
        if first_person:
            $Ship/FirstPersonCamera.set_current()
            $Ship/Cockpit.show()
            $Ship/Chassis.hide()
        else:
            seat.set_camera(1)
            $Ship/ThirdPersonCamera.set_current()
            $Ship/Cockpit.hide()
            $Ship/Chassis.show()
    
func toggle_camera_mode(state=1):
    if state:
        first_person = !first_person
        update_camera_mode()
    
func set_freelook(state=1):
    freelook = state

    # if !freelook:
    #     $Ship/FirstPersonCamera.reset()

func _handle_input_event(action, state):
    match action:
        'toggle_camera_mode':
            toggle_camera_mode(state)
        'free_mouse':
            toggle_mouse_capture(state)
        'freelook':
            set_freelook(state)
        'exit':
            get_tree().quit()

func get_object_under_mouse():
    var mouse_pos = get_viewport().get_mouse_position()
    var camera = get_viewport().get_camera()
    var ray_from = camera.project_ray_origin(mouse_pos)
    var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 100
    var space_state = get_world().direct_space_state
    var selection = space_state.intersect_ray(ray_from, ray_to)
    return selection

func _process(delta):
    var pitch = 0
    var roll = 0
    var mouse_delta = InputManager.get_mouse()

    if capture_mouse:
        pitch = mouse_delta.y
        roll = mouse_delta.x
    else:
        pitch = 0
        roll = 0
        # print(get_object_under_mouse())

    if ship:
        if first_person and freelook:
            ship.FirstPersonCamera.pitch(mouse_delta.y * delta)
            ship.FirstPersonCamera.yaw(-mouse_delta.x * delta)
        else:
            ship.pitch_input = pitch
            ship.roll_input = roll

        ship.input_state = InputManager.input_state
