extends Spatial

export(String, 'three', 'four') var rings = 'three'
var current_time = 0
export var respawn_delay = 5
var dead = false

func _ready():
    $Model/Rings3.hide()
    $Model/Rings4.hide()
    
    if rings == 'three':
        $Model/Rings3.show()
        
    if rings == 'four':
        $Model/Rings4.show()


func _physics_process(delta):
    if !dead:
        if $Health.current <= 0:
            dead = true
            $Model.hide()

    if dead:
        current_time += delta

        if current_time > respawn_delay:
            current_time = 0
            $Health.reset()
            dead = false
            $Model.show()
