package components 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class GameActorpool 
	{
		private var allNames:Vector.<String>;
		private var allKinds:Dictionary;
		private var allActors:Dictionary;
		
		private var actor:GameActor;
		private var actorList:Vector.<GameActor>;
		
		public var actorCreated:uint = 0;
		public var actorActive:uint = 0;
		public var totalpolycount:uint = 0;
		public var totalrendered:uint = 0;
		
		
		public var active:Boolean = true;
		public var visible:Boolean = true;
		
		public function GameActorpool() 
		{
			allKinds = new Dictionary();
			allActors = new Dictionary();
			allNames = new Vector.<String>;
		}
		
		public function defineActor(name:String, cloneSource:GameActor):void
		{
			allKinds[name] = cloneSource;
			allNames.push(name);
		}
		
		public function step(ms:uint, collisionDetection:Function = null, collisionReaction:Function = null):void
		{
			if (!active)
				return;
				
			actorActive = 0;
			for each (actorList in allActors)
			{
				for each (actor in actorList)
				{
					if (actor.active)
					{
						actorActive++;
						actor.step(ms);
						
						if (actor.collides && (collisionDetection != null))
						{
							actor.touching = collisionDetection(actor);
							if (actor.touching && collisionReaction != null)
								collisionReaction(actor, actor.touching);
						}
					}
				}
			}
		}
		
		public function render(view:Matrix3D, projection:Matrix3D):void
		{
			if (!visible)
				return;
				
			totalpolycount = 0;
			totalrendered = 0;
			
			var stateGhange:Boolean = true;
			
			for each (actorList in allActors)
			{
				for each (actor in actorList)
				{
					if (actor.active && actor.visible)
					{
						totalpolycount += actor.polycount;
						totalrendered++;
						actor.render(view, projection, stateGhange);
					}
				}
			}
		}
		
		public function spawn(name:String, pos:Matrix3D):GameActor 
		{
			var spawned:GameActor = null;
			var reuses:Boolean = false;
			if (allKinds[name])
			{
				if (allActors[name])
				{
					for each (actor in allActors[name])
					{
						if (!actor.active)
						{
							actor.respawn(pos);
							spawned = actor;
							reuses = true;
							return spawned;
						}
					}
				}
				else
				{
					allActors[name] = new Vector.<GameActor>();
				}
				if (!reuses)
				{
					actorCreated++;
					spawned = allKinds[name].cloneActor();
					spawned.classname = name;
					spawned.name = name + actorCreated;
					spawned.respawn(pos);
					allActors[name].push(spawned);
					return spawned;
				}
			}
			else
				trace("ERROR: unknown: " + name);
			
			return new GameActor();
		}
		
		public function colliding(checkthis:GameActor):GameActor
		{
			if (!checkthis.visible)
				return null;
			if (!checkthis.active)
				return null;
				
			var hit:GameActor;
			var str:String;
			for each(str in allNames)
			{
				for each(hit in allActors[str])
				{
					if (hit.visible && hit.active && checkthis.colliding(hit))
						return hit;
				}
			}
			return null;
		}
		
		public function hideDistant(pos:Vector3D, maxdist:Number = 500, maxz:Number = 0, minz:Number = 0, maxy:Number = 0, miny:Number = 0, maxx:Number = 0, minx:Number = 0):void
		{
			for each (actorList in allActors)
			{
				for each (actor in actorList)
				{
					if (actor.active)
					{
						if ((Vector3D.distance(actor.position, pos) >= (maxdist * actor.radius)) || (maxx != 0 && ((pos.x + maxx) < (actor.position.x - actor.radius))) || (maxy != 0 && ((pos.y + maxy) < (actor.position.y - actor.radius))) || (maxz != 0 && ((pos.z + maxz) < (actor.position.z - actor.radius))) || (minx != 0 && ((pos.x + minx) > (actor.position.x + actor.radius))) || (miny != 0 && ((pos.y + miny) > (actor.position.y + actor.radius))) || (minz != 0 && ((pos.z + minz) > (actor.position.z + actor.radius))))
						{
							actor.visible = false;
						}
						else
						{
							actor.visible = true;
						}
					}
				}
			}
		}
		
		public function destroyAll():void
		{
			for each (actorList in allActors)
			{
				for each (actor in actorList)
				{
					actor.active = false;
					actor.visible = false;
				}
			}
		}
		
	}

}