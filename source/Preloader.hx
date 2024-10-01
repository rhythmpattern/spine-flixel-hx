package;

import flixel.FlxG;
import flixel.system.FlxBasePreloader;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * This is the Default HaxeFlixel Themed Preloader
 * You can make your own style of Preloader by extending `FlxBasePreloader` and using this class as an example.
 * To use your Preloader, simply change `Project.xml` to say: `<app preloader="class.path.MyPreloader" />`
 */
class Preloader extends FlxBasePreloader
{
	var _buffer:Sprite;
	var _bmpBar:Bitmap;
	var _text:TextField;
	var _logo:Sprite;
	var _logoGlow:Sprite;

	/**
	 * Initialize your preloader here.
	 *
	 * ```haxe
	 * super(0, ["test.com", FlxPreloaderBase.LOCAL]); // example of site-locking
	 * super(10); // example of long delay (10 seconds)
	 * ```
	 */
	override public function new(MinDisplayTime:Float = 0, ?AllowedURLs:Array<String>):Void
	{
		super(MinDisplayTime, AllowedURLs);
	}

	/**
	 * This class is called as soon as the FlxPreloaderBase has finished initializing.
	 * Override it to draw all your graphics and things - make sure you also override update
	 * Make sure you call super.create()
	 */
	override function create():Void
	{
		
		super.create();
	}

	/**
	 * Cleanup your objects!
	 * Make sure you call super.destroy()!
	 */
	override function destroy():Void
	{
		if (_buffer != null)
		{
			removeChild(_buffer);
		}
		_buffer = null;
		_bmpBar = null;
		_text = null;
		_logo = null;
		_logoGlow = null;
		super.destroy();
	}

	/**
	 * Update is called every frame, passing the current percent loaded. Use this to change your loading bar or whatever.
	 * @param	Percent	The percentage that the project is loaded
	 */
	override public function update(Percent:Float):Void
	{
		
	}
}
