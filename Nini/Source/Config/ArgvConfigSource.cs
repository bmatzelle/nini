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
using System.IO;
using System.Text;
using System.Collections;
using Nini.Util;

namespace Nini.Config
{
	/// <include file='ArgvConfigSource.xml' path='//Class[@name="ArgvConfigSource"]/docs/*' />
	public class ArgvConfigSource : ConfigSourceBase, IConfigSource
	{
		#region Private variables
		ArgvParser parser = null;
		string[] arguments = null;
		#endregion

		#region Constructors
		/// <include file='ArgvConfigSource.xml' path='//Constructor[@name="Constructor"]/docs/*' />
		public ArgvConfigSource (string[] arguments)
		{
			parser = new ArgvParser (arguments);
			this.arguments = arguments;
		}
		#endregion
		
		#region Public properties
		/// <include file='ArgvConfigSource.xml' path='//Property[@name="Arguments"]/docs/*' />
		public string[] Arguments
		{
			get { return this.arguments; }
		}
		#endregion
		
		#region Public methods
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="Save"]/docs/*' />
		public void Save ()
		{
			throw new Exception ("Source is read only");
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="AddSwitch"]/docs/*' />
		public void AddSwitch (string configName, string longName)
		{
			AddSwitch (configName, longName, null);
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="AddSwitchShort"]/docs/*' />
		public void AddSwitch (string configName, string longName, 
								string shortName)
		{
			IConfig config = GetConfig (configName);
			
			if (shortName.Length < 1 || shortName.Length > 2) {
				throw new Exception ("Short name may only be 1 or 2 characters");
			}

			// Look for the long name first
			if (parser[longName] != null) {
				config.Set (longName, parser[longName]);
			} else if (shortName != null && parser[shortName] != null) {
				config.Set (longName, parser[shortName]);
			}
		}
		#endregion

		#region Private methods
		/// <summary>
		/// Returns an IConfig.  If it does not exist then it is added.
		/// </summary>
		private IConfig GetConfig (string name)
		{
			IConfig result = null;
			
			if (this.Configs[name] == null) {
				result = new ConfigBase (name, this);
				this.Configs.Add (result);
			} else {
				result = this.Configs[name];
			}
			
			return result;
		}
		#endregion
	}
}