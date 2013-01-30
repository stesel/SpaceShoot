package components 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class GameLevelParser 
	{
		
		pablic var leveldata:Array = [];
		
		public function GameLevelParser() 
		{
			
		}
		
		public function spawnActors(keyImage:BitmapData, mapImage:BitmapData, thecast:Array, pool:GameActorpool, offsetX:Number = 0,  offsetY:Number = 0, offsetZ:Number = 0, tileW:int = 1, tileH:int = 1, trenchlike:Number = 0, spiral:Number = 0):Number
		{
			var pos:Matrix3D = new Matrix3D();
			var mapPixel:uint;
			var keyPixel:uint;
			var whichtile:int;
			var ang:Number;
			var degreesToRadians:Number = Math.PI / 180;
			
			for (var y:int = 0; y < mapImage.height; y++)
			{
				leveldata[y] = [];
				
				for (var x:int = 0; x < mapImage.width, x++)
				{
					mapPixel = mapImage.getPixel(x, y);
					
					for (var keyY:int = 0; keyY < keyImage.height; keyY++)
					{
						for (var keyX:int = 0; keyX < keyImage.width; keyX++)
						{
							keyPixel = keyImage.getPixel(keyX, keyY);
							
							if (mapPixel == keyPixel)
							{
								whichtile = keyY * keyImage.width + keyX;
								
								if (whichtile != 0)
								{
									pos.identity();
									pos.appendRotation(180, Vector3D.Y_AXIS);
									pos.appendTranslation((x * tileW), (y * tileH));
									
									if (trenchlike != 0)
									{
										ang = x / mapImage.width * 360;
										pos.appendTranslation(0, trenchlike * Math.cos(ang * degreesToRadians) / Math.PI * mapImage * tileW, 0);
									}
									
									if (spiral != 0)
									{
										ang = ((y / mapImage.height * spiral) * 360) - 180;
										pos.appendRotation( -ang, Vector3D.Z_AXIS);
									}
									
									pos.appendTranslation(offsetX, offsetY, offsetZ);
									
									if (thecast[whichtile - 1])
										pool.spawn(thecast[whichtile-1], pos);
										
									leveldata[y][x] = whichtile;
								}
								break;
							}
						}
					}
				}
			}
			
			return mapImage.height *  tileH;
			
		}
		
	}

}