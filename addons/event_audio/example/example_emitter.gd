extends Node2D
class_name ExampleEmitter
#@onready var Audio = $"/root/Audio"

@export var Speed := 1.0
var _loop_emitter : EventAudioAPI.AudioEmitter2D

func _process(delta: float):
    var screen_width := get_viewport_rect().size.x

    var step := Speed * screen_width * delta
    var new_position := global_position
    new_position.x += step
    if new_position.x < 0:
        new_position.x = 0
        Speed = -Speed
    elif new_position.x >= screen_width:
        new_position.x = screen_width
        Speed = -Speed
        
    global_position = new_position


func _input(event: InputEvent):
    if not event is InputEventKey or not event.is_pressed():
        return
    
    if event.keycode == KEY_1:
        EventAudio.play_2d("hit", self)
            
    if event.keycode == KEY_2:
        EventAudio.play_2d("hit+large", self)

    if event.keycode == KEY_3:
        EventAudio.play_2d("shoot+laser", self)
        
    if event.keycode == KEY_4:
        if _loop_emitter:
            EventAudio.stop(_loop_emitter)
            _loop_emitter = null
        else:
            _loop_emitter = EventAudio.play_2d("loop", self)
