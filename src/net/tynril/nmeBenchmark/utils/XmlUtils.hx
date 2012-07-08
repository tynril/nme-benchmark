package net.tynril.nmeBenchmark.utils;
using StringTools;

/**
 * Utilitary class for dealing with XMLs.
 */
class XmlUtils 
{
	/**
	 * Append a named node with a PCData element in it.
	 */
	public static function appendTextNode(parent : Xml, nodeName : String, nodeText : String) : Void
	{
		var textNode = Xml.createElement(nodeName);
		textNode.addChild(Xml.createPCData(nodeText));
		parent.addChild(textNode);
	}
	
	/**
	 * Print an XML node with indentation.
	 */
	public static function toPrettyString(rootNode : Xml, padChar : String = "\t") : String
	{
		var formatted = '';
		var reg = ~/(>)(<)(\/*)/g;
		var xml = reg.replace(rootNode.toString(), '$1\n$2$3');
		var pad = 0;
		var splitted = xml.split('\n');
		for (index in 0...splitted.length)
		{
			var node = splitted[index];
			var indent = 0;
			if (~/.+<\/\w[^>]*>$/.match(node)) {
				indent = 0;
			} else if (~/^<\/\w/.match(node)) {
				if (pad != 0) {
					pad -= 1;
				}
			} else if (~/^<\w[^>]*[^\/]>.*$/.match(node)) {
				indent = 1;
			} else {
				indent = 0;
			}

			var padding = '';
			for (j in  0...pad) {
				padding += padChar;
			}

			formatted += padding + node + '\n';
			pad += indent;
		}

		return formatted;
	}
}