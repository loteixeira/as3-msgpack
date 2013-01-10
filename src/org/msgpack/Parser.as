package org.msgpack
{
	import flash.utils.*;

	public class Parser
	{
		private var workers:Object;

		public function Parser()
		{
			workers = {};
		}

		public function assign(type:Class, worker:Worker):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName] = worker;
		}

		public function unassign(type:Class):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName] = undefined;
		}

		internal function encode(data:*, destination:IDataOutput):void
		{
			var typeName:String = data == null ? "null" : getQualifiedClassName(data);
			var worker:Worker = workers[typeName];

			if (handler == null)
				throw new Error("MessagePack handler for type " + typeName + " not found");

			if (handler["encoder"] == null)
				throw new Error("MessagePack handler for type " + typeName + " does not have an encoder function");

			handler["encoder"](data, destination, this);
		}
	}
}