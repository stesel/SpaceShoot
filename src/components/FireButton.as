package components 
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientGlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class FireButton extends Sprite 
	{
		static private const BUTTON_RADIUS:int = 32;
		private var button:Sprite;
		
		public function FireButton() 
		{
				//Text Format Initialization
            var format:TextFormat = new TextFormat();
            format.font = "Times New Roman";
            format.color = 0xffffff;
            format.size = 22;
			format.align = "center";
			format.bold = true;
			
			//Text Field Initialization
			var buttonText: TextField;
			buttonText = new TextField();
			buttonText.defaultTextFormat = format;
			buttonText.selectable = false;
			buttonText.multiline = true;
			buttonText.antiAliasType = AntiAliasType.ADVANCED;
			buttonText.text = "FIRE";
			buttonText.autoSize = TextFieldAutoSize.CENTER;
			
			//Stroke Glow Initialization
			var strokeGlow:GradientGlowFilter;
			strokeGlow = new GradientGlowFilter(); 
			strokeGlow.distance = 0; 
			strokeGlow.angle = 45; 
			strokeGlow.colors = [0x000000, 0x000000];
			strokeGlow.alphas = [0, 1]; 
			strokeGlow.ratios = [0, 255]; 
			strokeGlow.blurX = 2; 
			strokeGlow.blurY = 2; 
			strokeGlow.strength = 3;
			strokeGlow.quality = BitmapFilterQuality.LOW;
			strokeGlow.type = BitmapFilterType.OUTER;
					
			//Add Filter Array to Text
			buttonText.filters = [strokeGlow];
				
			//Text Position	
			buttonText.x = - buttonText.textWidth / 2 - 2;
			buttonText.y = - buttonText.textHeight / 2;
			//buttonText.width = buttonText.textWidth + -3;
			//buttonText.height = buttonText.textHeight;
			
			this.addChild(buttonText);
			
			//Draw Round Background
			this.graphics.lineStyle(3, 0xffffff);
			this.graphics.beginFill(0xffffff ,0.6);
			this.graphics.drawCircle(0, 0, BUTTON_RADIUS);
			
			//Set Button Mode
			this.buttonMode = true;
			this.mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
		}
		
//-------------------------------------------------------------------------------------------------
//
//	Methods Definition
//
//-------------------------------------------------------------------------------------------------
		
		
		
//-------------------------------------------------------------------------------------------------
//
//	Event Handlers
//
//-------------------------------------------------------------------------------------------------
		
		
		private function mouseDown(e:MouseEvent):void 
		{
			e.stopPropagation();
			this.scaleX = 1.1;
			this.scaleY = 1.1;
			addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addEventListener(MouseEvent.MOUSE_OUT, mouseUp);
			
			dispatchEvent(new FireEvent(FireEvent.FIRE_PROCESSED, false, false, FireEvent.ON_FIRE));
		}
		
		private function mouseUp(e:MouseEvent):void 
		{
			this.scaleX = 1;
			this.scaleY = 1;
			
			removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseUp);
			
			dispatchEvent(new FireEvent(FireEvent.FIRE_PROCESSED, false, false, FireEvent.OFF_FIRE));
		}
		
	}

}