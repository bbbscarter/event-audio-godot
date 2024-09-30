extends Node

# Ideally this would be called just EventAudio, but that would class with the autoload
class_name EventAudioAPI

var _audio_banks: Array[EAEventBank]
@export var log_lookups: bool = true
@export var log_deaths: bool = true
@export var log_registrations: bool = true
@export var default_unit_size := 10.0

static var _separator := "+"
static var instance : EventAudioAPI

var _trigger_map: Dictionary
var _rng: RandomNumberGenerator

static func get_instance() -> EventAudioAPI:
    return instance

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
func _enter_tree():
    instance = self

func _exit_tree():
    instance = null

static func init_player_from_playback_settings(rng, stream_player, settings: EAEventPlaybackSettings):
    var min_pitch := min(settings.min_pitch, settings.max_pitch) as float
    var max_pitch := max(settings.min_pitch, settings.max_pitch) as float
    var pitch = rng.randf_range(min_pitch, max_pitch)
    stream_player.pitch_scale = pitch
    stream_player.volume_db = settings.volume_db

    if stream_player is AudioStreamPlayer3D:
        stream_player.unit_size = settings.unit_size
        stream_player.max_db = settings.max_db
        stream_player.panning_strength = settings.panning_strength

    elif stream_player is AudioStreamPlayer2D:
        stream_player.max_distance = settings.max_distance
        stream_player.attenuation = settings.attenuation
        stream_player.panning_strength = settings.panning_strength

        
        
    
func play_2d(trigger: String, source: Node2D) -> AudioEmitter2D:
# func play_2d(trigger: String, source: Node2D) -> AudioStreamPlayer2D:
    var entry := _find_entry_for_trigger(trigger)
    if entry == null:
        return null

    var stream = entry.get_weighted_random_stream(_rng.randf())    
    var stream_player = AudioStreamPlayer2D.new()
    stream_player.name = "AudioPlayback"
    add_child(stream_player)
    stream_player.stream = stream

    EventAudioAPI.init_player_from_playback_settings(_rng, stream_player, entry.playback_settings)

    if source:
        stream_player.global_position = source.global_position

    stream_player.play()
    
    var emitter := AudioEmitter2D.new()
    emitter.player = stream_player
    emitter.source = source
    emitter.event = entry
    _active_emitters_2d.append(emitter)
    
    return emitter

func play_3d(trigger: String, source: Node3D) -> AudioEmitter3D:
    var entry := _find_entry_for_trigger(trigger)
    if entry == null:
        return null

    var stream = entry.get_weighted_random_stream(_rng.randf())    
    var stream_player := AudioStreamPlayer3D.new()
    stream_player.name = "AudioPlayback"
    EventAudioAPI.init_player_from_playback_settings(_rng, stream_player, entry.playback_settings)
    add_child(stream_player)
    stream_player.stream = stream
    # stream_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
    stream_player.play()

    if source:
        stream_player.global_position = source.global_position
    
    var emitter = AudioEmitter3D.new()
    emitter.player = stream_player
    emitter.source = source
    emitter.event = entry
    _active_emitters_3d.append(emitter)
    
    return emitter

func stop(emitter):
    emitter.player.stop()

func register_bank_resource(bank: EAEventBank):
    if log_registrations:
        print("Registering bank: " + bank.resource_name)
    _audio_banks.append(bank)
    _invalidate_trigger_map()
    
func unregister_bank_resource(bank: EAEventBank):
    if log_registrations:
        print("Unregistering bank: " + bank.resource_name)
    var idx := _audio_banks.find(bank)
    if idx >= 0:
        _audio_banks.remove_at(idx)
        _invalidate_trigger_map()

func _process(_delta: float):
    _active_emitters_2d = _process_active_audio(_active_emitters_2d)
    _active_emitters_3d = _process_active_audio(_active_emitters_3d) 

func _process_active_audio(active_audio):
    var new_active_audio := Array()

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
            
func _init():
    _rng = RandomNumberGenerator.new()
    
func _invalidate_trigger_map():
    _trigger_map = {}
    
func _make_trigger_map():
    _trigger_map = {}
    for bank: EAEventBank in _audio_banks:
        for entry in bank.entries:
            var key = entry.trigger_tags
            _trigger_map[key] = entry

func _find_entry_for_trigger(trigger: String) -> EAEvent:
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
    
func get_random_str_for_trigger(trigger: String) -> AudioStream:
    var entry := _find_entry_for_trigger(trigger)
    
    if entry:
        return entry.audioStreams[0]
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
