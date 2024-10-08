package flixelspine;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxStrip;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixelspine.texture.FlixelTextureLoader;
import openfl.Assets;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import spine.AnimationState;
import spine.AnimationStateData;
import spine.Skeleton;
import spine.SkeletonData;
import spine.SkeletonJson;
import spine.Slot;
import spine.attachments.AtlasAttachmentLoader;
import spine.attachments.MeshAttachment;
import spine.attachments.RegionAttachment;
import spine.support.graphics.TextureAtlas;
import spine.support.utils.JsonReader;

/**
 * A Sprite that can play animations exported by Spine (http://esotericsoftware.com/)
 *
 * @author Big thanks to the work on spinehx by nitrobin (https://github.com/nitrobin/spinehx).
 * HaxeFlixel Port by: Sasha (Beeblerox), Sam Batista (crazysam), Kuris Makku (xraven13)
 *
 * The current version is using https://github.com/bendmorris/spinehaxe
 * since the original lib by nitrobin isn't supported anymore.
 */
class FlxSpine extends FlxSprite
{
	/**
	 * Get Spine animation data (atlas + animation).
	 *
	 * @param	AtlasName		The name of the atlas data files exported from Spine (.atlas and .png).
	 * @param	AnimationName	The name of the animation data file exported from Spine (.json).
	 * @param	DataPath		The directory these files are located at
	 * @param	Scale			Animation scale
	 */
	public static function readSkeletonData(AtlasName:String, AnimationName:String, DataPath:String, Scale:Float = 1):SkeletonData
	{
		if (DataPath.lastIndexOf("/") < 0)
			DataPath += "/"; // append / at the end of the folder path
		var spineAtlas:TextureAtlas = new TextureAtlas(Assets.getText(DataPath + AtlasName + ".atlas"), new FlixelTextureLoader(DataPath));
		var json:SkeletonJson = new SkeletonJson(new AtlasAttachmentLoader(spineAtlas));
		json.scale = Scale;
		var spineboyReader:JsonReader = new JsonReader();
		var skeletonData:SkeletonData = json.readSkeletonData(spineboyReader.parse(new FlixelFileHandle(DataPath + AnimationName + ".json")));
		return skeletonData;
	}

	public var skeleton(default, null):Skeleton;
	public var skeletonData(default, null):SkeletonData;
	public var state(default, null):AnimationState;
	public var stateData(default, null):AnimationStateData;

	/**
	 * Helper FlxObject, which you can use for colliding with other flixel objects.
	 * Collider have additional offsetX and offsetY properties which helps you to adjust hitbox.
	 * Change of position of this sprite causes change of collider's position and vice versa.
	 * But you should apply velocity and acceleration to collider rather than to this spine sprite.
	 */
	public var collider(default, null):FlxSpineCollider;

	public var renderMeshes:Bool = false;

	var _tempVertices:Array<Float>;
	var _quadTriangles:Array<Int>;
	var _regionWrappers = new Map<RegionAttachment, FlxSprite>();

	/**
	 * Instantiate a new Spine Sprite.
	 * @param	skeletonData	Animation data from Spine (.json .skel .png), get it like this: FlxSpineSprite.readSkeletonData( "mySpriteData", "assets/" );
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	Width			The maximum width of this sprite (avoid very large sprites since they are performance intensive).
	 * @param	Height			The maximum height of this sprite (avoid very large sprites since they are performance intensive).
	 * @param	OffsetX			The X offset of the sprite.
	 * @param	OffsetY			The Y offset of the sprite.
	 * @param	renderMeshes	If true, then graphic will be rendered with drawTriangles(), if false (by default), then it will be rendered with drawTiles().
	 */
	public function new(skeletonData:SkeletonData, X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0, OffsetX:Float = 0, OffsetY:Float = 0,
			renderMeshes:Bool = false)
	{
		super(X, Y);
		
		width = Width;
		height = Height;

		this.skeletonData = skeletonData;

		stateData = new AnimationStateData(skeletonData);
		state = new AnimationState(stateData);

		skeleton = new Skeleton(skeletonData);
		skeleton.updateWorldTransform();

		flipX = false;
		flipY = false;

		collider = new FlxSpineCollider(this, X, Y, Width, Height, OffsetX, OffsetY);

		var drawOrder:Array<Slot> = skeleton.drawOrder;
		for (slot in drawOrder)
		{
			if (slot.attachment == null)
			{
				continue;
			}

			if ((slot.attachment is MeshAttachment))
			{
				renderMeshes = true;
				break;
			}
		}

		this.renderMeshes = renderMeshes;

		_tempVertices = new Array<Float>();

		_quadTriangles = new Array<Int>();
		_quadTriangles[0] = 0; // = Vector.fromArray([0, 1, 2, 2, 3, 0]);
		_quadTriangles[1] = 1;
		_quadTriangles[2] = 2;
		_quadTriangles[3] = 2;
		_quadTriangles[4] = 3;
		_quadTriangles[5] = 0;
	}

