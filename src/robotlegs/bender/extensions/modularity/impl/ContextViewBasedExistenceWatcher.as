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
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * @private
	 */
	public class ContextViewBasedExistenceWatcher
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _logger:ILogger;

		private var _contextView:DisplayObjectContainer;

		private var _context:IContext;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function ContextViewBasedExistenceWatcher(context:IContext, contextView:DisplayObjectContainer)
		{
			_logger = context.getLogger(this);
			_contextView = contextView;
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
			_logger.debug("Listening for context existence events on contextView {0}", [_contextView]);
			IEventDispatcher(_contextView).addEventListener(ModularContextEvent.CONTEXT_ADD, onContextAdd);
		}
		/**
		 * @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		private function destroy():void
		{
			_logger.debug("Removing modular context existence event listener from contextView {0}", [_contextView]);
			IEventDispatcher(_contextView).removeEventListener(ModularContextEvent.CONTEXT_ADD, onContextAdd);
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
