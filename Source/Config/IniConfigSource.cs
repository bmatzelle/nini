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
using System.Collections;
using Nini.Ini;

namespace Nini.Config
{
	/// <include file='IniConfigSource.xml' path='//Class[@name="IniConfigSource"]/docs/*' />
	public class IniConfigSource : ConfigSourceBase
	{
		#region Private variables
		IniDocument iniDocument = null;
		string savePath = null;
		#endregion
		
		#region Public properties
		#endregion

		#region Constructors
		/// <include file='IniConfigSource.xml' path='//Constructor[@name="Constructor"]/docs/*' />
		public IniConfigSource ()
		{
			iniDocument = new IniDocument ();
		}

		/// <include file='IniConfigSource.xml' path='//Constructor[@name="ConstructorPath"]/docs/*' />
		public IniConfigSource (string filePath)
			: this (new StreamReader (filePath))
		{
			this.savePath = filePath;
		}
		
		/// <include file='IniConfigSource.xml' path='//Constructor[@name="ConstructorTextReader"]/docs/*' />
		public IniConfigSource (TextReader reader)
			: this (new IniDocument (reader))
		{
		}

		/// <include file='IniConfigSource.xml' path='//Constructor[@name="ConstructorIniDocument"]/docs/*' />
		public IniConfigSource (IniDocument document)
		{
			this.Merge (this); // required for SaveAll
			iniDocument = document;
			Load ();
		}
		
		/// <include file='IniConfigSource.xml' path='//Constructor[@name="ConstructorStream"]/docs/*' />
		public IniConfigSource (Stream stream)
			: this (new StreamReader (stream))
		{
		}
		#endregion
		
		#region Public properties
		/// <include file='IniConfigSource.xml' path='//Property[@name="SavePath"]/docs/*' />
		public string SavePath
		{
			get { return savePath; }
		}
		#endregion
		
		#region Public methods
		/// <include file='IniConfigSource.xml' path='//Method[@name="Save"]/docs/*' />
		public override void Save ()
		{
			if (!IsSavable ()) {
				throw new ArgumentException ("Source cannot be saved in this state");
			}

			MergeConfigsIntoDocument ();
			
			iniDocument.Save (this.savePath);
		}
		
		/// <include file='IniConfigSource.xml' path='//Method[@name="SavePath"]/docs/*' />
		public void Save (string path)
		{
			this.savePath = path;
			this.Save ();
		}
		
		/// <include file='IniConfigSource.xml' path='//Method[@name="SaveTextWriter"]/docs/*' />
		public void Save (TextWriter writer)
		{
			MergeConfigsIntoDocument ();
			iniDocument.Save (writer);
			savePath = null;
		}

		/// <include file='IniConfigSource.xml' path='//Method[@name="ToString"]/docs/*' />
		public override string ToString ()
		{
			MergeConfigsIntoDocument ();
			StringWriter writer = new StringWriter ();
			iniDocument.Save (writer);

			return writer.ToString ();
		}
		#endregion
		
		#region Private methods
		/// <summary>
		/// Merges all of the configs from the config collection into the 
		/// IniDocument.
		/// </summary>
		private void MergeConfigsIntoDocument ()
		{
			RemoveConfigs ();
			foreach (IConfig config in this.Configs)
			{
				string[] keys = config.GetKeys ();

				// Create a new section if one doesn't exist
				if (iniDocument.Sections[config.Name] == null) {
					IniSection section = new IniSection (config.Name);
					iniDocument.Sections.Add (section);
				}
				RemoveKeys (config.Name);

				for (int i = 0; i < keys.Length; i++)
				{
					iniDocument.Sections[config.Name].Set (keys[i], config.Get (keys[i]));
				}
			}
		}
		
		/// <summary>
		/// Removes all INI sections that were removed as configs.
		/// </summary>
		private void RemoveConfigs ()
		{
			IniSection section = null;
			for (int i = 0; i < iniDocument.Sections.Count; i++)
			{
				section = iniDocument.Sections[i];
				if (this.Configs[section.Name] == null) {
					iniDocument.Sections.Remove (section.Name);
				}
			}
		}
		
		/// <summary>
		/// Removes all INI keys that were removed as config keys.
		/// </summary>
		private void RemoveKeys (string sectionName)
		{
			IniSection section = iniDocument.Sections[sectionName];

			if (section != null) {
				foreach (string key in section.GetKeys ())
				{
					if (this.Configs[sectionName].Get (key) == null) {
						section.Remove (key);
					}
				}
			}
		}

		/// <summary>
		/// Loads the configuration file.
		/// </summary>
		private void Load ()
		{
			ConfigBase config = null;
			IniSection section = null;
			IniItem item = null;

			for (int j = 0; j < iniDocument.Sections.Count; j++)
			{
				section = iniDocument.Sections[j];
				config = new ConfigBase (section.Name, this);

				for (int i = 0; i < section.ItemCount; i++)
				{
					item = section.GetItem (i);
					
					if  (item.Type == IniType.Key) {
						config.Add (item.Name, item.Value);
					}
				}
				
				this.Configs.Add (config);
			}
		}
		
		/// <summary>
		/// Returns true if this instance is savable.
		/// </summary>
		private bool IsSavable ()
		{
			return (this.savePath != null);
		}
		#endregion
	}
}