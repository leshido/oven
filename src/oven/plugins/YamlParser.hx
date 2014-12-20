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

	private var floatCheck:EReg;
	private var intCheck:EReg;
	private var trueVals:Array<String>;
	private var falseVals:Array<String>;


	public function init(?data:Dynamic):Void {
		frontMatterSelector = ~/^---+$\n+((\w+\s*:\s*.*\n+)+)^---+$\n*/m;
		keyValSplitter = ~/\s*:\s*/;
		newLineCatcher = ~/\n+/g;

		floatCheck = ~/^[0-9]+\.[0-9]+$/;
		intCheck = ~/^[0-9]+$/;
		trueVals = ["true", "yes", "on", "y"];
		falseVals = ["false", "no", "off", "n"];
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
		var data = newLineCatcher.split(dataStr);
		// Remove trailing data entry
		data.pop();

		// Add front matter data to file data
		while (data.length > 0)
		{
			var kv:Array<String> = keyValSplitter.split(data.shift());
			// Assume type of value (Int, Float, Bool, String)
			var val = autoParseType(kv[1]);
			Reflect.setField(fd, kv[0], val);
		}
	}

	private function autoParseType(str:String):Dynamic
	{
		if (intCheck.match(str))
		{
			return Std.parseInt(str);
		}
		else if (floatCheck.match(str))
		{
			return Std.parseFloat(str);
		}
		else
		{
			var lowerStr:String = str.toLowerCase();
			if (trueVals.indexOf(lowerStr) != -1)
			{
				return true;
			}
			else if (falseVals.indexOf(lowerStr) != -1)
			{
				return false;
			}
		}

		return str;
	}
}
