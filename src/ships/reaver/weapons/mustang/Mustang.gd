extends Spatial

var magazine_capacity = 55
var magazine_current = magazine_capacity
var ammo = 660
var rof = 667.0 # rounds per minute
var reload_time = 2.4
var muzzle_velocity = 250
var damage = 190

var refire_delay = 60.0 / rof
var current_time = 0.0
var can_shoot = true
var reloading = false

var Bullet = preload('res://src/ships/Bullet.tscn')

func _ready():
    pass

func fire():
    var bullet = Bullet.instance()
    bullet.init(self)
    get_parent().get_parent().get_parent().add_child(bullet)

func reload():
    reloading = true

func on_impact(target):    
    if target.get('current_health'):
        target.current_health -= damage

func update(delta, shoot):
    current_time += delta

    if can_shoot and shoot:
        fire()
        can_shoot = false
        current_time = 0
        magazine_current -= 1

        if magazine_current == 0:
            reloading = true
        return

    if !can_shoot:
        if reloading:
            if (current_time < reload_time):
                return
            reloading = false
            can_shoot = true
            magazine_current = magazine_capacity
            current_time = 0
            return
        
        if (current_time < refire_delay):
            return
        can_shoot = true
        current_time = 0
