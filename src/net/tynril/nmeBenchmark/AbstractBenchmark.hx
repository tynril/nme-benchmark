package net.tynril.nmeBenchmark;
import nme.display.Sprite;

/**
 * Abstract class to be extended by every benchmarks.
 */
class AbstractBenchmark extends Sprite
{
	/**
	 * Function to call once the preparation is completed.
	 */
	public var preparationCompleted : Void -> Void;
	
	/**
	 * Function to call once the benchmark itself is completed.
	 */
	public var benchmarkCompleted : Void -> Void;
	
	/**
	 * Prepare the benchmark execution.
	 * 
	 * Once completed, call the <tt>preparationCompleted</tt> method.
	 */
	public function prepare() : Void {
		throw "Abstract method call.";
	}
	
	/**
	 * Starts the benchmarking process.
	 * 
	 * Once completed, call the <tt>benchmarkCompleted</tt> method.
	 */
	public function start() : Void {
		throw "Abstract method call.";
	}
	
	/**
	 * Disposes all memory and resources taken by the benchmark.
	 */
	public function dispose() : Void {
		throw "Abstract method call.";
	}
}