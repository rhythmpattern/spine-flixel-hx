import openfl.utils.Assets;

class FlixelFileHandle implements spine.support.files.FileHandle 
{
	public var path:String = ""; // TODO: actually use it...
	
	private var data:String;

	public function new(path:String, data:String = null)
	{
		if (path == null)
			path = "";
		
		this.path = path;

		if (data == null)
			data = Assets.getText(path);
		
		this.data = data;
	}

	public function getContent():String
	{
		return data;
	}
}