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
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	/**
	 * MessagePack class. Use objects of this class to read and write message pack data.<br>
	 * Each MsgPack instance has a Factory instance.
	 * @see Factory
	 */
	public class MsgPack extends EventDispatcher
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

		/**
		 * Flag which indicates that raw buffers must be decoded as a ByteArray instead of a String.
		 * @see Factory#checkFlag()
		 */
		public static const READ_RAW_AS_BYTE_ARRAY:uint = 0x01;
		/**
		 * Flag which indicates that little endian buffers must be accepted (MessagePack specification works only with big endian).
		 * @see Factory#checkFlag()
		 */
		public static const ACCEPT_LITTLE_ENDIAN:uint = 0x02;

		//
		// private attributes
		//
		private var _factory:Factory;
		private var root:Worker;


		//
		// constructor
		//
		/**
		 * Create a new instance of MsgPack capable of reading/writing data.
		 * You can read stream data using method read.<br>
		 * The standard workers are:<br>
		 * <li> NullWorker: null
		 * <li> BooleanWorker: Boolean
		 * <li> IntegerWorker: int and uint
		 * <li> NumberWorker: Number
		 * <li> ArrayWorker: Array
		 * <li> RawWorker: ByteArray and String
		 * <li> MapWorker: Object
		 * @param flags Set of flags capable of customizing the runtime behavior of this object.
		 * @see #read()
		 * @see Worker
		 * @see #READ_RAW_AS_BYTE_ARRAY
		 * @see #ACCEPT_LITTLE_ENDIAN
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
		 * Get the workers factory associated to this object.
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
		 * Write an object in the output buffer.
		 * @param data Object to be encoded
		 * @param output Any object that implements IDataOutput interface (ByteArray, Socket, URLStream, etc).
		 * @return Return the output instance if isn't null. Otherwise return a new ByteArray.
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
		 * Read an object from the input buffer. This methods supports streaming.
		 * If the object isn't completely decoded (not all bytes available in input), the <code>incomplete</code> object is returned.
		 * However, the internal state (the part that was already decoded) remain saved. Thus, you can read stream data making successives calls to this method.
		 * If the input stream was successfully decoded the object is returned.
		 * @param input Any object that implements IDataInput interface (ByteArray, Socket, URLStream, etc).
		 * @return Return the decoded object if all bytes were available in the input stream, otherwise return <code>incomplete</code> object.
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
			if (dataStream.endian == "littleEndian" && !_factory.checkFlag(ACCEPT_LITTLE_ENDIAN))
				throw new MsgPackError("Provided object uses little endian but MessagePack was designed for big endian. To avoid this error use the flag ACCEPT_LITTLE_ENDIAN.");
		}
	}
}