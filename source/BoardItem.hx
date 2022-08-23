package;

import flixel.FlxG;
import flixel.FlxSprite;

class BoardItem extends FlxSprite
{
	var type:Int;
	var types:Array<String> = ["Fire", "Leaf", "Earth", "Water", "Star"];

	// var colors:Array<Int> = [0xFF0000, 0x00FF00, 0xFFDD00, 0x0000FF, 0x9900FF];
	public var name(default, default):String;

	public function new(x, y, type)
	{
		super();
		this.x = x;
		this.y = y;
		makeItem(type);
	}

	public function makeItem(type)
	{
		var file:String = Paths.image('item' + types[type]);
		loadGraphic(file);
		// var typeNum:Int = FlxG.random.int(0, 4);
		// type = types[typeNum];
		// color = colors[FlxG.random.int(0, 4)];
	}
}
