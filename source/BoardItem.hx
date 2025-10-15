package;

import flixel.FlxG;
import flixel.FlxSprite;

class BoardItem extends FlxSprite
{
	public var type:String;
	public var name:String;
	public var row:Int;
	public var col:Int;
	public var needRefresh:Bool = false;

	public function new(x, y, type)
	{
		super();
		this.x = x;
		this.y = y;
		this.type = type;
		setType(type);
	}

	public function setType(type)
	{
		var file:String = Paths.image('item' + type);
		loadGraphic(file);
	}

	public function setName(row:Int, col:Int)
	{
		this.row = row;
		this.col = col;
		name = Std.string(row) + " " + Std.string(col);
	}
}
