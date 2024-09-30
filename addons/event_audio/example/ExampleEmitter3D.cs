using Godot;


public partial class ExampleEmitter3D : Node3D {
  [Export]
  float Speed = 1.0f;
  [Export]
  Node3D OrbitNode;
  EventAudio.EventAudioEmitter _loopEmitter;
  float _orbitRadius = 1.0f;
  
  public override void _Ready() {
    _orbitRadius = (GlobalPosition - OrbitNode.GlobalPosition).Length();
  }
    
  public override void _Process(double _delta) {
    float orbitAngle = (Time.GetTicksMsec() / 1000.0f % Speed) * 2.0f * 3.14159f;
    float offset_x = _orbitRadius * Mathf.Cos(orbitAngle);
    float offset_y = _orbitRadius * Mathf.Sin(orbitAngle);

    var new_position = OrbitNode.GlobalPosition;
    new_position.X += offset_x;
    new_position.Z += offset_y;

    GlobalPosition = new_position;
  }

  public override void _Input(InputEvent ev_) {
    if (!(ev_ is InputEventKey) || !ev_.IsPressed()) {
      return;
    }
    
    var ev = ev_ as InputEventKey;
    if (ev.Keycode == Key.Key1) {
      EventAudio.Instance.Play3D("hit", this);
    }
            
    if (ev.Keycode == Key.Key2) {
      EventAudio.Instance.Play3D("hit+large", this);
    }

    if (ev.Keycode == Key.Key3) {
      EventAudio.Instance.Play3D("hit+nonexistent", this);
    }

    if (ev.Keycode == Key.Key4) {
      EventAudio.Instance.Play3D("random_shoot", this);
    }
        
    if (ev.Keycode == Key.Key5) {
      if (_loopEmitter != null) {
        EventAudio.Instance.Stop(_loopEmitter);
        _loopEmitter = null;
      } else {
        _loopEmitter = EventAudio.Instance.Play3D("loop", this);
      }
    }
  }
}
