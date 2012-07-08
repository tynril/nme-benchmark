package net.tynril.nmeBenchmark;

import haxe.rtti.Infos;
import net.tynril.nmeBenchmark.benchmarks.CircleBenchmark;

/**
 * Lists all benchmarks to be run.
 * 
 * The benchmarks are executed in the order their are defined.
 */
class BenchmarksList implements Infos
{
	@args(1000)
	public static var c : CircleBenchmark;
	
	@args(10000)
	public static var d : CircleBenchmark;
}