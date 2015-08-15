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
	static public inline var VERSION:String = "0.1.0";

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
			// Setup oven alias
			try
			{
				setup();
			}
			catch (e:Dynamic)
			{
				Sys.println("ERROR!");
				Sys.println("---");
				Sys.println(e);
				Sys.exit(1);
			}
			Sys.println("DONE! you can now use 'oven' command");
			Sys.exit(0);
		}
		else if (command == "help")
		{
			// TODO: update help when commands are set better...
			printHello();
			Sys.println("Usage: oven create|bake|help");
			Sys.println("");
		}
		else if (command == null)
		{
			printHello();
			Sys.println("Use 'oven help' to list all commands");
		}
		else
		{
			Sys.println('Command "$command" not found. Use "oven help" for a list of available commands.');
			Sys.exit(1);
		}
	}
	
	static private function printHello() : Void
	{
		Sys.println("Oven (v. " + VERSION + ")");
		Sys.println("A simple & extendable static site generator");
		Sys.println("---");
	}

	static private function setup():Void {
		var sysName = Sys.systemName();
		if (sysName == "Windows")
		{
			var content = "@haxelib run oven %*";
			var path = Sys.getEnv("HAXEPATH");
			if (path == null || path.length == 0) {
				throw "HAXEPATH is not part of the environment variables.";
				return;
			}
			sys.io.File.saveContent( '$path/oven.bat', content );
		}
		else
		{
			var content = "#!/bin/sh\n\nhaxelib run oven $@";
			var path = "/usr/bin/oven";
			try
			{
				sys.io.File.saveContent(path , content );
				Sys.command( "chmod", ["+x", path]);
			}
			catch (e:Dynamic)
			{
				throw "Failed to save to '" + path + "'. Try to run this command with 'sudo'.";
				return;
			}
			
		}
	}
	
	static private function create()
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
	
	static private function copyDir(templatePath:String, filePath:String = "")
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
	
	static private function bake()
	{
		var jsonPath:String = getJsonFile();
		var json:String;
		try {
			json = File.getContent(jsonPath);
		} catch (e:Dynamic) {
			Sys.println("Error: unable to opne file " + jsonPath);
			return;
		}
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
		if (buildStatus == 0) Sys.command("neko", [outputFile]);
	}
	
	static private function getJsonFile():String
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