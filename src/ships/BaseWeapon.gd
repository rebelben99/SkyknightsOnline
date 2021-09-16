extends Spatial

# weapon stats
var magazine_capacity = 1
var magazine = magazine_capacity
var ammo_capacity = 10
var ammo = ammo_capacity
var rounds_per_minute = 10.0
var reload_time = 1.0 # seconds
var muzzle_velocity = 250 # meters per second
var pellet_count = 1
var pellet_spread = 0
var cone_of_fire = 0.1

var max_damage = 100
var max_damage_before = 100 # meters
var min_damage = 50
var min_damage_after = 200 # meters

# internal state
var current_time = 0.0
var can_shoot = true
var firing = false
var reloading = false
var reload_progress = 0.0
var automatic = true

var crosshair = null

var Bullet = preload('res://src/ships/Bullet.tscn')

var rng = RandomNumberGenerator.new()

func get_cof_spread():
    var x_spread = rng.randf_range(-1, 1)
    var y_spread = rng.randf_range(-1, 1)
    return Vector2(x_spread, y_spread).normalized() * ((cone_of_fire / 90) + (pellet_spread / 90))

func fire():
    var bullet = Bullet.instance()
    bullet.init(self, get_cof_spread())
    get_parent().get_parent().get_parent().add_child(bullet)

func reload():
    if magazine < magazine_capacity and ammo:
        can_shoot = false
        reloading = true

func remap_range(distance):
    return(distance - max_damage_before) / (min_damage_after - max_damage_before) * (min_damage - max_damage) + max_damage

func calculate_damage(distance):
    if distance < max_damage_before:
        return max_damage
    elif distance < min_damage_after:
        return remap_range(distance)
    else:
        return min_damage

func on_impact(target, distance):
    if target.has_node('Health'):
        target.get_node('Health').do_damage(calculate_damage(distance))

func give_ammo():
    ammo = min(ammo + magazine_capacity, ammo_capacity)
    if magazine == 0:
        reloading = true

func _process(delta):
    current_time += delta

    if can_shoot and firing:
        can_shoot = false
        current_time = 0
        for i in range(pellet_count):
            if magazine > 0:
                magazine -= 1
                fire()
                if !automatic:
                    firing = false

        if magazine == 0 and ammo:
            reloading = true
        return

    if reloading:
        reload_progress += delta
        if (current_time < reload_time):
            return
        reloading = false
        can_shoot = true
        
        if ammo > magazine_capacity:
            ammo -= magazine_capacity - magazine
            magazine = magazine_capacity
        else:
            magazine = ammo
            ammo = 0
        current_time = 0
        reload_progress = 0
        return
    
    if (current_time < 60.0 / rounds_per_minute):
        return
    can_shoot = true
    current_time = 0
