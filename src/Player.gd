extends Spatial

var mouse_sens = Vector2(1, 1)
var ship = null
var seat = null
var first_person = true
var freelook = false
export var capture_mouse = false setget set_capture_mouse, get_capture_mouse
var input_state = {}

func _ready():
    InputManager.connect('input_event', self, '_handle_input_event')
    Settings.MouseFlight.connect('value_changed', self, 'mouse_sens_changed')
    update_mouse_capture()
    update_camera_mode()
    HUD.Radial.connect('item_selected', self, 'radial_item_selected')
    
    for action in InputManager.actions:
        input_state[action] = false

func mouse_sens_changed(sens):
    if sens:
        mouse_sens = Vector2(float(sens), float(sens))

func radial_item_selected(id, pos):
    print(id, pos)

func update_mouse_capture():
    if capture_mouse:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_capture_mouse(state):
    capture_mouse = state
    update_mouse_capture()

func get_capture_mouse():
    return capture_mouse

func toggle_mouse_capture(state=1):
    if state:
        capture_mouse = !capture_mouse
        MainMenu.visible = !capture_mouse
        HUD.Radial.close_menu()

        update_mouse_capture()

func update_camera_mode():
    if ship:
        ship.set_camera(first_person)
        HUD.Crosshair.visible = first_person
    
func toggle_camera_mode(state=1):
    if state:
        first_person = !first_person
        update_camera_mode()
    
func set_freelook(state=1):
    freelook = state

    if !freelook:
        ship.reset_freelook()

func enter_ship(new_ship):
    if ship:
        print('already in a ship?')
    ship = new_ship
    # ship.healthbar.hide()
    update_camera_mode()
    if ship.get('seating_diagram') and ship.get('seating_diagram_outline'):
        HUD.SeatingDiagram.show()
        HUD.SeatingDiagram.max_health = ship.max_health
        HUD.SeatingDiagram.top_texture = load(ship.seating_diagram)
        HUD.SeatingDiagram.bottom_texture = load(ship.seating_diagram_outline)
    if ship.current_weapon:
        HUD.WeaponInfo.show()
        if ship.current_weapon.get('crosshair'):
            HUD.Crosshair.show()
            HUD.Crosshair.texture = load(ship.current_weapon.crosshair)

func leave_ship():
    # ship.healthbar.show()
    ship = null
    
    HUD.SeatingDiagram.hide()
    HUD.WeaponInfo.hide()
    HUD.Crosshair.hide()

func toggle_menu(state):
    if state:
        if MainMenu.visible:
            MainMenu.hide()
            set_capture_mouse(true)
        else:
            MainMenu.show()
            set_capture_mouse(false)

func get_object_under_mouse():
    var mouse_pos = get_viewport().get_mouse_position()
    var camera = get_viewport().get_camera()
    var ray_from = camera.project_ray_origin(mouse_pos)
    var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000
    var space_state = get_world().direct_space_state
    var selection = space_state.intersect_ray(ray_from, ray_to, [], 0x7FFFFFFF, true, true)
    return selection

#func _input(event):
#    if !capture_mouse:
#        if event is InputEventMouseButton:
#            if event.button_index == BUTTON_RIGHT and event.pressed:
#                print(get_object_under_mouse()['collider'].get_parent().name)
#                HUD.Radial.open_menu(get_viewport().get_mouse_position())

func _handle_input_event(action, state):
    match action:
        'toggle_camera_mode':
            toggle_camera_mode(state)
        'free_mouse':
            toggle_mouse_capture(state)
        'freelook':
            set_freelook(state)
        'open_menu':
            print('menu')
        'exit':
            get_tree().quit()


var previous_state = {}
var current_time = 0.0
func _physics_process(delta):
    current_time += delta
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
            pitch = 0
            roll = 0

        for action in InputManager.state:
            input_state[action] = InputManager.state[action]

        input_state['fire_primary'] = InputManager.state['fire_primary'] and capture_mouse
        input_state['pitch'] = pitch
        input_state['roll'] = roll
        input_state['yaw'] = 0

    
        # if !GameManager.connected:
        #     apply_input(input_state)
        #     return

        var state_diff = {}

        for action in input_state:
            if action in previous_state:
                pass
            else:
                previous_state[action] = null

            if previous_state[action] != input_state[action]:
                state_diff[action] = input_state[action]
                previous_state[action] = input_state[action]

        if current_time > 0.5:
            current_time = 0.0
            rpc_unreliable_id(1, 'network_update', input_state)
        else:
            rpc_unreliable_id(1, 'network_update', state_diff)

remotesync func apply_input(input):
    if ship:
        ship.input_state = input

func _process(delta):
    if ship:
        if ship.current_weapon:
            var weapon = ship.current_weapon

            if weapon.reloading:
                HUD.ReloadIndicator.show()
                HUD.ReloadIndicator.max_value = weapon.reload_time * 100
                HUD.ReloadIndicator.value = weapon.reload_progress * 100
            else:
                HUD.ReloadIndicator.hide()
            HUD.WeaponInfo.weapon_name = weapon.name
            HUD.WeaponInfo.magazine = "%04d" % weapon.magazine
            HUD.WeaponInfo.ammo = "%04d" % weapon.ammo

        HUD.SeatingDiagram.health = ship.current_health

        HUD.Debug.Throttle.text = 'throttle: ' + str(ship.get_node('Engine').throttle)
        HUD.Debug.Velocity.text = 'speed: ' + str(ship.linear_velocity.length())
