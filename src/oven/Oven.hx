package oven;

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
class Oven
{
	
	static private var _files:FilesHolder;
	
	static function main() 
	{
		_files = new FilesHolder();
		
		Sys.setCwd("test");
		Sys.setCwd("project");
		storeFiles("./");
		Sys.setCwd("../");
		// Call Plugins
		callPlugin();
		saveFiles();
	}
	
	private static function parseJson()
	{
		
	}
	
	private static function saveFiles()
	{
		// TODO: clear export directory
		FileSystem.createDirectory("export");
		for (fileName in _files.files())
		{
			var f:String = Path.join(["export", fileName]);
			
			// Create missing directories
			var pathArr:Array<String> = Path.directory(f).split("/");
			for (i in 0...pathArr.length)
			{
				var path:String = Path.join(pathArr.slice(0, i + 1));
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
		var files:Array<String> = FileSystem.readDirectory(dir);
		for (file in files)
		{
			file = Path.join([dir, file]);
			if (FileSystem.isDirectory(file))
			{
				storeFiles(file);
				continue;
			}
			
			var fd:FileData = new FileData();
			fd.content = File.getContent(file);
			_files.set(file, fd);
		}
	}
	
	private static function callPlugin()
	{
		__includePlugins();
		
		var json:Dynamic = Json.parse(haxe.Resource.getString("config"));
		var plugins:Array<Dynamic> = cast json.plugins;
		for (pluginPath in plugins)
		{
			Sys.println("Starting plugin: " + pluginPath);
			var pluginClass:Dynamic = Type.resolveClass(pluginPath);
			var plugin:IPlugin = Type.createEmptyInstance(pluginClass);
			plugin.init(null); // TODO: pass data
			if (plugin.runnable()) {
				plugin.run();
			}
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
	
	public static function getFiles():FilesHolder
	{
		return _files;
	}
	
	
	macro static function __includePlugins()
	{
		var json:Dynamic = Json.parse(haxe.Resource.getString("config"));
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