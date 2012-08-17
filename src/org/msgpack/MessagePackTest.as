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
		private var bytes:ByteArray;

		private var encoder:MessagePackEncoder;
		private var decoder:MessagePackDecoder;

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

			bytes = new ByteArray();
			encoder = new MessagePackEncoder(bytes);
			decoder = new MessagePackDecoder(bytes);

			// null
			doTest(null);

			// true
			doTest(true);

			// false
			doTest(false);

			// Number
			doTest(666.12345);

			// int
			doTest(10);
			doTest(1000);
			doTest(100000);
			doTest(-10);
			doTest(-1000);
			doTest(-100000);

			// String
			doTest("MessagePack for AS3");

			// Array
			doTest([1, 2, 3, "element"]);

			// Object
			doTest({name: "Lucas", age: 27, man: true});
		}

		private function doTest(data:*):void
		{
			var name:String = getQualifiedClassName(data);

			bytes.clear();
			cpln("testing '" + data + "' (" + name + "): ");
			encoder.write(data);
			cpln("encoded length = " + bytes.length);
			var tmp:* = decoder.read();
			cpln("decoded value = " + tmp);

			if (name == "Object")
			{
				for (var i:String in tmp)
					cpln(i + " = " + tmp[i]);
			}

			cpln("");
		}
	}
}