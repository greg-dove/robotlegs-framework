//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.modularity.impl
{
	import DisplayObjectContainer=org.apache.royale.core.IParent;
	import org.apache.royale.events.IEventDispatcher; //note: @royaleignorecoercion org.apache.royale.events.IEventDispatcher
	import robotlegs.bender.extensions.viewManager.api.IViewManager;
	import robotlegs.bender.extensions.viewManager.impl.ViewManagerEvent;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * @private
	 */
	public class ViewManagerBasedExistenceWatcher
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _logger:ILogger;

		private var _viewManager:IViewManager;

		private var _context:IContext;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function ViewManagerBasedExistenceWatcher(context:IContext, viewManager:IViewManager)
		{
			_logger = context.getLogger(this);
			_viewManager = viewManager;
			_context = context;
			_context.whenDestroying(destroy);
			init();
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/
		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		private function init():void
		{
			for each (var container:DisplayObjectContainer in _viewManager.containers)
			{
				_logger.debug("Adding context existence event listener to container {0}", [container]);
				IEventDispatcher(container).addEventListener(ModularContextEvent.CONTEXT_ADD, onContextAdd);
			}
			_viewManager.addEventListener(ViewManagerEvent.CONTAINER_ADD, onContainerAdd);
			_viewManager.addEventListener(ViewManagerEvent.CONTAINER_REMOVE, onContainerRemove);
		}
		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		private function destroy():void
		{
			for each (var container:DisplayObjectContainer in _viewManager.containers)
			{
				_logger.debug("Removing context existence event listener from container {0}", [container]);
				IEventDispatcher(container).removeEventListener(ModularContextEvent.CONTEXT_ADD, onContextAdd);
			}
			_viewManager.removeEventListener(ViewManagerEvent.CONTAINER_ADD, onContainerAdd);
			_viewManager.removeEventListener(ViewManagerEvent.CONTAINER_REMOVE, onContainerRemove);
		}
		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		private function onContainerAdd(event:ViewManagerEvent):void
		{
			_logger.debug("Adding context existence event listener to container {0}", [event.container]);
			IEventDispatcher(event.container).addEventListener(ModularContextEvent.CONTEXT_ADD, onContextAdd);
		}
		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		private function onContainerRemove(event:ViewManagerEvent):void
		{
			_logger.debug("Removing context existence event listener from container {0}", [event.container]);
			IEventDispatcher(event.container).removeEventListener(ModularContextEvent.CONTEXT_ADD, onContextAdd);
		}

		private function onContextAdd(event:ModularContextEvent):void
		{
			// We might catch out own existence event, so ignore that
			if (event.context != _context)
			{
				event.stopImmediatePropagation();
				_logger.debug("Context existence event caught. Configuring child context {0}", [event.context]);
				_context.addChild(event.context);
			}
		}
	}
}
