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

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;

	import org.msgpack.*;

	[SWF(width="800", height="600", backgroundColor="#FFFFFF", frameRate="30")]
	public class LibTest extends Sprite
	{
		private var startTime:uint;

		public function LibTest()
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
			cpln("starting as3-msgpack lib test (version " + MsgPack.VERSION + ")");
			cpln("");

			var msgpack:MsgPack = new MsgPack(MsgPackFlags.READ_RAW_AS_BYTE_ARRAY);

			// null
			test(msgpack, null);

			// true
			test(msgpack, true);

			// false
			test(msgpack, false);

			// Number
			test(msgpack, 666.12345);

			// int
			test(msgpack, 10);
			test(msgpack, 1000);
			test(msgpack, 100000);
			test(msgpack, -10);
			test(msgpack, -1000);
			test(msgpack, -100000);

			// ByteArray
			var tmp:ByteArray = new ByteArray();
			tmp.writeUTFBytes("aéçãªº°¹²³£¢¬");
			test(msgpack, tmp);

			// String
			test(msgpack, "MsgPack for AS3");

			// Array
			test(msgpack, [1, 2, 3, "message pack"]);

			// Testing empty string (bug fixed in version 0.4.1 - thanks to ccrossley)
			test(msgpack, ["lucas", "", "teixeira"]);

			// Object
			test(msgpack, {name: "Lucas", age: 27, man: true});

			// custom type test
			// here we create a handler to encode Date class as a number (miliseconds)
			customTypeTest();
		}

		private function test(msgpack:MsgPack, data:*):void
		{
			// print type info
			var name:String = getQualifiedClassName(data);
			cpln("testing '" + data + "' (" + name + "):");

			// encode data and print buffer length
			var bytes:ByteArray = msgpack.write(data);
			bytes.position = 0;
			cpln("encoded length = " + bytes.length);

			// decode data and print the result object
			var result:* = msgpack.read(bytes);
			cpln("decoded value = " + result);
			cpln(getQualifiedClassName(result));

			// if is a object, let's iterate through the elements
			if (name == "Object")
				printObject(result);

			cpln("");
		}

		private function printObject(obj:Object):void
		{
			for (var i:String in obj)
				cpln(i + " = " + obj[i]);
		}

		private function customTypeTest():void
		{
			cpln("testing custom type");

			var msgpack:MsgPack = new MsgPack();
			msgpack.factory.assign(DateWorker, Date);

			var date:Date = new Date();

			// encode date
			cpln("enconding date: " + date);
			var bytes:ByteArray = msgpack.write(date);
			bytes.position = 0;
			cpln("encoded length = " + bytes.length);

			// decode date
			var miliseconds:Number = msgpack.read(bytes);
			cpln("decoded value = " + miliseconds + " (" + new Date(miliseconds) + ")");

			cpln("");
		}
	}
}