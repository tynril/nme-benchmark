package net.tynril.nmeBenchmark.benchmarks;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Linear;
import net.tynril.nmeBenchmark.AbstractBenchmark;
import net.tynril.nmeBenchmark.utils.Random;
import nme.display.Sprite;
import nme.Lib;

class CircleBenchmark extends AbstractBenchmark
{
	private var _count : Int;
	private var _completed : Int;
	private var _random : Random;
	
	public function new(circlesCount : Int = 1)
	{
		super();
		
		_count = circlesCount;
		_random = new Random(circlesCount);
	}
	
	public override function getName() : String
	{
		return _count + " circles of pain";
	}
	
	public override function prepare() : Void
	{
		for (i in 0..._count)
		{
			var circle : Sprite = new Sprite();
			circle.graphics.beginFill(Std.int(_random.nextFloat() * 0xFFFFFF), 0.2 + _random.nextFloat());
			circle.graphics.drawCircle(0, 0, 10 + (_random.nextFloat() * 50));
			circle.graphics.endFill();
			
			circle.x = _random.nextFloat() * Lib.current.stage.stageWidth;
			circle.y = _random.nextFloat() * Lib.current.stage.stageHeight;
			
			addChild(circle);
			
			
		}
		
		_completed = 0;
		
		preparationCompleted();
	}
	
	public override function start() : Void
	{
		for (i in 0...this.numChildren)
		{
			Actuate.tween(this.getChildAt(i),
			2.0,
			{
				x: _random.nextFloat() * Lib.current.stage.stageWidth,
				y: _random.nextFloat() * Lib.current.stage.stageHeight
			}).ease(Linear.easeNone).onComplete(completed);
		}
	}
	
	private function completed() : Void
	{
		_completed ++;
		if (_completed == _count)
			benchmarkCompleted();
	}
	
	public override function dispose() : Void
	{
		for (i in 0...this.numChildren)
			Actuate.stop(this.getChildAt(i));
		while(this.numChildren > 0)
			this.removeChildAt(0);
	}
}