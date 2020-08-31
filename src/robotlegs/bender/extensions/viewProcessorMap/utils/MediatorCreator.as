//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.viewProcessorMap.utils
{
	COMPILE::SWF{ import flash.utils.Dictionary; }
	import robotlegs.bender.framework.api.IInjector;

	/**
	 * Simple Mediator creation processor
	 */
	public class MediatorCreator
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _mediatorClass:Class;
		COMPILE::SWF
		private const _createdMediatorsByView:Dictionary = new Dictionary(true);

		COMPILE::JS
		private const _createdMediatorsByView:WeakMap = new WeakMap();

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * Mediator Creator Processor
		 * @param mediatorClass The mediator class to create
		 */
		public function MediatorCreator(mediatorClass:Class)
		{
			_mediatorClass = mediatorClass;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function process(view:Object, type:Class, injector:IInjector):void
		{
			COMPILE::SWF{
				if (_createdMediatorsByView[view])
				{
					return;
				}
			}
			COMPILE::JS{
				if (_createdMediatorsByView.has(view))
				{
					return;
				}
			}
			const mediator:* = injector.instantiateUnmapped(_mediatorClass);
			COMPILE::SWF{
				_createdMediatorsByView[view] = mediator;
			}
			COMPILE::JS{
				_createdMediatorsByView.set(view, mediator);
			}
			initializeMediator(view, mediator);
		}

		/**
		 * @private
		 */
		public function unprocess(view:Object, type:Class, injector:IInjector):void
		{
			COMPILE::SWF{
				if (_createdMediatorsByView[view])
				{
					destroyMediator(_createdMediatorsByView[view]);
					delete _createdMediatorsByView[view];
				}
			}
			COMPILE::JS{
				if (_createdMediatorsByView.has(view))
				{
					destroyMediator(_createdMediatorsByView.get(view));
					_createdMediatorsByView.delete(view);
				}
			}
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function initializeMediator(view:Object, mediator:Object):void
		{
			if ('preInitialize' in mediator)
				mediator.preInitialize();

			if ('viewComponent' in mediator)
				mediator.viewComponent = view;

			if ('initialize' in mediator)
				mediator.initialize();

			if ('postInitialize' in mediator)
				mediator.postInitialize();
		}

		private function destroyMediator(mediator:Object):void
		{
			if ('preDestroy' in mediator)
				mediator.preDestroy();

			if ('destroy' in mediator)
				mediator.destroy();

			if ('viewComponent' in mediator)
				mediator.viewComponent = null;

			if ('postDestroy' in mediator)
				mediator.postDestroy();
		}
	}
}
