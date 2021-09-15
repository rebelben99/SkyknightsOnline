extends Sprite3D

onready var healthbar = $Viewport/HealthBar2D

var bar_red = preload("res://src/ui/healthbar/healthbar_red.png")
var bar_green = preload("res://src/ui/healthbar/healthbar_green.png")
var bar_yellow = preload("res://src/ui/healthbar/healthbar_yellow.png")
var auto = false

func _ready():
    hide()
    if get_parent() and get_parent().has_node('Health'):
        var health = get_parent().get_node('Health')
        healthbar.max_value = health.maximum
        show()
        auto = true

    texture = $Viewport.get_texture()

func _process(delta):
    if auto:
        var health = get_parent().get_node('Health')
        update(health.current)

func update(value):
    healthbar.texture_progress = bar_green
    if value < healthbar.max_value * 0.7:
        healthbar.texture_progress = bar_yellow
    if value < healthbar.max_value * 0.35:
        healthbar.texture_progress = bar_red
    if value < healthbar.max_value:
        show()
    healthbar.value = value
