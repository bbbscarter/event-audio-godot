class_name 	EAEditorTools
static var _editor_stream_player : AudioStreamPlayer
static var _global_rng : RandomNumberGenerator

static func get_global_rng() -> RandomNumberGenerator:
    if _global_rng == null:
        _global_rng = RandomNumberGenerator.new()
    return _global_rng
    
static func play_sound(entry: EAEvent, stream: AudioStream):
    var main_screen = EditorInterface.get_editor_main_screen()
    var audio = _editor_stream_player
    if audio == null:
        audio = AudioStreamPlayer.new()
        audio.name = "_EditorAudio"
        main_screen.add_child(audio)
        _editor_stream_player = audio

    EventAudioAPI.init_player_from_playback_settings(get_global_rng(), audio, entry.playback_settings)

    audio.stop()
    audio.stream = stream
    audio.play()

static func stop_sound():
    var audio := _editor_stream_player
    if audio != null:
        print("Stopping audio")
        audio.stop()
        audio.stream = null

static func make_property_panel(obj: Object, title: String, excludes : Dictionary, change_callback : Callable) -> Container:
    var panel := PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.modulate = Color(0.8, 0.8, 1)

    var property_container := VBoxContainer.new()
    property_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.add_child(property_container)
    
    if title != "":
        var title_label := Label.new()
        title_label.text = title
        title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        property_container.add_child(title_label)

    for prop in obj.get_property_list():
        if not prop.name in excludes:
            var val = obj.get(prop.name)
            var property_control := _make_property_control(prop, val, change_callback.bind(obj, prop.name))
            if property_control != null:
                property_container.add_child(property_control)

    return panel

static func _make_property_control(prop, initial_value, update_callback: Callable) -> Control:
    # print(prop)
    var control : Control
    
    if prop.usage & PROPERTY_USAGE_STORAGE:
        control = HBoxContainer.new()
        control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var text_label = Label.new()
        text_label.text = _property_name_to_display_name(prop.name)

        text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        control.add_child(text_label)

        var prop_type: Variant.Type = prop["type"]
        var prop_range : Dictionary = _parse_range(prop)

        match prop_type:
            TYPE_BOOL:
                var prop_editor = CheckBox.new()
                prop_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                if initial_value != null:
                    prop_editor.button_pressed = initial_value

                prop_editor.toggled.connect(update_callback)
                control.add_child(prop_editor)

            TYPE_INT, TYPE_FLOAT:
                var prop_editor := EditorSpinSlider.new()
                var default_step = null
                if prop_range.has("step"):
                    default_step = prop_range["step"]

                # For floats, show a normal input box if the step has been set to 1.
                # For ints, show a normal input box if the step has been set to 1, or left out.
                # Otherwise show a slider
                if prop_type == TYPE_FLOAT:
                    if default_step == null:
                        prop_editor.hide_slider = false
                        prop_editor.step = 0.0001
                    elif default_step == 1:
                        prop_editor.step = 1
                    else:
                        prop_editor.step = default_step
                        prop_editor.hide_slider = false
                else:
                    if default_step == null or default_step == 1:
                        prop_editor.step = 1
                    else:
                        prop_editor.step = default_step
                        prop_editor.hide_slider = false
                        

                prop_editor.allow_lesser = prop_range.has("or_lesser")
                prop_editor.allow_greater = prop_range.has("or_greater")

                if prop_range.has("min"):
                    prop_editor.min_value = prop_range["min"]

                if prop_range.has("max"):
                    prop_editor.max_value = prop_range["max"]

                prop_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                if initial_value != null:
                    prop_editor.value = initial_value

                prop_editor.value_changed.connect(update_callback)
                control.add_child(prop_editor)

            TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH:
                var prop_editor = LineEdit.new()
                prop_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                if initial_value != null:
                    prop_editor.text = initial_value

                prop_editor.text_changed.connect(update_callback)
                control.add_child(prop_editor)

            _:
                pass
    elif prop.usage & PROPERTY_USAGE_GROUP:
        var group_label := Label.new()
        group_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        group_label.text = prop.name
        control = group_label

    return control

static func _parse_range(prop) -> Dictionary:
    if prop["hint"] != PROPERTY_HINT_RANGE:
        return {}

    var prop_range := {}
    var parts := prop["hint_string"].split(",") as PackedStringArray
    var is_float : bool = prop["type"] == TYPE_FLOAT

    if parts.size() > 0:
        if is_float:
            prop_range["min"] = parts[0].to_float()
        else:
            prop_range["min"] = parts[0].to_int()

    if parts.size() > 1:
        if is_float:
            prop_range["max"] = parts[1].to_float()
        else:
            prop_range["max"] = parts[1].to_int()

    if parts.size() > 2:
        if is_float:
            prop_range["step"] = parts[2].to_float()
        else:
            prop_range["step"] = parts[2].to_int()

    if parts.size() > 3:
        match parts[3]:
            "or_lesser":
                prop_range["or_lesser"] = true
            "or_greater":
                prop_range["or_greater"] = true

    if parts.size() > 4:
        match parts[4]:
            "or_lesser":
                prop_range["or_lesser"] = true
            "or_greater":
                prop_range["or_greater"] = true
            _:
                pass

    return prop_range
        
    
static func _property_name_to_display_name(name: String):
    var name_snake := name.to_snake_case()
    var parts := name_snake.split("_")
    var display_name := ""

    for c1 : int in parts.size():
        var part := parts[c1]
        display_name += part.to_pascal_case()
        if c1 < parts.size() - 1:
            display_name += " "

    return display_name

    
