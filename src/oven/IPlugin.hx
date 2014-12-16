package oven;

interface IPlugin {

	public function init(?data:Dynamic):Void;

	public function run():Void;
}
