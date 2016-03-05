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

		for (f in _files.files())
        {
            var ignore = _files[f].ignore;
			if (ignore != null && ignore == true) _files.remove(f);
        }
	}
}
