extends CanvasLayer

onready var Radial = $Radial
onready var Debug = $Debug
onready var SeatingDiagram = $SeatingDiagram
onready var WeaponInfo = $WeaponInfo
onready var Crosshair = $Crosshair
onready var ReloadIndicator = $ReloadIndicator
onready var DebugOverlay = $DebugOverlay

func _ready():
    SeatingDiagram.hide()
    WeaponInfo.hide()
    Crosshair.hide()
    ReloadIndicator.hide()
