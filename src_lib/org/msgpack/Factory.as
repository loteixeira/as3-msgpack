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
	 * The factory class is reponsible for the workers which will encode/decode data. Each MsgPack instance has it own factory.<br>
	 * <strong>You shouldn't instantiate this class using operator new. The instances are created internally by MsgPack objects.</strong>
	 * @see MsgPack
	 */
	public class Factory
	{
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

		private var flags:uint;
		private var workers:Object;
		private var root:Worker;

		/**
		 * @private
		 */
		public function Factory(flags:uint)
		{
			this.flags = flags;
			workers = {};
		}

		/**
		 * Assign a worker to specified classes.
		 * @param  workerClass The worker class.
		 * @param  ...args A list of classes to attach the worker.
		 * @see Worker
		 * @throws org.msgpack.MsgPackError Thrown when you try to assign the worker to ordinary objects not classes.
		 */
		public function assign(workerClass:Class, ...args):void
		{
			for (var i:uint = 0; i < args.length; i++)
			{
				if (args[i] != null && !(args[i] is Class))
					throw new MsgPackError("Workers must be assigned to classes not objects");

				var typeName:String = getQualifiedClassName(args[i]);
				workers[typeName] = workerClass;
			}
		}

		/**
		 * Remove a worker from any classes which was assigned.
		 * @param type The worker class.
		 * @see Worker
		 */
		public function unassign(type:Class):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName] = undefined;
		}

		/**
		 * Return the worker assigned to the class of the object data. For example, if data is the value <code>1.5</code> Number class is used.
		 * @param data Data used to find the related worker.
		 * @return Return the related worker.
		 * @throws org.msgpack.MsgPackError Thrown when no worker is assigned to the class of data.
		 */
		public function getWorkerByType(data:*):Worker
		{
			var typeName:String = data == null ? "null" : getQualifiedClassName(data);

			if (!workers[typeName])
				throw new MsgPackError("Worker for type '" + typeName + "' not found");

			return new workers[typeName](this);
		}

		/**
		 * Return the worker which is capable of decoding the next byte of the input stream.
		 * @param source Input stream.
		 * @return Return the related worker.
		 * @throws org.msgpack.MsgPackError Thrown when no worker is capable of decode the next byte of the input stream.
		 */
		public function getWorkerByByte(source:IDataInput):Worker
		{
			var byte:int = source.readByte() & 0xff;

			for each (var workerClass:Class in workers)
			{
				if (!workerClass["checkType"](byte))
					continue;

				return new workerClass(this, byte);
			}

			throw new MsgPackError("Worker for signature 0x" + byte.toString(16) + " not found");
		}

		/**
		 * Check if the flag is true.
		 * @param f The flag value.
		 * @return True or flase.
		 * @see #ACCEPT_LITTLE_ENDIAN
		 * @see #READ_RAW_AS_BYTE_ARRAY
		 */
		public function checkFlag(f:uint):Boolean
		{
			return (f & flags) != 0;
		}
	}
}