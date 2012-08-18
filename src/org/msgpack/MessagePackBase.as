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

	public class MessagePackBase
	{
		public static const MAJOR:uint = 0;
		public static const MINOR:uint = 2;
		public static const REVISION:uint = 0;

		public static function get VERSION():String
		{
			return MAJOR + "." + MINOR + "." + REVISION;
		}

		protected var _buffer:ByteArray;
		protected var _typeMap:TypeMap;

		public function MessagePackBase(_buffer:ByteArray = null, _typeMap:TypeMap = null)
		{
			this._buffer = _buffer || new ByteArray();
			this._typeMap = _typeMap || TypeMap.global;
		}

		public function get buffer():ByteArray
		{
			return _buffer;
		}

		public function set buffer(_buffer:ByteArray):void
		{
			// should we force the buffer to be BIG_ENDIAN?
			// according to MessagePack specification the buffers must be written in big endian.
			this._buffer = _buffer;
		}

		public function get typeMap():TypeMap
		{
			return _typeMap;
		}
	}
}