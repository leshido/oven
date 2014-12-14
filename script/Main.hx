package;

import neko.Lib;
import sys.FileSystem;

/**
 * ...
 * @author leshido
 */

class Main 
{
	
	static function main() 
	{
		// Set CWD
		if (isCompilePending())
		{
			// Compile
		}
		// Run glue.n
	}
	
	static private function isCompilePending():Bool
	{
		if (!FileSystem.exists("glue.n"))
		{
			return true;
		}
		// Compare mtime of json file and glue.n
		return true;
	}
	
}