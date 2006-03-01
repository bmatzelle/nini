#region Copyright
//
// Nini Configuration Project.
// Copyright (C) 2006 Brent R. Matzelle.  All rights reserved.
//
// This software is published under the terms of the MIT X11 license, a copy of 
// which has been included with this distribution in the LICENSE.txt file.
// 
// Original code written by: R. LOPES (GriffonRL)
// Article: http://thecodeproject.com/csharp/command_line.asp
#endregion

using System;
using System.Collections;
using System.Collections.Specialized;
using System.Text.RegularExpressions;

namespace Nini.Util
{
	/// <include file='ArgvParser.xml' path='//Class[@name="ArgvParser"]/docs/*' />
	public class ArgvParser
	{
		#region Private variables
		Hashtable parameters;
		#endregion

		#region Constructors
		/// <include file='ArgvParser.xml' path='//Constructor[@name="Constructor"]/docs/*' />
		public ArgvParser (string[] args)
		{
			parameters = new Hashtable ();
			Regex splitter = new Regex (@"^-{1,2}|^/|=|:", RegexOptions.Compiled);
			Regex remover = new Regex (@"^['""]?(.*?)['""]?$", RegexOptions.Compiled);
			string parameter = null;
			string[] parts;

			// Valid parameters forms:
			// {-,/,--}param{ ,=,:}((",')value(",'))
			// Examples: -param1 value1 --param2 /param3:"Test-:-work" /param4=happy -param5 '--=nice=--'
			foreach (string text in args)
			{
				// Look for new parameters (-,/ or --) and a possible enclosed value (=,:)
				parts = splitter.Split (text, 3);
				switch (parts.Length)
				{
				// Found a value (for the last parameter found (space separator))
				case 1:
					if (parameter != null) {
						if (!parameters.Contains (parameter)) {
							parts[0] = remover.Replace (parts[0], "$1");
							parameters.Add (parameter, parts[0]);
						}
						parameter = null;
					}
					// else Error: no parameter waiting for a value (skipped)
					break;
				// Found just a parameter
				case 2:
					// The last parameter is still waiting. With no value, set it to true.
					if (parameter != null) {
						if (!parameters.Contains (parameter)) {
							parameters.Add (parameter, "true");
						}
					}
					parameter = parts[1];
					break;
				// parameter with enclosed value
				case 3:
					// The last parameter is still waiting. With no value, set it to true.
					if (parameter != null) {
						if (!parameters.Contains (parameter)) {
							parameters.Add (parameter, "true");
						}
					}
					parameter = parts[1];
					// Remove possible enclosing characters  (",')
					if (!parameters.Contains (parameter)) {
						parts[2] = remover.Replace (parts[2], "$1");
						parameters.Add (parameter, parts[2]);
					}
					parameter = null;
					break;
				}
			}

			// In case a parameter is still waiting
			if (parameter !=  null) {
				if (!parameters.Contains (parameter)) {
					parameters.Add (parameter, "true");
				}
			}
		}
		#endregion

		#region Public properties
		/// <include file='ArgvParser.xml' path='//Property[@name="this"]/docs/*' />
		public string this [string Param]
		{
			get { return (string)parameters[Param]; }
		}
		#endregion
	}
}
