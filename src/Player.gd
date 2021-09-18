extends Spatial

var flight_sens = Vector2(1, 1)
var freelook_sens = Vector2(1, 1)
var ship = null
var seat = null
var first_person = true
var freelook = false
export var capture_mouse = false setget set_capture_mouse, get_capture_mouse
var input_state = {}
var camera_pos = null

func _ready():
    InputManager.connect('input_event', self, '_handle_input_event')

    Settings.connect_to('Controls/Mouse/Flight', self, 'flight_sens_changed')
    Settings.connect_to('Controls/Mouse/Freelook', self, 'freelook_sens_changed')

    update_mouse_capture()
    update_camera_mode()
    HUD.Radial.connect('item_selected', self, 'radial_item_selected')
    
    for action in InputManager.actions:
        input_state[action] = false

func flight_sens_changed(sens):
    if sens:
        flight_sens = Vector2(float(sens), float(sens))
func freelook_sens_changed(sens):
    if sens:
        freelook_sens = Vector2(float(sens), float(sens))

func radial_item_selected(id, pos):
    print(id, pos)

func update_mouse_capture():
    if capture_mouse:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        HUD.Chat.InputField.release_focus()
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

func update_camera_pos():
    if ship and camera_pos:
        $Camera.current = true
        $Camera.transform = camera_pos.global_transform

func update_camera_mode():
    if ship:
        camera_pos = ship.seats.get_camera_pos(seat, int(!first_person))
        HUD.Crosshair.visible = first_person
    
func toggle_camera_mode(state=1):
    if state:
        first_person = !first_person
        update_camera_mode()
    
func set_freelook(state=1):
    freelook = state

    if ship and !freelook:
        ship.seats.reset_freelook(seat)

func switch_seat(new_seat):
    if ship.seats.enter_seat(new_seat, self):
        seat = new_seat
        update_camera_mode()

func enter_ship(new_ship):
    if !new_ship.seats.has_empty_seats():
        return

    if ship:
        leave_ship()
    ship = new_ship

    switch_seat(ship.seats.get_first_empty_seat())
    
    # update UI stuff
    ship.healthbar.hide()
    HUD.SeatingDiagram.load_ship(ship)
    if ship.current_weapon:
        HUD.WeaponInfo.show()
        if ship.current_weapon.get('crosshair'):
            HUD.Crosshair.show()
            HUD.Crosshair.texture = load(ship.current_weapon.crosshair)

func leave_ship():
    ship.healthbar.show()
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

func _input(event):
    if !capture_mouse and event is InputEventMouseButton:
        if event.button_index == BUTTON_RIGHT and event.pressed:
            
            var selection = get_object_under_mouse()
            if 'collider' in selection:
                HUD.Radial.open_menu(get_viewport().get_mouse_position())

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
        'scoreboard':
            print('scoreboard')
        # 'open_chat':
        #     if state:
        #         print('chat')
        'switch_seat_1':
            if state:
                switch_seat(0)
        'switch_seat_2':
            if state:
                switch_seat(1)
        'switch_seat_3':
            if state:
                switch_seat(2)

var previous_state = {}
var current_time = 0.0
func _physics_process(delta):
    current_time += delta
    var pitch = 0
    var roll = 0
    var mouse_delta = InputManager.get_mouse() * delta

    if capture_mouse:
        pitch = mouse_delta.y * flight_sens.y
        roll = mouse_delta.x * flight_sens.x
    else:
        pitch = 0
        roll = 0

    if ship and seat == 0:
        if first_person and freelook and capture_mouse:
            ship.seats.set_freelook(seat, mouse_delta * freelook_sens)
            pitch = 0
            roll = 0

        for action in InputManager.state:
            input_state[action] = InputManager.state[action]

        input_state['fire_primary'] = InputManager.state['fire_primary'] and capture_mouse
        input_state['pitch'] = pitch
        input_state['roll'] = roll
        input_state['yaw'] = 0
    
        if !Network.connected:
            apply_input(input_state)
            return

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
        update_camera_pos()
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

        HUD.SeatingDiagram.health = ship.get_node('Health').current

        HUD.Debug.Throttle.text = 'throttle: ' + str(ship.get_node('Engine').throttle)
        HUD.Debug.Velocity.text = 'speed: ' + str(ship.linear_velocity.length())
