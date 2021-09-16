extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 50
    magazine = magazine_capacity
    ammo_capacity = 500
    ammo = ammo_capacity
    rounds_per_minute = 400.0
    reload_time = 4.0
    muzzle_velocity = 750
    max_damage = 300
    max_damage_before = 1000
    min_damage = 300
    min_damage_after = 1000
    cone_of_fire = 0.3

    crosshair = 'res://src/ships/reaver/weapons/mustang/mustang_crosshair.png'
