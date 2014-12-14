package oven;

/**
 * ...
 * @author leshido
 */

class TestPlugin implements IPlugin {

	public function init(?data:Dynamic):Void {
		//
	}

	public function runnable():Bool {
		return true;
	}
	
	public function run():Void {

		var files = Oven.getFiles();

		for (file in files.keys()) {

			if (file.indexOf("i") != -1) {
				files[file].title = "Derp";
			}
			files.set(file+"derp", files[file]);
			files.remove(file);
		}
	}
}