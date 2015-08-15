package oven.plugins;

import oven.Oven;
import oven.FileData;
import oven.FilesMap;

/**
 * ...
 * @author leshido
 */

class IgnoreFiles implements IPlugin {

	private var _files:FilesMap;

	public function init(?data:Dynamic):Void
    {
        _files = Oven.getFiles();
	}

	public function run():Void {

		for (file in _files.files())
        {
            if (_files[file].ignore != null && _files[file].ignore == true)
            {
                _files.remove(file);
            }
        }
	}
}
