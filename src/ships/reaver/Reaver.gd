extends RigidBody

var ship_dir = "res://src/ships/reaver/"

var slots = {
    'weapons': {
        'nosegun': {
            'none': null,
            'mustang': "weapons/mustang/Mustang.tscn",
            'vortek': "weapons/vortek/Vortek.tscn",
        },
        'pylons': {
            'none': null,
            'tanks': "weapons/tanks/Tanks.tscn",
            'rocket_pods': "weapons/rocket_pods/RocketPods.tscn",
        },
    }
}

var inventory = {
    'weapons': {
        'nosegun': null,
        'pylons': null,
    }
}

var max_health = 3000
var current_health = max_health

export(String, 'none', 'mustang', 'vortek') var nosegun = 'none'

var pitch_input = 0.0
var yaw_input = 0.0
var roll_input = 0.0
var input_state = {}

func _ready():
    mass = 10
    linear_damp = 1
    angular_damp = 3

    $Cockpit.hide()

    if nosegun != 'none':
        equip('weapons', 'nosegun', nosegun)

    for action in InputManager.actions:
        input_state[action] = false

func set_camera(number=1):
    if number:
        $Seat1/FirstPersonCamera.set_current()
        $Cockpit.show()
        $Chassis.hide()
    else:
        $Seat1/ThirdPersonCamera.set_current()
        $Cockpit.hide()
        $Chassis.show()

func set_freelook(pos):
    $Seat1/FirstPersonCamera.yaw(-pos.x)
    $Seat1/FirstPersonCamera.pitch(pos.y)

func reset_freelook():
    $Seat1/FirstPersonCamera.reset()

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
    if item_type == 'pylons':
        $Pylons.add_child(item)

func _process(delta):
    if $Nosegun.get_child_count():
        if input_state['reload']:
            $Nosegun.get_child(0).reload()
        var weapon = $Nosegun.get_child(0)
        weapon.update(delta, input_state['fire_primary'])

func _physics_process(delta):
    $Engine.calculate_forces(input_state, pitch_input, yaw_input, roll_input)

    apply_torque_impulse($Engine.torque * delta)
    apply_central_impulse($Engine.velocity * delta)
