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

	public class Factory
	{
		private var flags:uint;
		private var workers:Object;
		private var root:Worker;

		public function Factory(flags:uint)
		{
			this.flags = flags;
			workers = {};
		}

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

		public function unassign(type:Class):void
		{
			var typeName:String = getQualifiedClassName(type);
			workers[typeName] = undefined;
		}

		public function getWorkerByType(data:*):Worker
		{
			var typeName:String = data == null ? "null" : getQualifiedClassName(data);

			if (!workers[typeName])
				throw new MsgPackError("Worker for type '" + typeName + "' not found");

			return new workers[typeName](this);
		}

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

		public function checkFlag(f:uint):Boolean
		{
			return (f & flags) != 0;
		}
	}
}