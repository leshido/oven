package oven;
import haxe.io.Path;

/**
 * ...
 * @author leshido
 */
@:forward(set, get, remove, exists, iterator)
abstract FilesMap(Map<String,FileData>)
{

	inline public function new() {
		this = new Map<String, FileData>();
	}

	public function renameFile(path:String, newName:String, ?newExt:String)
	{
		var file = this.get(path);
		if (file == null || newName == null) return;
		if (newExt == null) newExt = Path.extension(path);
		var newPath = Path.join( [Path.directory(path), Path.withExtension(newName, newExt)] );
		this.set(newPath, file);
		this.remove(path);
	}

	public function moveDir(path:String, newPath:String)
	{
		var file = this.get(path);
		if (file == null) return;
		var newPath = Path.join( [newPath, Path.withoutDirectory(path)] );
		this.set(newPath, file);
		this.remove(path);
	}

	public function changeExt(path:String, newExt:String)
	{
		var file = this.get(path);
		if (file == null) return;
		var newPath = Path.withExtension(Path.withoutExtension(path), newExt);
		this.set(newPath, file);
		this.remove(path);
	}

	public function listDir(dirPath:String, ?includeSubDirs:Bool = false):Array<String>
	{
		var ret:Array<String> = [];
		dirPath = Path.normalize(dirPath);
		dirPath = Path.removeTrailingSlashes(dirPath);
		var testEquals:String -> String -> Bool;
		if (includeSubDirs)
		{
			testEquals = function(path1:String, path2:String) { return path1.substr(0, path2.length) == path2; };
		}
		else
		{
			testEquals = function(path1:String, path2:String) { return Path.directory(path1) ==  path2; };
		}

		for (path in this.keys())
		{
			if (testEquals(path, dirPath))
			{
				ret.push(path);
			}
		}

		return ret;
	}
	
	public function count():Int
	{
		var ret:Int = 0;
		for (i in this.keys())
		{
			ret++;
		}
		return ret;
	}

	public function getAllByFiletype(exts:Array<String>):Array<String>
	{
		var ret:Array<String> = [];
		for (path in this.keys())
		{
			var ext:String = Path.extension(path);
			if (exts.indexOf(ext) != -1)
			{
				ret.push(path);
			}
		}
		return ret;
	}

	public function getPath(fd:FileData):String
	{
		for (path in this.keys())
		{
			var file = this.get(path);
			if (file == fd)
			{
				return path;
			}
		}
		return null;
	}

	public function getFileName(path:String):String
	{
		path = Path.withoutDirectory(path);
		path = Path.withoutExtension(path);
		return path;
	}

	public function files()
	{
		return this.keys();
	}

	@:arrayAccess
	public inline function get(key:String)
	{
		return this.get(key);
	}

	@:arrayAccess
	@:noCompletion
	public inline function arrayWrite(k:String, v:FileData):FileData
	{
		this.set(k, v);
		return v;
	}


}
