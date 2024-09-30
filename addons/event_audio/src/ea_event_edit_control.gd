@tool
extends Container
class_name EAEventEditControl

@export var delete_trigger_button : BaseButton
@export var play_random_button : BaseButton
@export var trigger_name_edit : LineEdit
@export var settings_button : BaseButton
@export var stream_settings_list : Container
var _exclude_props = {"resource_local_to_scene": true, "Resource": true, "resource_name": true, "script": true}
var _settings_panel : Control
var _event : EAEvent
var _bank_inspector : EAEventBankProperty

func create(bank_inspector: EAEventBankProperty, event: EAEvent, open_settings: bool) -> void:
    _event = event
    _bank_inspector = bank_inspector

    delete_trigger_button.pressed.connect(_on_delete_entry_button_clicked)
    trigger_name_edit.set_text(_event.trigger_tags)
    trigger_name_edit.text_submitted.connect(_on_trigger_submitted)
    trigger_name_edit.text_changed.connect(_on_trigger_changed)
    settings_button.pressed.connect(_on_settings_button_clicked)
    play_random_button.pressed.connect(_on_play_random_button_clicked)

    if open_settings:
        var panel := _make_settings_panel()
        self.add_sibling(panel)
        _settings_panel = panel

func is_settings_open():
    return _settings_panel != null

func get_event():
    return _event

func _on_settings_button_clicked():
    _toggle_settings_panel()

func _on_settings_entry_changed(val, settings: EAEventPlaybackSettings, member: StringName):
    settings.set(member, val)
    _bank_inspector.signal_entry_changed(false)

func _on_delete_entry_button_clicked():
    _bank_inspector.delete_event(_event)
        
func _check_trigger_name(entry: EAEvent, trigger: String) -> bool:
    var bank_entry := _bank_inspector._resource.find_entry_with_trigger(trigger)

    if bank_entry and bank_entry != entry:
        return false

    return true

func _on_trigger_changed(trigger: String):
    # If the trigger isn't valid, show an error color
    if _check_trigger_name(_event, trigger):
        trigger_name_edit.modulate = Color.WHITE
    else:
        trigger_name_edit.modulate = Color.RED
    
func _on_trigger_submitted(trigger: String):
    if _check_trigger_name(_event, trigger):
        _event.trigger_tags = trigger
        trigger_name_edit.release_focus()

        # Re-sort the bank - this may trigger a UI update, so make sure we focus on the right control
        _bank_inspector.set_focus_on_trigger(trigger)
        _bank_inspector.sort_bank()
        _bank_inspector.signal_entry_changed(true)

func _on_play_random_button_clicked():
    var roll := EAEditorTools.get_global_rng().randf_range(0, 1.0)
    var stream := _event.get_weighted_random_stream(roll)
    if stream:
        EAEditorTools.play_sound(_event, stream)

func _toggle_settings_panel():
    if _settings_panel:
        _settings_panel.get_parent().remove_child(_settings_panel)
        _settings_panel.queue_free()
        _settings_panel = null
    else:
        var panel := _make_settings_panel()
        _settings_panel = panel
        self.add_sibling(panel)

func _make_settings_panel() -> Container:
    return 	EAEditorTools.make_property_panel(
        _event.playback_settings, "Playback Settings", _exclude_props, _on_settings_entry_changed)
    
