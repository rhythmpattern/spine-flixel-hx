package;
import flixel.math.FlxRandom;
import flixel.FlxState;
import flixelspine.FlxSpine;
import spine.*;
class PlayState extends FlxState
{
	var spineboySkeletonData:SkeletonData;
	var spinestate:AnimationState;
	var spineSprite:SpineObject;
	override public function create()
	{
		super.create();
		
		spineSprite = new SpineObject(FlxSpine.readSkeletonData("spineboy-pro", "spineboy-pro", "assets", 1));
		//spineSprite.skeleton.findIkConstraint("crosshair");
		spineSprite.skeleton.x = 0;
		spineSprite.skeleton.y = 0;
		spineSprite.x = 600;
		spineSprite.y = 600;
		spineSprite.antialiasing = true;
		var r = new FlxRandom();
		//Performance test.
		// for (i in 0...100)
		// {
		// 	var sprite = new SpineObject(FlxSpine.readSkeletonData("spineboy-pro", "spineboy-pro", "assets", 1));
		// //spineSprite.skeleton.findIkConstraint("crosshair");
		// sprite.skeleton.x = 0;
		// sprite.skeleton.y = 0;
		// sprite.x = r.int(0,1280);
		// sprite.y = r.int(0,960);
		// sprite.antialiasing = true;
		// add(sprite);
		// }

		add(spineSprite);

	}

	override public function update(elapsed:Float)
	{
		
		super.update(elapsed);
	}
}
