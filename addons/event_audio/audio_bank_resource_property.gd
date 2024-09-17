@tool
extends EditorProperty

class_name AudioBankResourceProperty

var property_control = Button.new()
var _resource: AudioBankResource
var _property_name: StringName
var _entries: Array[AudioBankEntry]
var _viewContainer := VBoxContainer.new()
var _exclude_props = {"resource_local_to_scene": true, "resource_name": true, "script": true}
var _settings_open = {}
var _rng = RandomNumberGenerator.new()

var _internal_update := 0
var _panel_color: Color        

var _icon_settings := EditorInterface.get_editor_theme().get_icon("Tools", "EditorIcons")
var _icon_delete := EditorInterface.get_editor_theme().get_icon("Close", "EditorIcons")
var _icon_add_resource := EditorInterface.get_editor_theme().get_icon("Add", "EditorIcons")
var _icon_remove_resource := EditorInterface.get_editor_theme().get_icon("Remove", "EditorIcons")
var _icon_play := EditorInterface.get_editor_theme().get_icon("Play", "EditorIcons")
var _icon_play_random := EditorInterface.get_editor_theme().get_icon("RandomNumberGenerator", "EditorIcons")


func _update_property():
    if _internal_update > 0:
        _internal_update -= 1
        return

    for i in _viewContainer.get_children():
        _viewContainer.remove_child(i)

    _make_lines()

func _enter_tree():
    # EditorInterface.get_editor_main_screen()
    # print(EditorInterface.get_editor_theme().get_color_list("Editor"))
    # print(EditorInterface.get_editor_theme().has_color("dark_color_1", "Editor"))
    _panel_color = EditorInterface.get_editor_theme().get_color("contrast_color_1", "Editor") 
    #get_color_list("Editor"))
    _property_name = get_edited_property()

    _resource = get_edited_object() as AudioBankResource
    _entries = _resource.entries

    _viewContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        
    _make_lines()
    add_child(_viewContainer)
    set_bottom_editor(_viewContainer)

    # var gui = EditorInterface.get_base_control()
    # var load_icon = gui.get_icon("Load", "EditorIcons")
    # print(EditorInterface.get_editor_theme().get_icon_list("EditorIcons"))
    # print(EditorInterface.get_editor_theme().get_icon_type_list())
    # RandomNumberGenerator, Play, Tools, Add, Remove, Close/GuiClose

#--------------------------------------
func _add_settings_panel_maybe(entry: AudioBankEntry, entryLine: Container):
    if entry in _settings_open:
        var panel := _make_settings_panel(entry)
        entryLine.add_sibling(panel)

func _toggle_settings_panel(entry: AudioBankEntry, entryLine: Container):
    
    if entry in _settings_open:
        var panel = _settings_open[entry]
        panel.get_parent().remove_child(panel)
        _settings_open.erase(entry)
    # if _settings_open.has(entry):
    else:
        var panel := _make_settings_panel(entry)
        _settings_open[entry] = panel
        entryLine.add_sibling(panel)

func _make_lines():
    var add_button = Button.new()
    add_button.text = "Add Entry"
    add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_button.pressed.connect(_on_add_entry_button_clicked)
    _viewContainer.add_child(add_button)
    for entry in _resource.entries:
        var entryLine = _makeEntryLine(entry)
        _viewContainer.add_child(entryLine)
        _add_settings_panel_maybe(entry, entryLine)

