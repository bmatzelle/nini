#region Copyright
//
// Nini Configuration Project.
// Copyright (C) 2004 Brent R. Matzelle.  All rights reserved.
//
// This software is published under the terms of the MIT X11 license, a copy of 
// which has been included with this distribution in the LICENSE.txt file.
// 
#endregion

using System;
using System.Xml;
using System.Reflection;
using System.Collections;
using System.Configuration;
using System.Collections.Specialized;

namespace Nini.Config
{
	/// <include file='ArgvConfigSource.xml' path='//Class[@name="ArgvConfigSource"]/docs/*' />
	public class ArgvConfigSource : ConfigSourceBase, IConfigSource
	{
		#region Private variables
		#endregion

		#region Constructors
		/// <include file='ArgvConfigSource.xml' path='//Constructor[@name="Constructor"]/docs/*' />
		public ArgvConfigSource (string[] arguments)
		{
			// Perform the load of the arguments here
		}
		#endregion
		
		#region Public properties
		/// <include file='IConfigSource.xml' path='//Property[@name="IsReadOnly"]/docs/*' />
		public bool IsReadOnly
		{
			get { return true; }
		}
		#endregion
		
		#region Public methods
		/// <include file='IConfigSource.xml' path='//Method[@name="Save"]/docs/*' />
		public void Save ()
		{
			throw new Exception ("Source is read only");
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="AddSwitch"]/docs/*' />
		public void AddSwitch (string longName, string description)
		{
			AddSwitch (longName, null, description);
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="AddSwitchShort"]/docs/*' />
		public void AddSwitch (string longName, string shortName, string description)
		{
			//AddSwitch (new string[] { longName, shortName }, description);
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="GetUsage"]/docs/*' />
		public string GetUsage ()
		{
			string result = null;
			// return the usage string here.  Make it in one of several formats.
			// maybe pass in a parameter to pick either windows or unix style.
			// this enum might be useful later.
			return result;
		}
		#endregion

		#region Private methods
		/// <summary>
		/// Loads all sections and keys.
		/// </summary>
		private void PerformLoad ()
		{
		}
		#endregion
	}
}