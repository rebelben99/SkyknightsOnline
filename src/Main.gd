extends Node

var peer = null

const SERVER_PORT = 9099
const SERVER_ADDRESS = 'skyknights.daelon.net'
const MAX_PLAYERS = 10

onready var scenes = {
	'player': preload("res://src/Player.tscn"),
	'peer': preload("res://src/Peer.tscn"),
	'test_world': preload("res://src/scenes/TestWorld.tscn"),
	'hangar': preload("res://src/scenes/Hangar.tscn"),
}

onready var ships = {
	'reaver': preload("res://src/ships/reaver/Reaver.tscn"),
	'mosquito': preload("res://src/ships/mosquito/Mosquito.tscn"),
	'liberator': preload("res://src/ships/liberator/Liberator.tscn"),
}

func parse_cmd_args():
	# default args
	var args = {
		'server': 0,
		'connect': 0,
	}
	for arg in OS.get_cmdline_args():
		if arg.find("=") > -1:
			var key_value = arg.split("=")
			args[key_value[0].lstrip("--")] = key_value[1]
	return args

func _ready():
	var args = parse_cmd_args()
	$ServerUI.hide()

	if args['server']:
		$ServerUI.show()
		server_init()
		OS.set_window_title('Skyknights Online - Server')
		MainMenu.hide()
	elif args['connect']:
		client_init()
		MainMenu.Spawn.connect('spawn_pressed', self, 'spawn_pressed')
	else:
		MainMenu.Connect.connect('pressed', self, 'on_connect_pressed')
		MainMenu.Local.connect('pressed', self, 'on_local_pressed')
		MainMenu.Spawn.hide()
		load_world('hangar')
		MainMenu.Spawn.connect('spawn_pressed', self, 'spawn_pressed')

func on_local_pressed():
	load_world('test_world')
	create_player(0)
	MainMenu.Spawn.show()

func server_init():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS - 1)
	get_tree().network_peer = peer
	GameManager.connected = true
	
	get_tree().connect("network_peer_connected", self, "_on_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_client_disconnected")
	
	load_world('test_world')

func client_init():
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_ADDRESS, SERVER_PORT)
	get_tree().network_peer = peer
	MainMenu.Status.text = 'connected'
	
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

remote func load_world(name):
	if $World.get_child_count():
		$World.get_child(0).queue_free()
	var world = scenes[name].instance()
	$World.add_child(world)
	if world.get_node('Camera'):
		world.get_node('Camera').current = true

func _on_connected_to_server():
	GameManager.connected = true
	var id = GameManager.network_id
	MainMenu.ID.text = str(id)
	MainMenu.Connect.disabled = true
	MainMenu.Spawn.show()
	rpc('create_player', id)
	var name = MainMenu.UserName.text
	rpc_id(1, 'set_username', name)

remote func set_username(name):
	print(name)

func _on_server_disconnected():
	get_tree().quit()

func _on_connection_failed():
	print('connection_failed')
	
func on_connect_pressed():
	client_init()

func _on_peer_connected(id):
	rpc('create_player', id)
	$ServerUI/PeerList.add_item(str(id))

func _on_peer_disconnected(id):
	remove_player(id)

func _on_client_connected(id):
	rpc('create_player', id)

	rpc_id(id, 'load_world', 'test_world')
	for ship in get_tree().get_nodes_in_group('ships'):
		rpc_id(id, 'spawn_ship', ship.name, ship.data)

func _on_client_disconnected(id):
	rpc('remove_player', id)

remotesync func create_player(id):
	var player         

	if id == GameManager.network_id:
		player = scenes['player'].instance()
		player.set_network_master(GameManager.network_id)
	else:
		player = scenes['peer'].instance()

	player.name = str(id)
	$ServerUI/PeerList.add_item(str(id))
	$Players.add_child(player)

remotesync func remove_player(id):
	var i = 0
	while i < $ServerUI/ShipList.get_item_count():
		if $ServerUI/ShipList.get_item_text(i) == str(id):
			$ServerUI/ShipList.remove_item(i)
		else:
			i += 1

	if $Ships.get_node(str(id)):
		$Ships.get_node(str(id)).queue_free()
	
	i = 0
	while i < $ServerUI/PeerList.get_item_count():
		if $ServerUI/PeerList.get_item_text(i) == str(id):
			$ServerUI/PeerList.remove_item(i)
		else:
			i += 1
	$Players.get_node(str(id)).queue_free()

func spawn_pressed(data):
	var id = GameManager.network_id
	if id:
		rpc('spawn_ship', id, data)
	else:
		if $Ships.has_node(str(id)):
			var player = $Players.get_node(str(id))
			if player:
				player.leave_ship()
			$Ships.get_node(str(id)).kill()
		spawn_ship(id, data)

var next_spawn = 1
remotesync func spawn_ship(id, data):
	if $Ships.has_node(str(id)):
		return

	var spawn_origin = $World.get_child(0).get_node('Spawnpoints')
	var spawn = spawn_origin.get_node(str(next_spawn))
	next_spawn = ((next_spawn + 1) % 4) + 1

	if data['name'] in ships:
		var ship = ships[data['name']].instance()
		ship.name = str(id)
		ship.data = data
		$Ships.add_child(ship)
		ship.equip('weapons', 'nosegun', data['nosegun'])
		ship.global_transform = spawn.global_transform
		ship.look_at(spawn_origin.global_transform.origin, Vector3.UP)
		$Players.get_node(str(id)).enter_ship(ship)
	
#    $Players.get_node(str(GameManager.network_id)).update_camera_mode()
	var display_name = ''
	if id == GameManager.network_id:
		display_name += 'my '
	display_name += data['name']
	$ServerUI/ShipList.add_item(display_name)

remote func ping(id, time):
	if is_network_master():
		rpc_id(id, 'ping', id, time)
	else:
		var now = OS.get_system_time_msecs()
		MainMenu.Ping.text = '%4d ms' % int(now - time)

var current_time = 0
func _physics_process(delta):
	if GameManager.connected:
		if is_network_master():
			for ship in get_tree().get_nodes_in_group('ships'):
				if ship.dead:
					var player = $Players.get_node(ship.name)
					if player:
						player.leave_ship()
					ship.rpc('kill')
		else:
			current_time += delta
			if current_time > 0.1:
				current_time = 0.0
				var time = OS.get_system_time_msecs()
				rpc_id(1, 'ping', GameManager.network_id, time)