	override public function destroy():Void
	{
		collider = FlxDestroyUtil.destroy(collider);

		skeletonData = null;
		skeleton = null;
		state = null;
		stateData = null;

		_tempVertices = null;
		_quadTriangles = null;

		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		skeleton.update(elapsed);
		state.update(elapsed);
		state.apply(skeleton);
		skeleton.updateWorldTransform();
	}

	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
		if (alpha == 0)
			return;

		renderWithTriangles();
		
		collider.draw();
	}

	function renderWithTriangles():Void
	{
		var drawOrder:Array<Slot> = skeleton.drawOrder;
		var n:Int = drawOrder.length;
		var graph:FlxGraphic = null;
		var wrapper:FlxStrip;
		var worldVertices:Array<Float> = _tempVertices;
		var triangles:Array<Int> = null;
		var uvtData:Array<Float> = null;
		var verticesLength:Int = 0;
		var numVertices:Int;

		var r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 0;
		var wrapperColor:Int;

		for (i in 0...n)
		{
			var slot:Slot = drawOrder[i];
			if (slot.attachment != null)
			{
				wrapper = null;

				if ((slot.attachment is RegionAttachment))
				{
					var region:RegionAttachment = cast slot.attachment;
					verticesLength = 8;
					region.computeWorldVertices(slot.bone, worldVertices,0,2);
					uvtData = region.getUVs();
					triangles = _quadTriangles;

					if (_regionWrappers.exists(region))
					{
						wrapper = cast _regionWrappers[region];
					}
					else
					{
						var atlasRegion:AtlasRegion = cast region.getRegion(); //cast region.rendererObject;
						
						var graphic:FlxGraphicAsset = cast atlasRegion.page.rendererObject;// rendererObject;// .page.rendererObject;
						var bitmapData:BitmapData = cast(atlasRegion.page.rendererObject, BitmapData);
						wrapper = new FlxStrip(0, 0, bitmapData);
						_regionWrappers[region] = wrapper;
					}

					r = region.getColor().r; 
					g = region.getColor().g;
					b = region.getColor().b;
					a = region.getColor().a;
				}
				else if ((slot.attachment is MeshAttachment))
				{
					var mesh:MeshAttachment = cast slot.attachment;
					verticesLength = mesh.getWorldVerticesLength();
					mesh.computeWorldVertices(slot,0,mesh.getWorldVerticesLength(), worldVertices,0,2);
					uvtData = mesh.getUVs();
					triangles = mesh.getTriangles(); //triangles;

					if ((mesh.getRegion().rendererObject is FlxStrip))
					{
						wrapper = cast mesh.getRegion().rendererObject;
					}
					else
					{
						var region:AtlasRegion = cast mesh.getRegion();
						var graphic:FlxGraphicAsset = cast region.page.rendererObject;
						var bitmapData:BitmapData = cast(region.page.rendererObject, BitmapData);
						wrapper = new FlxStrip(0, 0, bitmapData);
						mesh.getRegion().rendererObject = wrapper;
					}

					r = mesh.getColor().r;
					g = mesh.getColor().g;
					b = mesh.getColor().b;
					a = mesh.getColor().a;
				}
				if (wrapper != null)
				{
					wrapper.x = 0;
					wrapper.y = 0;
					wrapper._cameras = _cameras;

					#if (flash || openfl >= "4.0.0")
					wrapper.vertices.length = verticesLength;
					for (i in 0...verticesLength)
					{
						wrapper.vertices[i] = worldVertices[i];
					}
					#else
					if (worldVertices.length - verticesLength > 0)
					{
						worldVertices.splice(verticesLength, worldVertices.length - verticesLength);
					}

					wrapper.vertices = worldVertices;
					#end

					wrapper.indices = Vector.ofArray(triangles);
					wrapper.uvtData = Vector.ofArray(uvtData);

					wrapperColor = FlxColor.fromRGBFloat(skeleton.getColor().r * slot.getColor().r * r * color.redFloat, skeleton.getColor().g * slot.getColor().g * g * color.greenFloat,
						skeleton.getColor().b * slot.getColor().b * b * color.blueFloat, 1);

					wrapper.color = wrapperColor;
					wrapper.alpha = skeleton.getColor().a * slot.getColor().a * a * alpha;

					wrapper.blend = (slot.data.blendMode == 1) ? BlendMode.ADD : null; //TODO: slot.data.blendMode == ?????
					wrapper.draw();
				}
			}
		}
	}

	override function set_x(NewX:Float):Float
	{
		super.set_x(NewX);

		if (skeleton != null)
		{
			skeleton.x = NewX;

			if (collider != null)
			{
				if (skeleton.scaleX < 0)
					collider.x = skeleton.x - collider.offsetX - width;
				else
					collider.x = skeleton.x + collider.offsetX;
			}
		}

		return NewX;
	}

	override function set_y(NewY:Float):Float
	{
		super.set_y(NewY);

		if (skeleton != null)
		{
			skeleton.y = NewY;

			if (collider != null)
			{
				if (skeleton.scaleY < 0)
					collider.y = skeleton.y + collider.offsetY - height;
				else
					collider.y = skeleton.y - collider.offsetY;
			}
		}

		return NewY;
	}

	override function set_width(Width:Float):Float
	{
		super.set_width(Width);

		if (skeleton != null && collider != null)
			collider.width = Width;

		return Width;
	}

	override function set_height(Height:Float):Float
	{
		super.set_height(Height);

		if (skeleton != null && collider != null)
			collider.height = Height;

		return Height;
	}

	override function set_flipX(value:Bool):Bool
	{
		//skeleton.flipX = value;
		set_x(x);
		return flipX = value;
	}

	override function set_flipY(value:Bool):Bool
	{
		//skeleton.flipY = value;
		set_y(y);
		return flipY = value;
	}
}

