//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved.
//
//  NOTICE: You are permitted to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.mediatorMap.impl
{
	COMPILE::SWF{ import flash.utils.Dictionary; }
	import robotlegs.bender.extensions.matching.ITypeFilter;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMapping;
	import robotlegs.bender.framework.api.IInjector;
	import robotlegs.bender.framework.impl.applyHooks;
	import robotlegs.bender.framework.impl.guardsApprove;

	/**
	 * @private
	 */
	public class MediatorFactory
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/
		COMPILE::SWF
		private const _mediators:Dictionary = new Dictionary();
		COMPILE::JS
		private const _mediators:Map = new Map();

		private var _injector:IInjector;

		private var _manager:MediatorManager;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function MediatorFactory(injector:IInjector, manager:MediatorManager = null)
		{
			_injector = injector;
			_manager = manager || new MediatorManager(this);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @private
		 * @royaleignorecoercion Map
		 */
		public function getMediator(item:Object, mapping:IMediatorMapping):Object
		{
			COMPILE::SWF{
				return _mediators[item] ? _mediators[item][mapping] : null;
			}
			COMPILE::JS{
				return _mediators.has(item) ? (_mediators.get(item) as Map).get(mapping) : null;
			}

		}

		/**
		 * @private
		 */
		public function createMediators(item:Object, type:Class, mappings:Array):Array
		{
			const createdMediators:Array = [];
			var mediator:Object;
			for each (var mapping:IMediatorMapping in mappings)
			{
				mediator = getMediator(item, mapping);

				if (!mediator)
				{
					mapTypeForFilterBinding(mapping.matcher, type, item);
					mediator = createMediator(item, mapping);
					unmapTypeForFilterBinding(mapping.matcher, type, item)
				}

				if (mediator)
					createdMediators.push(mediator);
			}
			return createdMediators;
		}

		/**
		 * @private
		 */
		public function removeMediators(item:Object):void
		{
			COMPILE::SWF{
				const mediators:Dictionary = _mediators[item];
				if (!mediators)
					return;

				for (var mapping:Object in mediators)
				{
					_manager.removeMediator(mediators[mapping], item, mapping as IMediatorMapping);
				}

				delete _mediators[item];
			}
			COMPILE::JS{
				const mediators:Map = _mediators.get(item);
				if (!mediators)
					return;

				//Don't use an IteratorIterable approach to maintain compatibility with IE11
				//IE11
				//ref: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map/forEach
				var manager:MediatorManager = _manager;
				mediators.forEach(
						function(value:Object, mapping:IMediatorMapping):void {
							manager.removeMediator(value, item, mapping );
						}, this
				)

				_mediators.delete(item);
			}
		}

		/**
		 * @private
		 */
		public function removeAllMediators():void
		{
			for (var item:Object in _mediators)
			{
				removeMediators(item);
			}
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function createMediator(item:Object, mapping:IMediatorMapping):Object
		{
			var mediator:Object = getMediator(item, mapping);

			if (mediator)
				return mediator;

			if (mapping.guards.length == 0 || guardsApprove(mapping.guards, _injector))
			{
				const mediatorClass:Class = mapping.mediatorClass;
				mediator = _injector.instantiateUnmapped(mediatorClass);
				if (mapping.hooks.length > 0)
				{
					_injector.map(mediatorClass).toValue(mediator);
					applyHooks(mapping.hooks, _injector);
					_injector.unmap(mediatorClass);
				}
				addMediator(mediator, item, mapping);
			}
			return mediator;
		}

		/**
		 *
		 * @royaleignorecoercion Map
		 */
		private function addMediator(mediator:Object, item:Object, mapping:IMediatorMapping):void
		{
			COMPILE::SWF{
				_mediators[item] ||= new Dictionary();
				_mediators[item][mapping] = mediator;
			}
			COMPILE::JS{
				if (!_mediators.has(item)) _mediators.set(item, new Map());
				(_mediators.get(item) as Map).set(mapping, mediator);
			}
			_manager.addMediator(mediator, item, mapping);
		}

		private function mapTypeForFilterBinding(filter:ITypeFilter, type:Class, item:Object):void
		{
			for each (var requiredType:Class in requiredTypesFor(filter, type))
			{
				_injector.map(requiredType).toValue(item);
			}
		}

		private function unmapTypeForFilterBinding(filter:ITypeFilter, type:Class, item:Object):void
		{
			for each (var requiredType:Class in requiredTypesFor(filter, type))
			{
				if (_injector.satisfiesDirectly(requiredType))
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
	}
}
