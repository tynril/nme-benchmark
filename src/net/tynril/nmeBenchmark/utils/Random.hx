package net.tynril.nmeBenchmark.utils;

/**
 * Utilitary class to generate seeded pseudo-random numbers.
 */
class Random 
{
	public var seed(default, default) : Float;
	
	public function new(initialSeed : Int = 1)
	{
		this.seed = initialSeed;
	}
	
	public function nextInt() : Int
	{
		return Std.int(gen() * 0x7fffffff);
	}
	
	public function nextFloat() : Float
	{
		return gen() / 2147483647.;
	}
	
	public function nextIntRange(min : Float, max : Float) : Int
	{
		return Math.round(nextFloatRange(min - .4999, max + .4999));
	}
	
	public function nextFloatRange(min : Float, max : Float) : Float
	{
		return min + ((max - min) * nextFloat());
	}
	
	private function gen() : Float
	{
		return seed = (seed * 16807.) % 2147483647.;
	}
}