package
{
	import flash.utils.*;

	import org.msgpack.*;

	public class DateWorker extends Worker
	{
		private var worker:Worker;

		public function DateWorker(factory:Factory, byte:int = -1)
		{
			super(factory, byte);
		}

		override public function assembly(data:*, destination:IDataOutput):void
		{
			var value:Number = data.time;

			if (!worker)
				worker = factory.getWorkerByType(value);

			worker.assembly(value, destination);
		}
	}
}