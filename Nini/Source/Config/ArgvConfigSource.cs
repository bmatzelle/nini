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
		StringBuilder usage = new StringBuilder ();
		ArgvParser parser = null;
		#endregion

		#region Constructors
		/// <include file='ArgvConfigSource.xml' path='//Constructor[@name="Constructor"]/docs/*' />
		public ArgvConfigSource (string[] arguments)
		{
			parser = new ArgvParser (arguments);
		}
		#endregion
		
		#region Public properties
		#endregion
		
		#region Public methods
		/// <include file='IConfigSource.xml' path='//Method[@name="Save"]/docs/*' />
		public void Save ()
		{
			throw new Exception ("Source is read only");
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="SavePath"]/docs/*' />
		public void Save (string path)
		{
			throw new Exception ("Cannot save this data to a file");
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="SaveTextWriter"]/docs/*' />
		public void Save (TextWriter writer)
		{
			throw new Exception ("Cannot save this data to a TextWriter");
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="AddSwitch"]/docs/*' />
		public void AddSwitch (string configName, string longName, 
								string description)
		{
			AddSwitch (configName, longName, null, description);
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="AddSwitchShort"]/docs/*' />
		public void AddSwitch (string configName, string longName, 
								string shortName, string description)
		{
			IConfig config = GetConfig (configName);

			if (parser[longName] != null) {
				config.Set (longName, parser[longName]);
			} else if (shortName != null && parser[shortName] != null) {
				config.Set (longName, parser[shortName]);
			}
			
			AddUsageItem (longName, shortName, description);
		}
		
		/// <include file='ArgvConfigSource.xml' path='//Method[@name="GetUsage"]/docs/*' />
		public string GetUsage ()
		{
			return usage.ToString ();
		}
		#endregion

		#region Private methods
		private void AddUsageItem (string longName, string shortName, string description)
		{
			if (shortName == null) {
				usage.Append (String.Format ("       --{0}         {1}",
							longName, description));
			} else {
				usage.Append (String.Format ("  -{0},  --{1}           {2}",
							shortName, longName, description));
			}
		}

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