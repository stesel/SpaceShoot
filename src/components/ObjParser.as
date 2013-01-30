package components 
{
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Leonid Trofimchuk
	 */
	public class ObjParser 
	{
		private var _vertexDataIsZxy:Boolean = false; 		//For invalid vertex order
		private var _mirrorUv:Boolean = false;				//mirror UV coords
		private var _randomVertexColors:Boolean = true;		//If false buffer is filled with pure white
		
		//Constants
		private const LINE_FEED:String = String.fromCharCode(10);
		private const SPACE:String = String.fromCharCode(32);
		private const SLASH:String = "/";
		private const VERTEX:String = "v";
		private const NORMAL:String = "vn";
		private const UV:String = "vt";
		private const INDEX_DATA:String = "f";
		
		//Temporary vars
		private var _scale:Number;
		private var _faceIndex:uint;
		private var _vertices:Vector.<Number>;
		private var _normals:Vector.<Number>;
		private var _uvs:Vector.<Number>;
		private var _cachedRawNormalsBuffer:Vector.<Number>;
		
		//Raw data
		protected var _rawIndexBuffer:Vector.<uint>;
		protected var _rawPositionsBuffer:Vector.<Number>;
		protected var _rawUvBuffer:Vector.<Number>;
		protected var _rawNormalsBuffer:Vector.<Number>;
		protected var _rawColorsBuffer:Vector.<Number>;
		
		//Final Buffers
		protected var _indexBuffer:IndexBuffer3D;
		protected var _positionsBuffer:VertexBuffer3D;
		protected var _uvBuffer:VertexBuffer3D;
		protected var _normalsBuffer:VertexBuffer3D;
		protected var _colorsBuffer:VertexBuffer3D;
		
		private var _context3d:Context3D;
		
		public function ObjParser(objFile:Class, acontext:Context3D, scale:Number = 1,dataIsZxy:Boolean = false, textureFlip:Boolean = false) 
		{
			_vertexDataIsZxy = dataIsZxy;
			_mirrorUv = textureFlip;
			
			_rawColorsBuffer = new Vector.<Number>();
			_rawIndexBuffer = new Vector.<uint>();
			_rawPositionsBuffer = new Vector.<Number>();
			_rawUvBuffer = new Vector.<Number>();
			_rawNormalsBuffer = new Vector.<Number>();
			
			_scale = scale;
			_context3d = acontext;
			
			var defenition:String = readClass(objFile);
			
			_vertices = new Vector.<Number>();
			_normals = new Vector.<Number>();
			_uvs = new Vector.<Number>();
			
			var lines:Array = defenition.split(LINE_FEED);
			var loop:uint = lines.length;
			for (var i:uint = 0; i < loop; i++)
				parseLine(lines[i]);
		}
		
//--------------------------------------------------------------------------
//
//  Private Methods
//
//--------------------------------------------------------------------------
		
		private function readClass(obj:Class):String
		{
			var bytes:ByteArray = new obj();
			return bytes.readUTFBytes(bytes.bytesAvailable);
		}
		
		private function parseLine(line:String):void 
		{
			var words:Array = line.split(SPACE);
			
			if (words.length > 0)
				var data:Array = words.slice(1);
			else
				return;
			
			var firstWord:String = words[0];
			switch (firstWord)
			{
				case VERTEX:
					parseVertex(data);
					break;
				case NORMAL:
					parseNormal(data);
					break;
				case UV:
					parseUV(data);
					break;
				case INDEX_DATA:
					parseIndex(data);
					break;
			}
		}
		
		private function parseVertex(data:Array):void
		{
			if ((data[0] == "") || (data[0] == " "))
				data = data.slice(1);
			if (_vertexDataIsZxy)
			{
				if (!_vertices.length)
					trace("zxy parse Vertex: " + data[1] + ", " + data[2] + ", " + data[0]);
				_vertices.push(Number(data[1]) * _scale);
				_vertices.push(Number(data[2]) * _scale);
				_vertices.push(Number(data[0]) * _scale);
			}
			else
			{
				if (!_vertices.length)
					trace("parseVertex: " + data);
				var loop:uint = data.length;
				if (loop > 3)
					loop = 3;
				for (var i:uint = 0; i < loop; i++)
				{
					var element:String = data[i];
					_vertices.push(Number(element) * _scale);
				}
			}
		}
		
		private function parseNormal(data:Array):void
		{
			if ((data[0] == "") || (data[0] == " "))
				data = data.slice(1);
			if (!_normals.length)
				trace("parseNormal: " + data);
			var loop:uint = data.length;
			if (loop > 3)
				loop = 3;
			for (var i:uint = 0; i < loop; i++)
			{
				var element:String = data[i];
				if (element != null)
					_normals.push(Number(element));
			}
		}
		
		private function parseUV(data:Array):void
		{
			if ((data[0] == "") || (data[0] == " "))
				data = data.slice(1);
			if (!_uvs.length)
				trace("ParseUV: " + data);
			var loop:uint = data.length;
			if (loop > 2)
				loop = 2;
			for (var i:uint = 0; i < loop; i++)
			{
				var element:String = data[i];
				_uvs.push(Number(element));
			}
		}
		
		private function parseIndex(data:Array):void
		{
			if (!_rawIndexBuffer.length)
				trace("parseIndex: " + data);
			var tripled:String;
			var subData:Array;
			var vertexIndex:int;
			var uvIndex:int;
			var normalIndex:int;
			var index:uint;
			
			var i:uint;
			var loop:uint = data.length;
			var startHere:uint = 0;
			while ((data[startHere]  == "") || (data[startHere] == " "))
				startHere++;
				
			loop = startHere + 3;
			
			for (i = startHere; i < loop; i++)
			{
				tripled = data[i];
				subData = tripled.split(SLASH);
				vertexIndex = int(subData[0]) - 1;
				uvIndex = int(subData[1]) - 1;
				normalIndex = int(subData[2]) - 1;
			
				if (vertexIndex < 0 )
					vertexIndex = 0;
				if (uvIndex < 0)
					uvIndex = 0;
				if (normalIndex < 0)
					normalIndex = 0;
					
				index = 3 * vertexIndex;
				_rawPositionsBuffer.push(_vertices[index + 0], _vertices[index + 1], _vertices[index + 2]);
				
				if (_randomVertexColors)
					_rawColorsBuffer.push(Math.random(), Math.random(), Math.random(), 1);
				else
					_rawColorsBuffer.push(1, 1, 1, 1);
					
				if (_normals.length)
				{
					index = 3 * normalIndex;
					_rawNormalsBuffer.push(_normals[index + 0], _normals[index + 1], _normals[index + 2]);
				}
				
				index = 2*uvIndex;
				if (_mirrorUv)
					_rawUvBuffer.push(_uvs[index + 0], 1 - _uvs[index + 1]);
				else
					_rawUvBuffer.push(1 - _uvs[index + 0], 1 - _uvs[index + 1]);
			}	
			
			_rawIndexBuffer.push(_faceIndex + 0, _faceIndex + 1, _faceIndex + 2);
			_faceIndex += 3;
		}
		
//--------------------------------------------------------------------------
//
//  Getters and Setters
//
//--------------------------------------------------------------------------
		
		public function get colorsBuffer():VertexBuffer3D
		{
			if (!_colorsBuffer)
				updateColorsBuffer();
			return _colorsBuffer;
		}
		
		public function get positionsBuffer():VertexBuffer3D
		{
			if (!_positionsBuffer)
				updateVertexBuffer();
			return _positionsBuffer;
		}
		
		public function get indexBuffer():IndexBuffer3D
		{
			if (!_indexBuffer)
				updateIndexBuffer();
			return _indexBuffer;
		}
		
		public function get indexBufferCount():int
		{
			return _rawIndexBuffer.length / 3;
		}
		
		public function get uvBuffer():VertexBuffer3D
		{
			if (!_uvBuffer)
				updateUvBuffer();
			return _uvBuffer;
		}
		
		public function get normalsBuffer():VertexBuffer3D
		{
			if (!_normalsBuffer)
				updateNormalsBuffer();
			return _normalsBuffer;
		}
		
//--------------------------------------------------------------------------
//
//  Update Methods
//
//--------------------------------------------------------------------------
		
		public function updateColorsBuffer():void
		{
			if (_rawColorsBuffer.length == 0)
				throw new Error("Raw Color buffer is empty");
			var colorsCount:uint = _rawColorsBuffer.length / 4;
			_colorsBuffer = _context3d.createVertexBuffer(colorsCount, 4);
			_colorsBuffer.uploadFromVector(_rawColorsBuffer, 0, colorsCount);
		}
		
		public function updateNormalsBuffer():void
		{
			if (_rawNormalsBuffer.length == 0)
				forceNormals();
			if (_rawNormalsBuffer.length == 0)
				throw new Error("Raw Normal buffer is empty");
			var normalsCount:uint = _rawNormalsBuffer.length / 3;
			_normalsBuffer = _context3d.createVertexBuffer(normalsCount, 3);
			_normalsBuffer.uploadFromVector(_rawNormalsBuffer, 0, normalsCount);
		}
		
		public function updateVertexBuffer():void
		{
			if (_rawPositionsBuffer.length == 0)
				throw new Error("Raw Vertex Buffer is empty");
			var vertexCount:uint = _rawPositionsBuffer.length / 3;
			_positionsBuffer = _context3d.createVertexBuffer(vertexCount, 3);
			_positionsBuffer.uploadFromVector(_rawPositionsBuffer, 0, vertexCount);
		}
		
		public function updateUvBuffer():void
		{
			if (_rawUvBuffer.length == 0)
				throw new Error("Raw UV buffer is empty");
			var uvsCount:uint = _rawUvBuffer.length / 2;
			_uvBuffer = _context3d.createVertexBuffer(uvsCount, 2);
			_uvBuffer.uploadFromVector(_rawUvBuffer, 0, uvsCount);
		}
		
		public function updateIndexBuffer():void
		{
			if (_rawIndexBuffer.length == 0)
				throw new Error("Raw Index buffer is empty");
			_indexBuffer = _context3d.createIndexBuffer(_rawIndexBuffer.length);
			_indexBuffer.uploadFromVector(_rawIndexBuffer, 0 , _rawIndexBuffer.length);
		}
		
//--------------------------------------------------------------------------
//
//  Utils Methods
//
//--------------------------------------------------------------------------	
		
		public function restoreNormals():void
		{
			_rawNormalsBuffer = _cachedRawNormalsBuffer.concat();
		}
		
		public function get3PointNormal(p0:Vector3D, p1:Vector3D, p2:Vector3D):Vector3D
		{
			var p0p1:Vector3D = p1.subtract(p0);
			var p0p2:Vector3D = p2.subtract(p0);
			var normal:Vector3D = p0p1.crossProduct(p0p2);
			normal.normalize();
			return normal;
		}
		
		public function forceNormals():void
		{
			_cachedRawNormalsBuffer = _rawNormalsBuffer.concat();
			
			var i:uint;
			var index:uint;
			var loop:uint = _rawPositionsBuffer.length / 3;
			var vertices:Vector.<Vector3D> = new Vector.<Vector3D>();
			var vertex:Vector3D;
			
			for (i = 0; i < loop; i++)
			{
				index = 3 * i;
				vertex = new Vector3D(_rawPositionsBuffer[index], _rawPositionsBuffer[index + 1], _rawPositionsBuffer[index + 2]);
				vertices.push(vertex);
			}
			
			loop = vertices.length;
			var p0:Vector3D;
			var p1:Vector3D;
			var p2:Vector3D;
			var normal:Vector3D;
			
			_rawNormalsBuffer = new Vector.<Number>();
			
			for (i = 0; i < loop; i += 3)
			{
				p0 = vertices[i];
				p1 = vertices[i + 1];
				p2 = vertices[i + 2];
				normal = get3PointNormal(p0, p1, p2);
				_rawNormalsBuffer.push(normal.x, normal.y, normal.z);
				_rawNormalsBuffer.push(normal.x, normal.y, normal.z);
				_rawNormalsBuffer.push(normal.x, normal.y, normal.z);
			}
		}
		
		public function dataDumpTrace():void
		{
			trace(dataDumpString());
		}
		
		public function dataDumpString():String
		{
			var str:String;
			str = "// Stage Model Data begins\n\n";
			
			str += "private var _Index:Vector.<uint> = new Vector.<uint>([" + _rawIndexBuffer.toString() + "]);\n\n";
			str += "private var _Positions:Vector.<Number> = new Vector.<Number>([" + _rawPositionsBuffer.toString() + "]);\n\n";
			str += "private var _Uvs:Vector.<Number> = new Vector.<Number>([" + _rawUvBuffer.toString() + "]);\n\n";
			str += "private var _Normals:Vector.<Number> = new Vector.<Number>([" + _rawNormalsBuffer.toString() + "]);\n\n";
			str += "private var _Colors:Vector.<Number> = new Vector.<Number>([" + _rawColorsBuffer.toString() + "]);\n\n";
			str += "// Stage Model Data ends\n";
			
			return str;
		}
		
	}

}