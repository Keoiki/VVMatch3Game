package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class PlayState extends FlxState
{
	var hello:FlxText;
	private var rows:Int = 8;
	private var cols:Int = 10;
	private var item:BoardItem;
	private var items:Array<BoardItem>;
	private var tile:BoardTile;
	private var tiles:Array<Array<Int>>;

	final GRID_X:Int = 290;
	final GRID_Y:Int = 125;
	final ITEM_SIZE:Int = 70;
	final TOTAL_ITEMS:Int = 5;

	private var selectedFrame:FlxSprite;
	private var pickedRow:Int;
	private var pickedCol:Int;

	private var types:Array<String> = ["Fire", "Leaf", "Earth", "Water", "Star"];

	var replenishColums:Array<Int> = [];

	override public function create()
	{
		super.create();
		// hello = new FlxText(FlxG.width / 2, 10, 0, "Hello World!", 24, false);
		// add(hello);

		FlxSprite.defaultAntialiasing = true;

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(bg);

		initGrid(rows, cols);

		selectedFrame = new FlxSprite(0, 0).loadGraphic(Paths.image('selectedFrame'));
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
				var tile = new BoardTile(GRID_X + c * (ITEM_SIZE), GRID_Y + r * (ITEM_SIZE));
				tile.row = r;
				tile.col = c;
				tiles[c].push(FlxG.random.int(0, TOTAL_ITEMS - 1));
				add(tile);
				FlxMouseEvent.add(tile, onTileMouseDown, onTileMouseUp, null, null, false, true, true, [LEFT]);
				// FlxMouseEvent.add(tile, null, , null, null, false, true, true, [RIGHT]);

				FlxTween.tween(tile, {alpha: 0, y: tile.y - 20}, 0.25, {type: FlxTweenType.BACKWARD, startDelay: r * 0.1});
			}
		}

		items = new Array();
		for (c in 0...col)
		{
			for (r in 0...row)
			{
				while (isChain(r, c))
				{
					tiles[c][r] = FlxG.random.int(0, TOTAL_ITEMS - 1);
				}
				var index:Int = tiles[c][r];
				var item:BoardItem = new BoardItem(GRID_X + c * ITEM_SIZE, GRID_Y + r * ITEM_SIZE, types[index]);
				// item.name = Std.string(r) + " " + Std.string(c);
				item.setName(r, c);
				items.push(item);
				add(item);

				FlxTween.tween(item, {alpha: 0, y: GRID_Y - 70}, 0.25, {type: FlxTweenType.BACKWARD, startDelay: r * 0.1});
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
			selectedFrame.x = tile.x - 4;
			selectedFrame.y = tile.y - 4;
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

	function onTileMouseUp(tile:BoardTile)
	{
		trace("Clicked on " + tile.row + ", " + tile.col);
		trace("Tile should have the " + types[tiles[tile.col][tile.row]] + " type");
		var item:BoardItem = items[getItemPos(tile.row, tile.col)];
		if (item?.scale == null)
		{
			trace("ITEM NOT FOUND????????");
			return;
		}
		FlxTween.tween(item, {"scale.x": 2, "scale.y": 2}, 0.2, {type: FlxTweenType.BACKWARD});
	}

	function isNextTo(row:Int, col:Int, prow:Int, pcol:Int):Bool
	{
		return Math.abs(row - prow) + Math.abs(col - pcol) == 1;
	}

	function getItemPos(row:Int, col:Int):Int
	{
		var position:Int = -1;
		for (p in 0...items.length)
		{
			if (items[p].row == row && items[p].col == col)
			{
				position = p;
			}
		}
		return position;
	}

	function getItemPosByName(name:String):Int
	{
		var position:Int = -1;
		for (p in 0...items.length)
		{
			if (items[p].name == name)
			{
				position = p;
			}
		}
		return position;
	}

	function replaceItem(name:String)
	{
		for (p in 0...items.length)
		{
			if (items[p].name == name)
			{
				// items[p].alpha = 0.25;
				items[p].needRefresh = true;
				// items[p].y -= 210;
			}
		}
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

		FlxTween.globalManager.completeTweensOf(items[p1]);
		FlxTween.globalManager.completeTweensOf(items[p2]);

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
		swapItemNames(row1, col1, row2, col2);
		swapTiles(row1, col1, row2, col2);
	}

	function swapTiles(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		var tmp:Int = tiles[col1][row1];
		tiles[col1][row1] = tiles[col2][row2];
		tiles[col2][row2] = tmp;
		trace("SwapTiles");
	}

	function swapItemNames(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		var p1:Int = getItemPos(row1, col1);
		var p2:Int = getItemPos(row2, col2);
		items[p1].setName(row2, col2);
		items[p2].setName(row1, col1);
	}

	function evalTiles(idx:Int, row:Int, col:Int):Bool
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

	function getChain(row:Int, col:Int):Array<String>
	{
		var current:Int = tiles[col][row];
		var chainItems:Array<String> = [];
		var tmp:Int;
		var tmp2:Int;

		chainItems.push(items[getItemPos(row, col)].name);

		if (isColumnChain(row, col))
		{
			tmp = row;
			while (evalTiles(current, tmp - 1, col))
			{
				tmp--;
				chainItems.push(items[getItemPos(tmp, col)].name);
			}
			tmp = row;
			while (evalTiles(current, tmp + 1, col))
			{
				tmp++;
				chainItems.push(items[getItemPos(tmp, col)].name);
			}
		}

		if (isRowChain(row, col))
		{
			tmp2 = col;
			while (evalTiles(current, row, tmp2 - 1))
			{
				tmp2--;
				chainItems.push(items[getItemPos(row, tmp2)].name);
			}
			tmp2 = col;
			while (evalTiles(current, row, tmp2 + 1))
			{
				tmp2++;
				chainItems.push(items[getItemPos(row, tmp2)].name);
			}
		}

		return chainItems;
	}

	function isRowChain(row:Int, col:Int):Bool
	{
		return doChain(row, col, false) > 2;
	}

	function isColumnChain(row:Int, col:Int):Bool
	{
		return doChain(row, col) > 2;
	}

	function isChain(row:Int, col:Int):Bool
	{
		return isRowChain(row, col) || isColumnChain(row, col);
	}

	function onSwapCompleted(tween:FlxTween, row1:Int, col1:Int, row2:Int, col2:Int)
	{
		if (isChain(row1, col1) || isChain(row2, col2))
		{
			if (isChain(row1, col1))
			{
				trace("Match #1!");
				handleChain(row1, col1, isColumnChain(row1, col1));
			}
			if (isChain(row2, col2))
			{
				trace("Match #2!");
				handleChain(row2, col2, isColumnChain(row2, col2));
			}
		}
		else
		{
			swapItems(row1, col1, row2, col2, true);
		}
	}

	function handleChain(row:Int, col:Int, isColumnChain:Bool)
	{
		var itemsToRemove:Array<String> = getChain(row, col);
		itemsToRemove.sort(sortAlphabetic);

		trace("Items to remove: " + itemsToRemove);

		var columnsToShift:Array<Int> = [];

		for (i in 0...itemsToRemove.length)
		{
			trace("Replacing " + itemsToRemove[i]);
			replaceItem(itemsToRemove[i]);

			var item:BoardItem = items[getItemPosByName(itemsToRemove[i])];

			if (!columnsToShift.contains(item.col))
			{
				columnsToShift.push(item.col);
			}
		}

		trace(columnsToShift);

		for (column in 0...columnsToShift.length)
		{
			var highestRow:Int = -1;
			var shift:Int = 0;
			for (_ in 0...itemsToRemove.length)
			{
				var filteredItems:Array<String> = itemsToRemove.filter(function(item:String):Bool
				{
					return item.endsWith(Std.string(columnsToShift[column]));
				});
				highestRow = Std.parseInt(filteredItems[0].split(" ")[0]);
				shift = filteredItems.length;
			}

			trace("Column: " + columnsToShift[column] + ", highestRow: " + highestRow + ", shift: " + shift);

			shiftItemsDown(columnsToShift[column], highestRow, shift);
		}
	}

	function shiftItemsDown(column:Int, highestRow:Int, shift:Int)
	{
		var prevRow:Int = -1;
		var prevCol:Int = -1;
		items.sort(sortByName);
		for (i in 0...items.length)
		{
			var item:BoardItem = items[i];
			// if (item.col == column && item.row < highestRow)
			// {
			// swapTiles(item.row, item.col, item.row + 1, item.col);
			// item.setName(item.row + 1, item.col);
			// FlxTween.tween(item, {y: item.y + ITEM_SIZE * shift}, 0.2);
			// trace("ShiftItemsDown");
			// }

			if (item.needRefresh)
			{
				var newType:Int = FlxG.random.int(0, TOTAL_ITEMS - 1);
				if (item.row == 0) // Refresh in place.
				{
					// This works, don't forget that...
					tiles[item.col][item.row] = newType;
					item.setType(types[newType]);
				}
				else
				{
					// swapTiles(item.row, item.col, item.row - 1, item.col);
					// swapItemNames(item.row, item.col, item.row - 1, item.col);
					// tiles[item.col][item.row - 1] = newType;
					// item.setType(types[newType]);
				}
				trace("Refreshing: " + item.name);
				item.needRefresh = false;
				prevRow = item.row;
				prevCol = item.col;
			}
		}
	}

	function sortAlphabetic(a:String, b:String):Int
	{
		a = a.toUpperCase();
		b = b.toUpperCase();
		if (a < b)
		{
			return -1;
		}
		else if (a > b)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}

	function sortByName(_a:BoardItem, _b:BoardItem):Int
	{
		var a:String = _a.name.toUpperCase();
		var b:String = _b.name.toUpperCase();
		if (a < b)
		{
			return -1;
		}
		else if (a > b)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
}
