extends PanelContainer

onready var ID = $Bar/System/NetStatus/ID
onready var Connect = $Bar/System/Connect
onready var Local = $Bar/System/Local
onready var Status = $Bar/System/NetStatus/Status
onready var Ping = $Bar/System/NetStatus/Ping
onready var Spawn = $Bar/Spawn
onready var Username = $Bar/System/NetStatus/Username


func _ready():
    $Bar/System/Settings.connect('pressed', Settings, 'toggle_visibility')
    $Bar/System/Quit.connect('pressed', self, 'quit_pressed')

    $Bar/System/Connect.disabled = true

    Settings.connect_to('General/Username', self, 'username_changed')

func quit_pressed():
    get_tree().quit()

func username_changed(name):
    Username.text = name
    if name != '':
        $Bar/System/Connect.disabled = false
    else:
        $Bar/System/Connect.disabled = true
