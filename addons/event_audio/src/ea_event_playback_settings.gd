extends Resource

class_name EAEventPlaybackSettings

## The factor for the attenuation effect. Higher values make the sound audible over a larger distance.
@export_group("Behaviour")
@export var stop_when_source_dies := false
@export var stationary := false

@export_group("Shared Playback")
@export_range(-10.0, 10.0, 0.1) var volume_db := 0.0
@export_range(0.1, 2.0, 0.1) var min_pitch := 1.0
@export_range(0.1, 2.0, 0.1) var max_pitch := 1.0
@export_range(0.0, 3.0, 0.1) var panning_strength := 1.0

@export_group("2D Playback")
@export_range(0.0, 3.0, 0.1) var attenuation := 1.0
@export_range(0, 9999999) var max_distance := 2000

@export_group("3D Playback")
@export_range(0, 1000) var unit_size := 10.0
@export_range(-10.0, 10.0, 0.1) var max_db := 3.0
