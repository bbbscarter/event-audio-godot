using Godot;

public partial class EventAudio : Node {
  static private EventAudio _instance;
  private GodotObject _eventAudio;
  private Callable _play3DMethod;
  private Callable _play2DMethod;
  private Callable _stopMethod;

  public override void _Ready() {
    _eventAudio = GetParent().GetNode("EventAudio");
    _play3DMethod = _eventAudio.Get("play_3d").AsCallable();
    _play2DMethod = _eventAudio.Get("play_2d").AsCallable();
    _stopMethod = _eventAudio.Get("stop").AsCallable();
    // GD.Print(_play_3d_call);
    // GDScript gdscript = GD.Load<GDScript>("res://addons/event_audio/event_audio.gd");
    // var instance = gdscript.Call("get_instance");
    // _eventAudio = instance.As<GodotObject>();
    _instance = this;
    base._EnterTree();
  }

  public static EventAudio Instance {
    get {
      return _instance;
    }
  }

  public EventAudioEmitter Play2D(string trigger, Node3D source) {
    // var godotEmitter = _eventAudio.Call("play_2d", trigger, source);
    var result = _play2DMethod.Call(trigger, source);
    var godotEmitter = result.AsGodotObject();
    if (godotEmitter != null) {
      return new EventAudioEmitter(godotEmitter);
    }
    return null;
  }

  public EventAudioEmitter Play3D(string trigger, Node3D source) {
    // var godotEmitter = _eventAudio.Call("play_3d", trigger, source);
    var result = _play3DMethod.Call(trigger, source);
    var godotEmitter = result.AsGodotObject();
    if (godotEmitter != null) {
      return new EventAudioEmitter(godotEmitter);
    }
    return null;
  }

  public void Stop(EventAudioEmitter emitter) {
    // _eventAudio.Call("stop", emitter.Emitter);
    _stopMethod.Call(emitter.Emitter);
  }

  public class EventAudioEmitter {
    public GodotObject Emitter;

    public EventAudioEmitter(GodotObject emitter) {
      Emitter = emitter;
    }
  }
}
