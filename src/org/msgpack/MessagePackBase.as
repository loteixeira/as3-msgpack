package org.msgpack
{
	import flash.utils.ByteArray;

	public class MessagePackBase
	{
		public static const MAJOR:uint = 0;
		public static const MINOR:uint = 1;
		public static const REVISION:uint = 0;

		public static function get VERSION():String
		{
			return MAJOR + "." + MINOR + "." + REVISION;
		}

		protected var _buffer:ByteArray;
		protected var _typeMap:TypeMap;

		public function MessagePackBase(_buffer:ByteArray = null, _typeMap:TypeMap = null)
		{
			if (!_buffer)
				_buffer = new ByteArray();

			this._buffer = _buffer;

			if (!_typeMap)
				_typeMap = TypeMap.global;

			this._typeMap = _typeMap;
		}

		public function get buffer():ByteArray
		{
			return _buffer;
		}

		public function set buffer(_buffer:ByteArray):void
		{
			this._buffer = _buffer;
		}

		public function get typeMap():TypeMap
		{
			return _typeMap;
		}
	}
}