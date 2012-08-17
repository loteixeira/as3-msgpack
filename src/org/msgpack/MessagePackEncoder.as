package org.msgpack
{
	import flash.utils.ByteArray;

	public class MessagePackEncoder extends MessagePackBase
	{
		public function MessagePackEncoder(_buffer:ByteArray = null)
		{
			super(_buffer);
		}

		public function write(data:*, offset:int = 0, rewind:Boolean = true):ByteArray
		{
			if (offset > -1)
				_buffer.position = offset;

			_typeMap.encode(data, _buffer);

			if (rewind)
				_buffer.position = 0;

			return _buffer;
		}
	}
}