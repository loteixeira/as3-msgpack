//
// as3-msgpack (MessagePack for Actionscript3)
// Copyright (C) 2013 Lucas Teixeira (Disturbed Coder)
// 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
package 
{
	import br.dcoder.console.*;

	import com.adobe.serialization.json.*;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;

	import org.msgpack.*;

	public class AS3Server extends Sprite
	{
		private var msgpack:MsgPack;
		private var serverSocket:ServerSocket;
		private var clientSocket:Socket;

    	public function AS3Server()
		{
			Console.create(this);
			Console.instance.caption = "as3-msgpack socket server"
			Console.instance.draggable = false;
			Console.instance.resizable = false;
			Console.instance.getEventDispatcher().addEventListener(ConsoleEvent.INPUT, consoleInput);

			msgpack = new MsgPack();

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		private function addedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.addEventListener(Event.RESIZE, resize);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			resize(null);
			start();
		}

		private function resize(e:Event):void
		{
			Console.instance.area = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}

		private function start():void
		{
			cpln("starting as3-msgpack socket server");

			serverSocket = new ServerSocket();
			serverSocket.addEventListener(Event.CLOSE, serverSocketClose);
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, serverSocketConnect);

			var port:int = 5555;
			cpln("binding server to port " + port);
			serverSocket.bind(port);

			cpln("listening for incoming connections...");
			serverSocket.listen();

			cpln("");
		}

		private function serverSocketClose(e:Event):void
		{
			cpln("connection closed");
			cpln("");
			clientSocket = undefined;
		}

		private function serverSocketConnect(e:ServerSocketConnectEvent):void
		{
			cpln("client connected");
			cpln("");
			clientSocket = e.socket;
			clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
		}

		private function socketData(e:ProgressEvent):void
		{
			cpln("read incoming data");
			var data:* = msgpack.read(clientSocket);

			if (data != incomplete)
			{
				cpln("packet decoded:");
				cpln(JSON.encode(data));
				cpln("");
			}
		}

		private function consoleInput(e:ConsoleEvent):void
		{
			if (!clientSocket)
			{
				cpln("ERROR: no client connect");
				return;
			}

			try
			{
				cpln("writing packet");
				var data:Object = JSON.decode(e.text);
				msgpack.write(data, clientSocket);
				clientSocket.flush();
			}
			catch (e:Error)
			{
				cpln("ERROR: can't parse json");
				cpln(e);
			}
		}
	}
}