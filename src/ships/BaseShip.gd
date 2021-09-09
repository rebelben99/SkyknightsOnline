extends RigidBody

var ship_dir = ''

var seating_diagram = ''
var seating_diagram_outline = ''

var slots = {}
var inventory = {}
var seats = {
    0: {'occupied': false},
}

var input_state = {} setget set_input

var current_weapon = null

onready var healthbar = $HealthBar

func _ready():
    $Cockpit.hide()

    for action in InputManager.actions:
        input_state[action] = false
    input_state['pitch'] = 0.0
    input_state['roll'] = 0.0
    input_state['yaw'] = 0.0

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

func _physics_process(delta):
    $Engine.calculate_forces(input_state)

    apply_torque_impulse($Engine.torque * delta)
    apply_central_impulse($Engine.velocity * delta)
