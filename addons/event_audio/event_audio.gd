extends Node

# Ideally this would be called just EventAudio, but that would class with the autoload
class_name EventAudioAPI
static var _separator := "+"
static var instance : EventAudioAPI

@export var log_lookups := false
@export var log_deaths := false
@export var log_registrations := false

var _trigger_map: Dictionary
var _rng: RandomNumberGenerator
var _audio_banks: Array[EAEventBank]

class AudioEmitter2D:
    var source: Node2D
    var player: AudioStreamPlayer2D
    var event: EAEvent

var _active_emitters_2d = Array()

class AudioEmitter3D:
    var source: Node3D
    var player: AudioStreamPlayer3D
    var event: EAEvent

var _active_emitters_3d = Array()

#---------------------------------------------------------
# API
#---------------------------------------------------------
static func get_instance() -> EventAudioAPI:
    return instance

func play_2d(trigger: String, source: Node2D, output_bus: String = '') -> AudioEmitter2D:
    var event := _find_event_for_trigger(trigger)
    if event == null:
        return null

    var stream_player = AudioStreamPlayer2D.new()
    return _play_event(event, stream_player, source, output_bus)

func play_3d(trigger: String, source: Node3D, output_bus: String = '') -> AudioEmitter3D:
    var event := _find_event_for_trigger(trigger)
    if event == null:
        return null

    var stream_player = AudioStreamPlayer3D.new()
    return _play_event(event, stream_player, source, output_bus)

func stop(emitter):
    if emitter.player != null:
        emitter.player.stop()

func register_event_bank(bank: EAEventBank):
    if log_registrations:
        print("Registering bank: " + bank.resource_path)
    _audio_banks.append(bank)
    _invalidate_trigger_map()
    
func unregister_event_bank(bank: EAEventBank):
    if log_registrations:
        print("Unregistering bank: " + bank.resource_name)
    var idx := _audio_banks.find(bank)
    if idx >= 0:
        _audio_banks.remove_at(idx)
        _invalidate_trigger_map()

static func init_player_from_playback_settings(rng, stream_player, settings: EAEventPlaybackSettings):
    var min_pitch := min(settings.min_pitch, settings.max_pitch) as float
    var max_pitch := max(settings.min_pitch, settings.max_pitch) as float
    var pitch = rng.randf_range(min_pitch, max_pitch)
    stream_player.pitch_scale = pitch
    stream_player.volume_db = settings.volume_db
    stream_player.set_bus(settings.playback_bus)

    if stream_player is AudioStreamPlayer3D:
        stream_player.unit_size = settings.unit_size
        stream_player.max_db = settings.max_db
        stream_player.panning_strength = settings.panning_strength

    elif stream_player is AudioStreamPlayer2D:
        stream_player.max_distance = settings.max_distance
        stream_player.attenuation = settings.attenuation
        stream_player.panning_strength = settings.panning_strength

#---------------------------------------------------------
func _init():
    _rng = RandomNumberGenerator.new()
    
func _process(_delta: float):
    _active_emitters_2d = _process_active_audio(_active_emitters_2d)
    _active_emitters_3d = _process_active_audio(_active_emitters_3d) 

func _process_active_audio(active_audio):
    var new_active_audio := Array()

    # TODO - find a better way of modifying the list of active audio emitters
    for audio in active_audio:
        var alive := true
        if audio.player == null:
            alive = false
        elif not audio.player.playing:
            audio.player.queue_free()
            audio.player = null
            alive = false
        elif audio.source == null:
            if audio.event.playback_settings.stop_when_source_dies:
                audio.player.stop()
                alive = false

        # Update the position
        if not audio.event.playback_settings.stationary and alive and audio.source != null:
            audio.player.global_position = audio.source.global_position

        if alive:
            new_active_audio.append(audio)
        else:
            _log_death(audio.event.trigger_tags)
    return new_active_audio

func _enter_tree():
    instance = self

func _exit_tree():
    instance = null
        
#---------------------------------------------------------------------------------
# Internals
#---------------------------------------------------------------------------------
func _play_event(event: EAEvent, stream_player, source: Node, output_bus: String = ''):
    var stream := event.get_weighted_random_stream(_rng.randf())    
    stream_player.name = "AudioPlayback"
    add_child(stream_player)
    stream_player.stream = stream

    EventAudioAPI.init_player_from_playback_settings(_rng, stream_player, event.playback_settings)
    if output_bus != '':
        stream_player.set_bus(output_bus)

    if source:
        stream_player.global_position = source.global_position

    stream_player.play()
    
    if stream_player is AudioStreamPlayer2D:
        var emitter := AudioEmitter2D.new()
        emitter.player = stream_player
        emitter.source = source
        emitter.event = event
        _active_emitters_2d.append(emitter)
        return emitter
    else:
        var emitter = AudioEmitter3D.new()
        emitter.player = stream_player
        emitter.source = source
        emitter.event = event
        _active_emitters_3d.append(emitter)
        return emitter
    

func _invalidate_trigger_map():
    _trigger_map = {}
    
func _make_trigger_map():
    _trigger_map = {}
    for bank: EAEventBank in _audio_banks:
        for entry in bank.entries:
            var key = entry.trigger_tags
            _trigger_map[key] = entry

func _find_event_for_trigger(trigger: String) -> EAEvent:
    if _trigger_map.size() == 0:
        _make_trigger_map()
        
    var current_trigger := trigger

    while current_trigger != "":
        _log_lookup(current_trigger)
        var found_entry := _trigger_map.get(current_trigger) as EAEvent
        if found_entry:
            _log_found(found_entry.trigger_tags)
            return found_entry
        var tag_pos := current_trigger.rfind(_separator)
        if tag_pos >= 0:
            current_trigger = current_trigger.substr(0, tag_pos)
        else:
            current_trigger = ""
    return null
    
func _log_lookup(msg: String):
    if log_lookups:
        print("Trying " + msg)

func _log_found(msg: String):
    if log_lookups:
        print("Found " + msg)
    
func _log_bank_add(msg: String):
    if log_registrations:
        print("Registering Bank " + msg)
    
func _log_bank_remove(msg: String):
    if log_registrations:
        print("Unregistering Bank " + msg)
    
func _log_death(msg: String):
    if log_deaths:
        print("Killing " + msg)
