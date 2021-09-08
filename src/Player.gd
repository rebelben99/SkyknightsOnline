extends Spatial

var mouse_sens = Vector2(5, 5)
var ship = null
var seat = null
var first_person = true
var freelook = false
export var capture_mouse = false setget set_capture_mouse, get_capture_mouse

func _ready():
    InputManager.connect('input_event', self, '_handle_input_event')
    update_mouse_capture()
    update_camera_mode()
    $HUD/SeatingDiagram.hide()
    $HUD/WeaponInfo.hide()
    $HUD/Crosshair.hide()
    $HUD/ReloadIndicator.hide()
    $Menus/MainMenu.hide()
    $HUD/Radial.connect('item_selected', self, 'radial_item_selected')

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
        if $Menus/MainMenu.visible:
            capture_mouse = false
        $HUD/Radial.close_menu()

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

func enter_ship(new_ship):
    if ship:
        print('already in a ship?')
    ship = new_ship
    ship.healthbar.hide()
    update_camera_mode()
    if ship.get('seating_diagram') and ship.get('seating_diagram_outline'):
        $HUD/SeatingDiagram.show()
        $HUD/SeatingDiagram/Progress.max_value = ship.max_health
        $HUD/SeatingDiagram/Progress.texture_progress = load(ship.seating_diagram)
        $HUD/SeatingDiagram/Progress.texture_under = load(ship.seating_diagram_outline)

    if ship.current_weapon:
        $HUD/WeaponInfo.show()
        if ship.current_weapon.get('crosshair'):
            $HUD/Crosshair.show()
            $HUD/Crosshair.texture = load(ship.current_weapon.crosshair)

func leave_ship():
    ship.healthbar.show()
    ship = null
    
    $HUD/SeatingDiagram.hide()
    $HUD/WeaponInfo.hide()
    $HUD/Crosshair.hide()

func toggle_menu(state):
    if state:
        if $Menus/MainMenu.visible:
            $Menus/MainMenu.hide()
            set_capture_mouse(true)
        else:
            $Menus/MainMenu.show()
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
    if !capture_mouse:
        if event is InputEventMouseButton:
            if event.button_index == BUTTON_RIGHT and event.pressed:
                print(get_object_under_mouse()['collider'].get_parent().name)
                $HUD/Radial.open_menu(get_viewport().get_mouse_position())

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
        'open_menu':
            toggle_menu(state)
        'reload':
            if ship and ship.current_weapon and state:
                ship.current_weapon.reload()
        'fire_primary':
            if ship.current_weapon and capture_mouse:
                ship.current_weapon.firing = state
        'switch_seat_1':
            if ship and state:
                ship.enter_seat(0)
        'switch_seat_2':
            if ship and state:
                ship.enter_seat(1)
        'switch_seat_3':
            if ship and state:
                ship.enter_seat(2)

func _process(delta):
    print(delta)
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

        if ship.current_weapon:
            var weapon = ship.current_weapon

            if weapon.reloading:
                $HUD/ReloadIndicator.show()
                $HUD/ReloadIndicator.max_value = weapon.reload_time * 100
                $HUD/ReloadIndicator.value = weapon.reload_progress * 100
            else:
                $HUD/ReloadIndicator.hide()
            $HUD/WeaponInfo/Name.text = weapon.name
            var mag = weapon.magazine
            $HUD/WeaponInfo/Ammo/Magazine.text = "%04d" % mag
            var ammo = weapon.ammo
            $HUD/WeaponInfo/Ammo/Reserve.text = "%04d" % ammo

        $HUD/SeatingDiagram/Progress.value = ship.current_health
        $HUD/SeatingDiagram/Health.text = str(ship.current_health)

        $HUD/Debug/VBox/Throttle.text = 'throttle: ' + str(ship.get_node('Engine').throttle)
        $HUD/Debug/VBox/Velocity.text = 'speed: ' + str(ship.linear_velocity.length())
