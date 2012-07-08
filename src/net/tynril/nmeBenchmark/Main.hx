package net.tynril.nmeBenchmark;

import haxe.Timer;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

using net.tynril.nmeBenchmark.utils.XmlUtils;

/**
 * Entry point of the NME Benchmark.
 * 
 * @author Samuel Loretan <tynril@gmail.com>
 */
class Main extends Sprite
{
	/** Delay in milliseconds between two benchmarks. */
	private static inline var DELAY_BETWEEN_BENCHMARKS : Int = 500;
	
	/** Time in milliseconds after which any unprepared or unfinished benchmark is killed. */
	private static inline var BENCHMARK_TIMEOUT : Int = 30000;
	
	/** List of all benchmarks to be run. */
	private var _benchmarks : Array<Benchmark>;
	
	/** List of all benchmarks results. */
	private var _results : Array<BenchmarkResults>;
	
	/** Benchmark currently being run. */
	private var _currentBenchmark : Benchmark;
	
	/** Results of the benchmark currently being run. */
	private var _currentResults : BenchmarkResults;
	
	/** Timestamp of the last frame on the current benchmark. */
	private var _lastFrameStamp : Float;
	
	/** Timeout related to the current operation. */
	private var _currentTimeout : Timer;
	
	/**
	 * Entry point.
	 */
	static public function main() 
	{
		// Prepares the stage to get the benchmarks.
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		// Adds the stage root.
		Lib.current.addChild(new Main());
	}
	
	/**
	 * Stage root constructor.
	 */
	public function new()
	{
		super();
		
		// Gets the list of benchmarks to run.
		_benchmarks = getBenchmarksList();
		_results = [];
		
		// Executes the first one.
		runNext();
	}
	
	/**
	 * Gets the list of benchmarks to run by scanning the BenchmarksList class.
	 */
	private function getBenchmarksList() : Array<Benchmark>
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
							var benchmark : Benchmark = new Benchmark();
							benchmark.clazz = cast Type.resolveClass(typeName);
							benchmark.args = [];
							
							if (Reflect.hasField(metaData, staticField.name) &&
								Reflect.hasField(Reflect.field(metaData, staticField.name), 'args')) {
								benchmark.args = Reflect.field(Reflect.field(metaData, staticField.name), 'args');
							}
							
							list.push(benchmark);
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
	private function runNext() : Void
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
	private function benchmarkReadyHandler() : Void
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
	private function delayedStartBenchmark() : Void
	{
		// Prepares a timeout for the execution.
		_currentTimeout = new Timer(BENCHMARK_TIMEOUT);
		_currentTimeout.run = benchmarkTimedOut;
		
		// Starts the frames time measurement.
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
		// Prepares the result container.
		_currentResults = new BenchmarkResults();
		_currentResults.name = _currentBenchmark.instance.getName();
		_currentResults.framesDurations = [];
		_currentResults.startTime = Timer.stamp();
		_lastFrameStamp = Timer.stamp();
		
		// Executes!
		Lib.current.addChild(_currentBenchmark.instance);
		_currentBenchmark.instance.start();
	}
	
	/**
	 * Called every frame while the benchmark is running.
	 */
	private function enterFrameHandler(e) : Void
	{
		var currentFrameStamp : Float = Timer.stamp();
		_currentResults.framesDurations.push(currentFrameStamp - _lastFrameStamp);
		_lastFrameStamp = currentFrameStamp;
	}
	
	/**
	 * Called when the current benchmark has finished running.
	 */
	private function benchmarkCompletedHandler() : Void
	{
		// Finishes the results recording.
		_currentResults.endTime = Timer.stamp();
		_results.push(_currentResults);
		
		// Clears the current benchmark and go to the next one.
		disposeBenchmark();
		runNext();
	}
	
	/**
	 * Called when the current benchmark operation has timed out.
	 */
	private function benchmarkTimedOut() : Void
	{
		// Stores the result.
		_currentResults.endTime = Timer.stamp();
		_currentResults.timedOut = true;
		_results.push(_currentResults);
		
		// Clears the current benchmark and go to the next one.
		disposeBenchmark();
		runNext();
	}
	
	/**
	 * Disposes the current benchmark.
	 */
	private function disposeBenchmark() : Void
	{
		// Clears the timeout.
		_currentTimeout.stop();
		
		// Stops frames time measurement.
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
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
	private function finish() : Void
	{
		// Preparing the XML to store the result.
		var xmlResults : Xml = Xml.createDocument();
		xmlResults.addChild(Xml.createProlog("xml version=\"1.0\""));
		var rootNode : Xml = Xml.createElement("benchmark-results");
		xmlResults.addChild(rootNode);
		
		for (result in _results)
		{
			// Get the frames.
			var frames = result.framesDurations;
			var framesCount = frames.length;
			
			// Calculate the overall duration.
			var benchmarkDuration = (result.endTime - result.startTime);
			
			// Deducing the average framerate...
			var avgFramerate = (framesCount / benchmarkDuration);
			
			// Sorting the frames, the slowest to the fastest.
			frames.sort(function(a, b) return ((a < b) ? -1 : ((a > b) ? 1 : 0)) );
			
			// Getting an (approximately good enough) median.
			var medianFramerate = 1 / frames[Math.round(framesCount / 2)];
			
			// Getting the fastest and slowest frame, skipping 5% of potential artifacts.
			var bestFramerate = 1 / frames[Std.int(framesCount * 0.05)];
			var worseFramerate = 1 / frames[Std.int((framesCount - 1) * 0.95)];
			
			// Outputting the result.
			var resultNode : Xml = Xml.createElement("result");
			resultNode.set("name", result.name);
			resultNode.appendTextNode("duration", Std.string(benchmarkDuration));
			resultNode.appendTextNode("frames-count", Std.string(framesCount));
			resultNode.appendTextNode("avg-fps", Std.string(avgFramerate));
			resultNode.appendTextNode("median-fps", Std.string(medianFramerate));
			resultNode.appendTextNode("best-fps", Std.string(bestFramerate));
			resultNode.appendTextNode("worse-fps", Std.string(worseFramerate));
			rootNode.addChild(resultNode);
		}
		
		trace(xmlResults.toPrettyString());
	}
}

/**
 * Wrapper type for benchmarks.
 */
private class Benchmark {
	public function new() {}
	public var clazz : Class<AbstractBenchmark>;
	public var args : Array<Dynamic>;
	public var instance : AbstractBenchmark;
}

/**
 * Wrapper type for benchmark results.
 */
private class BenchmarkResults {
	public function new() {}
	public var name : String;
	public var startTime : Float;
	public var endTime : Float;
	public var framesDurations : Array<Float>;
	public var timedOut : Bool;
}