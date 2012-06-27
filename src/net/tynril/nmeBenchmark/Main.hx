package net.tynril.nmeBenchmark;

import haxe.Timer;
import nme.Lib;

/**
 * Entry point of the NME Benchmark.
 * 
 * @author Samuel Loretan <tynril@gmail.com>
 */
class Main
{
	/** Delay in milliseconds between two benchmarks. */
	private static inline var DELAY_BETWEEN_BENCHMARKS : Int = 500;
	
	/** Time in milliseconds after which any unprepared or unfinished benchmark is killed. */
	private static inline var BENCHMARK_TIMEOUT : Int = 30000;
	
	/** List of all benchmarks to be run. */
	private static var _benchmarks : Array<Benchmark>;
	
	/** Benchmark currently being run. */
	private static var _currentBenchmark : Benchmark;
	
	/** Timeout related to the current operation. */
	private static var _currentTimeout : Timer;
	
	/**
	 * Entry point.
	 */
	static public function main() 
	{
		// Prepares the stage to get the benchmarks.
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		// Gets the list of benchmarks to run.
		_benchmarks = getBenchmarksList();
		
		// Executes the first one.
		runNext();
	}
	
	/**
	 * Gets the list of benchmarks to run by scanning the BenchmarksList class.
	 */
	private static function getBenchmarksList() : Array<Benchmark>
	{
		var list : Array<Benchmark> = [];
		var metaData = haxe.rtti.Meta.getStatics(BenchmarksList);
		var listXml = Xml.parse(untyped BenchmarksList.__rtti).firstElement();
		var listInfos = new haxe.rtti.XmlParser().processElement(listXml);
		switch(listInfos) {
			case haxe.rtti.TypeTree.TClassdecl(classDef):
				for(staticField in classDef.statics) {
					switch(staticField.type) {
						case haxe.rtti.CType.CClass(typeName, typeParams):
							list.push( {
								clazz: cast Type.resolveClass(typeName),
								args: Reflect.field(Reflect.field(metaData, staticField.name), 'args'),
								instance: null 
							} );
						default:
							throw "Error: the benchmarks list seems invalid.";
					}
				}
			default:
				throw "Error: the benchmarks list seems invalid.";
		}
		return list;
	}
	
	/**
	 * Executes the next benchmark in the stack.
	 */
	private static function runNext() : Void
	{
		// Check if there's still something to be run.
		if (_benchmarks.length == 0) {
			finish();
			return;
		}
		
		// Instanciate the next benchmark.
		_currentBenchmark = _benchmarks.shift();
		_currentBenchmark.instance = Type.createInstance(_currentBenchmark.clazz, _currentBenchmark.args);
		_currentBenchmark.instance.__preparationCompleted = benchmarkReadyHandler;
		_currentBenchmark.instance.__benchmarkCompleted = benchmarkCompletedHandler;
		
		// Prepares a timeout for the preparation.
		_currentTimeout = new Timer(BENCHMARK_TIMEOUT);
		_currentTimeout.run = benchmarkTimedOut;
		
		// Starts its preparation.
		_currentBenchmark.instance.prepare();
	}
	
	/**
	 * Called when the preparation of the current benchmark has completed.
	 */
	private static function benchmarkReadyHandler() : Void
	{
		// Clears the preparation timeout.
		_currentTimeout.stop();
		
		// Clean-up the memory.
		nme.system.System.gc();
		
		// Wait for one second, then start the benchmark.
		Timer.delay(delayedStartBenchmark, DELAY_BETWEEN_BENCHMARKS);
	}
	
	/**
	 * Starts the execution of a benchmark.
	 */
	private static function delayedStartBenchmark() : Void
	{
		// Prepares a timeout for the execution.
		_currentTimeout = new Timer(BENCHMARK_TIMEOUT);
		_currentTimeout.run = benchmarkTimedOut;
		
		// Executes!
		Lib.current.addChild(_currentBenchmark.instance);
		_currentBenchmark.instance.start();
	}
	
	/**
	 * Called when the current benchmark has finished running.
	 */
	private static function benchmarkCompletedHandler() : Void
	{
		trace("Benchmark complete.");
		disposeBenchmark();
		runNext();
	}
	
	/**
	 * Called when the current benchmark operation has timed out.
	 */
	private static function benchmarkTimedOut() : Void
	{
		trace("Benchmark timed out.");
		disposeBenchmark();
		runNext();
	}
	
	/**
	 * Disposes the current benchmark.
	 */
	private static function disposeBenchmark() : Void
	{
		// Clears the timeout.
		_currentTimeout.stop();
		
		// Removes the benchmark from the stage.
		Lib.current.removeChild(_currentBenchmark.instance);
		
		// Dispose of its internals.
		_currentBenchmark.instance.__preparationCompleted = null;
		_currentBenchmark.instance.__benchmarkCompleted = null;
		_currentBenchmark.instance.dispose();
	}
	
	/**
	 * Finishes the benchmark execution, and write the results to the
	 * output file.
	 */
	private static function finish() : Void
	{
		trace("Finished!");
	}
}

/**
 * Wrapper type for benchmarks.
 */
private typedef Benchmark = {
	var clazz : Class<AbstractBenchmark>;
	var args : Array<Dynamic>;
	var instance : AbstractBenchmark;
};
