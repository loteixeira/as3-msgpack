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
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	public class TypeMap
	{
		internal static var global:TypeMap = new TypeMap();

		private var map:Object;

		public function TypeMap()
		{
			map = {};

			assign(null, TypeHandler.encodeNull, TypeHandler.decodeNull, TypeHandler.checkNull);
			assign(Boolean, TypeHandler.encodeBoolean, TypeHandler.decodeBoolean, TypeHandler.checkBoolean);
			assign(Number, TypeHandler.encodeNumber, TypeHandler.decodeNumber, TypeHandler.checkNumber);
			assign(int, TypeHandler.encodeInt, TypeHandler.decodeInt, TypeHandler.checkInt);
			assign(ByteArray, TypeHandler.encodeByteArray, TypeHandler.decodeByteArray, TypeHandler.checkByteArray);
			assign(String, TypeHandler.encodeString, null, null);
			assign(XML, TypeHandler.encodeXML, null, null);
			assign(Array, TypeHandler.encodeArray, TypeHandler.decodeArray, TypeHandler.checkArray);
			assign(Object, TypeHandler.encodeObject, TypeHandler.decodeObject, TypeHandler.checkObject);
		}

		public function assign(type:Class, handlerEncoder:Function, handlerDecoder:Function, handlerChecker:Function):void
		{
			var typeName:String = getQualifiedClassName(type);
			map[typeName] = {encoder: handlerEncoder, decoder: handlerDecoder, checker: handlerChecker};
		}

		public function unassign(type:Class):void
		{
			var typeName:String = getQualifiedClassName(type);
			map[typeName] = undefined;
		}

		public function encode(data:*, destination:ByteArray):void
		{
			var typeName:String = data == null ? "null" : getQualifiedClassName(data);
			var handler:Object = map[typeName];

			if (handler == null)
				throw new Error("MessagePack handler for type " + typeName + " not found");

			if (handler["encoder"] == null)
				throw new Error("MessagePack handler for type " + typeName + " does not have an encoder function");

			handler["encoder"](data, destination, this);
		}

		public function decode(source:ByteArray):*
		{
			for (var typeName:String in map)
			{
				var handler:Object = map[typeName];

				if (handler["checker"] != null && handler["checker"](source) && handler["decoder"] != null)
					return handler["decoder"](source, this);
			}

			throw new Error("MessagePack handler for signature 0x" + source[source.position].toString(16) + " not found");
		}
	}
}