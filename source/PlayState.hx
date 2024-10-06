package;

import flixel.FlxState;
import flixelspine.FlxSpine;
import spine.*;
class PlayState extends FlxState
{
	var spineboySkeletonData:SkeletonData;
	var spinestate:AnimationState;
	var spineSprite:SpineSprite;
	override public function create()
	{
		super.create();
		
		spineSprite = new SpineSprite(FlxSpine.readSkeletonData("chibi-stickers-pro", "chibi-stickers-pro", "assets", 1));
		
		//Getting ik constraints for controlling spines.
		//spineSprite.skeleton.findIkConstraint("crosshair");

		spineSprite.skeleton.x = 0;
		
		spineSprite.skeleton.y = 0; 
		spineSprite.x = 600;
		spineSprite.y = 800; 
		spineSprite.antialiasing = true;
		
		add(spineSprite);

	}

	override public function update(elapsed:Float)
	{
		
		super.update(elapsed);
	}
}
