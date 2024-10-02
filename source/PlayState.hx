package;
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
		add(spineSprite);

	}

	override public function update(elapsed:Float)
	{
		
		super.update(elapsed);
	}
}
