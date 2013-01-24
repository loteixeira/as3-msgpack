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

	public class AS3Client extends Sprite
	{
		private var msgpack:MsgPack;
		private var socket:Socket;

    	public function AS3Client()
		{
			Console.create(this);
			Console.instance.caption = "as3-msgpack socket client"
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
			cpln("starting as3-msgpack socket client");

			socket = new Socket();
			socket.addEventListener(Event.CLOSE, socketClose);
			socket.addEventListener(Event.CONNECT, socketConnect);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
			socket.connect("localhost", 5555);
		}

		private function socketClose(e:Event):void
		{
			cpln("connection closed");
		}

		private function socketConnect(e:Event):void
		{
			cpln("connected to the server");
		}

		private function socketData(e:ProgressEvent):void
		{
			cpln("read incoming data");
			var data:* = msgpack.read(socket);

			if (data != incomplete)
			{
				cpln("packet decoded:");
				cpln(JSON.encode(data));
				cpln("");
			}
		}

		private function consoleInput(e:ConsoleEvent):void
		{
			if (!socket.connected)
			{
				cpln("ERROR: not connected to the server");
				return;
			}

			try
			{
				cpln("encoding packet");
				var data:Object = JSON.decode(e.text);
				msgpack.write(data, socket);
				socket.flush();
			}
			catch (e:Error)
			{
				cpln("ERROR: can't parse json");
				cpln(e);
			}
		}
	}
}