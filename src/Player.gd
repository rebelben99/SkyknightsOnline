extends Spatial

var mouse_sens = Vector2(5, 5)
var ship = null
var first_person = true
var freelook = false
export var capture_mouse = false setget capture_mouse_set, capture_mouse_get

func _ready():
    InputManager.connect('input_event', self, '_handle_input_event')
    update_mouse_capture()
    update_camera_mode()

func update_mouse_capture():
    if capture_mouse:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func capture_mouse_set(state):
    capture_mouse = state
    update_mouse_capture()

func capture_mouse_get():
    return capture_mouse

func toggle_mouse_capture(state=1):
    if state:
        capture_mouse = !capture_mouse
        update_mouse_capture()

func update_camera_mode():
    if ship:
        ship.set_camera(first_person)
    
func toggle_camera_mode(state=1):
    if state:
        first_person = !first_person
        update_camera_mode()
    
func set_freelook(state=1):
    freelook = state

    if !freelook:
        ship.reset_freelook()

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

func _process(delta):
    var pitch = 0
    var roll = 0
    var mouse_delta = InputManager.get_mouse() * delta

    if capture_mouse:
        pitch = mouse_delta.y * mouse_sens.y
        roll = mouse_delta.x * mouse_sens.x
    else:
        pitch = 0
        roll = 0

    if ship:
        if first_person and freelook:
            ship.set_freelook(mouse_delta)
        else:
            ship.pitch_input = pitch
            ship.roll_input = roll

        ship.input_state = InputManager.state

        if ship.get_node('Nosegun'):
            if ship.get_node('Nosegun').get_child_count():
                var ammo = ship.get_node('Nosegun').get_child(0).magazine_current
                $HUD/Panel/VBoxContainer/Ammo.set_text(str(ammo))
        $HUD/Panel/VBoxContainer/Health.set_text(str(ship.current_health))
