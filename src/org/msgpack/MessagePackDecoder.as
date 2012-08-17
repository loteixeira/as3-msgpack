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