extends PanelContainer

onready var ID = $Bar/System/VBox/ID
onready var Connect = $Bar/System/Connect
onready var Local = $Bar/System/Local
onready var Status = $Bar/System/VBox/Status
onready var Ping = $Bar/System/VBox/Ping
onready var Spawn = $Bar/Spawn
onready var UserName = $Bar/System/UserName/LineEdit


func _ready():
    $Bar/System/Settings.connect('pressed', Settings, 'toggle_visibility')
