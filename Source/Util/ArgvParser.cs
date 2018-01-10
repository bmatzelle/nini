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
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Text.RegularExpressions;

namespace Nini.Util
{
    /// <include file='ArgvParser.xml' path='//Class[@name="ArgvParser"]/docs/*' />
    public class ArgvParser
    {
        #region Private variables
        StringDictionary parameters;
        List<string> positional;
        List<string> parameterlessArgs;
        #endregion
        
        #region Constructors
        /// <include file='ArgvParser.xml' path='//Constructor[@name="Constructor"]/docs/*' />
        public ArgvParser(string args)
        {

            Regex Extractor = new Regex(@"(['""][^""]+['""])\s*|([^\s]+)\s*",
                                        RegexOptions.Compiled);
            MatchCollection matches;
            string[] parts;
            
            // Get matches (first string ignored because 
            // Environment.CommandLine starts with program filename)
            matches = Extractor.Matches (args);
            parts = new string[matches.Count - 1];

            for (int i = 1; i < matches.Count; i++)
            {
                parts[i-1] = matches[i].Value.Trim ();
            }

            Extract(parts);
        }
        
        /// <include file='ArgvParser.xml' path='//Constructor[@name="ConstructorArray"]/docs/*' />
        public ArgvParser (string[] args, List<string> paramlessArgs)
        {
            parameterlessArgs = paramlessArgs;
            Extract (args);
        }
        #endregion
        
        #region Public properties
        /// <include file='ArgvParser.xml' path='//Property[@name="this"]/docs/*' />
        public string this [string param]
        {
            get {
                return parameters[param];
            }
        }

        public string this [int number]
        {
            get  {
                if (number < 0 || number >= positional.Count)
                    return String.Empty;

                return positional[number];
            }
        }

        public int Count()
        {
            return positional.Count;
        }
        #endregion

        #region Private methods
        // Extract command line parameters and values stored in a string array
        private void Extract(string[] args)
        {
            parameters = new StringDictionary();
            positional = new List<string>();
            Regex splitter = new Regex (@"^([/-]|--){1}(?<name>\w+)([:=])?(?<value>.+)?$",
                                        RegexOptions.Compiled);
            char[] trimChars = {'"','\''};
            string parameter = null;
            Match part;

            // Valid parameters forms: {-,/,--}param{ , = ,:}((",')value(",'))
            // Examples: -param1 value1 --param2 /param3:"Test-:-work" 
            // /param4 = happy -param5 '-- = nice = --'
            foreach(string arg in args)
            {
                part = splitter.Match(arg);
                if (!part.Success) {
                    // Found a value (for the last parameter found (space separator))
                    if (parameter != null) {
                        parameters[parameter] = arg.Trim (trimChars);
                        parameter = null;
                    } else {
                        positional.Add(arg.Trim(trimChars));
                    }
                } else {
                    // Matched a name, optionally with inline value
                    parameter = part.Groups["name"].Value;
                    parameters.Add (parameter, 
                                    part.Groups["value"].Value.Trim (trimChars));
                    if (parameterlessArgs != null && parameterlessArgs.Contains(parameter))
                    {
                        // Make it true and don't look for an argument
                        parameters[parameter] = "True";
                        parameter = null;
                    }
                }
            }
        }
        #endregion
    }
}
