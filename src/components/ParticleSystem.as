package components 
{
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class ParticleSystem 
	{
		private var allKinds:Dictionary;
		private var allParticles:Dictionary;
		
		private var particle:Particle3D;
		
		private var particleList:Vector.<Particle3D>;
		
		public var particlesCreated:uint = 0;
		public var particlesActive:uint = 0;
		public var totalpolycount:uint = 0;
		
		
		public function ParticleSystem() 
		{
			trace("particle System created");
			allKinds = new Dictionary();
			allParticles = new Dictionary();
		}
		
		public function deefineParticle(name:String, cloneSourse:Particle3D):void
		{
			trace("new partical type defined: " + name);
			allKinds[name] = cloneSourse;
		}
		
		public function step(ms:uint):void
		{
			particlesActive = 0;
			for each (particleList in allParticles)
			{
				for each (particle in particleList)
				{
					if (particle.active)
					{
						particlesActive++;
						particle.step(ms);
					}
				}
			}
		}
		
		public function render(view:Matrix3D, projection:Matrix3D):void
		{
			totalpolycount = 0;
			for each (particleList in allParticles)
			{
				for each (particle in particleList)
				if (particle.active)
				{
					totalpolycount += particle.polycount;
					particle.render(view, projection);
				}
			}
		}
		
		public function spawn(name:String, pos:Matrix3D, maxage:Number = 1000, scale1:Number = 1, scale2:Number = 50):void
		{
			var reused:Boolean = false;
			if (allKinds[name])
			{
				if (allParticles[name])
				{
					for each (particle in allParticles[name])
					{
						if (!particle.active)
						{
							particle.respawn(pos, maxage, scale1, scale2);
							particle.updateValuesFromTransform();
							reused = true;
							return;
						}
					}
				}
				else
				{
					trace("This is first " + name + " particle.");
					allParticles[name] = new Vector.<Particle3D>;
				}	
				if (!reused)
				{
					particlesCreated++;
					trace("Creating new " + name);
					trace("Total particles " + particlesCreated);
					
					var newParticle:Particle3D = allKinds[name].cloneParticle(); 
					newParticle.respawn(pos, maxage, scale1, scale2);
					newParticle.updateValuesFromTransform();
					allParticles[name].push(newParticle);
				}
				else
					trace("Error: unknown particle type: " + name);
				
			}
		}
	}

}