extends Spatial

func _ready():
    $Player.ship = $Reaver
    $Reaver/HealthBar.hide()
    $Player.update_camera_mode()

func _process(delta):
   pass
