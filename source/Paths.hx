package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class Paths
{
	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}
}
