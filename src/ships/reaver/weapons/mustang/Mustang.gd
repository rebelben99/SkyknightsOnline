extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 55
    magazine = magazine_capacity
    ammo_capacity = 660
    ammo = ammo_capacity
    rounds_per_minute = 667.0
    reload_time = 2.4
    muzzle_velocity = 750
    max_damage = 190
    max_damage_before = 200
    min_damage = 160
    min_damage_after = 300
    cone_of_fire = 0.3

    crosshair = 'res://src/ships/reaver/weapons/mustang/mustang_crosshair.png'
