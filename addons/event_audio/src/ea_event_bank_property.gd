@tool
extends EditorProperty

class_name EAEventBankProperty

var _audio_bank_line_scene := preload("res://addons/event_audio/scenes/bank_line.tscn")
var _audio_bank_resource_line_scene := preload("res://addons/event_audio/scenes/bank_resource_line.tscn")

var _resource: EAEventBank
var _property_name: StringName
var _entries: Array[EAEvent]
var _root_container := VBoxContainer.new()
var _focus_on_trigger : String = ""

#----------------------------------------------
# Godot call to update rendering
func _update_property():
    # print("updating property")
    var open_settings := {}

    for control : Node in _root_container.get_children():
        if control is EAEventEditControl and control.is_settings_open():
            open_settings[control.get_event()] = true
            
        _root_container.remove_child(control)
        control.queue_free()

    _make_lines(open_settings)

    # Search for the trigger we were looking at previously.
    if _focus_on_trigger == "":
        return

    await get_tree().process_frame

    # Find the trigger we were editing previously and select it.
    for control : Control in _root_container.get_children():
        if control is not EAEventEditControl:
            continue
        var line = control as EAEventEditControl
        if line.trigger_name_edit.text == _focus_on_trigger:
            EditorInterface.get_inspector().ensure_control_visible(line.trigger_name_edit)
            break

    _focus_on_trigger = ""

func _enter_tree():
    _property_name = get_edited_property()
    _resource = get_edited_object() as EAEventBank
    _entries = _resource.entries

    _root_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        
    _make_lines()
    add_child(_root_container)
    set_bottom_editor(_root_container)

func _exit_tree() -> void:
    EAEditorTools.stop_sound()

func sort_bank():
    _resource.sort_by_trigger()

func signal_entry_changed(update_ui: bool):
    emit_changed(_property_name, _entries, "", not update_ui)

func set_focus_on_trigger(trigger: String):
    _focus_on_trigger = trigger

func delete_event(event: EAEvent):
    _resource.delete_entry(event)
    signal_entry_changed(true)

#--------------------------------------
func _make_lines(setting_to_restore = {}):
    var add_button := Button.new()
    add_button.text = "Add Entry"
    add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_button.pressed.connect(_on_add_entry_button_clicked)
    _root_container.add_child(add_button)

    var stop_button := Button.new()
    stop_button.text = "Stop playback"
    stop_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stop_button.pressed.connect(_on_stop_button_clicked)
    _root_container.add_child(stop_button)

    for entry : EAEvent in _resource.entries:
        var settings_open := setting_to_restore.has(entry)
        _makeEntryLine(entry, settings_open) 

func _makeEntryLine(entry: EAEvent, settings_open: bool):
    var line := _audio_bank_line_scene.instantiate() as EAEventEditControl
    _root_container.add_child(line)
    line.create(self, entry, settings_open)

    for c1: int in entry.audio_streams.size():
        var resource_line := _audio_bank_resource_line_scene.instantiate() as EAStreamEditControl
        line.stream_settings_list.add_child(resource_line)
        resource_line.create(self, entry, c1, entry.audio_streams.size() == 1)
    
func _on_add_entry_button_clicked():
    _resource.add_entry()
    signal_entry_changed(true)

func _on_stop_button_clicked():
    EAEditorTools.stop_sound()

    
