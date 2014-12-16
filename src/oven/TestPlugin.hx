package oven;

/**
 * ...
 * @author leshido
 */

class TestPlugin implements IPlugin {

	public function init(?data:Dynamic):Void {
		//
	}

	public function run():Void {

		var files = Oven.getFiles();

		for (file in files.files()) {

			if (file.indexOf("i") != -1) {
				files[file].title = "Derp";
			}
			//Sys.println('rename $file to ${files[file].title}');
			files.renameFile(file, files[file].title);
		}
	}
}
