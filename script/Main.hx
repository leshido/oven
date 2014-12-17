package;

import haxe.io.Path;
import haxe.Json;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author leshido
 */

class Main 
{
	private static var _args:Array<String>;
	private static var _config:Dynamic;
	
	static function main() 
	{
		_args = Sys.args();

		var jsonPath = getJsonFile();
		var json = File.getContent(jsonPath);
		_config = Json.parse(json);
		
		// Find plugin locations to add as -cp
		var pluginDirs:Array<String> = [];
		if (_config.config.pluginsDir != null)
		{
			pluginDirs.push(_config.config.pluginsDir);
		}
		else
		{
			if (FileSystem.exists("plugins"))
			{
				pluginDirs.push("plugins");
			}
		}
		var plugins:Array<Dynamic> = cast _config.plugins;
		for (plugin in plugins)
		{
			if (plugin.path != null && pluginDirs.indexOf(plugin.path) == -1)
			{
				pluginDirs.push(plugin.path);
			}
		}
		
		// Build
		var compilerArgs:Array<String> = [];
		var outputFile:String = Path.join([Path.directory(jsonPath), "oven.n"]);
		compilerArgs = compilerArgs.concat(["-cp", "src"]); //TODO: change to use -lib when used as haxelib
		compilerArgs = compilerArgs.concat(["-main", "oven.Oven"]);
		for (pluginDir in pluginDirs)
		{
			compilerArgs = compilerArgs.concat(["-cp", pluginDir]);
		}
		compilerArgs = compilerArgs.concat(["-resource", jsonPath + "@config"]);
		compilerArgs = compilerArgs.concat(["-neko", outputFile]);
		var buildStatus = Sys.command("haxe", compilerArgs);
		
		// Run
		if (buildStatus == 0) Sys.command("neko " + outputFile);
	}
	
	static function getJsonFile():String
	{
		// Try to load Json file in order
		var fileToLoad:String = "";
		if (_args.length > 0 && _args[0].indexOf(".json") != -1)
		{
			fileToLoad = _args[0];
		}
		else
		{
			var possibleFiles:Array<String> = ["recipe.json", "oven.json", "project.json"];
			for (file in possibleFiles)
			{
				if (FileSystem.exists(file))
				{
					fileToLoad = file;
					break;
				}
			}
		}
		
		if (fileToLoad == "")
		{
			throw "Could not find any JSON recipe file.";
		}
		return fileToLoad;
	}
	
}