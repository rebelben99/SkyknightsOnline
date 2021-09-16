extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 48
    magazine = magazine_capacity
    ammo_capacity = 576
    ammo = ammo_capacity
    rounds_per_minute = 1000
    reload_time = 2
    muzzle_velocity = 400
    max_damage = 150
    max_damage_before = 100
    min_damage = 100
    min_damage_after = 200
    cone_of_fire = 0.5

    crosshair = 'res://src/ships/reaver/weapons/vortek/vortek_crosshair.png'
