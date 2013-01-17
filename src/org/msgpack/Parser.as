package org.msgpack
{
	import flash.utils.*;

	public class Parser
	{
		private var workers:Object;
		private var stack:Array;

		public function Parser()
		{
			workers = {};
			stack = [];
		}

		public function assign(type:Class, worker:Worker):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName] = worker;
			worker.setParser(this);
		}

		public function unassign(type:Class):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName].setParser(undefined);
			workers[typeName] = undefined;
		}

		public function clear():void
		{
			stack = [];
		}

		internal function encode(data:*, destination:IDataOutput):void
		{
			var typeName:String = data == null ? "null" : getQualifiedClassName(data);
			var worker:Worker = workers[typeName];

			if (worker == null)
				throw new MsgPackError("Worker for type " + typeName + " not found");

			worker.encode(data, destination);
		}

		internal function decode(source:IDataInput):*
		{
			var result:*;
			var byte:int;
			var worker:Worker;
			var last:int = stack.length - 1;
			var stacked:Boolean;

			// get worker stack
			if (stack.length > 0)
			{
				cpln("GET WORKER FROM STACK");
				stacked = true;
				byte = stack[last][0];
				worker = stack[last][1];
			}
			// find worker from next signature byte
			else if (source.bytesAvailable > 0)
			{
				cpln("GET WORKER FROM SIGNATURE");
				stacked = false;
				byte = source.readByte() & 0xff;

				for (var typeName:String in workers)
				{
					if (!workers[typeName].checkType(byte))
						continue;

					worker = workers[typeName];
					break;
				}
             
				if (!worker)
					throw new MsgPackError("MessagePack handler for signature 0x" + byte.toString(16) + " not found");
			}

			if (worker)
			{
				// if object length is variable
				if (worker.getBufferLength(byte) == Worker.VARIABLE)
				{
					cpln("BUFFER HAS VARIABLE LENGTH");
				}
				// if object length is fixed
				else 
				{
					cpln("BUFFER HAS A FIXED LENGTH");

					if (worker.getBufferLength(byte) > source.bytesAvailable)
					{
						if (!stacked)
						{
							stack.push([byte, worker]);
							cpln("STACKING OPERATION");
						}

						cpln("NOT ENOUGH AVAILABLE BYTES... WAITING");
					}
					else
					{
						if (stacked)
						{
							stack.pop();
							cpln("UNSTACKING OPERATION");
						}

						result = worker.decode(byte, source);
						cpln("DECODING DATA");
					}
				}
			}

			// end of the history!
			return result;
		}
	}
}