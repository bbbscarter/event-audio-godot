@tool
extends Container
class_name AudioResourceLineUI

@export var Test : AudioStream
# Called when the node enters the scene tree for the first time.
var WeightEditor : EditorSpinSlider
var AudioSelector : EditorResourcePicker
@export var DeleteResourceButton : Button
@export var AddResourceButton : Button
@export var PlayButton : Button

func set_as_first_resource(on):
    if on:
        DeleteResourceButton.visible = false
        AddResourceButton.visible = true
    else:
        DeleteResourceButton.visible = true
        AddResourceButton.visible = false
    
func _init() -> void:
    var weight_editor := EditorSpinSlider.new()
    weight_editor.label = "weight"
    # weight_editor.custom_minimum_size = Vector2(128, 32) 
    weight_editor.step = 0.01
    weight_editor.hide_slider = false
    weight_editor.allow_lesser = false
    weight_editor.allow_greater = false
    weight_editor.min_value = 0
    weight_editor.max_value = 1.0
    weight_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    WeightEditor = weight_editor
    # get_node("WeightSliderContainer").add_child(weight_editor)

    var resource_selector := EditorResourcePicker.new()
    resource_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    resource_selector.base_type = "AudioStream"
    # resource_selector.custom_minimum_size = Vector2(0, 0)
    #resource_selector.toggle_mode = true
    resource_selector.editable = true
    # resource_selector.toggle_mode = true
    # get_node("ResourcePickerContainer").add_child(resource_selector)
    AudioSelector = resource_selector

func _ready() -> void:
    # print("Enter tree")
    get_node("WeightSliderContainer").add_child(WeightEditor)
    get_node("ResourcePickerContainer").add_child(AudioSelector)

    ## This is the only way I can find to get the 
    # for c in AudioSelector.get_children():
    #     print (c.name)
    #     c.custom_minimum_size = Vector2(0, 0)
    #     for cc in c.get_children():
    #         c.custom_minimum_size = Vector2(0, 0)
    #         # if cc is TextureRect:
    #         #     cc.free()
    #             # cc.visible = false
    #         # print (cc.name)