func _makeEntryLine(entry: AudioBankEntry) -> Container:
    var line_container = HBoxContainer.new()
    line_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    # lineContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    line_container.size_flags_vertical = Control.SIZE_EXPAND
    
    var deleteButton = TextureButton.new()
    deleteButton.texture_normal = _icon_delete
    # deleteButton.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
    deleteButton.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    deleteButton.pressed.connect(_on_delete_entry_button_clicked.bind(entry))
    line_container.add_child(deleteButton)


    var label_container = VBoxContainer.new()
    # labelContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    label_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    # labelContainer.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    line_container.add_child(label_container)
    
    var trigger_editor = LineEdit.new()
    trigger_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    trigger_editor.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    # label.size_flags_vertical = Control.SIZE_SHRINK_CENTER or Control.SIZE_EXPAND
    trigger_editor.set_text(entry.trigger_tags)
    trigger_editor.text_submitted.connect(_on_trigger_submitted.bind(entry, trigger_editor))
    trigger_editor.text_changed.connect(_on_trigger_changed.bind(entry, trigger_editor))
    label_container.add_child(trigger_editor)

    var settings_button := TextureButton.new()
    settings_button.texture_normal = _icon_settings
    settings_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
    settings_button.pressed.connect(_on_settings_button_clicked.bind(line_container, entry))
    settings_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    line_container.add_child(settings_button)

    var play_random_button := TextureButton.new()
    play_random_button.texture_normal = _icon_play_random
    play_random_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
    play_random_button.pressed.connect(_on_play_random_button_clicked.bind(entry))
    play_random_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    line_container.add_child(play_random_button)
    
    var resource_container = VBoxContainer.new()
    #labelContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    resource_container.size_flags_horizontal = Control.SIZE_FILL
    #resourceContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    # labelContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    resource_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    line_container.add_child(resource_container)

    for c1: int in entry.audio_streams.size():
        var resource_line_container = HBoxContainer.new()
        # labelContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
        resource_line_container.size_flags_horizontal = Control.SIZE_FILL
        # labelContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
        resource_line_container.size_flags_vertical = Control.SIZE_FILL
        resource_container.add_child(resource_line_container)

        var play_button := TextureButton.new()
        play_button.texture_normal = _icon_play
        play_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
        # addResourceButton.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
        ##print("Binding: %d" % c1)
        play_button.pressed.connect(_on_play_button_clicked.bind(c1, entry))
        resource_line_container.add_child(play_button)
        
        var weight_editor := EditorSpinSlider.new()
        weight_editor.label = "weight"
        weight_editor.custom_minimum_size = Vector2(128, 32) 
        weight_editor.step = 0.01
        weight_editor.hide_slider = false
        weight_editor.allow_lesser = false
        weight_editor.allow_greater = false
        weight_editor.min_value = 0
        weight_editor.max_value = 1.0
        weight_editor.value_changed.connect(_on_stream_weight_changed.bind(c1, entry))
        weight_editor.value = entry.probability_weights[c1]
        weight_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        resource_line_container.add_child(weight_editor)

        var resource_selector := EditorResourcePicker.new()
        resource_selector.size_flags_horizontal = Control.SIZE_FILL
        resource_selector.custom_minimum_size = Vector2(256, 32)

        # resourceSelector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        # resourceSelector.size_flags_stretch_ratio = 0.5
        resource_selector.base_type = "AudioStream"
        resource_selector.edited_resource = entry.audio_streams[c1]
        resource_selector.resource_changed.connect(_on_stream_changed.bind(c1, entry))
        resource_line_container.add_child(resource_selector)
    
        var resource_button_container := VBoxContainer.new()
        # labelContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
        resource_button_container.size_flags_horizontal = Control.SIZE_FILL
        # labelContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
        resource_button_container.size_flags_vertical = Control.SIZE_FILL
        resource_line_container.add_child(resource_button_container)

        var add_resource_button := TextureButton.new()
        add_resource_button.texture_normal = _icon_add_resource
        add_resource_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
        # addResourceButton.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
        add_resource_button.pressed.connect(_on_add_resource_button_clicked.bind(c1, entry))
        resource_button_container.add_child(add_resource_button)
    
        if entry.audio_streams.size() > 1:
            var delete_resource_button := TextureButton.new()
            delete_resource_button.texture_normal = _icon_remove_resource
            delete_resource_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
            # addResourceButton.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
            delete_resource_button.pressed.connect(_on_delete_resource_button_clicked.bind(c1, entry))
            resource_button_container.add_child(delete_resource_button)

    return line_container

func _make_settings_panel(entry: AudioBankEntry) -> Container:
    var settings_panel = PanelContainer.new()
    settings_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    # var style := StyleBoxLine.new()
    # style.set_color(Color(1.0, 0, 0, 1.0))
    # style.thickness = 5
    var style := StyleBoxFlat.new()
    style.bg_color = _panel_color#(0.2, 0, 0, 1)
    settings_panel.add_theme_stylebox_override("panel", style)
    # settingsPanel.theme.panel = style

    var settings_container = VBoxContainer.new()
    settings_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    # settingsContainer.add_child(settingsPanel)
    settings_panel.add_child(settings_container)
    
    settings_container.add_child(Label.new())
    var entry_settings := entry.playback_settings

    for prop in entry_settings.get_property_list():
        if prop.usage & PROPERTY_USAGE_STORAGE and not prop.name in _exclude_props:
            # print(prop)
            var val = entry_settings.get(prop.name)
            var c = _make_property_editor(
                prop, val,
                _on_settings_entry_changed.bind(entry_settings, prop.name))
            settings_container.add_child(c)

    return settings_panel
    # return settingsContainer

