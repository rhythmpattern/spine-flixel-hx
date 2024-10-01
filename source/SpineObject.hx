import flixel.FlxG;
import flixel.FlxSprite;
import flixelspine.FlxSpine;
import spine.SkeletonData;

class SpineObject extends FlxSpine {
    public function new(skeletonData:SkeletonData, x:Float = 0, y:Float = 0)
        {
            
            super(skeletonData, x, y);
            skeleton.scaleY *= -1;
            //stateData.setMixByName("walk", "jump", 0.2);
            //stateData.setMixByName("jump", "walk", 0.4);
            //stateData.setMixByName("jump", "jump", 0.2);
           
            state.setAnimationByName(0, "animation", true);
        }

        override public function update(elapsed:Float):Void
        {
            
            super.update(elapsed);
        }
}