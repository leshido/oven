package glue;

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
		var files = Glue.getFiles();
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