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
	public class IniConfigSource : ConfigSourceBase, IConfigSource
	{
		#region Private variables
		IniDocument iniDocument = null;
		string filePath = null;
		#endregion
		
		#region Public properties
		/// <include file='IConfigSource.xml' path='//Property[@name="IsReadOnly"]/docs/*' />
		public bool IsReadOnly
		{
			get { return (filePath == null); }
		}
		#endregion

		#region Constructors
		/// <include file='IniConfigSource.xml' path='//Constructor[@name="ConstructorPath"]/docs/*' />
		public IniConfigSource (string filePath)
			: this (new StreamReader (filePath))
		{
			this.filePath = filePath;
		}
		
		/// <include file='IniConfigSource.xml' path='//Constructor[@name="ConstructorTextReader"]/docs/*' />
		public IniConfigSource (TextReader reader)
		{
			this.Merge (this); // required for SaveAll
			iniDocument = new IniDocument (reader);
			Load ();
		}
		
		/// <include file='IniConfigSource.xml' path='//Constructor[@name="ConstructorStream"]/docs/*' />
		public IniConfigSource (Stream stream)
			: this (new StreamReader (stream))
		{
		}
		#endregion
		
		#region Public methods
		/// <include file='IConfigSource.xml' path='//Method[@name="Save"]/docs/*' />
		public void Save ()
		{
			if (this.IsReadOnly) {
				throw new Exception ("Source is read only");
			}

			foreach (IConfig config in this.Configs)
			{
				string[] keys = config.GetKeys ();
				
				for (int i = 0; i < keys.Length; i++)
				{
					// Create a new section if one doesn't exist
					if (iniDocument.Sections[config.Name] == null) {
						IniSection section = new IniSection (config.Name);
						iniDocument.Sections.Add (section);
					}
					iniDocument.Sections[config.Name].Set (keys[i], config.Get (keys[i]));
				}
			}
			
			iniDocument.Save (this.filePath);
		}
		#endregion
		
		#region Private methods
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
		#endregion
	}
}