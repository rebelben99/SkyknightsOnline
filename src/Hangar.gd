extends Spatial


var ships = {
	'reaver': preload("res://src/ships/reaver/Reaver.tscn"),
	'mosquito': preload("res://src/ships/mosquito/Mosquito.tscn"),
	'liberator': preload("res://src/ships/liberator/Liberator.tscn"),
	'galaxy': preload("res://src/ships/galaxy/Galaxy.tscn"),
}

var ship = null
var camera_location = null
var pedestal_rotation = -50
var secondary_type = null

func _ready():
	InputManager.connect('input_event', self, '_handle_input_event')

	$UI/ShipSelector.connect('item_activated', self, '_ship_selected')
	$UI/PrimarySelector.connect('item_activated', self, '_primary_selected')
	$UI/SecondarySelector.connect('item_activated', self, 'secondary_selected')
	
	$UI/PrimarySelector.hide()
	$UI/SecondarySelector.hide()

	for ship in ships:
		$UI/ShipSelector.add_item(ship)
	
	camera_location = $ShipCamera.transform

func _handle_input_event(action, state):
	match action:
		'exit':
			get_tree().quit()

func _ship_selected(index):
	var ship_name = $UI/ShipSelector.get_item_text(index)

	if ship:
		$Pedestal.remove_child(ship)

	ship = ships[ship_name].instance()
	$Pedestal.add_child(ship)

	$UI/PrimarySelector.clear()
	$UI/PrimarySelector.hide()
	if 'nosegun' in ship.slots['weapons']:
		$UI/PrimarySelector.show()
		for weapon in ship.slots['weapons']['nosegun']:
			$UI/PrimarySelector.add_item(weapon)
	
	$UI/SecondarySelector.clear()
	$UI/SecondarySelector.hide()
	if 'bellygun' in ship.slots['weapons']:
		secondary_type = 'bellygun'
		$UI/SecondarySelector.show()
		for weapon in ship.slots['weapons']['bellygun']:
			$UI/SecondarySelector.add_item(weapon)

	if 'pylons' in ship.slots['weapons']:
		secondary_type = 'pylons'
		$UI/SecondarySelector.show()
		for weapon in ship.slots['weapons']['pylons']:
			$UI/SecondarySelector.add_item(weapon)

	camera_location = $ShipCamera.transform
	pedestal_rotation = -50

func _primary_selected(index):
	var name = $UI/PrimarySelector.get_item_text(index)
	ship.equip('weapons', 'nosegun', name)
	camera_location = $NosegunCamera.transform
	pedestal_rotation = -40

func secondary_selected(index):
	var name = $UI/SecondarySelector.get_item_text(index)
	ship.equip('weapons', secondary_type, name)
	if secondary_type == 'bellygun':
		camera_location = $BellygunCamera.transform
		pedestal_rotation = -100
	else: 
		camera_location = $NosegunCamera.transform
		pedestal_rotation = -40
	
func _process(delta):
	if camera_location:
		$Camera.transform = $Camera.transform.interpolate_with(camera_location, delta)
		$Camera.current = true

	var current_rot = $Pedestal.rotation_degrees.y
	$Pedestal.rotation_degrees.y = lerp(current_rot, pedestal_rotation, delta)
