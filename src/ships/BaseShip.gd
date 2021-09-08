extends RigidBody

var ship_dir = ''

var seating_diagram = ''
var seating_diagram_outline = ''

var slots = {}
var inventory = {}
var seats = {
    0: {'occupied': false},
}

var pitch_input = 0.0
var yaw_input = 0.0
var roll_input = 0.0
var input_state = {}

var current_weapon = null

onready var healthbar = $HealthBar

func _ready():
    $Cockpit.hide()

    for action in InputManager.actions:
        input_state[action] = false

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

func _physics_process(delta):
    $Engine.calculate_forces(input_state, pitch_input, yaw_input, roll_input)

    apply_torque_impulse($Engine.torque * delta)
    apply_central_impulse($Engine.velocity * delta)
