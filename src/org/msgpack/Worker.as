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
	 * Worker base class. Workers are assigned to factories where they are used to encode/decode message pack data. Each type of data uses a own worker.<br>
	 * If you want to create a custom worker (for a custom type) you need to create a class which extends this class.
	 * @see Factory
	 */
	public class Worker
	{
		/**
		 * Static method which checks whether this worker is capable of decoding the data type of this byte.<br>
		 * Children classes must rewrite this static method.
		 * @param byte Signature byte of a message pack object.
		 * @return Must return true if this worker is capable of decoding the following data.
		 */
		public static function checkType(byte:int):Boolean
		{
			return false;
		}

		/**
		 * The instance of the parent factory
		 */
		protected var factory:Factory;
		/**
		 * The signature byte of the following data. If this worker was created to encode an object, the value of this property is always -1.
		 */
		protected var byte:int;

		/**
		 * Construct a new instance of this worker. Workers are created anytime that the parent factory needs to encode or decode the data type handled by this worker.
		 * @param factory Parent factory
		 * @param byte Signature byte
		 */
		public function Worker(factory:Factory, byte:int = -1)
		{
			this.factory = factory;
			this.byte = byte;
		}

		/**
		 * The instance of the parent factory.
		 * @return Return the instance of the parent factory.
		 */
		public function getFactory():Factory
		{
			return factory;
		}

		/**
		 * The signature byte of the following data. If this worker was created to encode an object, the value of this property is always -1.
		 * @return Return the signature byte.
		 */
		public function getByte():int
		{
			return byte;
		}

		/**
		 * Encode parameter data into the destination stream.
		 * @param data Object to be encoded.
		 * @param destination Object which implements IDataOutput where the encode object will be written.
		 * @see MsgPack#write()
		 */
		public function assembly(data:*, destination:IDataOutput):void
		{
		}

		/**
		 * Decode an object from the source stream. If not all bytes of the object are available, this method must return <code>incomplete</code>,
		 * but the content which was already decoded is saved. Thus, you can read stream data making successives calls to this method.
		 * @param source Object which implements IDataInput where the decoded object will be read.
		 * @return The decoded object
		 * @see org.msgpack#incomplete
		 * @see MsgPack#read()
		 */
		public function disassembly(source:IDataInput):*
		{
			return incomplete;
		}
	}
}