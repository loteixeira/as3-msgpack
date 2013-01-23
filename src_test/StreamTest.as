//
// as3-msgpack (MsgPack for Actionscript3)
// Copyright (C) 2012 Lucas Teixeira (Disturbed Coder)
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

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;

	import org.msgpack.*;

	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="30")]
	public class StreamTest extends Sprite
	{
		private var startTime:uint;

		public function StreamTest()
		{
			// create console
			Console.create(this);
			Console.instance.draggable = false;
			Console.instance.resizable = false;

			// wait to be added on the stage
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		private function addedToStage(e:Event):void
		{
			// configure stage
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, resize);

			// set resize
			resize(null);

			// start the test!
			start();
		}

		private function resize(e:Event):void
		{
			Console.instance.area = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}

		private function start():void
		{
			cpln("starting as3-msgpack stream test (version " + MsgPack.VERSION + ")");
			cpln("");

			var msgpack:MsgPack = new MsgPack();
			streamTest(msgpack);
		}

		private function streamTest(msgpack:MsgPack):void
		{
			startTime = getTimer();
			cpln("testing stream reading");

			var data:Object =
			{
				title: "My Title",
				body: "My Body",
				isMsgPackCool: true,
				theNumber: 42,
				planets: ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
			};

			var bytes:ByteArray = msgpack.write(data);
			bytes.position = 0;
			cpln("assembling object, length = " + bytes.length);

			var streamBytes:ByteArray = new ByteArray();
			setTimeout(writeStream, 10, bytes, streamBytes, 0, msgpack);
			setTimeout(readStream, 10, msgpack, streamBytes);
		}

		private function writeStream(bytes:ByteArray, streamBytes:ByteArray, counter:int, msgpack:MsgPack):void
		{
			streamBytes.length = counter + 1;
			streamBytes[counter] = bytes[counter];

			if (counter < bytes.length - 1)
				setTimeout(writeStream, 10, bytes, streamBytes, counter + 1, msgpack);
			else
				cpln(streamBytes.length + " bytes written");
		}

		private function readStream(msgpack:MsgPack, streamBytes:ByteArray):void
		{
			var obj:* = incomplete;
			obj = msgpack.read(streamBytes);

			if (obj == incomplete)
			{
				setTimeout(readStream, 10, msgpack, streamBytes);
			}
			else
			{
				cpln("done in " + (getTimer() - startTime) + "ms");
				printObject(obj);
			}
		}

		private function printObject(obj:Object):void
		{
			for (var i:String in obj)
				cpln(i + " = " + obj[i]);
		}
	}
}