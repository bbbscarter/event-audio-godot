@tool
extends EditorPlugin

var _editor_plugin = preload("res://addons/event_audio/audio_bank_resource_inspector.gd").new()
var _runtime_scene = "res://addons/event_audio/scenes/event_audio_autoload.tscn"

func _enter_tree():

    if ClassDB.class_exists("CSharpScript"):
        print ("Mono supported")
    else:
        print ("Mono unsupported")

    add_inspector_plugin(_editor_plugin)

    if not ProjectSettings.has_setting("autoload/EventAudio"):
        add_autoload_singleton("EventAudio", _runtime_scene)

func _exit_tree():
    if _editor_plugin != null:
        remove_inspector_plugin(_editor_plugin)
    if ProjectSettings.has_setting("autoload/EventAudio"):
        remove_autoload_singleton("EventAudio")
