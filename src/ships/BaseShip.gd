extends RigidBody

var data = null

var ship_dir = ''

var seating_diagram = ''
var seating_diagram_outline = ''

var slots = {}
var inventory = {}

sync var server_transform = Transform()
sync var server_linear_velocity = Vector3()
sync var server_angular_velocity = Vector3()
var interpolation_active = true

var input_state = {} setget set_input

var current_weapon = null
sync var dead = false

onready var healthbar = $HealthBar
onready var seats = $Seats

func _ready():
    add_to_group('ships')

    for action in InputManager.actions:
        input_state[action] = false
    input_state['pitch'] = 0.0
    input_state['roll'] = 0.0
    input_state['yaw'] = 0.0

    if get_tree().get_network_peer():
        if !is_network_master():
            server_transform = transform

func equip(category, item_type, item_name):
    if !(category in slots):
        return
    if !(item_type in slots[category]):
        return
    if !(item_name in slots[category][item_type]):
        return

    if inventory[category][item_type]:
        var prev_item = inventory[category][item_type]
        if prev_item:
            prev_item.queue_free()
        current_weapon = null

    var item_dir = slots[category][item_type][item_name]
    if !item_dir:
        inventory[category][item_type] = null
        return
    
    var item = load(ship_dir + item_dir).instance()
    inventory[category][item_type] = item
    if item_type == 'nosegun':
        $Nosegun.add_child(item)
        current_weapon = item
    if item_type == 'pylons':
        $Pylons.add_child(item)
    if item_type == 'bellygun':
        $Bellygun.add_child(item)

func set_input(input):
    for action in input:
        input_state[action] = input[action]

remotesync func kill():
    queue_free()

func _physics_process(delta):
    if GameManager.connected:
        if is_network_master():
            rset_unreliable('server_transform', transform)
#            rset_unreliable('current_health', current_health)
        else:
            if interpolation_active:		
                var scale_factor = 0.1
                var dist = transform.origin.distance_squared_to(server_transform.origin)
                var weight = clamp(pow(2, dist/4) * scale_factor, 0.0, 1.0)
                transform = transform.interpolate_with(server_transform, weight)
            else:
                transform = server_transform

    $Engine.calculate_forces(input_state)

    apply_torque_impulse($Engine.torque * delta)
    apply_central_impulse($Engine.velocity * delta)
