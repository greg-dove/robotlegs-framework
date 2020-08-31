//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.viewProcessorMap.impl
{
	COMPILE::SWF{ import flash.utils.Dictionary; }
	import robotlegs.bender.extensions.matching.ITypeFilter;
	import robotlegs.bender.extensions.viewProcessorMap.dsl.IViewProcessorMapper;
	import robotlegs.bender.extensions.viewProcessorMap.dsl.IViewProcessorMapping;
	import robotlegs.bender.extensions.viewProcessorMap.dsl.IViewProcessorMappingConfig;
	import robotlegs.bender.extensions.viewProcessorMap.dsl.IViewProcessorUnmapper;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * @private
	 */
	public class ViewProcessorMapper implements IViewProcessorMapper, IViewProcessorUnmapper
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		COMPILE::SWF
		private const _mappings:Dictionary = new Dictionary();

		COMPILE::JS
		private const _mappings:Map = new Map();

		private var _handler:IViewProcessorViewHandler;

		private var _matcher:ITypeFilter;

		private var _logger:ILogger;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function ViewProcessorMapper(matcher:ITypeFilter, handler:IViewProcessorViewHandler, logger:ILogger = null)
		{
			_handler = handler;
			_matcher = matcher;
			_logger = logger;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @inheritDoc
		 */
		public function toProcess(processClassOrInstance:*):IViewProcessorMappingConfig
		{
			COMPILE::SWF{
				const mapping:IViewProcessorMapping = _mappings[processClassOrInstance];
			}
			COMPILE::JS{
				const mapping:IViewProcessorMapping = _mappings.get(processClassOrInstance);
			}

			return mapping
				? overwriteMapping(mapping, processClassOrInstance)
				: createMapping(processClassOrInstance);
		}

		/**
		 * @inheritDoc
		 */
		public function toInjection():IViewProcessorMappingConfig
		{
			return toProcess(ViewInjectionProcessor);
		}

		/**
		 * @inheritDoc
		 */
		public function toNoProcess():IViewProcessorMappingConfig
		{
			return toProcess(NullProcessor);
		}

		/**
		 * @inheritDoc
		 */
		public function fromProcess(processorClassOrInstance:*):void
		{
			COMPILE::SWF{
				const mapping:IViewProcessorMapping = _mappings[processorClassOrInstance];
			}
			COMPILE::JS{
				const mapping:IViewProcessorMapping = _mappings.get(processorClassOrInstance);
			}
			mapping && deleteMapping(mapping);
		}

		/**
		 * @inheritDoc
		 */
		public function fromAll():void
		{
			COMPILE::SWF{
				for (var processor:Object in _mappings)
				{
					fromProcess(processor);
				}
			}
			COMPILE::JS{
				_mappings.forEach(
						function(value:Object, processor:Object):void{
							fromProcess(processor);
						}, this
				);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function fromNoProcess():void
		{
			fromProcess(NullProcessor);
		}

		/**
		 * @inheritDoc
		 */
		public function fromInjection():void
		{
			fromProcess(ViewInjectionProcessor);
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function createMapping(processor:Object):ViewProcessorMapping
		{
			const mapping:ViewProcessorMapping = new ViewProcessorMapping(_matcher, processor);
			_handler.addMapping(mapping);
			COMPILE::SWF{
				_mappings[processor] = mapping;
			}
			COMPILE::JS{
				_mappings.set(processor, mapping);
			}
			_logger && _logger.debug('{0} mapped to {1}', [_matcher, mapping]);
			return mapping;
		}

		private function deleteMapping(mapping:IViewProcessorMapping):void
		{
			_handler.removeMapping(mapping);
			COMPILE::SWF{
				delete _mappings[mapping.processor];
			}
			COMPILE::JS{
				_mappings.delete(mapping.processor);
			}
			_logger && _logger.debug('{0} unmapped from {1}', [_matcher, mapping]);
		}

		private function overwriteMapping(mapping:IViewProcessorMapping,
			processClassOrInstance:*):IViewProcessorMappingConfig
		{
			_logger && _logger.warn('{0} is already mapped to {1}.\n' +
				'If you have overridden this mapping intentionally you can use "unmap()" ' +
				'prior to your replacement mapping in order to avoid seeing this message.\n',
				[_matcher, mapping]);
			deleteMapping(mapping);
			return createMapping(processClassOrInstance);
		}
	}
}
