package p2p
{
	import flash.events.NetStatusEvent;
	import flash.net.*;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class Peer
	{
		private var _id:String;
		
		private var _group:NetGroup;
		private var _suscriber:NetStream;
		
		public var _sendStream:NetStream;
		public var _recvStream:NetStream;
		
		private var _connectedCallback:Function;
		
		private var _registeredCallbacks:Dictionary = new Dictionary();
		
		public function get id():String
		{
			return _id;
		}
		
		public function get otherID():String
		{
			return _suscriber.farID;
		}
		
		public function set id(value:String):void
		{
			trace("Peer id:", value);
			
			_id = value;
		}
		
		public function get isConnected():Boolean
		{
			return _suscriber != null;
		}
		
		public function get streamClient():Object
		{
			var o:Object = {};
			o.onPeerConnect = function(suscriber:NetStream):Boolean
			{
				if (isConnected)
				{
					trace("Rejecting connection with peer:", suscriber.farID);
					return false;
				}
				else
				{
					trace("Accepting connection with peer:", suscriber.farID);
					onPeerAccepted(suscriber);
					return true;
				}
			};
			return o;
		}
		
		public function Peer(connectedCallback:Function)
		{
			_connectedCallback = connectedCallback;
		}
		
		public function onGroupConnect(netConnection:NetConnection, group:NetGroup):void 
		{
			_sendStream = new NetStream(netConnection, NetStream.DIRECT_CONNECTIONS);
			_sendStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_sendStream.publish("intro");
			_sendStream.client = streamClient;
			
			_group = group;
		}
		
		public function onNeighborConnect(netConnection:NetConnection, farID:String):void 
		{
			if (isConnected || _recvStream != null)
				return;
			
			_recvStream = new NetStream(netConnection, farID);
			_recvStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_recvStream.play("intro");
			_recvStream.client = this;
		}
		
		public function onNeighborDisconnect(netConnection:NetConnection, farID:String):void 
		{
		}
		
		private function onNetStatus(e:NetStatusEvent):void 
		{
			trace("NetStatusEvent: " + e.info.code);
			
			switch (e.info.code)
			{
				case "NetStream.Connect.Success":
					onNetStreamConnect(e.info.stream);
					break;
				case "NetStream.Connect.Failed":
					onNetStreamClosed(e.info.stream);
					break;
				case "NetStream.Connect.Closed":
					onNetStreamClosed(e.info.stream);
					break;
			}
		}
		
		private function onNetStreamConnect(netStream:NetStream):void 
		{
			trace("onNetStreamConnect:", netStream.farID);
		}
		
		public function onNetStreamClosed(netStream:NetStream):void 
		{
			trace("onNetStreamClosed:", netStream.farID);
			
			if (_recvStream && _recvStream.farID == netStream.farID)
			{
				_recvStream = null;
			}
		}
		
		private function onPeerAccepted(suscriber:NetStream):void 
		{
			_suscriber = suscriber;
			_connectedCallback();
		}
		
		private function disconnect():void 
		{
			trace("disconnected from other peer");
			_suscriber.close();
			_suscriber = null;
		}
		
		public function closeGroup():void
		{
			_group.close();
		}
		
		public function sendMessage(text:String, ...args):void 
		{
			trace("Sending message: ", text, args);
			_suscriber.send.apply(_suscriber, ["peerMessage"].concat(text, args));
		}
		
		public function registerToMessage(text:String, callback:Function):void 
		{
			_registeredCallbacks[text] = callback;
		}
		
		public function peerMessage(text:String, ...args):void 
		{
			var callback:Function = _registeredCallbacks[text];
			if (callback != null)
			{
				callback.apply(callback, args);
			}
		}
	}
}