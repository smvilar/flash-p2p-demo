package p2p
{
	import flash.events.NetStatusEvent;
	import flash.net.*;
	
	/**
	 * Connection
	 * @author Santiago Vilar
	 */
	public class Connection 
	{
		private var _netConnection:NetConnection;
		private var _netGroup:NetGroup;
		
		private var _peer:Peer;
		
		public function get peer():Peer
		{
			return _peer;
		}
		
		public function init(serverUrl:String, connectedCallback:Function):void 
		{
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_netConnection.connect(serverUrl);
			
			_peer = new Peer(connectedCallback);
		}
		
		public function close():void
		{
			_netGroup.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_netGroup.close();
			_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_netConnection.close();
		}
		
		private function onNetStatus(e:NetStatusEvent):void 
		{
			trace("NetStatusEvent: " + e.info.code);
			
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					onConnect();
					break;
				case "NetGroup.Connect.Success":
					_peer.onGroupConnect(_netConnection, _netGroup);
					break;
				case "NetGroup.Neighbor.Connect":
					_peer.onNeighborConnect(_netConnection, e.info.peerID);
					break;
				case "NetGroup.Neighbor.Disconnect":
					_peer.onNeighborDisconnect(_netConnection, e.info.peerID);
					break;
				case "NetStream.Connect.Closed":
					_peer.onNeighborDisconnect(_netConnection, e.info.peerID);
					break;
				
				default:
					//trace("Unhandled NetStatusEvent: " + e.info.code);
					break;
			}
		}
		
		private function onConnect():void
		{
			var groupSpecifier:GroupSpecifier = new GroupSpecifier("NickPuzzleFighter");
			groupSpecifier.multicastEnabled = true;
			groupSpecifier.postingEnabled = true;
			groupSpecifier.serverChannelEnabled = true;
			
			_netGroup = new NetGroup(_netConnection, groupSpecifier.groupspecWithAuthorizations());
			_netGroup.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			_peer.id = _netConnection.nearID;
		}
		
		//---------------------------------------------------------------------
		// Singleton implementation
		//---------------------------------------------------------------------
		
		private static var _instance:Connection;
		
		public static function get instance():Connection
		{
			if (!_instance)
				_instance = new Connection(new SingletonEnforcer);
			return _instance;
		}
		
		public function Connection(se:SingletonEnforcer)
		{
		}
	}
}

internal class SingletonEnforcer
{
}