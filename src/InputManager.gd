extends Node


var actions = {
    # misc
    'exit': {'key': KEY_ESCAPE},
    'free_mouse': {'key': KEY_ALT},
    'toggle_camera_mode': {'key': KEY_T},
    'freelook': {'mouse': BUTTON_MIDDLE},
    'scoreboard': {'key': KEY_TAB},
    'map': {'key': KEY_M},
    'open_chat': {'key': KEY_ENTER},

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

signal input_event(action, state)
var state = {}
var mouse_delta = Vector2()

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

        state[action] = false

func _ready():
    get_mouse()
    register_actions()
    get_mouse()

func _input(event):
    # use godot events to collect relative mouse movements 
    if event is InputEventMouseMotion:
        mouse_delta += event.relative

func get_mouse():
    var mouse = mouse_delta
    mouse_delta.y = 0
    mouse_delta.x = 0
    return mouse
    
func _process(delta):
    for action in actions:
        if Input.is_action_pressed(action):
            if state[action] == false:
                state[action] = true
                emit_signal('input_event', action, true)
        else:
            if state[action] == true:
                state[action] = false
                emit_signal('input_event', action, false)
