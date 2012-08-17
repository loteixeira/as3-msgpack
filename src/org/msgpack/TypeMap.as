package org.msgpack
{
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	public class TypeMap
	{
		internal static var global:TypeMap = new TypeMap();

		private var map:Object;

		public function TypeMap()
		{
			map = {};

			assign("null", TypeHandler.encodeNull, TypeHandler.decodeNull, TypeHandler.checkNull);
			assign("Boolean", TypeHandler.encodeBoolean, TypeHandler.decodeBoolean, TypeHandler.checkBoolean);
			assign("Number", TypeHandler.encodeNumber, TypeHandler.decodeNumber, TypeHandler.checkNumber);
			assign("int", TypeHandler.encodeInt, TypeHandler.decodeInt, TypeHandler.checkInt);
			assign("flash.utils::ByteArray", TypeHandler.encodeBytes, TypeHandler.decodeBytes, TypeHandler.checkBytes);
			assign("String", TypeHandler.encodeString, null, null);
			assign("XML", TypeHandler.encodeXML, null, null);
			assign("Array", TypeHandler.encodeArray, TypeHandler.decodeArray, TypeHandler.checkArray);
			assign("Object", TypeHandler.encodeObject, TypeHandler.decodeObject, TypeHandler.checkObject);
		}

		public function assign(typeName:String, handlerEncoder:Function, handlerDecoder:Function, handlerChecker:Function):void
		{
			map[typeName] = {encoder: handlerEncoder, decoder: handlerDecoder, checker: handlerChecker};
		}

		public function unassign(typeName:String):void
		{
			map[typeName] = undefined;
		}

		public function encode(data:*, destination:ByteArray):void
		{
			var type:String = data == null ? "null" : getQualifiedClassName(data);
			var handler:Object = map[type];

			if (handler == null)
				throw new Error("MessagePack handler for type " + type + " not found");

			if (handler["encoder"] == null)
				throw new Error("MessagePack handler for type " + type + " does not have an encoder function");

			handler["encoder"](data, destination, this);
		}

		public function decode(source:ByteArray):*
		{
			for (var type:String in map)
			{
				var handler:Object = map[type];

				if (handler["checker"] != null && handler["checker"](source) && handler["decoder"] != null)
					return handler["decoder"](source, this);
			}

			throw new Error("MessagePack handler for signature 0x" + source[source.position].toString(16) + " not found");
		}
	}
}