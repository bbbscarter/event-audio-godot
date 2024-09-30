extends Node3D
class_name ExampleEmitter3D

@export var Speed := 1.0
@export var OrbitNode : Node3D
var _loop_emitter : EventAudioAPI.AudioEmitter3D
var _orbit_radius := 1.0

func _init():
    EventAudio.log_lookups = true
    EventAudio.log_registrations = true
    EventAudio.log_deaths = true
    
func _ready():
    _orbit_radius = (global_position - OrbitNode.global_position).length()
    
func _process(_delta: float):
    var orbit_angle = fmod(Time.get_ticks_msec() / 1000.0, Speed) * 2 * PI

    var offset_x = _orbit_radius * cos(orbit_angle)
    var offset_y = _orbit_radius * sin(orbit_angle)

    var new_position := OrbitNode.global_position
    new_position.x += offset_x
    new_position.z += offset_y

    global_position = new_position

func _input(event: InputEvent):
    if not event is InputEventKey or not event.is_pressed():
        return
    
    if event.keycode == KEY_1:
        EventAudio.play_3d("hit", self)
            
    if event.keycode == KEY_2:
        EventAudio.play_3d("hit+large", self)

    if event.keycode == KEY_3:
        EventAudio.play_3d("hit+nonexistent", self)

    if event.keycode == KEY_4:
        EventAudio.play_3d("random_shoot", self)
        
    if event.keycode == KEY_5:
        if _loop_emitter:
            EventAudio.stop(_loop_emitter)
            _loop_emitter = null
        else:
            _loop_emitter = EventAudio.play_3d("loop", self)
