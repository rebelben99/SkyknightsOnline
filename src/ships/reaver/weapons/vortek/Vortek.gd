extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 27
    magazine = magazine_capacity
    ammo_capacity = 324
    ammo = ammo_capacity
    rounds_per_minute = 750.0
    reload_time = 2.25
    muzzle_velocity = 650
    max_damage = 240
    max_damage_before = 100
    min_damage = 143
    min_damage_after = 200
    cone_of_fire = 0.5

    crosshair = 'res://src/ships/reaver/weapons/vortek/vortek_crosshair.png'
