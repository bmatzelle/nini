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
using System.Text;
using System.Collections;

namespace Nini.Config
{
	#region ConfigSourceEventHandler class
	/// <include file='ConfigSourceEventArgs.xml' path='//Delegate[@name="ConfigSourceEventHandler"]/docs/*' />
	public delegate void ConfigSourceEventHandler (object sender, ConfigSourceEventArgs e);

	/// <include file='ConfigSourceEventArgs.xml' path='//Class[@name="ConfigSourceEventArgs"]/docs/*' />
	public class ConfigSourceEventArgs : EventArgs
	{
		IConfig config = null;

		/// <include file='ConfigSourceEventArgs.xml' path='//Constructor[@name="ConstructorIConfig"]/docs/*' />
		public ConfigSourceEventArgs (IConfig config)
		{
			this.config = config;
		}

		/// <include file='ConfigSourceEventArgs.xml' path='//Constructor[@name="Constructor"]/docs/*' />
		public ConfigSourceEventArgs ()
		{
		}

		/// <include file='ConfigSourceEventArgs.xml' path='//Property[@name="Config"]/docs/*' />
		public IConfig Config
		{
			get { return config; }
		}
	}
	#endregion

	/// <include file='IConfigSource.xml' path='//Interface[@name="IConfigSource"]/docs/*' />
	public abstract class ConfigSourceBase : IConfigSource
	{
		#region Private variables
		ArrayList sourceList = new ArrayList ();
		ConfigCollection configList = new ConfigCollection ();
		bool autoSave = false;
		AliasText alias = new AliasText ();
		event ConfigSourceEventHandler configAddedEvent;
		event ConfigSourceEventHandler reloadedEvent;
		event ConfigSourceEventHandler savedEvent;
		#endregion

		#region Constructors
		#endregion
		
		#region Public properties
		/// <include file='IConfigSource.xml' path='//Property[@name="Configs"]/docs/*' />
		public ConfigCollection Configs
		{
			get { return configList; }
		}
		
		/// <include file='IConfigSource.xml' path='//Property[@name="AutoSave"]/docs/*' />
		public bool AutoSave
		{
			get { return autoSave; }
			set { autoSave = value; }
		}
		
		/// <include file='IConfigSource.xml' path='//Property[@name="Alias"]/docs/*' />
		public AliasText Alias
		{
			get { return alias; }
		}
		#endregion
		
		#region Public methods
		/// <include file='IConfigSource.xml' path='//Method[@name="Merge"]/docs/*' />
		public void Merge (IConfigSource source)
		{
			if (!sourceList.Contains (source))  {
				sourceList.Add (source);
			}
			
			foreach (IConfig config in source.Configs)
			{
				this.Configs.Add (config);
			}
		}
		
		/// <include file='IConfigSource.xml' path='//Method[@name="AddConfig"]/docs/*' />
		public IConfig AddConfig (string name)
		{
			ConfigBase result = null;

			if (configList[name] == null) {
				result = new ConfigBase (name, this);
				configList.Add (result);
			} else {
				throw new ArgumentException ("An IConfig of that name already exists");
			}

			if (configAddedEvent != null) {
				configAddedEvent (this, new ConfigSourceEventArgs (result));
			}
			
			return result;
		}
		
		/// <include file='IConfigSource.xml' path='//Method[@name="Save"]/docs/*' />
		public virtual void Save ()
		{
			if (savedEvent != null) {
				savedEvent (this, new ConfigSourceEventArgs ());
			}
		}

		/// <include file='IConfigSource.xml' path='//Method[@name="Reload"]/docs/*' />
		public virtual void Reload ()
		{
			if (reloadedEvent != null) {
				reloadedEvent (this, new ConfigSourceEventArgs ());
			}
		}
		
		/// <include file='IConfigSource.xml' path='//Method[@name="ReplaceKeyValues"]/docs/*' />
		public void ReplaceKeyValues ()
		{
			string[] keys = null;

			foreach (IConfig config in configList)
			{
				keys = config.GetKeys ();
				for (int i = 0; i < keys.Length; i++)
				{
					Replace (config, keys[i]);
				}
			}
		}
		#endregion

		#region Public events
		/// <include file='IConfigSource.xml' path='//Event[@name="ConfigAdded"]/docs/*' />
		public event ConfigSourceEventHandler ConfigAdded
		{
			add { configAddedEvent += value; }
			remove { configAddedEvent -= value; }
		}

		/// <include file='IConfigSource.xml' path='//Event[@name="Reloaded"]/docs/*' />
		public event ConfigSourceEventHandler Reloaded
		{
			add { reloadedEvent += value; }
			remove { reloadedEvent -= value; }
		}

		/// <include file='IConfigSource.xml' path='//Event[@name="Saved"]/docs/*' />
		public event ConfigSourceEventHandler Saved
		{
			add { savedEvent += value; }
			remove { savedEvent -= value; }
		}
		#endregion

		#region Private methods		
		/// <summary>
		/// Recursively replaces text.
		/// </summary>
		private void Replace (IConfig config, string key)
		{
			string text = config.Get (key);
			if (text == null) {
				throw new ArgumentException (String.Format ("[{0}] not found in [{1}]",
										key, config.Name));
			}
			int startIndex = text.IndexOf ("${", 0);

			if (startIndex != -1) {
				int endIndex = text.IndexOf ("}");
				if (endIndex != -1) {
					string search = text.Substring (startIndex + 2, 
													endIndex - (startIndex + 2));

					string replace = ReplaceValue (config, search);

					// Assemble the result string
					StringBuilder builder = new StringBuilder ();
					for (int i = 0; i < startIndex; i++)
					{
						builder.Append (text[i]);
					}
					builder.Append (replace);
					for (int i = endIndex + 1; i < text.Length; i++)
					{
						builder.Append (text[i]);
					}
					
					config.Set (key, builder.ToString ());
					Replace (config, key); // recurse
				}
			}
		}
		
		/// <summary>
		/// Returns the replacement value of a config.
		/// </summary>
		private string ReplaceValue (IConfig config, string search)
		{
			string result = null;
			
			string[] replaces = search.Split ('|');
			
			if (replaces.Length > 1) {
				IConfig newConfig = this.Configs[replaces[0]];
				if (newConfig == null) {
					throw new ArgumentException ("IConfig not found: " + replaces[0]);
				}
				result = newConfig.Get (replaces[1]);
				if (result == null) {
					throw new ArgumentException ("Key not found: " + result);
				}
			} else {
				result = config.Get (search);
			}
			
			return result;
		}
		#endregion
	}
}
