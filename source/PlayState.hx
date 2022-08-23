package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var hello:FlxText;
	private var rows:Int = 8;
	private var cols:Int = 10;
	private var item:BoardItem;
	private var items:Array<BoardItem>;
	private var tile:BoardTile;
	private var tiles:Array<Array<Int>>;

	private var GRID_X:Int = 290;
	private var GRID_Y:Int = 125;
	private var ITEM_SIZE:Int = 60;
	private var TOTAL_ITEMS:Int = 5;

	private var selectedFrame:FlxSprite;
	private var pickedRow:Int;
	private var pickedCol:Int;

	// private var types:Array<String> = ["Fire", "Leaf", "Earth", "Water", "Star"];

	override public function create()
	{
		super.create();
		// hello = new FlxText(FlxG.width / 2, 10, 0, "Hello World!", 24, false);
		// add(hello);

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(bg);

		initGrid(rows, cols);

		selectedFrame = new FlxSprite(0, 0).loadGraphic(Paths.image('selectedTile'));
		add(selectedFrame);
		selectedFrame.alpha = 0;

		pickedRow = -1;
		pickedCol = -1;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function initGrid(row:Int, col:Int)
	{
		tiles = new Array();
		for (c in 0...col)
		{
			tiles.push(new Array());
			for (r in 0...row)
			{
				var tile = new BoardTile(GRID_X + c * (ITEM_SIZE + 10), GRID_Y + r * (ITEM_SIZE + 10));
				// tile.x = GRID_X + c * (ITEM_SIZE + 10);
				// tile.y = GRID_Y + r * (ITEM_SIZE + 10);
				tile.row = r;
				tile.col = c;
				tiles[c].push(Math.floor(Math.random() * 5));
				add(tile);
				FlxMouseEventManager.add(tile, onTileMouseDown);
			}
		}

		items = new Array();
		for (c in 0...col)
		{
			var xs:Int = 10; // Spacing between columns
			// c != 0 ? xs = 10 : xs = 0;
			for (r in 0...row)
			{
				while (isChain(r, c))
				{
					tiles[c][r] = Math.floor(Math.random() * 5);
				}

				var ys:Int = 10; // Spacing between rows
				// r != 0 ? ys = 10 : ys = 0;
				var index:Int = tiles[c][r];
				var item:BoardItem = new BoardItem(GRID_X + 5 + xs * c + c * ITEM_SIZE, GRID_Y + 5 + ys * r + r * ITEM_SIZE, index);
				item.name = Std.string(r) + " " + Std.string(c);
				items.push(item);
				add(item);
			}
		}
	}

	function onTileMouseDown(tile:BoardTile)
	{
		if ((pickedRow == tile.row) && (pickedCol == tile.col))
		{
			pickedRow = -1;
			pickedCol = -1;
			selectedFrame.alpha = 0;
			return;
		}

		if (!isNextTo(tile.row, tile.col, pickedRow, pickedCol))
		{
			pickedRow = tile.row;
			pickedCol = tile.col;
			selectedFrame.x = tile.x;
			selectedFrame.y = tile.y;
			selectedFrame.alpha = 1;
		}
		else
		{
			swapItems(pickedRow, pickedCol, tile.row, tile.col);
			pickedRow = -1;
			pickedCol = -1;
			selectedFrame.alpha = 0;
		}
	}

	function isNextTo(row:Int, col:Int, prow:Int, pcol:Int)
	{
		return Math.abs(row - prow) + Math.abs(col - pcol) == 1;
	}

	function getItemPos(row:Int, col:Int):Int
	{
		var position:Int = -1;
		for (p in 0...items.length)
		{
			if (items[p].name == Std.string(row) + " " + Std.string(col))
			{
				position = p;
			}
		}
		return position;
	}

	function swapItems(row1:Int, col1:Int, row2:Int, col2:Int, ?fromCompletedSwap:Bool = false)
	{
		if (row1 == -1 || row2 == -1 || col1 == -1 || col2 == -1)
		{
			return;
		}

		var options = {};

		if (!fromCompletedSwap)
		{
			options = {
				type: ONESHOT,
				onComplete: onSwapCompleted.bind(_, row1, col1, row2, col2)
			}
		}

		var p1:Int = getItemPos(row1, col1);
		var p2:Int = getItemPos(row2, col2);
		var time:Float = 0.2;

		if (col1 > col2)
		{
			FlxTween.tween(items[p1], {x: items[p1].x - 70}, time, options);
			FlxTween.tween(items[p2], {x: items[p2].x + 70}, time);
		}
		else if (col1 < col2)
		{
			FlxTween.tween(items[p1], {x: items[p1].x + 70}, time, options);
			FlxTween.tween(items[p2], {x: items[p2].x - 70}, time);
		}
		else if (row1 > row2)
		{
			FlxTween.tween(items[p1], {y: items[p1].y - 70}, time, options);
			FlxTween.tween(items[p2], {y: items[p2].y + 70}, time);
		}
		else if (row1 < row2)
		{
			FlxTween.tween(items[p1], {y: items[p1].y + 70}, time, options);
			FlxTween.tween(items[p2], {y: items[p2].y - 70}, time);
		}
		items[p1].name = Std.string(row2) + " " + Std.string(col2);
		items[p2].name = Std.string(row1) + " " + Std.string(col1);
		swapTiles(row1, col1, row2, col2);
	}

	function swapTiles(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		var tmp:Int = tiles[col1][row1];
		tiles[col1][row1] = tiles[col2][row2];
		tiles[col2][row2] = tmp;
	}

	function evalTiles(idx:Int, row:Int, col:Int)
	{
		if (col > cols - 1 || col < 0)
			return false;
		if (row > rows - 1 || row < 0)
			return false;

		return idx == tiles[col][row];
	}

	function doChain(row:Int, col:Int, colChain:Bool = true):Int
	{
		var current:Int = tiles[col][row];
		var chain:Int = 1;
		var tmp:Int;

		if (colChain)
		{
			tmp = row;
			while (evalTiles(current, tmp - 1, col))
			{
				tmp--;
				chain++;
			}
			tmp = row;
			while (evalTiles(current, tmp + 1, col))
			{
				tmp++;
				chain++;
			}
		}
		else
		{
			tmp = col;
			while (evalTiles(current, row, tmp - 1))
			{
				tmp--;
				chain++;
			}
			tmp = col;
			while (evalTiles(current, row, tmp + 1))
			{
				tmp++;
				chain++;
			}
		}
		return chain;
	}

	function isChain(row:Int, col:Int):Bool
	{
		return doChain(row, col, false) > 2 || doChain(row, col) > 2;
	}

	function onSwapCompleted(tween:FlxTween, row1:Int, col1:Int, row2:Int, col2:Int)
	{
		if (isChain(row1, col1) || isChain(row2, col2))
		{
			if (isChain(row1, col1))
			{
				trace("Match #1!");
			}
			if (isChain(row2, col2))
			{
				trace("Match #2!");
			}
		}
		else
		{
			swapItems(row1, col1, row2, col2, true);
		}
	}
}
