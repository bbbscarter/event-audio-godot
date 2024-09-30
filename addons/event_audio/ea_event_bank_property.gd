@tool
extends EditorProperty

class_name EAEventBankProperty

var _audio_bank_line_scene = preload("res://addons/event_audio/scenes/bank_line.tscn")
var _audio_bank_resource_line_scene = preload("res://addons/event_audio/scenes/bank_resource_line.tscn")

var _resource: EAEventBank
var _property_name: StringName
var _entries: Array[EAEvent]
var _viewContainer := VBoxContainer.new()
var _exclude_props = {"resource_local_to_scene": true, "Resource": true, "resource_name": true, "script": true}
var _settings_open = {}
var _rng = RandomNumberGenerator.new()

var _internal_update := 0

var _focus_on_trigger : String = ""

#----------------------------------------------
# Godot call to update rendering
func _update_property():
    # If the rendering has already been handled, don't do anything else.
    if _internal_update > 0:
        print("skipping updating property")
        _internal_update -= 1
        return

    print("updating property")
    for i in _viewContainer.get_children():
        _viewContainer.remove_child(i)

    _make_lines()

    # Search for the trigger we were looking at previously.
    if _focus_on_trigger == "":
        return

    await get_tree().process_frame

    for control : Control in _viewContainer.get_children():
        if control is not EAEventEditControl:
            continue
        var line = control as EAEventEditControl
        if line.TriggerNameEdit.text == _focus_on_trigger:
            print("found " + _focus_on_trigger)
            EditorInterface.get_inspector().ensure_control_visible(line.TriggerNameEdit)
            break

    _focus_on_trigger = ""

func _enter_tree():
    _property_name = get_edited_property()

    _resource = get_edited_object() as EAEventBank
    _entries = _resource.entries

    _viewContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        
    _make_lines()
    add_child(_viewContainer)
    set_bottom_editor(_viewContainer)

func _exit_tree() -> void:
    EAEditorTools.stop_sound()

#--------------------------------------
func _add_settings_panel_maybe(entry: EAEvent, entryLine: Container):
    if entry in _settings_open:
        var panel := _make_settings_panel(entry)
        entryLine.add_sibling(panel)

func _toggle_settings_panel(entry: EAEvent, entryLine: Container):
    if entry in _settings_open:
        var panel = _settings_open[entry]
        panel.get_parent().remove_child(panel)
        _settings_open.erase(entry)
    else:
        var panel := _make_settings_panel(entry)
        _settings_open[entry] = panel
        entryLine.add_sibling(panel)

func _make_settings_panel(entry : EAEvent) -> Container:
        return 	EAEditorTools.make_property_panel(entry.playback_settings, "Playback Settings", _exclude_props, _on_settings_entry_changed)
    
func _make_lines():
    var add_button = Button.new()
    add_button.text = "Add Entry"
    add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_button.pressed.connect(_on_add_entry_button_clicked)
    _viewContainer.add_child(add_button)

    var stop_button = Button.new()
    stop_button.text = "Stop playback"
    stop_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stop_button.pressed.connect(_on_stop_button_clicked)
    _viewContainer.add_child(stop_button)

    for entry in _resource.entries:
        var entryLine = _makeEntryLine(entry)
        _viewContainer.add_child(entryLine)
        _add_settings_panel_maybe(entry, entryLine)

