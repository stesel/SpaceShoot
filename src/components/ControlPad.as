package components
{
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class ControlPad extends Sprite 
	{
		static private const CIRCLE_RADIUS:int = 60;
		static private const PAD_RADIUS:int = 28;
		static private const PAD_LIMIT:int = 50;
		private var circle:Sprite;
		private var circleX:int = 0;
		private var circleY:int = 0;
		private var pad:Sprite;
		
		private var _x:Number;
		private var _y:Number;
		public var dx:Number = 0;
		public var dy:Number = 0;
		private var rad:Number;
		private var dist:Number;
		
		public function ControlPad() 
		{
			initGraph();
			activate();
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------

		private function initGraph():void 
		{
			//Circle
			circle = new Sprite();
			circle.graphics.clear();
			circle.graphics.lineStyle(5, 0xffffff, 0.6);
			circle.graphics.beginFill(0xffffff, 0.2);
			circle.graphics.drawCircle(0, 0, CIRCLE_RADIUS);
			circle.graphics.endFill();
			addChild(circle);
			
			//Pad
			var fillType:String = GradientType.RADIAL;
			var colors:Array = [0xffffff, 0xB0B0B0];
			var alphas:Array = [1, 1];
			var ratios:Array = [0x0, 0x3C];
			//
			pad = new Sprite();
			pad.buttonMode = true;
			pad.graphics.clear();
			pad.graphics.beginGradientFill(fillType, colors, alphas, ratios);
			pad.graphics.drawCircle(0, 0, PAD_RADIUS);
			pad.graphics.endFill();
			addChild(pad);
		}
		
		private function activate():void 
		{
			pad.addEventListener(MouseEvent.MOUSE_DOWN, pad_mouseDown);
		}
		
		private function deactivate():void 
		{
			pad.removeEventListener(MouseEvent.MOUSE_DOWN, pad_mouseDown);
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Event Handlers
//
//-------------------------------------------------------------------------------------------------
		
		private function pad_mouseDown(e:MouseEvent):void 
		{
			e.stopPropagation();
			var matrix:Matrix = new Matrix(); // creates an identity matrix 
			pad.cacheAsBitmapMatrix = matrix; 
			pad.cacheAsBitmap = true;
			
			pad.x = this.mouseX;
			pad.y = this.mouseY;
			
			dx = (pad.x) / PAD_LIMIT;
			dy = (pad.y) / PAD_LIMIT;
			
			dx = Number(dx.toFixed(3));
			dy = - Number(dy.toFixed(3));
			
			dispatchEvent(new ControlPadEvent(ControlPadEvent.PAD_MOVE, false, false, dx, dy));
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, pad_mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, pad_mouseUp);
		}
		
		private function pad_mouseUp(e:MouseEvent):void 
		{
			pad.cacheAsBitmap = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, pad_mouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, pad_mouseUp);
			
			pad.x = circleX;
			pad.y = circleY;
			
			dx = 0;
			dy = 0;
			
			dispatchEvent(new ControlPadEvent(ControlPadEvent.PAD_MOVE, false, false, dx, dy));
		}
		
		private function pad_mouseMove(e:MouseEvent):void 
		{
			_x = this.mouseX;
			_y = this.mouseY;
			
			dx = (_x) / PAD_LIMIT;
			dy = (_y) / PAD_LIMIT;
			
			dist = Math.sqrt((dx * dx) + (dy * dy));
			
			if (dist >= 1)
			{
				rad = Math.atan2(dy, dx);
				_x = PAD_LIMIT * Math.cos(rad)  + circleX;
				_y = PAD_LIMIT * Math.sin(rad)  + circleY;
				dx = (_x - circleX) / PAD_LIMIT;
				dy = (_y - circleY) / PAD_LIMIT;
			}
			
			dx = Number(dx.toFixed(1));
			dy = - Number(dy.toFixed(1));
			
			pad.x = _x;
			pad.y = _y;
			
			dispatchEvent(new ControlPadEvent(ControlPadEvent.PAD_MOVE, false, false, dx, dy));
		}
	}

}