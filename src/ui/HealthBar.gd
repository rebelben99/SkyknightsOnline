extends Sprite3D

onready var healthbar = $Viewport/HealthBar2D

var bar_red = preload("res://src/ui/healthbar_red.png")
var bar_green = preload("res://src/ui/healthbar_green.png")
var bar_yellow = preload("res://src/ui/healthbar_yellow.png")
var auto = false

func _ready():
    hide()
    if get_parent() and get_parent().get("max_health"):
        healthbar.max_value = get_parent().max_health
        # show()
        auto = true

    texture = $Viewport.get_texture()

func _process(delta):
    if auto:
        var hp = get_parent().get("current_health")
        update(hp)

func update(value):
    healthbar.texture_progress = bar_green
    if value < healthbar.max_value * 0.7:
        healthbar.texture_progress = bar_yellow
    if value < healthbar.max_value * 0.35:
        healthbar.texture_progress = bar_red
    if value < healthbar.max_value:
        show()
    healthbar.value = value
