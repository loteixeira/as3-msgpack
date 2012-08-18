//
// as3-msgpack (MessagePack for Actionscript3)
//
// Copyright (C) 2012 Lucas Teixeira (Disturbed Coder)
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
package org.msgpack
{
	import br.dcoder.console.Console;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import flash.utils.ByteArray;

	public class MessagePackTest extends Sprite
	{
		public function MessagePackTest()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		private function addedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, resize);

			Console.create(stage);
			Console.instance.area = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			Console.instance.draggable = false;
			Console.instance.resizable = false;

			start();
		}

		private function resize(e:Event):void
		{
			Console.instance.area = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}

		private function start():void
		{
			cpln("starting MessagePackTest (version " + MessagePackBase.VERSION + ")");
			cpln("");

			// null
			test(null);

			// true
			test(true);

			// false
			test(false);

			// Number
			test(666.12345);

			// int
			test(10);
			test(1000);
			test(100000);
			test(-10);
			test(-1000);
			test(-100000);

			// String
			// Strings are transformed into bytes and so packed in raw byte format
			// thus you can't unpack a raw package directly into a String, you'll always get a byte array.
			test("MessagePack for AS3");

			// Array
			test([1, 2, 3, "element"]);

			// Object
			test({name: "Lucas", age: 27, man: true});

			// custom type test
			// here we create a handler to encode Date class as a number (miliseconds)
			customTypeTest();
		}

		private function test(data:*):void
		{
			var name:String = getQualifiedClassName(data);
			cpln("testing '" + data + "' (" + name + "):");

			var encoder:MessagePackEncoder = new MessagePackEncoder();
			var bytes:ByteArray = encoder.write(data);
			cpln("encoded length = " + bytes.length);

			var decoder:MessagePackDecoder = new MessagePackDecoder(bytes);
			var result:* = decoder.read();
			cpln("decoded value = " + result);

			if (name == "Object")
				for (var i:String in result)
					cpln(i + " = " + result[i]);

			cpln("");
		}

		private function customTypeTest():void
		{
			cpln("testing custom type");

			var dateEncoder:Function = function(data:Date, destination:ByteArray, typeMap:TypeMap):void
			{
				// get miliseconds from date object, and pack it as a Number
				typeMap.encode(data.getTime(), destination);
			};

			cpln("assigning Date encoding handler");
			var encoder:MessagePackEncoder = new MessagePackEncoder();
			encoder.typeMap.assign(Date, dateEncoder, null, null);

			var date:Date = new Date();
			cpln("enconding date: " + date);
			var bytes:ByteArray = encoder.write(date);
			cpln("encoded length = " + bytes.length);

			var decoder:MessagePackDecoder = new MessagePackDecoder(bytes);
			var miliseconds:Number = decoder.read();
			cpln("decoded value = " + miliseconds + " (" + new Date(miliseconds) + ")");

			cpln("");
		}
	}
}