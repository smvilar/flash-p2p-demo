package game
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import p2p.Connection;

	public class Entity
	{
		private var _asset:Sprite;
		private var _color:uint;
		private var _peerId:String;
		
		public function get asset():Sprite { return _asset; }
		public function get color():uint { return _color; }
		
		public function get peerId():String { return _peerId; }
		public function get playerControlled():Boolean { return _peerId == Connection.instance.peer.id; }
		
		public function Entity(peerId:String, givenColor:uint = uint.MAX_VALUE)
		{
			_peerId = peerId;
			_color = (givenColor != uint.MAX_VALUE) ? givenColor : (Math.random() * 0xffffff);
			
			_asset = new Sprite();
			_asset.graphics.beginFill(color);
			_asset.graphics.drawCircle(0, 0, 20);
			_asset.graphics.endFill();
			
			if (playerControlled)
				_asset.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			_asset.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.LEFT:
					_asset.x -= 5;
					break;
				case Keyboard.RIGHT:
					_asset.x += 5;
					break;
				case Keyboard.UP:
					_asset.y -= 5;
					break;
				case Keyboard.DOWN:
					_asset.y += 5;
					break;
			}
			Connection.instance.peer.sendMessage("entityMoved", {id:peerId, x:asset.x, y:asset.y});
		}
	}
}