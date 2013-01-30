package components 
{
	import adobe.utils.CustomActions;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class GameActor extends Stage3DEntity
	{
		public var name:String = " ";
		public var classname:String = " ";
		public var owner:GameActor;
		public var touching:GameActor;
		public var active:Boolean = true;
		public var visible:Boolean = true;
		public var health:Number = 1;
		public var damage:Number = 250;
		public var points:Number = 25;
		public var collides:Boolean = false;
		public var collidemode:uint = 0;
		public var radius:Number = 1;
		public var aabbMin:Vector3D = new Vector3D(1, 1, 1, 1);
		public var aabbMax:Vector3D = new Vector3D(1, 1, 1, 1);
		
		public var runConstantly:Function;
		public var runConstantlyDelay:uint = 1000;
		public var runWhenNoHealth:Function;
		public var runWhenMaxAge:Function;
		public var runWhenCreated:Function;
		
		public var age:uint = 0;
		public var ageMax:uint = 0;
		public var stepCounter:uint = 0;
		
		public var posVelocity:Vector3D;
		public var rotVelocity:Vector3D;
		public var scaleVelocity:Vector3D;
		public var tintVelocity:Vector3D;
		
		public var bullets:GameActorpool;
		public var shootName:String = " ";
		public var shootDelay:uint = 4000;
		public var shootNext:uint = 0;
		public var shootRandomDelay:Number = 2000;
		public var shootDist:Number = 100;
		public var shootAt:GameActor = null;
		public var shootVelocity:Number = 50;
		public var shootSound:Sound;
		
		public var particles:ParticleSystem;
		public var spawnConstantly:String = " ";
		public var spawnConstantlyDelay:uint = 0;
		public var spawnConstantlyNext:uint = 0;
		public var spawnWhenNoHealth:String = " ";
		public var spawnWhenMaxAge:String = " ";
		public var spawnWhenCreated:String = " ";
		
		public var soundConstantlyDelay:uint = 1000;
		public var soundConstantlyNext:uint = 0;
		public var soundConstantly:Sound;
		public var soundWhenNoHealth:Sound;
		public var soundWhenMaxAge:Sound;
		public var soundWhenCreated:Sound;
		
		public function GameActor(mydata:Class = null, mycontext:Context3D = null, myshader:Program3D = null, mytexture:Texture = null, modelscale:Number = 1, flipAxis:Boolean = true, flipTexture:Boolean = true)
		{
			super(mydata, mycontext, myshader, mytexture, modelscale, flipAxis, flipTexture);
		}
		
//--------------------------------------------------------------------------
//
//  Step Method
//
//--------------------------------------------------------------------------
		
		public function step(ms:uint):void
		{
			if (!active)
				return;
			
			age += ms;
			stepCounter++;
			
			if (health <= 0)
			{
				if (particles && spawnWhenNoHealth)
				{
					var spawnxform:Matrix3D = new Matrix3D();
					spawnxform.position = position.clone();
					particles.spawn(spawnWhenNoHealth, spawnxform, 5555, 0, 10);
				}
				if (soundWhenNoHealth)
					soundWhenNoHealth.play();
				if (runWhenNoHealth != null)
					runWhenNoHealth();
				die();
				return;
			}
			
			if ((ageMax != 0) && (age >= ageMax))
			{
				if (particles && spawnWhenMaxAge)
					particles.spawn(spawnWhenMaxAge, transform);
				if (soundWhenMaxAge)
					soundWhenMaxAge.play();
				if (runWhenMaxAge != null)
					runWhenMaxAge();
				die();
				return;
			}
			
			if (posVelocity)
			{
				x += posVelocity.x * (ms / 1000); 
				y += posVelocity.y * (ms / 1000); 
				z += posVelocity.z * (ms / 1000); 
			}
			
			if (rotVelocity)
			{
				rotationDegreesX += rotVelocity.x * (ms / 1000);
				rotationDegreesY += rotVelocity.y * (ms / 1000);
				rotationDegreesZ += rotVelocity.z * (ms / 1000);
			}
			
			if (scaleVelocity)
			{
				scaleX += scaleVelocity.x * (ms / 1000);
				scaleY += scaleVelocity.y * (ms / 1000);
				scaleZ += scaleVelocity.z * (ms / 1000);
			}
			
			if (visible && particles && spawnConstantlyDelay > 0)
			{
				if (spawnConstantly != " ")
				{
					if (age >= spawnConstantlyNext)
					{
						spawnConstantlyNext = age + spawnConstantlyDelay;
						particles.spawn(spawnConstantly, transform);
					}
				}
			}
			
			if (visible && soundConstantlyDelay > 0)
			{
				if (soundConstantly)
				{
					if (age >= soundConstantlyNext)
					{
						soundConstantlyNext = age + soundConstantlyDelay;
						soundConstantly.play();
					}
				}
			}
			
			if (visible && bullets && (shootName != " "))
			{
				var shouldShoot:Boolean = false;
				if (age >= shootNext)
				{
					shootNext = age + shootDelay + (Math.random() * shootRandomDelay);
					
					if (shootDist < 0)
						shouldShoot = true;
					else if (shootAt && (shootDist > 0) && (Vector3D.distance(position, shootAt.position) <= shootDist))
					{
						shouldShoot = true;
					}
					
					if (shouldShoot)
					{
						var b:GameActor = bullets.spawn(shootName, transform);
						b.owner = this;
						if (shootAt)
						{
							b.transform.pointAt(shootAt.transform.position)
							b.rotationDegreesY -= 90;
							b.posVelocity = b.transform.position.subtract(shootAt.transform.position);
							b.posVelocity.normalize();
							b.posVelocity.negate();
							b.posVelocity.scaleBy(shootVelocity);
						}
						
						if (shootSound)
							shootSound.play();
					}
				}
			}
			
		}
		
//--------------------------------------------------------------------------
//
//  Clone Method
//
//--------------------------------------------------------------------------
		
		public function cloneActor():GameActor
		{
			var myClone:GameActor = new GameActor();
				
			updateTransformFromValues();
				
			myClone.transform = this.transform.clone();
			myClone.updateValuesFromTransform();
			myClone.mesh = this.mesh;
			myClone.texture = this.texture;
			myClone.shader = this.shader;
			myClone.vertexBuffer = this.vertexBuffer;
			myClone.indexBuffer = this.indexBuffer;
			myClone.context = this.context;
			myClone.polycount = this.polycount;
			myClone.blendScr = this.blendScr;
			myClone.blendDst = this.blendDst;
			myClone.cullingMode = this.cullingMode;
			myClone.depthTestMode = this.depthTestMode;
			myClone.depthTest = this.depthTest;
			myClone.depthDraw = this.depthDraw;
				
			myClone.name = this.name;
			myClone.classname = this.classname;
			myClone.owner = this.owner;
			myClone.active = this.active;
			myClone.visible = this.visible;
			myClone.health = this.health;
			myClone.damage = this.damage;
			myClone.points = this.points;
			myClone.collides = this.collides;
			myClone.collidemode = this.collidemode;
			myClone.radius = this.radius;
			myClone.aabbMin = this.aabbMin.clone();
			myClone.aabbMax = this.aabbMax.clone();
				
			myClone.runConstantly = this.runConstantly;
			myClone.runConstantlyDelay = this.runConstantlyDelay;
			myClone.runWhenNoHealth = this.runWhenNoHealth;
			myClone.runWhenMaxAge = this.runWhenMaxAge;
			myClone.runWhenCreated = this.runWhenCreated;
				
			myClone.age = this.age;
			myClone.ageMax = this.ageMax;
			myClone.stepCounter = this.stepCounter;
				
			myClone.posVelocity = this.posVelocity;
			myClone.rotVelocity = this.rotVelocity;
			myClone.scaleVelocity = this.scaleVelocity;
			myClone.tintVelocity = this.tintVelocity;
				
			myClone.bullets = this.bullets;
			myClone.shootName = this.shootName;
			myClone.shootDelay = this.shootDelay;
			myClone.shootNext = this.shootNext;
			myClone.shootRandomDelay = this.shootRandomDelay;
			myClone.shootDist = this.shootDist;
			myClone.shootAt = this.shootAt;
			myClone.shootVelocity = this.shootVelocity;
			myClone.shootSound = this.shootSound;
				
			myClone.particles = this.particles;
			myClone.spawnConstantly = this.spawnConstantly;
			myClone.spawnConstantlyDelay = this.spawnConstantlyDelay;
			myClone.spawnConstantlyNext = this.spawnConstantlyNext;
			myClone.spawnWhenNoHealth = this.spawnWhenNoHealth;
			myClone.spawnWhenMaxAge = this.spawnWhenMaxAge;
			myClone.spawnWhenCreated = this.spawnWhenCreated;
				
			myClone.soundConstantlyDelay = this.soundConstantlyDelay;
			myClone.soundConstantlyNext = this.soundConstantlyNext;
			myClone.soundConstantly = this.soundConstantly;
			myClone.soundWhenNoHealth = this.soundWhenNoHealth;
			myClone.soundWhenMaxAge = this.soundWhenMaxAge;
			myClone.soundWhenCreated = this.soundWhenCreated;
				
			myClone.active = true;
			myClone.visible = true;
				
			return myClone;
			
		}
		
//--------------------------------------------------------------------------
//
//  Die Method
//
//--------------------------------------------------------------------------
		
		public function die():void
		{
			active = false;
			visible = false;
		}
		
//--------------------------------------------------------------------------
//
//  Respawn Method
//
//--------------------------------------------------------------------------
		
		public function respawn(pos:Matrix3D = null):void
		{
			age = 0;
			stepCounter = 0;
			active = true;
			visible = true;
			
			shootNext = Math.random() * shootRandomDelay;
			
			if (pos)
				transform = pos.clone();
				
			if (soundWhenCreated)
				soundWhenCreated.play();
				
			if (runWhenCreated != null)
				runWhenCreated();
				
			if (particles && spawnWhenCreated)
				particles.spawn(spawnWhenCreated, transform);
		}
		
//--------------------------------------------------------------------------
//
//  Colliding Methods
//
//--------------------------------------------------------------------------
		
		public function colliding(checkme:GameActor):GameActor
		{
			if (collidemode == 0)
			{
				if (isCollidingSphere(checkme))
					return checkme;
				else
					return null;
			}
			else
			{
				if (isCollidingAabb(checkme))
					return checkme;
				else
					return null;
			}
		}
		
		public function isCollidingSphere(checkme:GameActor):Boolean
		{
			if (this == checkme)
				return false;
				
			if (!collides || !checkme.collides)
				return false;
				
			if (checkme.owner == this)
				return false;
				
			if (radius == 0 || checkme.radius == 0)
				return false;
				
			var dist:Number = Vector3D.distance(position, checkme.position);
			
			if (dist <= (radius + checkme.radius))
			{
				touching = checkme;
				return true;
			}
			
			return false;
		}
		
		private function aabbCollision(min1:Vector3D, max1:Vector3D, min2:Vector3D, max2:Vector3D):Boolean
		{
			if (min1.x > max2.x || min1.y > max2.y || min1.z > max2.z || max1.x < min2.x || max1.y < min2.y || max1.z < min2.z)
				return false;
				
			return true;
		}
		
		public function isCollidingAabb(checkme:GameActor):Boolean
		{
			if (this == checkme)
				return false;
				
			if (!collides || !checkme.collides)
			return false;
			
			if (checkme.owner == this)
				return false;
				
			if (aabbMin == null || aabbMax == null || checkme.aabbMin == null || checkme.aabbMax == null)
				return false;
				
			if (aabbCollision(position + aabbMin, position + aabbMax, checkme.position + checkme.aabbMin, checkme.position + checkme.aabbMax))
			{
				touching = checkme;
				return true;
			}
			
			return false;
			
		}
		
		
	}

}