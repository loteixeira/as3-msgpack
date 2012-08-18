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

	public class MessagePackDecoder extends MessagePackBase
	{
		public function MessagePackDecoder(_buffer:ByteArray = null)
		{
			super(_buffer);
		}

		public function read(offset:int = 0, rewind:Boolean = true):*
		{
			if (offset > -1)
				_buffer.position = offset;

			var data:* = _typeMap.decode(_buffer);

			if (rewind)
				_buffer.position = 0;

			return data;
		}
	}
}