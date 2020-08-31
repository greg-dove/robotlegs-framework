//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.mxml
{
	import DisplayObjectContainer=org.apache.royale.core.IParent;
	COMPILE::SWF{ import flash.utils.setTimeout; }
	//import mx.core.IMXMLObject;
	import org.apache.royale.utils.MXMLDataInterpreter;
	import org.apache.royale.core.IBead;
	import org.apache.royale.core.IStrand;
	import org.apache.royale.core.IMXMLDocument;
	import org.apache.royale.binding.ContainerDataBinding;
	import org.apache.royale.events.Event;
	import org.apache.royale.events.EventDispatcher;
	import org.swiftsuspenders.reflection.DescribeTypeReflector;
	import org.swiftsuspenders.reflection.Reflector;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;
	import robotlegs.bender.framework.impl.Context;

	[DefaultProperty("configs")]
	/**
	 * Apache Flex context builder tag
	 */
	public class ContextBuilderTag extends EventDispatcher implements /*IMXMLObject,*/ IMXMLDocument, IStrand
	{


		public function ContextBuilderTag(){
			addBindingSupport(); //@todo consider using same approach as Crux BeanProvider, just supporting startup assignments
		}

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		private var _configs:Array = [];

		/**
		 * Configs, extensions or bundles
		 */
		public function get configs():Array
		{
			return _configs;
		}

		/**
		 * Configs, extensions or bundles
		 */
		public function set configs(value:Array):void
		{
			_configs = value;
		}

		private var _contextView:DisplayObjectContainer;

		/**
		 * The context view
		 * @param value
		 */
		public function set contextView(value:DisplayObjectContainer):void
		{
			_contextView = value;
		}

		private const _context:IContext = new Context();

		/**
		 * The context associated with this builder
		 */
		public function get context():IContext
		{
			return _context;
		}

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _reflector:Reflector = new DescribeTypeReflector();

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		/**
		 * @inheritDoc
		 */
		public function initialized(document:Object, id:String):void
		{
			_contextView ||= document as DisplayObjectContainer;
			// if the contextView is bound it will only be set a frame later
			setTimeout(configureBuilder, 1);
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function configureBuilder():void
		{
			for each (var config:Object in _configs)
			{
				isExtension(config)
					? _context.install(config)
					: _context.configure(config);
			}

			_contextView && _context.configure(new ContextView(_contextView));
			_configs.length = 0;
		}

		private function isExtension(object:Object):Boolean
		{
			return (object is IExtension) || (object is Class && _reflector.typeImplements(object as Class, IExtension));
		}


		//porting notes, set up for use in MXML subclass
		private var _mxmlDescriptor:Array;
		private var _mxmlDocument:Object = this;
		private var _bindingSupport:ContainerDataBinding;

		public function get MXMLDescriptor():Array {
			return _mxmlDescriptor;
		}


		public function setMXMLDescriptor(document:Object, value:Array):void{
			_mxmlDocument = document;
			_mxmlDescriptor = value;
		}

		/**
		 *  @copy org.apache.royale.core.Application#generateMXMLAttributes()
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.0
		 */
		public function generateMXMLAttributes(data:Array):void{
			if (data) MXMLDataInterpreter.generateMXMLProperties(this, data);
		}

		private function addBindingSupport():void{
			if ('_bindings' in this && !_bindingSupport) {
				_bindingSupport = new ContainerDataBinding();
				_bindingSupport.strand = this;
				this.dispatchEvent(new Event('initBindings'));
			}
		}

		private var beads:Array = [];
		//conformance only for now:
		public function addBead(bead:IBead):void{
			beads.push(bead);
			bead.strand = this;
		}

		/**
		 *  Find a bead (IBead instance) on the strand.
		 *
		 *  @param classOrInterface The class or interface to use
		 *                                to search for the bead
		 *  @return The bead.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.0
		 */
		public function getBeadByType(classOrInterface:Class):IBead{
			return null;
		}

		/**
		 *  Remove a bead from the strand.
		 *
		 *  @param bead The bead (IBead instance) to be removed.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.0
		 */
		public function removeBead(bead:IBead):IBead{
			return bead;
		}
	}
}
