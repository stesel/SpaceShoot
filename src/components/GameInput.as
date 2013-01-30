package components 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class GameInput 
	{
		public var mouseIsDown:Boolean = false;
		public var mouseClickX:int = 0;
		public var mouseClickY:int = 0;
		public var mouseX:int = 0;
		public var mouseY:int = 0;
		
		public var pressing:Object = { up:0, down:0, left:0, right:0, fire:0 };
		
		public var cameraAngleX:Number = 0;
		public var cameraAngleY:Number = 0;
		public var cameraAngleZ:Number = 0;
		
		public var delta:int;
		
		public var mouseLookMode:Boolean = true;
		
		public var stage:Stage;
		
		public var zoomX:Number = 0;
		public var zoomY:Number = 0;
		
		
		public function GameInput(_stage:Stage = null)
		{
			stage = _stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			stage.addEventListener(Event.ACTIVATE, activate);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			stage.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoom);
		}
		
		private function onZoom(e:TransformGestureEvent):void 
		{
			zoomX *= e.scaleX;
			zoomY *= e.scaleY;
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			trace("keyPressed " + e.keyCode);
			
			switch(e.keyCode)
			{
				case Keyboard.UP:
				case 87:
					pressing.up = true;
					break;
				case Keyboard.DOWN:
				case 83:
					pressing.down = true;
					break;
				case Keyboard.LEFT:
				case 65:
					pressing.left = true;
					break;
				case Keyboard.RIGHT:
				case 68:
					pressing.right = true;
					break;
				case Keyboard.SPACE:
					pressing.fire = true;
					break;
			}
		}
		
		private function keyUp(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case Keyboard.UP:
				case 87:
					pressing.up = false;
					break;
				case Keyboard.DOWN:
				case 83:
					pressing.down = false;
					break;
				case Keyboard.LEFT:
				case 65:
					pressing.left = false;
					break;
				case Keyboard.RIGHT:
				case 68:
					pressing.right = false;
					break;
				case Keyboard.SPACE:
					pressing.fire = false;
					break;
			}
		}
		
		private function mouseDown(e:MouseEvent):void 
		{
			trace("mouseDown at " + e.stageX + ", " + e.stageY);
			mouseClickX = e.stageX;
			mouseClickY = e.stageY;
			mouseIsDown = true;
		}
		
		private function mouseUp(e:MouseEvent):void 
		{
			trace("mouse up at " + e.stageX + ", " + e.stageY + ", drag dist: " + (e.stageX - mouseClickX) + ", " + (e.stageY - mouseClickY));
			mouseIsDown = false;
			if (mouseLookMode)
				cameraAngleX = cameraAngleY = cameraAngleZ = 0;
		}
		
		private function mouseMove(e:MouseEvent):void 
		{
			mouseX = e.stageX;
			mouseY = e.stageY;
			if (mouseIsDown && mouseLookMode)
			{
				cameraAngleY = 180 * (mouseX - mouseClickX) / stage.width;
				cameraAngleX = 180 * (mouseY - mouseClickY) / stage.height;
			}
		}
		
		
		private function mouseWheel(e:MouseEvent):void 
		{
			if (mouseLookMode)
			{
				delta -= e.delta / 3;
				//trace(delta);
			}
		}	
		
		private function activate(e:Event):void 
		{
			trace("Game received keyboadr focus");
		}
		
		private function deactivate(e:Event):void 
		{
			pressing.up = false;
			pressing.down = false;
			pressing.left = false;
			pressing.right = false;
			pressing.fire = false;
		}
		
	}

}