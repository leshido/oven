package glue;

import haxe.io.Path;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author leshido
 */
class Glue
{
	
	static private var _files:Map<String, FileData>;
	
	static function main() 
	{
		_files = new Map<String, FileData>();
		
		Sys.setCwd("test");
		Sys.setCwd("project");
		storeFiles("./"); // Does this work on PC?
		Sys.setCwd("../");
		// Call Plugins
		callPlugin();
		saveFiles();
		//trace(_files);
	}
	
	private static function parseJson()
	{
		
	}
	
	private static function saveFiles()
	{
		// TODO: clear export directory
		FileSystem.createDirectory("export");
		for (fileName in _files.keys())
		{
			var f = Path.join(["export", fileName]);
			
			// Create missing directories
			var pathArr = Path.directory(f).split("/");
			for (i in 0...pathArr.length)
			{
				var path = Path.join(pathArr.slice(0, i + 1));
				if (!FileSystem.exists(path))
				{
					FileSystem.createDirectory(path);
				}
			}
			
			File.saveContent(f, _files.get(fileName).content);
		}
	}
	
	private static function storeFiles(dir:String)
	{
		var files = FileSystem.readDirectory(dir);
		for (file in files)
		{
			file = Path.join([dir, file]);
			if (FileSystem.isDirectory(file))
			{
				storeFiles(file);
				continue;
			}
			
			var fd = new FileData();
			fd.content = File.getContent(file);
			_files.set(file, fd);
		}
	}
	
	private static function callPlugin()
	{
		__includePlugins();
		
		var json = Json.parse(haxe.Resource.getString("config"));
		var plugins:Array<Dynamic> = cast json.plugins;
		for (pluginPath in plugins)
		{
			Sys.println("Starting plugin: " + pluginPath);
			var pluginClass = Type.resolveClass(pluginPath);
			var plugin = Type.createInstance(pluginClass, []);
			plugin.run();
		}
	}
	
	public static function getData(key:String):Dynamic
	{
		// retrun data
		return null;
	}
	
	public static function setData(key:String, val:Dynamic)
	{
		// set data
	}
	
	public static function getFiles():Map<String, FileData>
	{
		return _files;
	}
	
	
	macro static function __includePlugins()
	{
		var json = Json.parse(haxe.Resource.getString("config"));
		var exprArr:Array<Expr> = [];
		var plugins:Array<Dynamic> = cast json.plugins;
		for (plugin in plugins)
		{
			var expr: Expr = Context.parse(plugin, Context.currentPos());
			exprArr.push(expr);
		}
		
		return macro $b{exprArr};
	}
	
}