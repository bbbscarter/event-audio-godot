using Godot;

public partial class EventAudio : Node {
  static private EventAudio _instance;
  private GodotObject _eventAudio;
  private Callable _play3DMethod;
  private Callable _play2DMethod;
  private Callable _stopMethod;

  // Simple 'handle' class for managing Godot audio emitters.
  public class EventAudioEmitter {
    public GodotObject Emitter;

    public EventAudioEmitter(GodotObject emitter) {
      Emitter = emitter;
    }
  }

  public override void _Ready() {
    base._Ready();
    _eventAudio = GetParent().GetNode("EventAudio");
    _play3DMethod = _eventAudio.Get("play_3d").AsCallable();
    _play2DMethod = _eventAudio.Get("play_2d").AsCallable();
    _stopMethod = _eventAudio.Get("stop").AsCallable();
    _instance = this;
  }

  public static EventAudio Instance {
    get {
      return _instance;
    }
  }

  public EventAudioEmitter Play2D(string trigger, Node3D source) {
    var result = _play2DMethod.Call(trigger, source);
    var godotEmitter = result.AsGodotObject();
    if (godotEmitter != null) {
      return new EventAudioEmitter(godotEmitter);
    }
    return null;
  }

  public EventAudioEmitter Play3D(string trigger, Node3D source) {
    var result = _play3DMethod.Call(trigger, source);
    var godotEmitter = result.AsGodotObject();
    if (godotEmitter != null) {
      return new EventAudioEmitter(godotEmitter);
    }
    return null;
  }

  public void Stop(EventAudioEmitter emitter) {
    _stopMethod.Call(emitter.Emitter);
  }
}
