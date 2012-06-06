package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import game.Entity;
	
	import p2p.*;
	
	[SWF(width="320", height="240")]
	public class MultiplayerGame extends Sprite
	{
		public static const CIRRUS_KEY:String = "e6c03c83c31778d730a34805-dece97415cbe";
		public static const CIRRUS_URL:String = "rtmfp://p2p.rtmfp.net/" + CIRRUS_KEY;

		private var _conn:Connection;
		private var _localEntity:Entity;
		private var _otherEntity:Entity;
		
		public function MultiplayerGame()
		{
			Connection.instance.init(CIRRUS_URL, onConnect);
		}
		
		private function onConnect():void
		{
			trace("connected!!");
			
			Connection.instance.peer.registerToMessage("entityCreated", onEntityCreated);
			Connection.instance.peer.registerToMessage("entityMoved", onEntityMoved);
			
			_localEntity = new Entity(Connection.instance.peer.id);
			_localEntity.asset.x = Math.random() * stage.stageWidth;
			_localEntity.asset.y = Math.random() * stage.stageHeight;
			addChild(_localEntity.asset);
			
			Connection.instance.peer.sendMessage("entityCreated", {id:_localEntity.peerId, color:_localEntity.color});
			Connection.instance.peer.sendMessage("entityMoved", {id:_localEntity.peerId, x:_localEntity.asset.x, y:_localEntity.asset.y});
		}
		
		private function onEntityCreated(obj:Object):void
		{
			trace("new entity!!");
			_otherEntity = new Entity(obj.id, obj.color);
			addChild(_otherEntity.asset);
		}
		
		private function onEntityMoved(obj:Object):void
		{
			trace("entity moved!!");
			if (obj.id != _otherEntity.peerId) throw new Error("Error on entity peer id!");
			_otherEntity.asset.x = obj.x;
			_otherEntity.asset.y = obj.y;
		}
	}
}