func _on_settings_button_clicked(line: Container, entry: AudioBankEntry):
    _toggle_settings_panel(entry, line)
    # var settingsPanel := _make_settings_panel(entryIdx)
    # line.add_sibling(settingsPanel)

func _on_settings_entry_changed(val, settings: AudioEntryPlaybackSettings, member: StringName):
    settings.set(member, val)
    _internal_update += 1
    emit_changed(_property_name, _entries)
    
func _on_add_entry_button_clicked():
    print(_resource)
    _resource.add_entry()
    emit_changed(_property_name, _entries)

func _on_delete_entry_button_clicked(entry: AudioBankEntry):
    _resource.delete_entry(entry)
    emit_changed(_property_name, _entries)

func _on_play_button_clicked(index: int, entry: AudioBankEntry):
    var stream := entry.audio_streams[index]
    if stream:
        _play_sound(entry, stream)
        
func _on_play_random_button_clicked(entry: AudioBankEntry):
    var roll := _rng.randf_range(0, 1.0)
    var stream := entry.get_weighted_random_stream(roll)
    if stream:
        _play_sound(entry, stream)

func _on_stream_weight_changed(val, index: int, entry: AudioBankEntry):
    entry.probability_weights[index] = val
    _internal_update += 1
    emit_changed(_property_name, _entries)

func _on_add_resource_button_clicked(index: int, entry: AudioBankEntry):
    entry.add_stream(index)
    # _internal_update += 1
    emit_changed(_property_name, _entries)

func _on_delete_resource_button_clicked(index: int, entry: AudioBankEntry):
    entry.remove_stream(index)
    emit_changed(_property_name, _entries)

func _check_trigger_name(entry: AudioBankEntry, trigger: String) -> bool:
    var bank_entry := _resource.find_entry_with_trigger(trigger)

    if bank_entry and bank_entry != entry:
        return false

    return true

func _on_trigger_changed(trigger: String, entry: AudioBankEntry, text_label):
    if _check_trigger_name(entry, trigger):
        text_label.modulate = Color.WHITE
    else:
        text_label.modulate = Color.RED
    
func _on_trigger_submitted(trigger: String, entry: AudioBankEntry, text_label):
    if _check_trigger_name(entry, trigger):
        entry.trigger_tags = trigger
        _internal_update += 1
        emit_changed(_property_name, _entries)
        text_label.release_focus()

func _on_stream_changed(res: Resource, idx: int, entry: AudioBankEntry):
    entry.audio_streams[idx] = res as AudioStream
    _internal_update += 1
    emit_changed(_property_name, _entries)

func _make_property_editor(prop, initial_value, update_callback: Callable) -> Container:
    print(prop)
    var line_container = HBoxContainer.new()
    line_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var text_label = Label.new()
    text_label.text = prop.name
    line_container.add_child(text_label)

    var prop_type: Variant.Type = prop["type"]
    match prop_type:
        TYPE_BOOL:
            var prop_editor = CheckBox.new()
            prop_editor.size_flags_horizontal = SIZE_EXPAND_FILL
            if initial_value != null:
                prop_editor.button_pressed = initial_value

            prop_editor.toggled.connect(update_callback)
            line_container.add_child(prop_editor)

        TYPE_INT, TYPE_FLOAT:
            var prop_editor = EditorSpinSlider.new()
            prop_editor.step = 1
            if prop_type == TYPE_FLOAT:
                prop_editor.step = 0.001

            prop_editor.hide_slider = false
            prop_editor.allow_lesser = true
            prop_editor.allow_greater = true
            prop_editor.size_flags_horizontal = SIZE_EXPAND_FILL
            if initial_value != null:
                prop_editor.value = initial_value

            prop_editor.value_changed.connect(update_callback)
            line_container.add_child(prop_editor)

        TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH:
            var prop_editor = LineEdit.new()
            prop_editor.size_flags_horizontal = SIZE_EXPAND_FILL
            # prop_editor.size_flags_stretch_ratio = 2.0
            if initial_value != null:
                prop_editor.text = initial_value

            prop_editor.text_changed.connect(update_callback)
            line_container.add_child(prop_editor)

        _:
            pass
    return line_container

func _play_sound(entry: AudioBankEntry, stream: AudioStream):
    var audio: AudioStreamPlayer = EditorInterface.get_editor_main_screen().find_child("_EditorAudio") as AudioStreamPlayer
    if audio == null:
        audio = AudioStreamPlayer.new()
        audio.name = "_EditorAudio"
        EditorInterface.get_editor_main_screen().add_child(audio)

    EventAudioAPI.init_player_from_playback_settings(_rng, audio, entry.playback_settings)

    audio.stop()
    audio.stream = stream
    audio.play()
