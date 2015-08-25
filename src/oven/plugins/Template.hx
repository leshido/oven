package oven.plugins;

import oven.Oven;
import oven.FileData;
import oven.FilesMap;
import haxe.io.Path;

/**
 * ...
 * @author leshido
 */

class Template implements IPlugin
{

	private var _files:FilesMap;
	private var _templateDir:String;

	public function init(?data:Dynamic):Void
	{	
		_files = Oven.getFiles();
		_templateDir = data.dir;
	}

	public function run():Void
	{
		// build global context using template dir
		var templateFiles = _files.listDir(_templateDir, true);
		var global = {};
		var templateIDs = [];
		for (tf in templateFiles)
		{
			var templateName = new EReg("^" + _templateDir + "/*", "i").replace(tf, "");
			templateName = Path.withoutExtension(templateName);
			templateName = StringTools.replace(templateName, "/", "_");
			templateIDs.push(templateName);
			Reflect.setField(global, templateName, _files[tf].content);
		}
		haxe.Template.globals = global;
		
		// replace content with templates where necessary, use file data to create specific context
		for (path in _files.files())
		{
			var file = _files[path];
			var templateID = file.template;
			if (templateID != null && templateIDs.indexOf(templateID) != -1)
			{
				var template = _files[templateFiles[templateIDs.indexOf(templateID)]].content;
				var newContent = new haxe.Template(template).execute(file);
				file.content = newContent;
			}
		}
		
		// remove templates folder
		for (tf in templateFiles)
		{
			_files.remove(tf);
		}
		
		// TODO: test on windows
		// TODO: way to resolve nested templates?
	}

}
