extends Node

signal server_created                          # when server is successfully created
signal join_success                            # When the peer successfully joins a server
signal join_fail                               # Failed to join a server
signal player_list_changed                     # List of players has been changed
signal player_removed(pinfo)                   # A player has been removed from the list
signal disconnected                            # So outside code can act to disconnections from the server
signal ping_updated(peer, value)               # When the ping value has been updated
signal chat_message_received(name, msg)              # Whenever a chat message has been received - the msg argument is correctly formatted

var server_info = {
    name = "Server",
    max_players = 10,
    used_port = 9099
}

var player_info = {
    name = "Player",
    net_id = 1,
    char_color = Color(1, 1, 1),
}

var connected = false 
var net_id = 0 setget , get_network_id

func get_network_id():
    if connected:
        return get_tree().get_network_unique_id()
    else:
        return 0

const ping_interval = 1.0           # Wait one second between ping requests
const ping_timeout = 5.0            # Wait 5 seconds before considering a ping request as lost

# This dictionary holds an entry for each connected player and will keep the necessary data to perform
# ping/pong requests. This will be filled only on the server
var ping_data = {}

var players = {}

# If bigger than 0, specifies the amount of simulated latency, in milliseconds
var fake_latency = 0

var ip = ''
var port = 0

func _ready():
    get_tree().connect("network_peer_connected", self, "_on_player_connected")
    get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
    get_tree().connect("connected_to_server", self, "_on_connected_to_server")
    get_tree().connect("connection_failed", self, "_on_connection_failed")
    get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")

    Settings.connect_to('General/Username', self, 'username_changed')
    Settings.connect_to('General/ServerAddress', self, 'address_changed')
    Settings.connect_to('General/ServerPort', self, 'port_changed')

func username_changed(new_name):
    player_info.name = new_name

func address_changed(new_address):
    ip = new_address

func port_changed(new_port):
    port = int(new_port)

func create_server():
    var net = NetworkedMultiplayerENet.new()
    
    # Try to create the server
    if (net.create_server(server_info.used_port, server_info.max_players) != OK):
        print("Failed to create server")
        return
    
    Network.connected = true
    get_tree().set_network_peer(net)
    emit_signal("server_created")
    player_info.name = 'Server'
    register_player(player_info)
    
    Game.load_world('test_world')

func join_server():
    var net = NetworkedMultiplayerENet.new()
    
    if (net.create_client(ip, port) != OK):
        print("Failed to create client")
        emit_signal("join_fail")
        return

    MainMenu.Status.text = 'connecting...'
        
    get_tree().set_network_peer(net)

func kick_player(net_id, reason):
    rpc_id(net_id, "kicked", reason)
    get_tree().network_peer.disconnect_peer(net_id)


### Event handlers

# Everyone gets notified whenever a new client joins the server
func _on_player_connected(id):
    if (get_tree().is_network_server()):
        # Send the server info to the player
        rpc_id(id, "get_server_info", server_info)
        Game.rpc_id(id, 'load_world', 'test_world')
        
        # Initialize the ping data entry
        var ping_entry = {
            timer = Timer.new(),          # Timer object to control the ping/pong loop
            signature = 0,                # Used to match ping/pong packets
            packet_lost = 0,              # Count number of lost packets
            last_ping = 0,                # Last measured time taken to get an answer from the peer
        }
        
        # Setup the timer
        ping_entry.timer.one_shot = true
        ping_entry.timer.wait_time = ping_interval
        ping_entry.timer.process_mode = Timer.TIMER_PROCESS_IDLE
        ping_entry.timer.connect("timeout", self, "_on_ping_interval", [id], CONNECT_ONESHOT)
        ping_entry.timer.set_name("ping_timer_" + str(id))
        
        add_child(ping_entry.timer)
        ping_data[id] = ping_entry
        ping_entry.timer.start()


func _on_player_disconnected(id):
    print("Player ", players[id].name, " disconnected from server")
    if (get_tree().is_network_server()):
        ping_data[id].timer.stop()
        ping_data[id].timer.queue_free()
        ping_data.erase(id)
        
        unregister_player(id)
        rpc("unregister_player", id)

# Peer trying to connect to server is notified on success
func _on_connected_to_server():
    emit_signal("join_success")
    Network.connected = true

    var id = Network.net_id
    MainMenu.ID.text = str(id)
    MainMenu.Connect.disabled = true
    MainMenu.Spawn.show()
    MainMenu.Status.text = 'connected'
    
    HUD.Chat.show()
    Game.rpc('create_player', id)

    player_info.net_id = get_tree().get_network_unique_id()
    rpc_id(1, "register_player", player_info)
    register_player(player_info)
    Game.create_player(id)

# Peer trying to connect to server is notified on failure
func _on_connection_failed():
    emit_signal("join_fail")
    get_tree().set_network_peer(null)

# Peer is notified when disconnected from server
func _on_disconnected_from_server():
    emit_signal("chat_message_received", 'Server', 'Disconnected from Server')
    get_tree().paused = true
    get_tree().set_network_peer(null)
    emit_signal("disconnected")
    players.clear()
    player_info.net_id = 1
    
    MainMenu.Connect.disabled = false
    get_tree().quit()


