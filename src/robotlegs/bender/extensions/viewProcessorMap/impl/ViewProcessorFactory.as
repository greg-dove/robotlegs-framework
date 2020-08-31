//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.viewProcessorMap.impl
{
	import DisplayObject=org.apache.royale.core.IUIBase;
	import org.apache.royale.events.Event;
	COMPILE::SWF{ import flash.utils.Dictionary; }
	import org.swiftsuspenders.errors.InjectorInterfaceConstructionError;
	import robotlegs.bender.extensions.matching.ITypeFilter;
	import robotlegs.bender.extensions.viewProcessorMap.api.ViewProcessorMapError;
	import robotlegs.bender.extensions.viewProcessorMap.dsl.IViewProcessorMapping;
	import robotlegs.bender.framework.api.IInjector;
	import robotlegs.bender.framework.impl.applyHooks;
	import robotlegs.bender.framework.impl.guardsApprove;

	/**
	 * @private
	 */
	public class ViewProcessorFactory implements IViewProcessorFactory
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _injector:IInjector;
//@todo review this... it originally relied on Weak keys in flash.
		COMPILE::SWF
		private var _listenersByView:Dictionary = new Dictionary();//new Dictionary(true); swapping out weak keys to be consistent with JS
		COMPILE::JS
		private var _listenersByView:Map = new Map(); //cannot use WeakMap because it needs to be iterable

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function ViewProcessorFactory(injector:IInjector)
		{
			_injector = injector;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @inheritDoc
		 */
		public function runProcessors(view:Object, type:Class, processorMappings:Array):void
		{
			createRemovedListener(view, type, processorMappings);

			var filter:ITypeFilter;

			for each (var mapping:IViewProcessorMapping in processorMappings)
			{
				filter = mapping.matcher;
				mapTypeForFilterBinding(filter, type, view);
				runProcess(view, type, mapping);
				unmapTypeForFilterBinding(filter, type, view);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function runUnprocessors(view:Object, type:Class, processorMappings:Array):void
		{
			for each (var mapping:IViewProcessorMapping in processorMappings)
			{
				// ?? Is this correct - will assume that people are implementing something sensible in their processors.
				mapping.processor ||= createProcessor(mapping.processorClass);
				mapping.processor.unprocess(view, type, _injector);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function runAllUnprocessors():void
		{
			COMPILE::SWF{
				for each (var removalHandlers:Array in _listenersByView)
				{
					const iLength:uint = removalHandlers.length;
					for (var i:uint = 0; i < iLength; i++)
					{
						removalHandlers[i](null);
					}
				}
			}
			COMPILE::JS{
				_listenersByView.forEach(
					function(removalHandlers:Array):void{
						const iLength:uint = removalHandlers.length;
						for (var i:uint = 0; i < iLength; i++)
						{
							removalHandlers[i](null);
						}
					}, this
				)
			}



		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function runProcess(view:Object, type:Class, mapping:IViewProcessorMapping):void
		{
			if (guardsApprove(mapping.guards, _injector))
			{
				mapping.processor ||= createProcessor(mapping.processorClass);
				applyHooks(mapping.hooks, _injector);
				mapping.processor.process(view, type, _injector);
			}
		}

		private function createProcessor(processorClass:Class):Object
		{
			if (!_injector.hasMapping(processorClass))
			{
				_injector.map(processorClass).asSingleton();
			}

			try
			{
				return _injector.getInstance(processorClass);
			}
			catch (error:InjectorInterfaceConstructionError)
			{
				var errorMsg:String = "The view processor "
					+ processorClass
					+ " has not been mapped in the injector, "
					+ "and it is not possible to instantiate an interface. "
					+ "Please map a concrete type against this interface.";
				throw(new ViewProcessorMapError(errorMsg));
			}
			return null;
		}

		private function mapTypeForFilterBinding(filter:ITypeFilter, type:Class, view:Object):void
		{
			var requiredType:Class;
			const requiredTypes:Vector.<Class> = requiredTypesFor(filter, type);

			for each (requiredType in requiredTypes)
			{
				_injector.map(requiredType).toValue(view);
			}
		}

		private function unmapTypeForFilterBinding(filter:ITypeFilter, type:Class, view:Object):void
		{
			var requiredType:Class;
			const requiredTypes:Vector.<Class> = requiredTypesFor(filter, type);

			for each (requiredType in requiredTypes)
			{
				if (_injector.hasDirectMapping(requiredType))
					_injector.unmap(requiredType);
			}
		}

		private function requiredTypesFor(filter:ITypeFilter, type:Class):Vector.<Class>
		{
			const requiredTypes:Vector.<Class> = filter.allOfTypes.concat(filter.anyOfTypes);

			if (requiredTypes.indexOf(type) == -1)
				requiredTypes.push(type);

			return requiredTypes;
		}

		private function createRemovedListener(view:Object, type:Class, processorMappings:Array):void
		{
			if (view is DisplayObject)
			{
				COMPILE::SWF{
					_listenersByView[view] ||= [];
				}
				COMPILE::JS{
					if (!_listenersByView.has(view) )
						_listenersByView.set(view, []);
				}


				const handler:Function = function(e:Event):void {
					runUnprocessors(view, type, processorMappings);
					(view as DisplayObject).removeEventListener("removedFromStage" /*Event.REMOVED_FROM_STAGE */, handler);
					removeHandlerFromView(view, handler);
				};

				COMPILE::SWF{
					_listenersByView[view].push(handler);
				}
				COMPILE::JS{
					_listenersByView.get(view).push(handler);
				}

				(view as DisplayObject).addEventListener("removedFromStage" /*Event.REMOVED_FROM_STAGE */, handler, false/*, 0, true*/);
			}
		}

		private function removeHandlerFromView(view:Object, handler:Function):void
		{

			COMPILE::SWF{
				const viewListeners:Array =_listenersByView[view];
			}
			COMPILE::JS{
				const viewListeners:Array = _listenersByView.get(view);
			}

			if (viewListeners && (viewListeners.length > 0))
			{
				const handlerIndex:uint = viewListeners.indexOf(handler);
				viewListeners.splice(handlerIndex, 1);
				if (viewListeners.length == 0)
				{
					COMPILE::SWF{
						delete _listenersByView[view];
					}
					COMPILE::JS{
						_listenersByView.delete(view);
					}
				}
			}
		}
	}
}
