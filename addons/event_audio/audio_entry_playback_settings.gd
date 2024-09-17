extends Resource

class_name AudioEntryPlaybackSettings

@export_range(0, 1000) var unit_size := 10.0
@export_range(-10.0, 10.0, 0.1) var volume_db := 0.0
@export_range(0.1, 10.0, 0.1, "or_greater", "or_less") var min_pitch := 1.0
@export_range(0.1, 10.0, 0.1, "or_greater", "or_less") var max_pitch := 1.0
@export var stop_when_source_dies := false
@export var stationary := false