class FlxSpineCollider extends FlxObject
{
	public var offsetX(default, set):Float = 0;
	public var offsetY(default, set):Float = 0;

	public var parent(default, null):FlxSpine;

	public function new(Parent:FlxSpine, X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0, OffsetX:Float = 0, OffsetY:Float = 0)
	{
		super(X, Y, Width, Height);
		offsetX = OffsetX;
		offsetY = OffsetY;
		parent = Parent;
	}

	override public function destroy():Void
	{
		parent = null;
		super.destroy();
	}

	override function set_x(NewX:Float):Float
	{
		if (parent != null && x != NewX)
		{
			super.set_x(NewX);

			if (parent.skeleton.scaleX < 0)
				parent.x = NewX + offsetX + width;
			else
				parent.x = NewX - offsetX;
		}
		else
		{
			super.set_x(NewX);
		}

		return NewX;
	}

	override function set_y(NewY:Float):Float
	{
		if (parent != null && y != NewY)
		{
			super.set_y(NewY);

			if (parent.skeleton.scaleY < 0)
				parent.y = NewY - offsetY + height;
			else
				parent.y = NewY + offsetY;
		}
		else
		{
			super.set_y(NewY);
		}

		return NewY;
	}

	override function set_width(Width:Float):Float
	{
		if (parent != null && width != Width)
		{
			super.set_width(Width);
			parent.x = parent.x;
		}
		else
		{
			super.set_width(Width);
		}

		return Width;
	}

	override function set_height(Height:Float):Float
	{
		if (parent != null && height != Height)
		{
			super.set_height(Height);
			parent.y = parent.y;
		}
		else
		{
			super.set_height(Height);
		}

		return Height;
	}

	function set_offsetX(value:Float):Float
	{
		if (parent != null && offsetX != value)
		{
			offsetX = value;
			parent.x = parent.x;
		}
		else
		{
			offsetX = value;
		}

		return value;
	}

	function set_offsetY(value:Float):Float
	{
		if (parent != null && offsetY != value)
		{
			offsetY = value;
			parent.y = parent.y;
		}
		else
		{
			offsetY = value;
		}

		return value;
	}
}
