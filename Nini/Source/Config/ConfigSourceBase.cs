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
	/// <include file='IConfigSource.xml' path='//Class[@name="IConfigSource"]/docs/*' />
	public abstract class ConfigSourceBase
	{
		#region Private variables
		ArrayList sourceList = new ArrayList ();
		ConfigCollection configList = new ConfigCollection ();
		bool autoSave = false;
		bool replaceText = false;
		bool textReplaced = false;
		#endregion

		#region Constructors
		#endregion
		
		#region Public properties
		/// <include file='IConfigSource.xml' path='//Property[@name="Configs"]/docs/*' />
		public ConfigCollection Configs
		{
			get
			{
				if (this.ReplaceText && !textReplaced) {
					ReplaceTextAll ();
				}
				return configList;
			}
		}
		
		/// <include file='IConfigSource.xml' path='//Property[@name="AutoSave"]/docs/*' />
		public bool AutoSave
		{
			get { return autoSave; }
			set { autoSave = value; }
		}
		
		/// <include file='IConfigSource.xml' path='//Property[@name="ReplaceText"]/docs/*' />
		public bool ReplaceText
		{
			get { return replaceText; }
			set { replaceText = value; }
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
			ConfigBase result = new ConfigBase (name, (IConfigSource)this);
			configList.Add (result);
			
			return result;
		}
		
		/// <include file='IConfigSource.xml' path='//Method[@name="SetGlobalAlias"]/docs/*' />
		public void SetGlobalAlias (AliasText alias)
		{
			foreach (IConfig config in Configs)
			{
				config.Alias = alias;
			}
		}
		#endregion

		#region Private methods
		/// <summary>
		/// This performs a total lazy replace of all text.
		/// </summary>
		private void ReplaceTextAll ()
		{
			string[] keys = null;
			textReplaced = true;

			foreach (IConfig config in configList)
			{
				keys = config.GetKeys ();
				for (int i = 0; i < keys.Length; i++)
				{
					Replace (config, keys[i]);
				}
			}
		}
		
		/// <summary>
		/// Recursively replaces text.
		/// </summary>
		private void Replace (IConfig config, string key)
		{
			string text = config.Get (key);
			if (text == null) {
				throw new Exception (String.Format ("[{0}] not found in [{1}]",
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
					throw new Exception ("IConfig not found: " + replaces[0]);
				}
				result = newConfig.Get (replaces[1]);
				if (result == null) {
					throw new Exception ("Key not found: " + result);
				}
			} else {
				result = config.Get (search);
			}
			
			return result;
		}
		#endregion
	}
}
