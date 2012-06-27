package net.tynril.nmeBenchmark.benchmarks;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Linear;
import net.tynril.nmeBenchmark.AbstractBenchmark;
import nme.display.Sprite;
import nme.Lib;

class CircleBenchmark extends AbstractBenchmark
{
	private var _count : Int;
	private var _completed : Int;
	
	public function new(circlesCount : Int = 1)
	{
		super();
		
		_count = circlesCount;
	}
	
	public override function prepare() : Void
	{
		//trace("prepare");
		for (i in 0..._count)
		{
			var circle : Sprite = new Sprite();
			circle.graphics.beginFill(Std.int(Math.random() * 0xFFFFFF), 0.2 + Math.random());
			circle.graphics.drawCircle(0, 0, 10 + (Math.random() * 50));
			circle.graphics.endFill();
			
			circle.x = Math.random() * Lib.current.stage.stageWidth;
			circle.y = Math.random() * Lib.current.stage.stageHeight;
			
			addChild(circle);
			
			
		}
		
		_completed = 0;
		
		preparationCompleted();
	}
	
	public override function start() : Void
	{
		//trace("start");
		for (i in 0...this.numChildren)
		{
			Actuate.tween(this.getChildAt(i),
			2.0,
			{
				x: Math.random() * Lib.current.stage.stageWidth,
				y: Math.random() * Lib.current.stage.stageHeight
			}).ease(Linear.easeNone).onComplete(completed);
		}
	}
	
	private function completed() : Void
	{
		_completed ++;
		if (_completed == _count) {
			//trace("DONE");
			benchmarkCompleted();
		} //else
			//trace(_completed + "/" + _count);
	}
	
	public override function dispose() : Void
	{
		//trace("dispose");
		for (i in 0...this.numChildren)
			Actuate.stop(this.getChildAt(i));
		while(this.numChildren > 0)
			this.removeChildAt(0);
	}
}