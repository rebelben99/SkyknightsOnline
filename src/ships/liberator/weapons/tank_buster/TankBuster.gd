extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 30
    magazine = magazine_capacity
    ammo_capacity = 300
    ammo = ammo_capacity
    rounds_per_minute = 1200.0
    reload_time = 3.5
    muzzle_velocity = 400
    max_damage = 250
    max_damage_before = 50
    min_damage = 100
    min_damage_after = 300
    cone_of_fire = 0.3
    pellet_count = 2
    pellet_spread = 1

    crosshair = 'res://src/ships/reaver/weapons/vortek/vortek_crosshair.png'
