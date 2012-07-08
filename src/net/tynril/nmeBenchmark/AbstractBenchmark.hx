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
	public function preparationCompleted() : Void {
		if (__preparationCompleted != null) __preparationCompleted();
	}
	public var __preparationCompleted : Void -> Void;
	
	/**
	 * Function to call once the benchmark itself is completed.
	 */
	public function benchmarkCompleted() : Void {
		if (__benchmarkCompleted != null) __benchmarkCompleted();
	}
	public var __benchmarkCompleted : Void -> Void;
	
	/**
	 * Get the name of the benchmark.
	 */
	public function getName() : String {
		throw "Abstract method call.";
		return "";
	}
	
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