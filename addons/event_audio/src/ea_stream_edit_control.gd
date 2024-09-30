@tool
extends Container
class_name EAStreamEditControl

@export var delete_event_button : Button
@export var add_stream_button : Button
@export var play_button : Button
@export var audio_label : Label
var weight_editor : EditorSpinSlider
var audio_selector : EditorResourcePicker
    
var _stream_id : int
var _event : EAEvent
var _bank_inspector : EAEventBankProperty

func create(bank_inspector: EAEventBankProperty, event: EAEvent, stream_id: int, primary: bool) -> void:
    # When this is the primary resource, we don't want to delete it.
    # add_stream_button.visible = true
    _stream_id = stream_id
    _event = event
    _bank_inspector = bank_inspector

    if primary:
        delete_event_button.disabled = true
    else:
        delete_event_button.disabled = false
    
    play_button.pressed.connect(_on_play_button_clicked)

    audio_selector.resource_changed.connect(_on_stream_changed)
    audio_selector.edited_resource = _event.audio_streams[_stream_id]
        
    add_stream_button.pressed.connect(_on_add_resource_button_clicked)
    delete_event_button.pressed.connect(_on_delete_resource_button_clicked)

    weight_editor.value_changed.connect(_on_stream_weight_changed)
    weight_editor.value = _event.probability_weights[_stream_id]
    _make_audio_picker_pretty()

func _ready() -> void:
    get_node("WeightSliderContainer").add_child(weight_editor)
    get_node("ResourcePicker/ResourcePickerContainer").add_child(audio_selector)
    # if _event:
    #     audio_selector.edited_resource = _event.audio_streams[_stream_id]

    _make_audio_picker_pretty()

func _init() -> void:
    weight_editor = EditorSpinSlider.new()
    weight_editor.label = "weight"
    weight_editor.step = 0.05
    weight_editor.hide_slider = false
    weight_editor.allow_lesser = false
    weight_editor.allow_greater = false
    weight_editor.min_value = 0
    weight_editor.max_value = 1.0
    weight_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    audio_selector = EditorResourcePicker.new()
    audio_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    audio_selector.base_type = "AudioStream"
    # audio_selector.edited_resource = _event.audio_streams[_stream_id]

    audio_selector.resource_changed.connect(_on_resource_changed)
    audio_selector.resource_selected.connect(_on_resource_clicked)

    
func _on_resource_clicked(res: Resource, _inspect: bool):
    # When the resource picker is clicked, visit the resource.
    # Do it the next frame, however, in case the controls are being updated.
    if res != null:
        await get_tree().process_frame
        EditorInterface.edit_resource(res)
    
func _on_resource_changed(_res: Resource):
    # When the resource is changed, update the prettification of the resource picker.
    _make_audio_picker_pretty()
    
# The default resource picker has several drawbacks when used in a custom inspector.
# - It draws double-height, to show an audio preview; even when there is no preview.
# - When audio is assigned it stops showing the path name.
# This function 'fixes' that, somewhat hackily.
func _make_audio_picker_pretty():
    # In certain circumstances, show a custom label with the resources file path.
    # Otherwise, hide it and rely on the default control.
    var res := audio_selector.edited_resource

    if res == null:
        # If no resource, show the default button text
        audio_label.visible = false
    else:
        # Otherwise, try to show the file name
        if FileAccess.file_exists(res.resource_path):
            audio_label.text = res.resource_path.get_file()
            audio_label.visible = true
        else:
            audio_label.text = res.get_class()
            # TODO - can't tell when the button is rendering at the moment, so this shows on top, sometimes.
            # Until we can, make the label invisible
            audio_label.visible = false
    
    # This is the only way we found to get the ResourcePicker smaller.
    # It's not ideal, as it depends on the internals of the resource picker.
    # Search for the texture rect that shows the preview and detach it.
    var children := audio_selector.get_children()
    while not children.is_empty():
        var child := children.pop_back() as Node
        children.append_array(child.get_children())
        if child is TextureRect:
            child.get_parent().remove_child(child)

func _on_play_button_clicked():
    var stream := _event.audio_streams[_stream_id]
    if stream:
        EAEditorTools.play_sound(_event, stream)

func _on_stream_weight_changed(val):
    _event.probability_weights[_stream_id] = val
    _bank_inspector.signal_entry_changed(false)

func _on_add_resource_button_clicked():
    _event.add_stream(_stream_id)
    _bank_inspector.signal_entry_changed(true)

func _on_delete_resource_button_clicked():
    _event.remove_stream(_stream_id)
    _bank_inspector.signal_entry_changed(true)

func _on_stream_changed(res: Resource):
    _event.audio_streams[_stream_id] = res as AudioStream
    _bank_inspector.signal_entry_changed(false)
