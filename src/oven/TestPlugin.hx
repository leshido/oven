package oven;

/**
 * ...
 * @author leshido
 */
@:keep
class TestPlugin
{

	public function new() 
	{
		
	}
	
	public function run()
	{
		var files = Oven.getFiles();
		for (file in files.keys())
		{
			if (file.indexOf("i") != -1)
			{
				files[file].title = "Derp";
			}
			files.set(file+"derp", files[file]);
			files.remove(file);

		}
	}
	
}