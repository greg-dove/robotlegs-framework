//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.framework.impl
{
	COMPILE::SWF{ import flash.utils.Dictionary; }
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * Installs custom extensions into a given context
	 *
	 * @private
	 */
	public class ExtensionInstaller
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/
		//@todo review impact of switching from weak keys to non-weak keys here:
		COMPILE::SWF
		private const _classes:Dictionary = new Dictionary();//new Dictionary(true);

		COMPILE::JS
		private const _classes:Map = new Map();

		private var _context:IContext;

		private var _logger:ILogger;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function ExtensionInstaller(context:IContext)
		{
			_context = context;
			_logger = _context.getLogger(this);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * Installs the supplied extension
		 * @param extension An object or class implementing IExtension
		 */
		COMPILE::SWF
		public function install(extension:Object):void
		{
			if (extension is Class)
			{
				_classes[extension] || install(new (extension as Class));
			}
			else
			{
				const extensionClass:Class = extension.constructor as Class;
				if (_classes[extensionClass])
					return;
				_logger.debug("Installing extension {0}", [extension]);
				_classes[extensionClass] = true;
				extension.extend(_context);
			}
		}

		/**
		 * Installs the supplied extension
		 * @param extension An object or class implementing IExtension
		 *
		 * @royaleignorecoercion Class
		 */
		COMPILE::JS
		public function install(extension:Object):void
		{
			if (extension is Class)
			{
				if (!_classes.has(extension)) install(new (extension as Class));
			}
			else
			{
				const extensionClass:Class = extension.constructor as Class;
				if (_classes.has(extensionClass))
					return;
				_logger.debug("Installing extension {0}", [extension]);
				_classes.set(extensionClass, true);
				extension.extend(_context);
			}
		}


		/**
		 * Destroy
		 */
		public function destroy():void
		{
			COMPILE::SWF{
				for (var extensionClass:Object in _classes)
				{
					delete _classes[extensionClass];
				}
			}
			COMPILE::JS{
				_classes.forEach(
					function(value:Object,extensionClass:Object, map:Map ):void{
						map.delete(extensionClass);
					}, this
				)

			}

		}
	}
}
