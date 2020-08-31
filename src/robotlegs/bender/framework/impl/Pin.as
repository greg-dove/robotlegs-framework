//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.framework.impl
{
	import org.apache.royale.events.IEventDispatcher;
	COMPILE::SWF{ import flash.utils.Dictionary; }
	import robotlegs.bender.framework.api.PinEvent;

	/**
	 * Pins objects in memory
	 *
	 * @private
	 */
	public class Pin
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		//@todo check impact of removing weak keys
		COMPILE::SWF
		private const _instances:Dictionary = new Dictionary();//new Dictionary(false);

		COMPILE::JS
		private const _instances:Map = new Map();

		private var _dispatcher:IEventDispatcher;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function Pin(dispatcher:IEventDispatcher)
		{
			_dispatcher = dispatcher;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * Pin an object in memory
		 * @param instance Instance to pin
		 */
		public function detain(instance:Object):void
		{
			COMPILE::SWF{
				if (!_instances[instance])
				{
					_instances[instance] = true;
					_dispatcher.dispatchEvent(new PinEvent(PinEvent.DETAIN, instance));
				}
			}
			COMPILE::JS{
				if (!_instances.has(instance))
				{
					_instances.set(instance, true);
					_dispatcher.dispatchEvent(new PinEvent(PinEvent.DETAIN, instance));
				}
			}
		}

		/**
		 * Unpins an object
		 * @param instance Instance to unpin
		 */
		public function release(instance:Object):void
		{
			COMPILE::SWF{
				if (_instances[instance])
				{
					delete _instances[instance];
					_dispatcher.dispatchEvent(new PinEvent(PinEvent.RELEASE, instance));
				}
			}
			COMPILE::JS{
				if (_instances.has(instance))
				{
					_instances.delete(instance);
					_dispatcher.dispatchEvent(new PinEvent(PinEvent.RELEASE, instance));
				}
			}
		}

		/**
		 * Removes all pins
		 */
		public function releaseAll():void
		{
			COMPILE::SWF{
				for (var instance:Object in _instances)
				{
					release(instance);
				}
			}
			COMPILE::JS{
				_instances.forEach(
					function(value:Object, instance:Object):void{
						release(instance);
					}, this
				)
			}
		}
	}
}
