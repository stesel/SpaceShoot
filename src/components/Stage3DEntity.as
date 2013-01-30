package components 
{
	import away3d.core.math.Matrix3DUtils;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class Stage3DEntity 
	{
		///////
		private var _transform:Matrix3D;
		private var _inverseTransform:Matrix3D;
		private var _transformNeedsUpdate:Boolean;
		private var _valuesNeedUpdate:Boolean;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _z:Number = 0;
		private var _rotationDegreesX:Number = 0;
		private var _rotationDegreesY:Number = 0;
		private var _rotationDegreesZ:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _scaleZ:Number = 1;
		///////
		private const RAD_TO_DEG:Number = 180 / Math.PI;
		///////
		public var context:Context3D;
		public var vertexBuffer:VertexBuffer3D;
		public var indexBuffer:IndexBuffer3D;
		public var shader:Program3D;
		public var texture:Texture;
		public var mesh:ObjParser;
		///////
		public var cullingMode:String = Context3DTriangleFace.FRONT;
		public var blendScr:String = Context3DBlendFactor.ONE;
		public var blendDst:String = Context3DBlendFactor.ZERO;
		public var depthTestMode:String = Context3DCompareMode.LESS;
		public var depthTest:Boolean = true;
		public var depthDraw:Boolean = true;
		///////
		public var polycount:uint = 0;
		//////
		public var following:Stage3DEntity;
		//////
		public var shaderUsesUV:Boolean = true;
		public var shaderUsesRGBA:Boolean = true;
		public var shaderUsesNormals:Boolean = false;
		
		
		public function Stage3DEntity(mydata:Class = null, mycontext:Context3D = null, myshader:Program3D = null, mytexture:Texture = null, modelscale:Number = 1, flipAxis:Boolean = false, flipTexture:Boolean = true)
		{
			_transform = new Matrix3D();
			context = mycontext;
			shader = myshader;
			texture = mytexture;
			if (mydata && context)
			{
				mesh = new ObjParser(mydata, context, modelscale, flipAxis, flipTexture);
				polycount = mesh.indexBufferCount;
				trace("Mesh has " + polycount + " polygons.");
			}
				
		}
		
//--------------------------------------------------------------------------
//
//  Getters and Setters
//
//--------------------------------------------------------------------------
		
		public function get transform():Matrix3D
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
			return _transform;
		}
		
		public function set transform(value:Matrix3D):void
		{
			_transform = value;
			_transformNeedsUpdate = false;
			_valuesNeedUpdate = true;
		}
		
	private var _posvec:Vector3D = new Vector3D();
		public function get position():Vector3D
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			_posvec.setTo(_x, _y, _z);
			return _posvec;
		}
		
		public function set position(value:Vector3D):void
		{
			_x = value.x;
			_y = value.y;
			_z = value.z;
			
			_transformNeedsUpdate = true;
		}
		
		public function get x():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
			_transformNeedsUpdate = true;
		}
		
		public function get y():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
			_transformNeedsUpdate = true;
		}
		
		public function get z():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _z;
		}
		
		public function set z(value:Number):void
		{
			_z = value;
			_transformNeedsUpdate = true;
		}
		
		public function get rotationDegreesX():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _rotationDegreesX;
		}
		
		public function set rotationDegreesX(value:Number):void
		{
			_rotationDegreesX = value;
			_transformNeedsUpdate = true;
		}
		
		public function get rotationDegreesY():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _rotationDegreesY;
		}
		
		public function set rotationDegreesY(value:Number):void
		{
			_rotationDegreesY = value;
			_transformNeedsUpdate = true;
		}
		
		public function get rotationDegreesZ():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _rotationDegreesZ;
		}
		
		public function set rotationDegreesZ(value:Number):void
		{
			_rotationDegreesZ = value;
			_transformNeedsUpdate = true;
		}
		
		private var _scalevec:Vector3D = new Vector3D();
		public function get scale():Vector3D
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			_scalevec.setTo(_scaleX, _scaleY, _scaleZ);
			_scalevec.w = 1.0;
			return _scalevec;
		}
		
		public function set scale(value:Vector3D):void
		{
			_scaleX = value.x;
			_scaleY = value.y;
			_scaleZ = value.z;
			_transformNeedsUpdate = true;
		}
		
		public function get scaleXYZ():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _scaleX
			//_transformNeedsUpdate = true;
		}
		
		public function set scaleXYZ(value:Number):void
		{
			_scaleX = value;
			_scaleY = value;
			_scaleZ = value;
			_transformNeedsUpdate = true;
		}
		
		public function get scaleX():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void
		{
			_scaleX = value;
			_transformNeedsUpdate = true;
		}
		
		public function get scaleY():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void
		{
			_scaleY = value;
			_transformNeedsUpdate = true;
		}
		
		public function get scaleZ():Number
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			return _scaleZ;
		}
		
		public function set scaleZ(value:Number):void
		{
			_scaleZ = value;
			_transformNeedsUpdate = true;
		}
		
