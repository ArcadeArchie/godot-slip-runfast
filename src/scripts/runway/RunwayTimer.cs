using Godot;
using System;

public class RunwayTimer : Timer
{
    private Label _timerText;
    public TimeSpan CurrentTime { get; private set; }

    [Signal]
    delegate void Ticked(int minutes, int seconds);
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        this.Connect("timeout", this, nameof(_onTimerTick));
        _timerText = GetNode<Label>("Canvas/TimeText");
    }

    public void Start()
    {
        CurrentTime = TimeSpan.Zero;
        base.Start();
    }
    const string timerFormat = "Total time: {0}";
    public void _onTimerTick()
    {
        CurrentTime += TimeSpan.FromSeconds(1);
        _timerText.Text = string.Format(timerFormat, CurrentTime.ToString("mm':'ss"));
        // AddUserSignal(nameof(Ticked), CurrentTime.Minutes, CurrentTime.Seconds);
        EmitSignal(nameof(Ticked), CurrentTime.Minutes, CurrentTime.Seconds);
    }
}
