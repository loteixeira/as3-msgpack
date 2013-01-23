//
// as3-msgpack (MessagePack for Actionscript3)
// Copyright (C) 2013 Lucas Teixeira (Disturbed Coder)
// 
// Contribution:
// * 2012.10.22 - ccrossley (https://github.com/ccrossley)
// * 2013.01.22 - sparkle (https://github.com/sparkle)
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
package org.msgpack
{
	import flash.utils.*;

	internal class RawWorker extends Worker
	{
		private var count:int;

		public static function checkType(byte:int):Boolean
		{
			return (byte & 0xe0) == 0xa0 || byte == 0xda || byte == 0xdb;
		}

		public function RawWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
			count = -1;
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			var bytes:ByteArray;

			if (data is ByteArray)
			{
				bytes = data;
			}
			else
			{
				bytes = new ByteArray();
				bytes.writeUTFBytes(data.toString());
			}

			if (bytes.length < 32)
			{
				// fix raw
				destination.writeByte(0xa0 | bytes.length);
			}
			else if (bytes.length < 65536)
			{
				// raw 16
				destination.writeByte(0xda);
				destination.writeShort(bytes.length);
			}
			else
			{
				// raw 32
				destination.writeByte(0xdb);
				destination.writeInt(bytes.length);
			}

			destination.writeBytes(bytes);
		}

		override public function disassembly(source:IDataInput):*
		{
			if (count == -1)
			{
				if ((byte & 0xe0) == 0xa0)
					count = byte & 0x1f;
				else if (byte == 0xda && source.bytesAvailable >= 2)
					count = source.readUnsignedShort();
				else if (byte == 0xdb && source.bytesAvailable >= 4)
					count = source.readUnsignedInt();
			}

			if (source.bytesAvailable >= count)
			{
				var data:ByteArray = new ByteArray();

				// we need to check if the byte array is empty to avoid EOFError
				// thanks to ccrossley
				if (count > 0)
					source.readBytes(data, 0, count);

				// using flags this worker may return RAW as String (not only as ByteArray like previous version)
				// thanks to sparkle
				return factory.checkFlag(Factory.READ_RAW_AS_BYTE_ARRAY) ? data : data.toString();
			}

			return incomplete;
		}
	}
}