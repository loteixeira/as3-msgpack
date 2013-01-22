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
package org.msgpack
{
	import flash.utils.*;

	internal class NullWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return byte == 0xc0;
		}

		public function NullWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			super.assembly(data, destination);
			destination.writeByte(0xc0);
		}

		override public function disassembly(source:IDataInput):*
		{
			return null;
		}
	}
}