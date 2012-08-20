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
		protected var _typeMap:TypeMap;

		public function MessagePackBase(_typeMap:TypeMap = null)
		{
			this._typeMap = _typeMap || TypeMap.global;
		}

		public function get typeMap():TypeMap
		{
			return _typeMap;
		}
	}
}