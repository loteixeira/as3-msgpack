package org.msgpack
{
	import flash.utils.*;

	public class Factory
	{
		private var workers:Object;
		private var root:Worker;

		public function Factory()
		{
			workers = {};
		}

		public function assign(workerClass:Class, ...args):void
		{
			for (var i:uint = 0; i < args.length; i++)
			{
				if (args[i] != null && !(args[i] is Class))
					throw new MsgPackError("Workers must be assigned to classes not objects");

				var typeName:String = getQualifiedClassName(args[i]);
				workers[typeName] = workerClass;
			}
		}

		public function unassign(type:Class):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName] = undefined;
		}

		internal function getWorkerByType(data:*):Worker
		{
			var typeName:String = data == null ? "null" : getQualifiedClassName(data);

			if (!workers[typeName])
				throw new MsgPackError("Worker for type '" + typeName + "' not found");

			return new workers[typeName](this);
		}

		internal function getWorkerByByte(source:IDataInput):Worker
		{
			var byte:int = source.readByte() & 0xff;

			for each (var workerClass:Class in workers)
			{
				if (!workerClass["checkType"](byte))
					continue;

				return new workerClass(this, byte);
			}

			throw new MsgPackError("Worker for signature 0x" + byte.toString(16) + " not found");
		}
	}
}