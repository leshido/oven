package ;

/**
* ...
* @author nndovo
*/

import oven.IPlugin;
import oven.Oven;

class TestPluginB implements IPlugin {

    public function init(?data:Dynamic):Void {
        //
    }

    public function runnable():Bool {
        return true;
    }

    public function run():Void {

        var files = Oven.getFiles();

        for (file in files.files()) {

            if (file.indexOf("i") != -1) {
                files[file].title = "DerpHerp";
            }

            files.renameFile(file, files[file].title);
        }
    }
}
