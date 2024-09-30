@tool
extends EditorPlugin

var _editor_plugin = preload("res://addons/event_audio/src/ea_event_bank_inspector.gd").new()
var _runtime_scene = "res://addons/event_audio/scenes/event_audio_autoload.tscn"

func _enter_tree():

    var mono_supported = ClassDB.class_exists("CSharpScript")

    if mono_supported:
        print ("Mono supported")
    else:
        print ("Mono unsupported")

    add_inspector_plugin(_editor_plugin)

    if not ProjectSettings.has_setting("autoload/EventAudio"):
        add_autoload_singleton("EventAudio", _runtime_scene)

    if mono_supported:
        if not ProjectSettings.has_setting("autoload/EventAudioCSharp"):
            var _cs_script = "res://addons/event_audio/EventAudio.cs"
            add_autoload_singleton("EventAudioCSharp", _cs_script)

func _exit_tree():
    if _editor_plugin != null:
        remove_inspector_plugin(_editor_plugin)
    if ProjectSettings.has_setting("autoload/EventAudio"):
        remove_autoload_singleton("EventAudio")

    if ProjectSettings.has_setting("autoload/EventAudioCSharp"):
        remove_autoload_singleton("EventAudioCSharp")
