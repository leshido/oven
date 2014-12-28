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
	private static var _libPath:String;
	private static var _projectPath:String;
	
	static function main() 
	{
		_args = Sys.args();
		
		_projectPath = _args.pop();
		_libPath = Sys.getCwd();
		Sys.setCwd(_projectPath);

		var command = _args.shift();
		if (command == "bake")
		{
			// Bake project
			bake();
		}
		else if (command == "create")
		{
			// Create template
			create();
		}
		else if (command == "setup")
		{
			// TODO: Install oven alias
		}
		else if (command == "help" || command == null)
		{
			// TODO: Display help
		}
		else
		{
			Sys.println('Command "$command" not found. Use "oven help" for a list of available commands.');
			Sys.exit(1);
		}
	}
	
	static function create()
	{
		if (_args.length == 0)
		{
			Sys.println('List of available templates:');
			var templates = FileSystem.readDirectory(Path.join([_libPath, "templates"]));
			for (template in templates)
			{
				Sys.println(template);
			}
			return;
		}
		var templateName = _args.shift();
		var templatePath = Path.join([_libPath, "templates", templateName]);

		var currDir = Sys.getCwd();
		var targetDir = _args.length > 0 ? _args.shift() : currDir;
		if (!FileSystem.exists(targetDir))
		{
			FileSystem.createDirectory(targetDir);
		}
		Sys.setCwd(targetDir);

		if (FileSystem.exists(templatePath))
		{
			copyDir(templatePath);
			Sys.println('DONE! all files of template "$templateName" were created.');
			Sys.setCwd(currDir);
		}
		else
		{
			Sys.setCwd(currDir);
			Sys.println('Template "$templateName" not found. Use "oven create" for a list of available templates.');
			Sys.exit(1);
		}
	}
	
	static function copyDir(templatePath:String, filePath:String = "")
	{
		var files = FileSystem.readDirectory(Path.join([templatePath, filePath]));
		for (fileName in files)
		{
			fileName = Path.join([filePath, fileName]);
			var origFile = Path.join([templatePath, fileName]);
			if (FileSystem.isDirectory(origFile))
			{
				FileSystem.createDirectory(fileName);
				copyDir(templatePath, fileName);
			}
			else
			{
				File.copy(origFile, fileName);
			}
		}
	}
	
	static function bake()
	{
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
		compilerArgs = compilerArgs.concat(["-cp", Path.join([_libPath, "src"]) ]);
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
			Sys.println("Could not find any JSON recipe file.");
			Sys.exit(1);
		}
		return fileToLoad;
	}
	
}