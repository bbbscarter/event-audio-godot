# Event Audio for Godot
A fire-and-forget audio triggering system for Godot.

- Create audio banks, linking event triggers with audio resources.
- Play audio with one line of code:
```gdscript
EventAudio.play3d("laser+shoot", my_player)
```
- If a trigger isn't found, nothing is played.

# Features
- Works with 2D and 3D scenes.
- Multiple audio resources can be associated with a trigger. When triggered, a random choice will be picked.
- Triggers are searched for hierarchically the using `+` separator.
- Audio banks can be swapped out at runtime.

# Trigger lookups
The lookup system is simple but powerful, based on left to right specialisation with a special separator character `+`.

For example, if an audio bank contains: 
- `FOO` -> Sample 1.
- `FOO+BAR` -> Sample 2

Triggering `FOO+BAR` will trigger Sample 2.
Triggering `FOO+QUX` will trigger Sample 1.
Triggering `BAZ` will trigger nothing.

This allows an audio designer to populate the audio space quickly with triggers like `HIT`, `COLLISION`, `DAMAGE`, `FOOTSTEP`, etc, and then specialise them for `HIT+WALL`, `HIT+WOOD`, as necessary.

# Installation and Usage
- Download from the Godot Asset Library.
- Import the plugin into your Godot project.
- Enable the plugin in your project settings.
