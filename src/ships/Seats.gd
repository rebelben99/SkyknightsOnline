extends Spatial

onready var seats = {}

func _ready():
    for seat in get_children():
        seats[int(seat.name)] = {
            'occupant': null,
        }
        for view in seat.get_children():
            seats[int(seat.name)][view.name] = view

func get_camera_pos(seat=0, view=0):
    if seat in seats:
        if view == 0:
            return seats[seat]['FirstPersonCamera'].pos
        if view == 1:
            return seats[seat]['ThirdPersonCamera'].pos

func set_freelook(seat, pos):
    if seat in seats:
        seats[seat]['FirstPersonCamera'].freelook(pos)

func reset_freelook(seat):
    if seat in seats:
        seats[seat]['FirstPersonCamera'].reset()

func enter_seat(seat, occupant):
    # find old seat
    for number in seats:
        if seats[number]['occupant'] == occupant:
            print('already in seat ', number)
            seats[number]['occupant'] = null

    if seat in seats:
        seats[seat]['occupant'] = occupant
        return true
    return false

func get_first_empty_seat():
    for seat in seats:
        if seats[seat]['occupant'] == null:
            return seat
    return -1

func has_empty_seats():
    for seat in seats:
        if seats[seat]['occupant'] == null:
            return true
    return false