### Remote functions
remote func register_player(pinfo):
    if (fake_latency > 0):
        yield(get_tree().create_timer(fake_latency / 1000), "timeout")
    
    if (get_tree().is_network_server()):
        for id in players:
            rpc_id(pinfo.net_id, "register_player", players[id])
            if (id != 1):
                rpc_id(id, "register_player", pinfo)
                
    Game.create_player(pinfo.net_id)
    print("Registering player ", pinfo.name, " (", pinfo.net_id, ") to internal player table")
    players[pinfo.net_id] = pinfo
    emit_signal("player_list_changed")
    if (get_tree().is_network_server()):
        send_message(pinfo.name + ' joined')

remote func unregister_player(id):
    if (fake_latency > 0):
        yield(get_tree().create_timer(fake_latency / 1000), "timeout")

    print("Removing player ", players[id].name, " from internal table")
    if (get_tree().is_network_server()):
        send_message(players[id].name + ' left')
    var pinfo = players[id]
    players.erase(id)
    emit_signal("player_list_changed")
    emit_signal("player_removed", pinfo)

remote func get_server_info(sinfo):
    if (fake_latency > 0):
        yield(get_tree().create_timer(fake_latency / 1000), "timeout")
    
    if (!get_tree().is_network_server()):
        server_info = sinfo

remote func kicked(reason):
    if (fake_latency > 0):
        yield(get_tree().create_timer(fake_latency / 1000), "timeout")
    
    var msg = "You have been kicked from the server, reason: " + reason
    emit_signal("chat_message_received", 'Server', msg)


### Manual latency measurement

func request_ping(dest_id):
    ping_data[dest_id].timer.connect("timeout", self, "_on_ping_timeout", [dest_id], CONNECT_ONESHOT)
    ping_data[dest_id].timer.start(ping_timeout)
    rpc_unreliable_id(dest_id, "on_ping", ping_data[dest_id].signature, ping_data[dest_id].last_ping)

remote func on_ping(signature, last_ping):
    if (fake_latency > 0):
        yield(get_tree().create_timer(fake_latency / 1000), "timeout")
    
    rpc_unreliable_id(1, "on_pong", signature)
    emit_signal("ping_updated", get_tree().get_network_unique_id(), last_ping)

remote func on_pong(signature):
    if (fake_latency > 0):
        yield(get_tree().create_timer(fake_latency / 1000), "timeout")
    
    if (!get_tree().is_network_server()):
        return
    
    var peer_id = get_tree().get_rpc_sender_id()
    
    if (ping_data[peer_id].signature == signature):
        ping_data[peer_id].last_ping = (ping_timeout - ping_data[peer_id].timer.time_left) * 1000
        ping_data[peer_id].timer.stop()
        ping_data[peer_id].timer.disconnect("timeout", self, "_on_ping_timeout")
        ping_data[peer_id].timer.connect("timeout", self, "_on_ping_interval", [peer_id], CONNECT_ONESHOT)
        ping_data[peer_id].timer.start(ping_interval)
        rpc_unreliable("ping_value_changed", peer_id, ping_data[peer_id].last_ping)
        emit_signal("ping_updated", peer_id, ping_data[peer_id].last_ping)

remote func ping_value_changed(peer_id, value):
    if (fake_latency > 0):
        yield(get_tree().create_timer(fake_latency / 1000), "timeout")
    
    emit_signal("ping_updated", peer_id, value)

    if peer_id == player_info.net_id:
        MainMenu.Ping.text = '%4d ms' % int(value)

func _on_ping_timeout(peer_id):
    print("Ping timeout, destination peer ", peer_id)
    ping_data[peer_id].packet_lost += 1
    ping_data[peer_id].signature += 1
    call_deferred("request_ping", peer_id)

func _on_ping_interval(peer_id):
    ping_data[peer_id].signature += 1
    request_ping(peer_id)


### Chat system
func send_message(msg):
    if (!get_tree().is_network_server()):
        emit_signal("chat_message_received", 'You', msg)
        rpc_id(1, '_send_message', player_info.net_id, msg)
    else:
        _send_message(player_info.net_id, msg)

remote func _send_message(src_id, msg):
    if (fake_latency > 0):
        yield(get_tree().create_timer(fake_latency / 1000), "timeout")

    emit_signal("chat_message_received", players[src_id].name, msg)

    if (!get_tree().is_network_server()):
        return

    if msg.begins_with('@'):
        # rpc_id(src_id, "_send_message", 1, 'direct messages not supported yet')

        var parts = msg.split(" ", true, 1)
        var name = parts[0].trim_prefix('@')
        for id in players:
            if players[id].name == name:
                rpc_id(id, "_send_message", src_id, msg)
        return

    if msg.begins_with('/'):
        if src_id != 1:
            rpc_id(src_id, "_send_message", 1, 'chat commands not supported yet')
        handle_chat_command(src_id, msg)
        return
        
    for id in players:
        if id != src_id:
            rpc_id(id, "_send_message", src_id, msg)

func handle_chat_command(src_id, msg):
    if src_id == 1:
        if msg.begins_with('/kick'):
            var parts = Array(msg.split(" ", true, 2))
            if parts.size() == 3:
                for id in players:
                    if players[id].name == parts[1]:
                        kick_player(id, parts[2])
