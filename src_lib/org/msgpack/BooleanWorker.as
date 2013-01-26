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
	
	internal class BooleanWorker extends Worker
	{
		public static function checkType(byte:int):Boolean
		{
			return byte == 0xc3 || byte == 0xc2;
		}

		public function BooleanWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			destination.writeByte(data ? 0xc3 : 0xc2);
		}

		override public function disassembly(source:IDataInput):*
		{
			return byte == 0xc3;
		}
	}
}