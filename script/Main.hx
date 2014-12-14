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
		// Run oven.n
	}
	
	static private function isCompilePending():Bool
	{
		if (!FileSystem.exists("oven.n"))
		{
			return true;
		}
		// Compare mtime of json file and oven.n
		return true;
	}
	
}