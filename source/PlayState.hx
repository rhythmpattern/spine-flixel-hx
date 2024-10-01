package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixelspine.FlxSpine;
import flixelspine.texture.FlixelTextureLoader;
import openfl.utils.Assets;
import spine.*;
import spine.attachments.AtlasAttachmentLoader;
import spine.support.graphics.TextureAtlas;
import spine.support.utils.JsonReader;
class PlayState extends FlxState
{
	var spineboySkeletonData:SkeletonData;
	var spinestate:AnimationState;
	var spineSprite:SpineObject;
	override public function create()
	{
		super.create();
		
		spineSprite = new SpineObject(FlxSpine.readSkeletonData("spineboy-pro", "spineboy-pro", "assets", 1));
		spineSprite.skeleton.findIkConstraint("crosshair");
		spineSprite.skeleton.x = 0;
		spineSprite.skeleton.y = 0;
		spineSprite.x = 300;
		spineSprite.y = 600;
		spineSprite.antialiasing = true;
		add(spineSprite);

	}

	override public function update(elapsed:Float)
	{
		
		super.update(elapsed);
	}
}
