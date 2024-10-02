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
		
		spineSprite = new SpineSprite(FlxSpine.readSkeletonData("spineboy-pro", "spineboy-pro", "assets", 1));
		//spineSprite.skeleton.findIkConstraint("crosshair");
		spineSprite.skeleton.x = 0;
		spineSprite.skeleton.y = 0; 
		spineSprite.x = 600;
		spineSprite.y = 600;
		spineSprite.antialiasing = true;
		
		add(spineSprite);

	}

	override public function update(elapsed:Float)
	{
		
		super.update(elapsed);
	}
}
