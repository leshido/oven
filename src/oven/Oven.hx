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
	// Static instance
	static private var _inst:Oven;

	// Private vars
	private var _files:FilesMap;
	private var _globalConfig:Dynamic;

	static function main()
	{
		_inst = new Oven();
		// TODO: change later? according to command?
		_inst.bake();
	}

	private function new()
	{
		// Initialize
		_files = new FilesMap();
		var json:Dynamic = Json.parse(haxe.Resource.getString("config"));
		_globalConfig = cast json.config;
	}

	private function bake()
	{
		var startingDir:String = Sys.getCwd();

		// Load sources
		Sys.setCwd(_globalConfig.sourcesDir);
		loadSources("./");
		Sys.setCwd(startingDir);

		// Run plugins, bake them goods
		runPlugins();

		// Go to export dir, delete and recreate if exists
		var pathToExport:Array<String> = _globalConfig.exportDir.split("/");
		var exportFolder:String = pathToExport.pop();
		Sys.setCwd(Path.join(pathToExport));
		if (FileSystem.exists(exportFolder))
		{
			recursiveDelete(exportFolder);
		}
		FileSystem.createDirectory(exportFolder);

		// Save baked files to 'export' folder
		exportFiles(exportFolder);
		
	}

	private function exportFiles(exportFolder:String):Void
	{
		for (fileName in _files.files())
		{
			var f:String = Path.join([exportFolder, fileName]);

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

	// Load source filse from 'sources' folder
	private function loadSources(dir:String):Void
	{
		var files:Array<String> = FileSystem.readDirectory(dir);
		for (file in files)
		{
			file = Path.join([dir, file]);
			if (FileSystem.isDirectory(file))
			{
				loadSources(file);
				continue;
			}

			var fd:FileData = new FileData();
			fd.content = File.getContent(file);
			_files.set(file, fd);
		}
	}

	// Run through json data, list out all of the plugin classes
	macro static function __includePlugins()
	{
		var json:Dynamic = Json.parse(haxe.Resource.getString("config"));
		var exprArr:Array<Expr> = [];
		var plugins:Array<Dynamic> = cast json.plugins;
		for (plugin in plugins)
		{
			var expr: Expr = Context.parse(plugin.name, Context.currentPos());
			exprArr.push(expr);
		}

		return macro $b{exprArr};
	}

	private function runPlugins()
	{
		__includePlugins();

		var json:Dynamic = Json.parse(haxe.Resource.getString("config"));
		var plugins:Array<Dynamic> = cast json.plugins;
		for (plugin in plugins)
		{
			Sys.println("Running plugin: " + plugin.name);

			var pluginConfig:Dynamic = mergeData(_inst._globalConfig, plugin);
			var pluginClass:Dynamic = Type.resolveClass(plugin.name);
			var plugin:IPlugin = Type.createEmptyInstance(pluginClass);

			// TODO: combine init with run?
			plugin.init(pluginConfig); // TODO: pass data
			plugin.run();
		}
	}

	static public function globalConfig():Dynamic
	{
		var strConfig:String = Json.stringify(_inst._globalConfig);
		return Json.parse(strConfig);
	}

	static public function getFiles():FilesMap
	{
		return _inst._files;
	}

	// TODO: change to make sure child-fo-child isn't copied by reference,
	// maybe using recursion for children?
	static public function mergeData(baseData:Dynamic, extraData:Dynamic, overwrite:Bool = true):Dynamic
	{
		baseData = (baseData == null ? {} : baseData);
		extraData = (extraData == null ? {} : extraData);
		var merged:Dynamic = Reflect.copy(baseData);
		for (key in Reflect.fields(extraData))
		{
			if (overwrite || !Reflect.hasField(merged, key))
			{
				var value:Dynamic = Reflect.field(extraData, key);
				Reflect.setField(merged, Std.string(key), value);
			}
		}
		return merged;
	}

	public static function recursiveDelete (path:String)
	{
		for (file in FileSystem.readDirectory(path))
		{
			var currPath = Path.join([path, file]);
			if (FileSystem.isDirectory(currPath))
			{
				recursiveDelete(currPath);
				if (FileSystem.readDirectory(currPath).length == 0)
				{
					try
					{
						FileSystem.deleteDirectory(currPath);
					}
					catch (err:Dynamic)
					{
						Sys.println("-- Problem deleting folder " + currPath);
					}
				}
			}
			else
			{
				try
					{
						FileSystem.deleteFile(currPath);
					}
					catch (err:Dynamic)
					{
						Sys.println("-- Problem deleting file " + currPath);
					}
			}
		}
	}
}
