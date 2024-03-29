using Godot;
using System;

public class Runway : Node
{
    private Timer _timer;
    private Node _playerData;
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.
 public override void _Ready()
    {
        _playerData = GetNode("/root/player_data");
        _timer = GetNode<Timer>("HUD_TotalTime");
        _timer.Connect("Ticked", this, nameof(OnTick));
        _timer.Start();
    }

        private void OnTick(int minutes, int seconds)
    {
        _playerData.Set("minutes", minutes);
        _playerData.Set("seconds", seconds);
    }

    //  // Called every frame. 'delta' is the elapsed time since the previous frame.
    //  public override void _Process(float delta)
    //  {
    //      
    //  }
//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
