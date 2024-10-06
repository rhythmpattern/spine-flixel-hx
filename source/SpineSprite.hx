import spine.Skin;
import flixel.FlxG;
import flixel.FlxSprite;
import flixelspine.FlxSpine;
import spine.SkeletonData;

class SpineSprite extends FlxSpine {
    public function new(skeletonData:SkeletonData, x:Float = 0, y:Float = 0)
        {
            
            super(skeletonData, x, y);
            skeleton.scaleY *= -1;
            // stateData.setMixByName("walk", "jump", 0.2);
            // stateData.setMixByName("jump", "walk", 0.4);
            // stateData.setMixByName("jump", "jump", 0.2);
            skeleton.setSkinByName("erikari");
            //------Skins Example. mix-and-match-pro -----------//
            // var skin:Skin = skeleton.data.findSkin("skin-base");
            // skin.addSkin(skeleton.data.findSkin("accessories/backpack"));
            // skin.addSkin(skeleton.data.findSkin("nose/short"));
            // skin.addSkin(skeleton.data.findSkin("eyelids/girly"));
            // skin.addSkin(skeleton.data.findSkin("eyes/violet"));
            // skin.addSkin(skeleton.data.findSkin("hair/brown"));
            // skin.addSkin(skeleton.data.findSkin("clothes/hoodie-orange"));
            // skin.addSkin(skeleton.data.findSkin("legs/pants-jeans"));
            // skin.addSkin(skeleton.data.findSkin("accessories/bag"));
            // skin.addSkin(skeleton.data.findSkin("accessories/hat-red-yellow"));
            // skeleton.setSkin(skin);

            // ---Set setup full skin -------//
           //skeleton.setSkinByName("full-skins/girl");

            state.setAnimationByName(0, "emotes/wave", true);
        }

        override public function update(elapsed:Float):Void
        {
            
            super.update(elapsed);
        }
}