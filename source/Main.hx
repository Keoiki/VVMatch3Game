package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var startingState:Class<FlxState> = PlayState;
	var zoom:Float = 1;
	var framerate:Int = 60;
	var skipSplash:Bool = true;
	var startFullScreen:Bool = false;

	public function new()
	{
		super();
		startGame();
	}

	private function startGame()
	{
		addChild(new FlxGame(gameWidth, gameHeight, startingState, framerate, framerate, skipSplash, startFullScreen));
		addChild(new FPS(10, 3, 0xFFFFFF));
	}
}
