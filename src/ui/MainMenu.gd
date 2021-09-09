extends PanelContainer

signal connect_pressed()

onready var ID = $Bar/System/VBox/ID
onready var Connect = $Bar/System/Connect
onready var Status = $Bar/System/VBox/Status
onready var Spawn = $Bar/Spawn
onready var MouseSens = $Bar/System/VBoxContainer/MouseSens

func _ready():
    pass

func _on_Connect_pressed():
    emit_signal("connect_pressed")