func _makeEntryLine(entry: EAEvent) -> Container:
    var line := _audio_bank_line_scene.instantiate() as EAEventEditControl
    line.DeleteTriggerButton.pressed.connect(_on_delete_entry_button_clicked.bind(entry))
    line.TriggerNameEdit.set_text(entry.trigger_tags)
    line.TriggerNameEdit.text_submitted.connect(_on_trigger_submitted.bind(entry, line.TriggerNameEdit))
    line.TriggerNameEdit.text_changed.connect(_on_trigger_changed.bind(entry, line.TriggerNameEdit))
    line.SettingsButton.pressed.connect(_on_settings_button_clicked.bind(line, entry))
    line.PlayRandomButton.pressed.connect(_on_play_random_button_clicked.bind(entry))

    for c1: int in entry.audio_streams.size():
        var resource_line := _audio_bank_resource_line_scene.instantiate() as EAStreamEditControl
        line.ResourceList.add_child(resource_line)
        resource_line.set_as_first_resource(entry.audio_streams.size() == 1)

        resource_line.PlayButton.pressed.connect(_on_play_button_clicked.bind(c1, entry))

        resource_line.WeightEditor.value_changed.connect(_on_stream_weight_changed.bind(c1, entry))
        resource_line.WeightEditor.value = entry.probability_weights[c1]

        resource_line.AudioSelector.edited_resource = entry.audio_streams[c1]
        resource_line.AudioSelector.resource_changed.connect(_on_stream_changed.bind(c1, entry))
        
        resource_line.AddResourceButton.pressed.connect(_on_add_resource_button_clicked.bind(c1, entry))

        resource_line.DeleteResourceButton.pressed.connect(_on_delete_resource_button_clicked.bind(c1, entry))

    return line
    

func _on_settings_button_clicked(line: Container, entry: EAEvent):
    _toggle_settings_panel(entry, line)

func _on_settings_entry_changed(val, settings: EAEventPlaybackSettings, member: StringName):
    settings.set(member, val)
    _internal_update += 1
    emit_changed(_property_name, _entries)
    
func _on_add_entry_button_clicked():
    _resource.add_entry()
    emit_changed(_property_name, _entries)

func _on_stop_button_clicked():
    EAEditorTools.stop_sound()

func _on_delete_entry_button_clicked(entry: EAEvent):
    _resource.delete_entry(entry)
    emit_changed(_property_name, _entries)

func _on_play_button_clicked(index: int, entry: EAEvent):
    var stream := entry.audio_streams[index]
    if stream:
        EAEditorTools.play_sound(entry, stream, _rng)
        
func _on_play_random_button_clicked(entry: EAEvent):
    var roll := _rng.randf_range(0, 1.0)
    var stream := entry.get_weighted_random_stream(roll)
    if stream:
        EAEditorTools.play_sound(entry, stream, _rng)

func _on_stream_weight_changed(val, index: int, entry: EAEvent):
    entry.probability_weights[index] = val
    _internal_update += 1
    emit_changed(_property_name, _entries)

func _on_add_resource_button_clicked(index: int, entry: EAEvent):
    entry.add_stream(index)
    emit_changed(_property_name, _entries)

func _on_delete_resource_button_clicked(index: int, entry: EAEvent):
    entry.remove_stream(index)
    emit_changed(_property_name, _entries)

func _check_trigger_name(entry: EAEvent, trigger: String) -> bool:
    var bank_entry := _resource.find_entry_with_trigger(trigger)

    if bank_entry and bank_entry != entry:
        return false

    return true

func _on_trigger_changed(trigger: String, entry: EAEvent, text_label):
    # If the trigger isn't valid, show an error color
    if _check_trigger_name(entry, trigger):
        text_label.modulate = Color.WHITE
    else:
        text_label.modulate = Color.RED
    
func _on_trigger_submitted(trigger: String, entry: EAEvent, text_label):
    if _check_trigger_name(entry, trigger):
        entry.trigger_tags = trigger
        text_label.release_focus()

        # Re-sort the bank - this may trigger a UI update, so make sure we focus on the right control
        _sort_bank()
        _focus_on_trigger = trigger
        emit_changed(_property_name, _entries)

func _on_stream_changed(res: Resource, idx: int, entry: EAEvent):
    entry.audio_streams[idx] = res as AudioStream
    _internal_update += 1
    emit_changed(_property_name, _entries)


func _sort_bank():
    _resource.sort_by_trigger()
    
