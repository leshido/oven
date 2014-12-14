package oven;

interface IPlugin {

	public function init(?data:Dynamic):Void;

	public function runnable():Bool;

	public function run():Void;
}