//--------------------------------------------------------------------------
//
//  Update Methods
//
//--------------------------------------------------------------------------
		
		public function updateValuesFromTransform():void 
		{
			var d:Vector.<Vector3D> = _transform.decompose();
			
			var position:Vector3D = d[0];
			_x = position.x;
			_y = position.y;
			_z = position.z;
			
			var rotation:Vector3D = d[1];
			_rotationDegreesX = rotation.x * RAD_TO_DEG;
			_rotationDegreesY = rotation.y * RAD_TO_DEG;
			_rotationDegreesZ = rotation.z * RAD_TO_DEG;
			
			var scale:Vector3D = d[2];
			_scaleX = scale.x;
			_scaleY = scale.y;
			_scaleZ = scale.z;
			
			_valuesNeedUpdate = false;
		}
		
		public function updateTransformFromValues():void 
		{
			_transform.identity();
			
			_transform.appendRotation(_rotationDegreesX, Vector3D.X_AXIS);
			_transform.appendRotation(_rotationDegreesY, Vector3D.Y_AXIS);
			_transform.appendRotation(_rotationDegreesZ, Vector3D.Z_AXIS);
			
			if (_scaleX == 0)
				_scaleX = 0.0000001;
			if (_scaleY == 0)
				_scaleY = 0.0000001;
			if (_scaleZ == 0)
				_scaleZ = 0.0000001;
				
			_transform.appendScale(_scaleX, _scaleY, _scaleZ);
			_transform.appendTranslation(_x, _y, _z);
		}

//--------------------------------------------------------------------------
//
//  Movement Utils
//
//--------------------------------------------------------------------------
		
		public function moveForward(amt:Number):void
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
				
			var v:Vector3D = frontvector;
			v.scaleBy( -amt);
			transform.appendTranslation(v.x, v.y, v.z);
			_valuesNeedUpdate = true;
		}
		
		public function moveBackward(amt:Number):void
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
				
			var v:Vector3D = backvector;
			v.scaleBy( -amt);
			transform.appendTranslation(v.x, v.y, v.z);
			_valuesNeedUpdate = true;
		}
		
		public function moveUp(amt:Number):void
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
				
			var v:Vector3D = upvector;
			v.scaleBy( -amt);
			transform.appendTranslation(v.x, v.y, v.z);
			_valuesNeedUpdate = true;
		}
		
		public function moveDown(amt:Number):void
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
				
			var v:Vector3D = downvector;
			v.scaleBy( -amt);
			transform.appendTranslation(v.x, v.y, v.z);
			_valuesNeedUpdate = true;
		}
		
		public function moveLeft(amt:Number):void
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
				
			var v:Vector3D = leftvector;
			v.scaleBy( -amt);
			transform.appendTranslation(v.x, v.y, v.z);
			_valuesNeedUpdate = true;
		}
		
		public function moveRight(amt:Number):void
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
				
			var v:Vector3D = rightvector;
			v.scaleBy( -amt);
			transform.appendTranslation(v.x, v.y, v.z);
			_valuesNeedUpdate = true;
		}
		
		////////
		private static const vecft:Vector3D = new Vector3D(0, 0, 1);
		private static const vecbk:Vector3D = new Vector3D(0, 0, -1);
		private static const veclf:Vector3D = new Vector3D(-1, 0, 0);
		private static const vecrt:Vector3D = new Vector3D(1, 0, 0);
		private static const vecup:Vector3D = new Vector3D(0, 1, 0);
		private static const vecdn:Vector3D = new Vector3D(0, -1, 0);
		////////
		
		public function get frontvector():Vector3D
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
			return transform.deltaTransformVector(vecft);
		}
		
		public function get backvector():Vector3D
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
			return transform.deltaTransformVector(vecbk);
		}
		
		public function get upvector():Vector3D
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
			return transform.deltaTransformVector(vecup);
		}
		
		public function get downvector():Vector3D
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
			return transform.deltaTransformVector(vecdn);
		}
		
		public function get leftvector():Vector3D
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
			return transform.deltaTransformVector(veclf);
		}
		
		public function get rightvector():Vector3D
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
			return transform.deltaTransformVector(vecrt);
		}
		
