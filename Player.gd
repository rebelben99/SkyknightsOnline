extends Spatial


var actions = {
    # misc
    'exit': {'key': KEY_ESCAPE},
    'free_mouse': {'key': KEY_ALT},
    'toggle_camera_mode': {'key': KEY_T},
    'freelook': {'mouse': BUTTON_MIDDLE},
    'scoreboard': {'key': KEY_TAB},

    # movement
    'throttle_up': {'key': KEY_W},
    'throttle_down': {'key': KEY_S},
    'afterburner': {'key': KEY_SHIFT},
    'pitch_up': {'key': KEY_UP},
    'pitch_down': {'key': KEY_DOWN},
    'yaw_left': {'key': KEY_A},
    'yaw_right': {'key': KEY_D},
    'roll_left': {'key': KEY_Q},
    'roll_right': {'key': KEY_E},
    'vertical_thrust_up': {'key': KEY_SPACE},
    'vertical_thrust_down': {'key': KEY_CONTROL},

    #
    'switch_seat_1': {'key': KEY_F1},
    'switch_seat_2': {'key': KEY_F2},
    'switch_seat_3': {'key': KEY_F3},

    # weapons and items
    'fire_primary': {'mouse': BUTTON_LEFT},
    'fire_secondary': {'mouse': BUTTON_RIGHT},
    'reload': {'key': KEY_R},
    'select_item_1': {'key': KEY_1},
    'select_item_2': {'key': KEY_2},
    'select_item_3': {'key': KEY_3},
    'activate_abilty': {'key': KEY_F},
}

var input_state = {}
var mouse_delta = Vector2()
var first_person = false
var capture_mouse = true
var freelook = false

func register_actions():
    for action in actions:
        var control = actions[action]
        InputMap.add_action(action)

        if 'key' in control:
            var ev = InputEventKey.new()
            ev.scancode = control['key']
            InputMap.action_add_event(action, ev)

        if 'mouse' in control:
            var ev = InputEventMouseButton.new()
            ev.button_index = control['mouse']
            InputMap.action_add_event(action, ev)

        input_state[action] = false

func _ready():
    mouse_delta.y = 0
    mouse_delta.x = 0
    update_mouse_capture()
    set_process_input(true)
    register_actions()
    update_camera_mode()

    mouse_delta.y = 0
    mouse_delta.x = 0
        
func _input(event):
    # use godot events to collect relative mouse movements 
    if event is InputEventMouseMotion:
        if capture_mouse:
            mouse_delta += event.relative

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
    if first_person:
        $Ship/FirstPersonCamera.set_current()
        $Ship/Cockpit.show()
        $Ship/Chassis.hide()
    else:
        $Ship/ThirdPersonCamera.set_current()
        $Ship/Cockpit.hide()
        $Ship/Chassis.show()
    
func toggle_camera_mode(state=1):
    if state:
        first_person = !first_person
        update_camera_mode()
    
func set_freelook(state=1):
    freelook = state

    if !freelook:
        $Ship/FirstPersonCamera.reset()

func handle_input(action, state):
    match action:
        'toggle_camera_mode':
            toggle_camera_mode(state)
        'free_mouse':
            toggle_mouse_capture(state)
        'freelook':
            set_freelook(state)
        'exit':
            get_tree().quit()


func debounce_inputs():
    for action in actions:
        if Input.is_action_pressed(action):
            if self.input_state[action] == false:
                self.input_state[action] = true
                handle_input(action, true)
        else:
            if self.input_state[action] == true:
                self.input_state[action] = false
                handle_input(action, false)
    
func _process(delta):
    if capture_mouse:
        if first_person and freelook:
            $Ship/FirstPersonCamera.pitch(mouse_delta.y * delta)
            $Ship/FirstPersonCamera.yaw(-mouse_delta.x * delta)
        else:
            $Ship.roll_input = mouse_delta.x
            $Ship.pitch_input = mouse_delta.y
    else:
        $Ship.roll_input = 0
        $Ship.pitch_input = 0

    $Ship.input = input_state

    mouse_delta.y = 0
    mouse_delta.x = 0
    
    debounce_inputs()
