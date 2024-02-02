using Godot;
using System;

public class RunwayTimer : Timer
{
    private Label _timerText;
    private TimeSpan _startTime;
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
        _startTime = TimeSpan.Zero;
        base.Start();
    }
    const string timerFormat = "Total time: {0}";
    public void _onTimerTick()
    {
        _startTime += TimeSpan.FromSeconds(1);
        _timerText.Text = string.Format(timerFormat, _startTime.ToString("mm':'ss"));
    }
}
