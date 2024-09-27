@tool
extends Container
class_name AudioResourceLineUI

@export var Test : AudioStream
@export var DeleteResourceButton : Button
@export var AddResourceButton : Button
@export var PlayButton : Button


# Called when the node enters the scene tree for the first time.
var WeightEditor : EditorSpinSlider
var AudioSelector : EditorResourcePicker
@export var AudioLabel : Label
    
func set_as_first_resource(on):
    AddResourceButton.visible = true
    if on:
        DeleteResourceButton.disabled = true
    else:
        DeleteResourceButton.disabled = false
    
func _init() -> void:
    var weight_editor := EditorSpinSlider.new()
    weight_editor.label = "weight"
    weight_editor.step = 0.05
    weight_editor.hide_slider = false
    weight_editor.allow_lesser = false
    weight_editor.allow_greater = false
    weight_editor.min_value = 0
    weight_editor.max_value = 1.0
    weight_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    WeightEditor = weight_editor

    var resource_selector := EditorResourcePicker.new()
    resource_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    resource_selector.base_type = "AudioStream"

    resource_selector.resource_changed.connect(_on_resource_changed)
    resource_selector.resource_selected.connect(_on_resource_clicked)

    AudioSelector = resource_selector
    
func _on_resource_clicked(res: Resource, _inspect: bool):
    # When the resource picker is clicked, visit the resource.
    # Do it the next frame, however, in case the controls are being updated.
    if res != null:
        await get_tree().process_frame
        EditorInterface.edit_resource(res)
    
func _on_resource_changed(_res: Resource):
    _make_audio_picker_pretty()
    
func _make_audio_picker_pretty():
    # If no resource, show the default button text
    # Otherwise, show the file name
    var res := AudioSelector.edited_resource
    if res == null:
        AudioLabel.visible = false
    else:
        if FileAccess.file_exists(res.resource_path):
            AudioLabel.text = res.resource_path.get_file()
            AudioLabel.visible = true
        else:
            AudioLabel.text = res.get_class()
            # TODO - can't tell when the button is rendering at the moment.
            # Until we can, make the label invisible
            AudioLabel.visible = false
        
    
    # This is the only way I can find to get the ResourcePicker smaller
    # Detach the texture rect that shows the preview
    var children := AudioSelector.get_children()
    while not children.is_empty():
        var child = children.pop_back()
        children.append_array(child.get_children())
        if child is TextureRect:
            child.get_parent().remove_child(child)

func _ready() -> void:
    get_node("WeightSliderContainer").add_child(WeightEditor)
    get_node("ResourcePicker/ResourcePickerContainer").add_child(AudioSelector)

    _make_audio_picker_pretty()
