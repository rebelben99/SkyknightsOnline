extends Spatial

var ship = null

func _ready():
    pass

func enter_ship(new_ship):
    # ship.healthbar.hide()
    ship = new_ship
    if ship:
        ship.set_camera(0)

func leave_ship():
    # ship.healthbar.show()
    ship = null

remote func network_update(input):
    rpc_unreliable('apply_input', input)

remotesync func apply_input(input):
    if ship and ship.get('input_state'):
        ship.input_state = input

var current_time = 0.0
func _physics_process(delta):
    current_time += delta
    if current_time >= 1:
        current_time = 0.0
        # if ship