//--------------------------------------------------------------------------
//
//  Handy Utils
//
//--------------------------------------------------------------------------
		
		public function get rotationTransform():Matrix3D
		{
			var d:Vector.<Vector3D> = transform.decompose();
			d[0] = new Vector3D();
			d[1] = new Vector3D(1, 1, 1);
			var t:Matrix3D = new Matrix3D();
			t.recompose(d);
			return t;
		}
		
		public function reducedTransform():Matrix3D
		{
			var raw:Vector.<Number> = transform.rawData;
			raw[3] = 0; //remove translation
			raw[7] = 0;
			raw[11] = 0;
			raw[15] = 1;
			raw[12] = 0;
			raw[13] = 0;
			raw[14] = 0;
			
			var reducedTransform:Matrix3D = new Matrix3D();
			reducedTransform.copyRawDataFrom(raw);
			return reducedTransform;
		}
		
		public function get invRotationTransform():Matrix3D
		{
			var t:Matrix3D = rotationTransform;
			t.invert();
			return t;
		}
		
		public function get inverseTransform():Matrix3D
		{
			
			_inverseTransform = transform.clone();
			_inverseTransform.invert();
			
			return _inverseTransform;
		}
		
		public function get positionVector():Vector.<Number>
		{
			return Vector.<Number>([_x, _y, _z, 1.0]);
		}
		
		public function posString():String
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
				
			return _x.toFixed(2) + ", " + _y.toFixed(2) + ", " + _z.toFixed(2);
		}
		
		public function rotString():String
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
				
			return _rotationDegreesX.toFixed(2) + ", " + _rotationDegreesY.toFixed(2) + ", " + _rotationDegreesZ.toFixed(2);
		}
		
		public function follow(thisentity:Stage3DEntity):void
		{
			following = thisentity;
		}
		
//--------------------------------------------------------------------------
//
//  Handy Utils
//
//--------------------------------------------------------------------------	
		
		public function clone():Stage3DEntity
		{
			if (_transformNeedsUpdate)
				updateTransformFromValues();
				
			var myClone:Stage3DEntity = new Stage3DEntity();
			myClone.transform = this.transform.clone();
			myClone.mesh = this.mesh;
			myClone.texture = this.texture;
			myClone.shader = this.shader;
			myClone.vertexBuffer = this.vertexBuffer;
			myClone.indexBuffer = this.indexBuffer;
			myClone.context = this.context;
			myClone.polycount = this.polycount;
			myClone.shaderUsesNormals = this.shaderUsesNormals;
			myClone.shaderUsesRGBA = this.shaderUsesRGBA;
			myClone.shaderUsesUV = this.shaderUsesUV;
			myClone.updateValuesFromTransform();
			return myClone;
		}
		
//--------------------------------------------------------------------------
//
//  Render
//
//--------------------------------------------------------------------------		
		
		private var _rendermatrix:Matrix3D = new Matrix3D();
		
		public function render(view:Matrix3D, projection:Matrix3D, statechanged:Boolean = true):void
		{
			if (!mesh)
				trace("Missimg mesh!");
			if	(!context)
				trace("Missing context!");
			if (!shader)
				trace("Missing shader!");
				
			if (!mesh)
				return;
			if (!context)
				return;
			if (!shader)
				return;
				
			_rendermatrix.identity();
			_rendermatrix.append(transform);
			if (following)
				_rendermatrix.append(following.transform);
			_rendermatrix.append(view);
			_rendermatrix.append(projection);
				
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _rendermatrix, true);
			
			if (statechanged)
			{
				context.setProgram(shader);
				
				if (texture)
					context.setTextureAt(0, texture);
					
				context.setVertexBufferAt(0, mesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
				
				if(shaderUsesUV)
					context.setVertexBufferAt(1, mesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
					
				if (shaderUsesRGBA)
					context.setVertexBufferAt(2, mesh.colorsBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
					
				if (shaderUsesNormals)
					context.setVertexBufferAt(3, mesh.normalsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
					
				context.setBlendFactors(blendScr, blendDst);
				context.setDepthTest(depthTest, depthTestMode);
				context.setCulling(cullingMode);
				context.setColorMask(true, true, true, depthDraw);
			}
			context.drawTriangles(mesh.indexBuffer, 0, mesh.indexBufferCount);
			
		}
		
		
	}

}