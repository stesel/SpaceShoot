package components 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Particle3D extends Stage3DEntity 
	{
		public var active:Boolean = true;
		public var age:uint = 0;
		public var ageMax:uint = 1000;
		public var stepCounter:uint = 0;
		
		private var mesh2:ObjParser;
		private var ageScale:Vector.<Number> = new Vector.<Number>([1, 0, 1, 1]);
		private var rgbaScale:Vector.<Number> = new Vector.<Number>([1, 1, 1, 1]);
		private var startSize:Number = 0;
		private var endSize:Number = 1;
		
		private static var particleshadermesh1:Program3D = null;
		private static var particleshadermesh2:Program3D = null;
		
		
		public function Particle3D(mydata:Class = null, mycontext:Context3D = null, myTexture:Texture = null, mydata2:Class = null) 
		{
			transform = new Matrix3D();
			context = mycontext;
			texture = myTexture;
			
			if (context && mydata2)
				initParticleShader(true);
			else if (context)
				initParticleShader(false);
				
			if (mydata && context)
			{
				mesh = new ObjParser(mydata, context, 1, false, true);
				polycount = mesh.indexBufferCount;
				trace(polycount + " poligons.");
			}
			
			if (mydata2 && context)
				mesh2 = new ObjParser(mydata2, context, 1, false, true);
				
			blendScr = Context3DBlendFactor.ONE;		
			blendDst = Context3DBlendFactor.ONE;	
			cullingMode = Context3DTriangleFace.NONE;
			depthTestMode = Context3DCompareMode.LESS;
			depthTest = false;
		}
		
//--------------------------------------------------------------------------
//
//  Clone Method
//
//--------------------------------------------------------------------------
		
		public function cloneParticle():Particle3D
		{
			var myClone:Particle3D = new Particle3D();
			myClone.transform = this.transform.clone();
			myClone.mesh = this.mesh;
			myClone.texture = this.texture;
			myClone.shader = this.shader;
			myClone.vertexBuffer = this.vertexBuffer;
			myClone.indexBuffer = this.indexBuffer;
			myClone.context = this.context;
			myClone.updateValuesFromTransform();
			myClone.mesh2 = this.mesh2;
			myClone.startSize = this.startSize;
			myClone.endSize = this.endSize;
			myClone.polycount = this.polycount;
			return myClone;
		}
		
//--------------------------------------------------------------------------
//
//  Wobble Methods
//
//--------------------------------------------------------------------------
		
		private var twoPi:Number = 2 * Math.PI;
		
		private function wobble(ms:Number = 0, amp:Number = 1, spd:Number = 1):Number
		{
			var val:Number;
			val = amp * Math.sin((ms / 1000) * spd * twoPi);
			return val;
		}
		
		private function wobble010(ms:Number):Number
		{
			var retval:Number;
			retval = wobble(ms - 250, 0.5, 1.0) + 0.5;
			return retval;	
		}
		
		
		public function step(ms:uint):void
		{
			stepCounter++;
			age += 2 * ms;
			if (age >= ageMax)
			{
				active = false;
				return;
			}
			ageScale[0] = 1 - (age / ageMax);
			ageScale[1] = age / ageMax;
			ageScale[2] = wobble010(age);
			
			if (ageScale[0] < 0)
				ageScale[0] = 0;
			if (ageScale[0] > 1)
				ageScale[0] = 1;
			if (ageScale[1] < 0)
				ageScale[1] = 0;
			if (ageScale[1] > 1)
				ageScale[1] = 1;
			if (ageScale[2] < 0)
				ageScale[2] = 0;
			if (ageScale[2] > 1)
				ageScale[2] = 1;
				
			rgbaScale[0] = ageScale[0];
			rgbaScale[1] = ageScale[0];
			rgbaScale[2] = ageScale[0];
			rgbaScale[3] = ageScale[2];
		}
		
//--------------------------------------------------------------------------
//
//  Respawn Method
//
//--------------------------------------------------------------------------
		
		public function respawn(pos:Matrix3D, maxage:uint = 1000, scale1:Number = 0, scale2:Number = 50):void
		{
			age = 0;
			stepCounter = 0;
			ageMax = maxage;
			
			transform = pos.clone();
			updateValuesFromTransform();
			
			rotationDegreesX = 180;
			rotationDegreesY = Math.random() * 360 - 180;
			
			updateTransformFromValues();
			
			ageScale[0] = 1;
			ageScale[1] = 0;
			ageScale[2] = 0;
			ageScale[3] = 1;
			
			rgbaScale[0] = 1;
			rgbaScale[1] = 1;
			rgbaScale[2] = 1;
			rgbaScale[3] = 1;
			
			startSize = scale1;
			endSize = scale2;
			active = true;
		}
		
//--------------------------------------------------------------------------
//
//  Render Method
//
//--------------------------------------------------------------------------
		
		private var _rendermatrix:Matrix3D = new Matrix3D();
		
		override public function render(view:Matrix3D, projectoin:Matrix3D, statechanged:Boolean = true):void
		{
			if (!active)
				return;
			if (!mesh)
				return;
			if (!context)
				return;
			if (!shader)
				return;
			if (!texture)
				return;
				
			scaleXYZ = startSize +((endSize - startSize) * ageScale[1]);
			_rendermatrix.identity();
			_rendermatrix.append(transform);
			
			if (following)
				_rendermatrix.append(following.transform);
			_rendermatrix.append(view);
			_rendermatrix.append(projectoin);
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _rendermatrix, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, ageScale);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, rgbaScale);
			
			context.setProgram(shader);
			context.setTextureAt(0, texture);
			context.setVertexBufferAt(0, mesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, mesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			
			if (mesh2)
				context.setVertexBufferAt(2, mesh2.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			
			context.setBlendFactors(blendScr, blendDst);
			context.setDepthTest(depthTest, depthTestMode);
			context.setCulling(cullingMode);
			
			context.drawTriangles(mesh.indexBuffer, 0, mesh.indexBufferCount);
			
		}
		
//--------------------------------------------------------------------------
//
//  Shader Init
//
//--------------------------------------------------------------------------
		
		private function initParticleShader(twomodels:Boolean = false):void
		{
			var vertexShader:AGALMiniAssembler = new AGALMiniAssembler();
			var fragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
			if (twomodels)
			{
				if (particleshadermesh2)
				{
					shader = particleshadermesh2;
					return;
				}
				
				trace("Compile 2  Frame Shader...");
				vertexShader.assemble(Context3DProgramType.VERTEX,
					"mul vt0 va0, vc4.xxxx\n" +
					"mul vt1, va2, vc4.yyyy\n" +
					"add vt2, vt0, vt1\n" +
					"m44 op, vt2, vc0\n" +
					"mov v1, va1" 
				);
			}
			else
			{
				if (particleshadermesh1)
				{
					shader = particleshadermesh1;
					return;
				}
				trace("Compile 1 Frame Shader...");
				vertexShader.assemble(Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" +
				"mov v1, va1"
				);
			}
			
			fragmentShader.assemble(Context3DProgramType.FRAGMENT,
				"tex ft0, v1, fs0 <2d, linear, repeat, miplinear>\n" +
				"mull ft0, ft0, fc0\n" +
				"mov oc, ft0\n"
				);
				
			shader = context.createProgram();
			shader.upload(vertexShader.agalcode, fragmentShader.agalcode);
			
			if (twomodels)
				particleshadermesh2 = shader;
			else
				particleshadermesh1 = shader
			
		}
		
	}

}