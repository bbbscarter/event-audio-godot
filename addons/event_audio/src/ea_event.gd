@tool
extends Resource
class_name EAEvent

@export var audio_streams : Array[AudioStream] = []
@export var probability_weights : Array[float] = []
@export var trigger_tags: String = ""
@export var playback_settings: EAEventPlaybackSettings

func _init():
    if audio_streams.size() == 0:
        audio_streams.push_front(null)
        probability_weights.push_front(1.0)
    playback_settings = EAEventPlaybackSettings.new()
    
func add_stream(index: int):
    audio_streams.insert(index+1, null)
    probability_weights.insert(index+1, 1.0)
    
func remove_stream(index: int):
    audio_streams.remove_at(index)
    probability_weights.remove_at(index)
    
func get_weighted_random_stream(random: float) -> AudioStream:
    var total_weight := 0.0
    for w : float in probability_weights:
        total_weight = total_weight + w
    
    var r := random * total_weight    
    var num_entries := probability_weights.size()
    var weight_count := 0.0
    for i in num_entries:
        if i + 1 == num_entries:
            return audio_streams[i]
        elif r <= weight_count + probability_weights[i]:
            return audio_streams[i]
        weight_count += probability_weights[i]
    return null
        
    
