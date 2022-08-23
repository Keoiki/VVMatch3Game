package;

import flixel.FlxSprite;

class BoardTile extends FlxSprite
{
	public var row(default, default):Int;
	public var col(default, default):Int;

	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);

		loadGraphic(Paths.image('tile'));
	}
}
