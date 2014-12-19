package oven.plugins;

import oven.Oven;
import oven.FileData;
import oven.FilesMap;

/**
 * ...
 * @author leshido
 */

class YamlParser implements IPlugin {

	private var _files:FilesMap;
	
	private var frontMatterSelector:EReg;
	private var keyValSplitter:EReg;
	private var newLineCatcher:EReg;

	public function init(?data:Dynamic):Void {
		frontMatterSelector = ~/^---+$\n+((\w+\s*:\s*.*\n+)+)^---+$\n*/m;
		keyValSplitter = ~/\s*:\s*/;
		newLineCatcher = ~/\n+/g;
	}

	public function run():Void {

		_files = Oven.getFiles();
		for (file in _files.files()) {
			parseFile(file);
		}
	}

	private function parseFile(fileName:String):Void
	{
		var fd = _files[fileName];
		var c = fd.content;
		if (c == null) return;
		
		// Check if file contents has front matter
		var match:Bool = frontMatterSelector.match(c);
		if (!match) return;

		// Remove front matter from contents
		fd.content = frontMatterSelector.replace(c, "");

		// Get front matter data
		var dataStr:String = frontMatterSelector.matched(1);
		dataStr = newLineCatcher.replace(dataStr, "\n");
		var data = newLineCatcher.split(dataStr);
		// Remove trailing data entry
		data.pop();

		// Add front matter data to file data
		while (data.length > 0)
		{
			// TODO: Guess value type (Int, Float, String, Bool)
			var kv:Array<String> = keyValSplitter.split(data.shift());
			Reflect.setField(fd, kv[0], kv[1]);
		}
	}
}
