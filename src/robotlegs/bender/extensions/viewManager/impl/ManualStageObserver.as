//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.viewManager.impl
{
	import DisplayObject=org.apache.royale.core.IUIBase;
	import DisplayObjectContainer=org.apache.royale.core.IParent;
	import org.apache.royale.events.IEventDispatcher; //note: @royaleignorecoercion org.apache.royale.events.IEventDispatcher

	/**
	 * @private
	 */
	public class ManualStageObserver
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _registry:ContainerRegistry;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function ManualStageObserver(containerRegistry:ContainerRegistry)
		{
			_registry = containerRegistry;
			// We care about all containers (not just roots)
			_registry.addEventListener(ContainerRegistryEvent.CONTAINER_ADD, onContainerAdd);
			_registry.addEventListener(ContainerRegistryEvent.CONTAINER_REMOVE, onContainerRemove);
			// We might have arrived late on the scene
			for each (var binding:ContainerBinding in _registry.bindings)
			{
				addContainerListener(binding.container);
			}
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function destroy():void
		{
			_registry.removeEventListener(ContainerRegistryEvent.CONTAINER_ADD, onContainerAdd);
			_registry.removeEventListener(ContainerRegistryEvent.CONTAINER_REMOVE, onContainerRemove);
			for each (var binding:ContainerBinding in _registry.bindings)
			{
				removeContainerListener(binding.container);
			}
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function onContainerAdd(event:ContainerRegistryEvent):void
		{
			addContainerListener(event.container);
		}

		private function onContainerRemove(event:ContainerRegistryEvent):void
		{
			removeContainerListener(event.container);
		}
		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		private function addContainerListener(container:DisplayObjectContainer):void
		{
			// We're interested in ALL container bindings
			// but just for normal, bubbling events
			IEventDispatcher(container).addEventListener(ConfigureViewEvent.CONFIGURE_VIEW, onConfigureView);
		}
		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		private function removeContainerListener(container:DisplayObjectContainer):void
		{
			IEventDispatcher(container).removeEventListener(ConfigureViewEvent.CONFIGURE_VIEW, onConfigureView);
		}

		private function onConfigureView(event:ConfigureViewEvent):void
		{
			// Stop that event!
			event.stopImmediatePropagation();
			const container:DisplayObjectContainer = event.currentTarget as DisplayObjectContainer;
			const view:DisplayObject = event.target as DisplayObject;
			const type:Class = view['constructor'];
			_registry.getBinding(container).handleView(view, type);
		}
	}
}
