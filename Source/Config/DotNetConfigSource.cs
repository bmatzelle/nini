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
	/// <include file='DotNetConfigSource.xml' path='//Class[@name="DotNetConfigSource"]/docs/*' />
	public class DotNetConfigSource : ConfigSourceBase, IConfigSource
	{
		#region Private variables
		string[] sections = null;
		bool isReadOnly = false;
		XmlDocument configDoc = new XmlDocument ();
		#endregion

		#region Constructors
		/// <include file='DotNetConfigSource.xml' path='//Constructor[@name="ConstructorWeb"]/docs/*' />
		public DotNetConfigSource (string[] sections)
		{
			this.sections = sections;
			isReadOnly = true;
			Load ();
		}

		/// <include file='DotNetConfigSource.xml' path='//Constructor[@name="ConstructorFile"]/docs/*' />
		public DotNetConfigSource ()
		{
			configDoc.Load (ConfigFileName ());
			this.sections = SectionList (configDoc.DocumentElement);
			isReadOnly = false;
			Load ();
		}
		#endregion
		
		#region Public properties
		/// <include file='IConfigSource.xml' path='//Property[@name="IsReadOnly"]/docs/*' />
		public bool IsReadOnly
		{
			get { return isReadOnly; }
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
					SetKey (config.Name, keys[i], config.Get (keys[i]));
				}
			}
			
			configDoc.Save (ConfigFileName ());
		}
		#endregion

		#region Private methods
		/// <summary>
		/// Loads all collection classes.
		/// </summary>
		private void Load ()
		{
			this.Merge (this); // required for SaveAll
			for (int i = 0; i < sections.Length; i++)
			{
				LoadCollection (sections[i], (NameValueCollection)ConfigurationSettings
								.GetConfig (sections[i]));
			}
		}
		
		/// <summary>
		/// Sets an XML key.
		/// </summary>
		private void SetKey (string section, string key, string value)
		{
			string search = "configuration/" + section 
							+ "/add[@key='" + key + "']";
			
			XmlNode node = configDoc.SelectSingleNode (search);
			
			if (node != null) {
				node.Attributes["value"].Value = value;
			}
		}

		/// <summary>
		/// Loads a collection class.
		/// </summary>
		private void LoadCollection (string name, NameValueCollection collection)
		{
			ConfigBase config = new ConfigBase (name, this);

			if (collection == null) {
				throw new Exception ("Section was not found");
			}

			if (collection != null) {
				for (int i = 0; i < collection.Count; i++)
				{
					config.Add (collection.Keys[i], collection[i]);
				}
				
				this.Configs.Add (config);
			}
		}
		
		/// <summary>
		/// Loads all of the sections from an XML node.
		/// </summary>
		private string[] SectionList (XmlNode docNode)
		{
			ArrayList list = new ArrayList ();
			XmlDocument doc = new XmlDocument ();
			
			XmlNode node = docNode.SelectSingleNode ("/configuration/appSettings");
			if (node != null) {
				list.Add ("appSettings");
			}
			
			XmlNodeList nodeList = docNode.SelectNodes ("/configuration/configSections/section");
			
			for (int i = 0; i < nodeList.Count; i++)
			{
				XmlNode attr = nodeList[i].Attributes["name"];
				if (attr != null) {
					list.Add (attr.Value);
				}
			}
			
			string[] result = new string[list.Count];
			list.CopyTo (result, 0);
			
			return result;
		}
		
		/// <summary>
		/// Returns the name of the configuration file for this application.
		/// </summary>
		private string ConfigFileName ()
		{
			return ((Assembly.GetEntryAssembly()).GetName()).Name +
					".exe.config";
		}
		#endregion
	}
}