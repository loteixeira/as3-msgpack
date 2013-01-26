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

	/**
	 * MessagePack class. Use objects of this class to read and write message pack data.<br>
	 * Each MsgPack instance has a Factory instance.
	 * @see Factory
	 */
	public class MsgPack
	{
		//
		// static attributes
		//
		/**
		 * Major version value.
		 */
		public static const MAJOR:uint = 1;
		/**
		 * Minor version value.
		 */
		public static const MINOR:uint = 0;
		/**
		 * Revision version value;
		 */
		public static const REVISION:uint = 0;

		/**
		 * Get full version as string.
		 * @return Full version string.
		 */
		public static function get VERSION():String
		{
			return MAJOR + "." + MINOR + "." + REVISION;
		}

		//
		// private attributes
		//
		private var _factory:Factory;
		private var root:Worker;


		//
		// constructor
		//
		/**
		 * Create a new instance of <code>MsgPack</code> capable of reading/writing data.
		 * You can decode streaming data using the method <code>read</code>.<br>
		 * The standard workers are:<br>
		 * <li><code>NullWorker: null</code></li>
		 * <li><code>BooleanWorker: Boolean</code></li>
		 * <li><code>IntegerWorker: int and uint</code></li>
		 * <li><code>NumberWorker: Number</code></li>
		 * <li><code>ArrayWorker: Array</code></li>
		 * <li><code>RawWorker: ByteArray or String</code></li>
		 * <li><code>MapWorker: Object</code></li>
		 * @param flags Set of flags capable of customizing the runtime behavior of this object.
		 * @see #read()
		 * @see #write()
		 * @see Worker
		 * @see MsgPackFlags#READ_RAW_AS_BYTE_ARRAY
		 * @see MsgPackFlags#ACCEPT_LITTLE_ENDIAN
		 * @see Factory#checkFlag()
		 */
		public function MsgPack(flags:uint = 0)
		{
			_factory = new Factory(flags);
			_factory.assign(NullWorker, null);
			_factory.assign(BooleanWorker, Boolean);
			_factory.assign(IntegerWorker, int, uint);
			_factory.assign(NumberWorker, Number);
			_factory.assign(ArrayWorker, Array);
			_factory.assign(RawWorker, ByteArray, String);
			_factory.assign(MapWorker, Object);
		}

		//
		// getters and setters
		//
		/**
		 * Get the factory associated to this object.
		 * @return Factory instance used by this instance.
		 * @see Worker
		 */
		public function get factory():Factory
		{
			return _factory;
		}

		//
		// public interface
		//
		/**
		 * Write an object in <code>output</code> buffer.
		 * @param data Object to be encoded
		 * @param output Any object that implements <code>IDataOutput</code> interface (<code>ByteArray</code>, <code>Socket</code>, <code>URLStream</code>, etc).
		 * @return Return <code>output</code> whether it isn't <code>null</code>. Otherwise return a new <code>ByteArray</code>.
		 * @see Worker#assembly()
		 */
		public function write(data:*, output:IDataOutput = null):*
		{
			var worker:Worker = _factory.getWorkerByType(data);

			if (!output)
				output = new ByteArray();

			checkBigEndian(output);

			worker.assembly(data, output);
			return output;
		}

		/**
		 * Read an object from <code>input</code> buffer. This method supports streaming.
		 * If the object cannot be completely decoded (not all bytes available in <code>input</code>), <code>incomplete</code> object is returned.
		 * However, the internal state (the part that was already decoded) is saved. Thus, you can read from a stream if you make successive calls to this method.
		 * If all bytes are available, the decoded object is returned.
		 * @param input Any object that implements <code>IDataInput</code> interface (<code>ByteArray</code>, <code>Socket</code>, <code>URLStream</code>, etc).
		 * @return Return the decoded object if all bytes were available in the input stream, otherwise returns <code>incomplete</code> object.
		 * @see org.msgpack#incomplete
		 * @see Worker#disassembly()
		 */
		public function read(input:IDataInput):*
		{
			checkBigEndian(input);

			if (!root)
			{
				if (input.bytesAvailable == 0)
					return incomplete;

				root = _factory.getWorkerByByte(input);
			}

			var obj:* = root.disassembly(input);

			if (obj != incomplete)
				root = undefined;

			return obj;
		}

		private function checkBigEndian(dataStream:*):void
		{
			if (dataStream.endian == "littleEndian" && !_factory.checkFlag(MsgPackFlags.ACCEPT_LITTLE_ENDIAN))
				throw new MsgPackError("Provided object uses little endian but MessagePack was designed for big endian. To avoid this error use the flag ACCEPT_LITTLE_ENDIAN.");
		}
	}
}