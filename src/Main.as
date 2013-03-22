package 
{
	import components.ControlPad;
	import components.ControlPadEvent;
	import components.FireButton;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	import components.GameActor;
	import components.GameInput;
	import components.GameTimer;
	import components.Particle3D;
	import components.ParticleSystem;
	import components.Stage3DEntity;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.system.ApplicationDomain;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	[SWF(width = "480", height = "762", frameRate = "60", backgroundColor = "#808080")]
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Main extends Sprite 
	{
		private static const RAD:Number = Math.PI / 180;
		
		private var gameTimer:GameTimer;
		
		private var gameInput:GameInput;
		private var cameraContainer:Stage3DEntity;
		private var chaseCamera:Stage3DEntity;
		
		private var playerContainer:Stage3DEntity;
		private var player:Stage3DEntity;
		private var props:Vector.<Stage3DEntity>;
		private var enemies:Vector.<Stage3DEntity>;
		private var bullets:Vector.<Stage3DEntity>;
		
		private var particles:Vector.<Stage3DEntity>;
		
		private var entity:Stage3DEntity;
		
		private var asteroid1:Stage3DEntity;
		private var asteroid2:Stage3DEntity;
		private var asteroid3:Stage3DEntity;
		private var asteroid4:Stage3DEntity;
		private var engineGlow:Stage3DEntity;
		private var sky:Stage3DEntity;
		
		private const moveSpeed:Number = 0.5;
		private const asteroidRotationSpeed:Number = 0.01;
		
		private var fpsLast:uint = getTimer();
		private var fpsTicks:uint = 0;
		private var fpsText:TextField;
		private var scoreText:TextField;
		private var score:uint = 0;
		
		private var context3D:Context3D;
		
		private var shaderProgram1:Program3D;
		
		private var projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		private var viewMatrix:Matrix3D = new Matrix3D();
		
		
		//////////////// 
		////////////////
		[Embed(source = "../lib/ship.jpg")]
		private var playerTextureBitmap:Class;
		private var playerTextureData:Bitmap = new playerTextureBitmap() as Bitmap;
		
		//[Embed(source="../lib/terrain.jpg")]
		[Embed(source="../lib/t3.jpg")]
		private var terrainTextureBitmap:Class;
		private var terrainTextureData:Bitmap = new terrainTextureBitmap() as Bitmap;
		
		[Embed(source="../lib/craters.jpg")]
		private var cratersTextureBitmap:Class;
		private var cratersTextureData:Bitmap = new cratersTextureBitmap() as Bitmap;
		
		//[Embed(source = "../lib/sky.jpg")]
		//[Embed(source="../lib/ski1.jpg")]
		[Embed(source="../lib/ski1.jpg")]
		private var skyTextureBitmap:Class;
		private var skyTextureData:Bitmap = new skyTextureBitmap() as Bitmap;
		
		[Embed(source = "../lib/engine.jpg")]
		private var puffTextureBitmap:Class;
		private var puffTextureData:Bitmap = new puffTextureBitmap() as Bitmap;
		
		[Embed(source = "../lib/hud.png")]
		private var hudData:Class;
		private var hud:Bitmap = new hudData as Bitmap;
		
		////////////////
		private var playerTexture:Texture;
		private var terrainTexture:Texture;
		private var cratersTexture:Texture;
		private var skyTexture:Texture;
		private var puffTexture:Texture;
		
		////////////////
		[Embed(source = "../lib/ship.obj", mimeType = "application/octet-stream")]
		private var shipObjData:Class;
		
		[Embed(source = "../lib/puffCluster.obj", mimeType = "application/octet-stream")]
		private var puffObjData:Class;
		
		[Embed(source="../lib/terrain.obj", mimeType="application/octet-stream")]
		//[Embed(source="../lib/terrain3.obj", mimeType="application/octet-stream")]
		private var terrainObjData:Class;
		
		[Embed(source = "../lib/asteroids.obj", mimeType = "application/octet-stream")]
		private var asteroidsObjData:Class;
		
		[Embed(source = "../lib/sphere.obj", mimeType = "application/octet-stream")]
		private var skyObjData:Class;
		
		private var moveXAmount:Number = 0;
		private var moveYAmount:Number = 0;
		private var moveZAmount:Number = 0;
		
		
		private var sin:Number = 0;
		private var cos:Number = 1;
		
		
		//////Particles
		private var nextShootTime:uint = 0;
		private var shootDelay:uint = 100;
		private var explo:Particle3D;
		private var particleSystem:ParticleSystem;
		private var scenePolycount:uint = 0;
		
		private var particleTexture1:Texture;
		private var particleTexture2:Texture;
		private var particleTexture3:Texture;
		private var particleTexture4:Texture;
		private var particleTexture5:Texture;
		
		//Sparks1 Texture
		[Embed(source="../lib/Sparks1.jpg")]
		private var particleTextureBitmap1:Class;
		private var particleTextureData1:Bitmap = new particleTextureBitmap1();
		
		//Sparks2 Texture
		[Embed(source="../lib/Sparks2.jpg")]
		private var particleTextureBitmap2:Class;
		private var particleTextureData2:Bitmap = new particleTextureBitmap2();
		
		//Sparks3 Texture
		[Embed(source="../lib/Particular1.jpg")]
		private var particleTextureBitmap3:Class;
		private var particleTextureData3:Bitmap = new particleTextureBitmap3();
		
		//Sparks4 Texture
		[Embed(source="../lib/Particular2.jpg")]
		private var particleTextureBitmap4:Class;
		private var particleTextureData4:Bitmap = new particleTextureBitmap4();
		
		//Sparks5 Texture
		[Embed(source="../lib/Particular3.jpg")]
		private var particleTextureBitmap5:Class;
		private var particleTextureData5:Bitmap = new particleTextureBitmap5();
		
		
		
		//start
		[Embed(source = "../lib/sparks1.obj", mimeType = "application/octet-stream")]
		private var explosionData1:Class;
		
		//end
		[Embed(source="../lib/sparks2.obj", mimeType="application/octet-stream")]
		private var explosionData2:Class;
		
		private var control:ControlPad;
		private var fireButton: FireButton;
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			///////////
			gameTimer = new GameTimer(heartBeat);
			gameInput = new GameInput(stage);
			
			///////////
			props = new Vector.<Stage3DEntity>();
			enemies = new Vector.<Stage3DEntity>();
			bullets = new Vector.<Stage3DEntity>();
			particles = new Vector.<Stage3DEntity>();
			
			///////////
			initGUI();
			
			var stage3DAvability:Boolean = ApplicationDomain.currentDomain.hasDefinition("flash.display.Stage3D");
			if (!stage3DAvability)
				scoreText.text = "Stage3D isn't available!";
			
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			stage.stage3Ds[0].requestContext3D();
			
			
			
			// new to AIR? please read *carefully* the readme.txt files!
		}
		
//--------------------------------------------------------------------------
//
//  Update Methods
//
//--------------------------------------------------------------------------
		
		
		private function heartBeat():void 
		{
			trace("heartbeat at " + gameTimer.gameElapsedTime + 'ms');
			trace("player " + player.posString());
			trace("camera " + chaseCamera.posString());
			
			trace("particles active: " + particleSystem.particlesActive);
			trace("particles total: " + particleSystem.particlesCreated);
			trace("particles polies: " + particleSystem.totalpolycount);
		}
		
		private function initGUI():void 
		{
			//addChild(hud);
			control = new ControlPad();
			control.x = control.width;
			control.y = control.height;
			addChild(control);
			
			fireButton = new FireButton();
			fireButton.x = stage.stageHeight - control.width * 0.6;
			fireButton.y = stage.stageWidth - fireButton.height * 1.2;
			addChild(fireButton);
			
			///////////
			var myFormat:TextFormat = new TextFormat();
			myFormat.color = 0xffffaa;
			myFormat.size = 16;
			
			///////////
			fpsText = new TextField();
			fpsText.x = 4;
			fpsText.y = 0;
			fpsText.selectable = false;
			fpsText.autoSize = TextFieldAutoSize.LEFT;
			fpsText.defaultTextFormat = myFormat;
			fpsText.text = "Initialization Stage3D...";
			addChild(fpsText);
			
			///////////
			scoreText = new TextField();
			scoreText.x = 600;
			scoreText.y = 0;
			scoreText.selectable = false;
			scoreText.autoSize = TextFieldAutoSize.LEFT;
			scoreText.defaultTextFormat = myFormat;
			scoreText.text = "Initialization Stage3D...";
			addChild(scoreText);
		}
		
		
		private function onContext3DCreate(e:Event):void 
		{
			if (hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, enterFrame);
				
			var t:Stage3D = e.target as Stage3D;
			context3D = t.context3D;
			
			if (context3D == null)
			{
				fpsText.text = "ERROR: no context3D - video driver problem?";
				trace("ERROR: no context3D - video driver problem?");
				return;
			}
			
			context3D.enableErrorChecking = true;
			
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 3, true);
			
			initShaders();
			
			playerTexture = context3D.createTexture(playerTextureData.width, playerTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(playerTexture, playerTextureData.bitmapData);
			
			terrainTexture = context3D.createTexture(terrainTextureData.width, terrainTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(terrainTexture, terrainTextureData.bitmapData);
			
			cratersTexture = context3D.createTexture(cratersTextureData.width, cratersTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(cratersTexture, cratersTextureData.bitmapData);
			
			puffTexture = context3D.createTexture(puffTextureData.width, puffTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(puffTexture, puffTextureData.bitmapData);
			
			skyTexture = context3D.createTexture(skyTextureData.width, skyTextureData.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(skyTexture, skyTextureData.bitmapData);
			
			particleTexture1 = context3D.createTexture(particleTextureData1.width, particleTextureData1.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(particleTexture1, particleTextureData1.bitmapData);
			
			particleTexture2 = context3D.createTexture(particleTextureData2.width, particleTextureData2.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(particleTexture2, particleTextureData2.bitmapData);
			
			particleTexture3 = context3D.createTexture(particleTextureData3.width, particleTextureData3.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(particleTexture3, particleTextureData3.bitmapData);
			
			particleTexture4 = context3D.createTexture(particleTextureData4.width, particleTextureData4.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(particleTexture4, particleTextureData4.bitmapData);
			
			particleTexture5 = context3D.createTexture(particleTextureData5.width, particleTextureData5.height, Context3DTextureFormat.BGRA, false);
			uploadTextureWithMipmaps(particleTexture5, particleTextureData5.bitmapData);
			
			initData();
			
			projectionMatrix.identity();
			projectionMatrix.perspectiveFieldOfViewRH(45, stage.width / stage.stageHeight, 0.01, 300000.0); 
			
			//stage.addEventListener(Event.RESIZE, stage_resize);
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function uploadTextureWithMipmaps(dest:Texture, scr:BitmapData):void
		{
			var ws:int = scr.width;
			var hs:int = scr.height;
			var level: int = 0;
			var tmp:BitmapData;
			var transform:Matrix = new Matrix();
			tmp = new BitmapData(ws, hs, true, 0x00000000);
			while (ws >= 1 && hs >= 1)
			{
				tmp.draw(scr, transform, null, null, null, true);
				dest.uploadFromBitmapData(tmp, level);
				transform.scale(0.5, 0.5);
				level++;
				ws >>= 1;
				hs >>= 1;
				if (ws && hs)
				{
					tmp.dispose();
					tmp = new BitmapData(ws, hs, true, 0x00000000);
				}
			}
			tmp.dispose();
		}
		
		private function initData():void 
		{
			var actor:GameActor = new GameActor();
			cameraContainer = new Stage3DEntity();
			chaseCamera = new Stage3DEntity();
			
			playerContainer = new Stage3DEntity();
			playerContainer.rotationDegreesX = -90;
			playerContainer.y = 10;
			playerContainer.z = 0;
			
			player = new Stage3DEntity(shipObjData, context3D, shaderProgram1, playerTexture, 1, false, true);
			player.follow(playerContainer);
			//player.rotationDegreesX = -90;
			//player.y = 10;
			//player.z = 0;
			
			var terrain:Stage3DEntity = new Stage3DEntity(terrainObjData, context3D, shaderProgram1, terrainTexture, 1, false, false);
			terrain.rotationDegreesX = 90;
			terrain.cullingMode = Context3DTriangleFace.NONE;
			terrain.scaleX = 5;
			terrain.scaleY = 3;
			terrain.scaleZ = 5;
			terrain.x = 0;
			terrain.y = -50;
			terrain.z = 0;
			props.push(terrain);
			
			var terrain2:Stage3DEntity = terrain.clone();
			terrain.z = -4000;
			terrain2.cullingMode = Context3DTriangleFace.NONE;
			//terrain2.scaleXYZ = 4;
			
			//props.push(terrain2);
			
			asteroid1 = new Stage3DEntity(asteroidsObjData, context3D, shaderProgram1, cratersTexture, 1, false, true);
			asteroid1.scaleXYZ = 200;
			asteroid1.y = 500;
			asteroid1.z = -1000;
			props.push(asteroid1);
			
			asteroid2 = asteroid1.clone();
			asteroid2.z = -5000;
			props.push(asteroid2);
			
			asteroid3 = asteroid1.clone();
			asteroid3.z = -9000;
			props.push(asteroid3);
			
			asteroid4 = asteroid1.clone();
			asteroid4.z = -9000;
			asteroid4.y = -500;
			props.push(asteroid4);
			
			engineGlow = new Stage3DEntity(shipObjData, context3D, shaderProgram1, playerTexture, 0.5, false, true);
			
			engineGlow.follow(playerContainer);
			//engineGlow.blendScr = Context3DBlendFactor.ONE;
			//engineGlow.blendDst = Context3DBlendFactor.ONE;
			engineGlow.depthTest = false;
			engineGlow.depthTestMode = Context3DCompareMode.ALWAYS;
			engineGlow.cullingMode = Context3DTriangleFace.FRONT;
			//engineGlow.y = -2.1;
			//engineGlow.rotationDegreesX = 90;
			particles.push(engineGlow);
			
			sky = new Stage3DEntity(skyObjData, context3D, shaderProgram1, skyTexture, 1, false, true);
			//sky.follow(player);
			sky.depthTest = false;
			sky.depthTestMode = Context3DCompareMode.LESS;
			sky.cullingMode = Context3DTriangleFace.NONE;
			sky.z = 0;
			sky.scaleX = 5000;
			sky.scaleY = 3000;
			sky.scaleZ = 5000;
			sky.rotationDegreesX = 120;
			props.push(sky);
			
			
			particleSystem = new ParticleSystem();
			particleSystem.deefineParticle("explosion", new Particle3D(explosionData1, context3D, particleTexture1, explosionData1));
			particleSystem.deefineParticle("1", new Particle3D(explosionData1, context3D, particleTexture2, explosionData1));
			particleSystem.deefineParticle("2", new Particle3D(explosionData1, context3D, particleTexture3, explosionData1));
			particleSystem.deefineParticle("3", new Particle3D(explosionData1, context3D, particleTexture4, explosionData1));
			particleSystem.deefineParticle("4", new Particle3D(explosionData1, context3D, particleTexture5, explosionData1));
		}
		
		private function initShaders():void 
		{
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble
			(
				Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" +
				"mov v0, va0\n" +
				"mov v1 va1\n" +
				"mov v2, va2"
			);
			
			var fragmentShaderAssembler1:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler1.assemble
			(
				Context3DProgramType.FRAGMENT,
				"tex ft0, v1, fs0 <2d, lenear, repeat, miplinear>\n" +
				"mov oc, ft0"
			);
			
			shaderProgram1 = context3D.createProgram();
			shaderProgram1.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler1.agalcode);
		}
		
		private function enterFrame(e:Event):void 
		{
			context3D.clear(0, 0, 0);
			gameTimer.tick();
			gameStep(gameTimer.frameMs);
			
			renderScene();
			
			context3D.present();
			
			
			//FPS
			fpsTicks++;
			var now:uint = getTimer();
			var delta:uint = now - fpsLast;
			if (delta >= 1000)
			{
				var fps:Number = fpsTicks / delta * 1000;
				fpsText.text = fps.toFixed(1) + " fps " + scenePolycount + " polies";
				fpsTicks = 0;
				fpsLast = now;
			}
			
			updateScore();
		}
		
		private function updateScore():void
		{
			var str:String;
			score++;
			if (score < 10)
				str = "Score: 00000" + score.toString();
			else if (score < 100)
				str = "Score: 0000" + score.toString();
			else if (score < 1000)
				str = "Score: 000" + score.toString();
			else if (score < 10000)
				str = "Score: 00" + score.toString();
			else if (score < 100000)
				str = "Score: 0" + score.toString();
			else
				str = "Score: " + score.toString();
				
			scoreText.text = str;	
		}
		
		private function renderScene():void
		{
			scenePolycount = 0;
			
			
			viewMatrix.identity();
			viewMatrix.append(cameraContainer.transform);
			
			viewMatrix.invert();
			
			viewMatrix.appendRotation(15, Vector3D.X_AXIS);
			viewMatrix.appendTranslation(chaseCamera.x, chaseCamera.y, chaseCamera.z);
			
			//viewMatrix.appendRotation(gameInput.cameraAngleX, Vector3D.X_AXIS);
			//viewMatrix.appendRotation(gameInput.cameraAngleY, Vector3D.Y_AXIS);
			//viewMatrix.appendRotation(gameInput.cameraAngleZ, Vector3D.Z_AXIS);
			
			player.render(viewMatrix, projectionMatrix);
			
			for each (entity in props)
				entity.render(viewMatrix, projectionMatrix);
			for each (entity in enemies)
				entity.render(viewMatrix, projectionMatrix);
			for each (entity in bullets)
				entity.render(viewMatrix, projectionMatrix);
			for each (entity in particles)
				entity.render(viewMatrix, projectionMatrix);
				
			particleSystem.render(viewMatrix, projectionMatrix);
			scenePolycount += particleSystem.totalpolycount;
		}
		
		private function gameStep(frameMS:uint):void
		{
			var moveAmount:Number = moveSpeed * frameMS;
			
			moveZAmount *= 0.99;
			moveXAmount *= 0.93;
			moveYAmount *= 0.8;
			
			
			moveZAmount -= control.dy * 0.5; 
			moveXAmount += control.dx * 0.5;
			moveYAmount += control.dx * 15;
			
			playerContainer.rotationDegreesY += moveXAmount * (0.1 * moveZAmount - 0.1) * 0.2;
			//playerContainer.rotationDegreesY -= moveXAmount * 0.2;
			cameraContainer.rotationDegreesY += moveXAmount * (0.1 * moveZAmount - 0.1) * 0.2;
			//cameraContainer.rotationDegreesY -= moveXAmount * 0.2;
			
			//if (moveZAmount <= 0)
			//{
				//playerContainer.rotationDegreesY -= moveXAmount * 0.2;
				//cameraContainer.rotationDegreesY -= moveXAmount * 0.2;
			//}
			//else if (moveZAmount >= 0)
			//{
				//playerContainer.rotationDegreesY += moveXAmount * 0.2;
				//cameraContainer.rotationDegreesY += moveXAmount * 0.2;
			//}
			
			
			
			sin = Math.sin(playerContainer.rotationDegreesY * RAD);
			cos = Math.cos(playerContainer.rotationDegreesY * RAD);
			
			player.rotationDegreesY = moveYAmount;
			
			playerContainer.x += moveZAmount * sin;
			playerContainer.z += moveZAmount * cos;
			
			
			
			
			//if (!gameInput.pressing.up && !gameInput.pressing.down)
				//moveZAmount *= 0.99;
			//if (!gameInput.pressing.right && !gameInput.pressing.left)
			{
				moveXAmount *= 0.93;
				moveYAmount *= 0.8;
			}
			
			
			
			cameraContainer.x = playerContainer.x;
			cameraContainer.y = playerContainer.y;
			cameraContainer.z = playerContainer.z;
			
			
			chaseCamera.x = 0;
			chaseCamera.y = -2;
			chaseCamera.z = -gameInput.delta - 8;
			chaseCamera.z = - gameInput.zoomX - gameInput.zoomY - 8;
			
			cameraContainer.rotationDegreesX -= gameInput.cameraAngleX * 0.1;
			cameraContainer.rotationDegreesY -= gameInput.cameraAngleY * 0.1;
			cameraContainer.rotationDegreesZ += gameInput.cameraAngleZ;
			
			asteroid1.rotationDegreesX += asteroidRotationSpeed * frameMS;
			asteroid2.rotationDegreesX -= asteroidRotationSpeed * frameMS;
			asteroid3.rotationDegreesX += asteroidRotationSpeed * frameMS;
			asteroid4.rotationDegreesX -= asteroidRotationSpeed * frameMS;
			
			//engineGlow.rotationDegreesY -= 10 * frameMS;
			//engineGlow.scaleXYZ = Math.cos(gameTimer.gameElapsedTime / 66) / 20 + 0.5;
			
			sky.x = playerContainer.x;
			sky.y = playerContainer.y;
			sky.z = playerContainer.z;
			
			
			if (gameTimer.gameElapsedTime >= nextShootTime)
			{
				trace("Fire!");
				nextShootTime = gameTimer.gameElapsedTime + shootDelay;
				var groundzero:Matrix3D = new Matrix3D;
				groundzero.prependTranslation(playerContainer.x + Math.random() * 200 - 100, playerContainer.y + Math.random() * 100 - 50, playerContainer.z + Math.random() * -800 - 400);
				particleSystem.spawn("explosion", groundzero, 2000);
				//particleSystem.spawn("explosion", groundzero, 2000);
				//particleSystem.spawn("explosion", groundzero, 2000);
				//particleSystem.spawn("explosion", groundzero, 2000);
				//particleSystem.spawn("explosion", groundzero, 2000);
				//particleSystem.spawn("explosion", groundzero, 2000);
				groundzero.prependTranslation(playerContainer.x + Math.random() * 200 - 100, playerContainer.y + Math.random() * 100 - 50, 0);
				particleSystem.spawn("1", groundzero, 2000);
				//particleSystem.spawn("1", groundzero, 2000);
				//particleSystem.spawn("1", groundzero, 2000);
				//particleSystem.spawn("1", groundzero, 2000);
				//particleSystem.spawn("1", groundzero, 2000);
				//particleSystem.spawn("1", groundzero, 2000);
				//particleSystem.spawn("1", groundzero, 2000);
				//particleSystem.spawn("1", groundzero, 2000);
				groundzero.prependTranslation(playerContainer.x + Math.random() * 200 - 100, playerContainer.y + Math.random() * 100 - 50, 0);
				particleSystem.spawn("2", groundzero, 2000);
				//particleSystem.spawn("2", groundzero, 2000);
				//particleSystem.spawn("2", groundzero, 2000);
				//particleSystem.spawn("2", groundzero, 2000);
				//particleSystem.spawn("2", groundzero, 2000);
				//particleSystem.spawn("2", groundzero, 2000);
				groundzero.prependTranslation(playerContainer.x + Math.random() * 200 - 100, playerContainer.y + Math.random() * 100 - 50, 0);
				particleSystem.spawn("3", groundzero, 2000);
				//particleSystem.spawn("3", groundzero, 2000);
				//particleSystem.spawn("3", groundzero, 2000);
				//particleSystem.spawn("3", groundzero, 2000);
				//particleSystem.spawn("3", groundzero, 2000);
				//particleSystem.spawn("3", groundzero, 2000);
				//particleSystem.spawn("3", groundzero, 2000);
				//particleSystem.spawn("3", groundzero, 2000);
				groundzero.prependTranslation(playerContainer.x + Math.random() * 200 - 100, playerContainer.y + Math.random() * 100 - 50, 0);
				particleSystem.spawn("4", groundzero, 2000);
				//particleSystem.spawn("4", groundzero, 2000);
				//particleSystem.spawn("4", groundzero, 2000);
				//particleSystem.spawn("4", groundzero, 2000);
				//particleSystem.spawn("4", groundzero, 2000);
				//particleSystem.spawn("4", groundzero, 2000);
				//particleSystem.spawn("4", groundzero, 2000);
				//particleSystem.spawn("4", groundzero, 2000);
			}
			particleSystem.step(frameMS);
				
		}
		
		private function gameOver():void
		{
			System.gc();
		}
		
		private function stage_resize(e:Event):void 
		{
			this.height = stage.stageWidth;
			this.width = stage.stageHeight;
			//
			if (this.scaleY > this.scaleX)
				this.scaleY = this.scaleX;
			else
				this.scaleX = this.scaleY;
				
			this.x = (stage.stageWidth - this.width) / 2;
			this.y = (stage.stageHeight - this.height) / 2;
			if (stage.stageWidth > 50 && stage.stageHeight > 50)
			{
				context3D.configureBackBuffer(this.width, this.height, 0, true);
				stage.stage3Ds[0].x = this.x;
				stage.stage3Ds[0].y = this.y;
			}
		}
		
		
		
		
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}