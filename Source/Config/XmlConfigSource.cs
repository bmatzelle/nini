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
using System.Xml;
using System.Xml.XPath;
using System.Collections;

namespace Nini.Config
{
	/// <include file='XmlConfigSource.xml' path='//Class[@name="XmlConfigSource"]/docs/*' />
	public class XmlConfigSource : ConfigSourceBase
	{
		#region Private variables
		XmlDocument configDoc = null;
		string savePath = null;
		#endregion

		#region Constructors
		/// <include file='XmlConfigSource.xml' path='//Constructor[@name="ConstructorPath"]/docs/*' />
		public XmlConfigSource (string path)
		{
			savePath = path;
			configDoc = new XmlDocument ();
			configDoc.Load (path);
			PerformLoad (configDoc.CreateNavigator ());
		}

		/// <include file='XmlConfigSource.xml' path='//Constructor[@name="ConstructorXmlDoc"]/docs/*' />
		public XmlConfigSource (IXPathNavigable document)
		{
			if (document is XmlNode) {
				XmlNode node = (XmlNode)document;
				configDoc = (node.OwnerDocument == null)
							? (XmlDocument)node
							: (XmlDocument)node.OwnerDocument;  
			}
			PerformLoad (document.CreateNavigator ());
		}
		#endregion
		
		#region Public properties
		/// <include file='XmlConfigSource.xml' path='//Property[@name="SavePath"]/docs/*' />
		public string SavePath
		{
			get { return savePath; }
		}
		#endregion
		
		#region Public methods
		/// <include file='XmlConfigSource.xml' path='//Method[@name="Save"]/docs/*' />
		public override void Save ()
		{
			if (!IsSavable ()) {
				throw new ArgumentException ("Source cannot be saved in this state");
			}

			MergeConfigsIntoDocument ();
			configDoc.Save (savePath);
		}
		
		/// <include file='XmlConfigSource.xml' path='//Method[@name="SavePath"]/docs/*' />
		public void Save (string path)
		{
			this.savePath = path;
			this.Save ();
		}
		
		/// <include file='XmlConfigSource.xml' path='//Method[@name="SaveTextWriter"]/docs/*' />
		public void Save (TextWriter writer)
		{
			if (!IsSavable ()) {
				throw new ArgumentException ("Source cannot be saved in this state");
			}

			MergeConfigsIntoDocument ();
			configDoc.Save (writer);
			savePath = null;
		}
		#endregion

		#region Private methods
		/// <summary>
		/// Merges all of the configs from the config collection into the 
		/// XmlDocument.
		/// </summary>
		private void MergeConfigsIntoDocument ()
		{
			RemoveConfigs ();
			foreach (IConfig config in this.Configs)
			{
				string[] keys = config.GetKeys ();
				
				string search = "Nini/Section[@Name='" + config.Name + "']";
				XmlNode node = configDoc.SelectSingleNode (search);
				if (node == null) {
					node = SectionNode (config.Name);
					configDoc.DocumentElement.AppendChild (node);
				}
				RemoveKeys (config.Name);
				
				for (int i = 0; i < keys.Length; i++)
				{
					SetKey (node, keys[i], config.Get (keys[i]));
				}
			}
		}
		
		/// <summary>
		/// Removes all XML sections that were removed as configs.
		/// </summary>
		private void RemoveConfigs ()
		{
			XmlAttribute attr = null;
			XmlNodeList list = configDoc.SelectNodes ("Nini/Section");
			foreach (XmlNode node in list)
			{
				attr = node.Attributes["Name"];
				if (attr != null) {
					if (this.Configs[attr.Value] == null) {
						configDoc.DocumentElement.RemoveChild (node);
					}
				} else {
					throw new ArgumentException ("Section name attribute not found");
				}
			}
		}
		
		/// <summary>
		/// Removes all XML keys that were removed as config keys.
		/// </summary>
		private void RemoveKeys (string sectionName)
		{
			string search = "Nini/Section[@Name='" + sectionName + "']";
			XmlNode node = configDoc.SelectSingleNode (search);
			XmlAttribute keyName = null;
			
			if (node != null) {
				foreach (XmlNode key in node.SelectNodes ("Key"))
				{
					keyName = node.Attributes["Name"];
					if (keyName != null) {
						if (this.Configs[sectionName].Get (keyName.Value) == null) {
							node.RemoveChild (key);
						}
					} else {
						throw new ArgumentException ("Name attribute not found in key");
					}
				}
			}
		}

		/// <summary>
		/// Loads all sections and keys.
		/// </summary>
		private void PerformLoad (XPathNavigator navigator)
		{
			this.Merge (this); // required for SaveAll
			
			navigator.MoveToRoot (); // start at root node
			XPathNodeIterator iterator = navigator.Select ("/Nini");
			if (iterator.Count < 1) {
				throw new ArgumentException ("Did not find Nini XML root node");
			}
			
			LoadSections (navigator);
			base.ReplaceTextAll ();
		}
		
		/// <summary>
		/// Loads all configuration sections.
		/// </summary>
		private void LoadSections (XPathNavigator navigator)
		{
			XPathNodeIterator iterator = navigator.Select ("/Nini/Section");
			ConfigBase config = null;
			
			while (iterator.MoveNext ())
			{
				config = new ConfigBase (
							iterator.Current.GetAttribute ("Name", ""), this);
				
				this.Configs.Add (config);
				LoadKeys (iterator.Current, config);
			}
		}
		
		/// <summary>
		/// Loads all keys for a config.
		/// </summary>
		private void LoadKeys (XPathNavigator navigator, ConfigBase config)
		{
			XPathNodeIterator iterator = navigator.Select ("Key");

			while (iterator.MoveNext ())
			{
				config.Add (iterator.Current.GetAttribute ("Name", ""),
							iterator.Current.GetAttribute ("Value", ""));
			}
		}
		
		/// <summary>
		/// Sets an XML key.  If it does not exist then it is created.
		/// </summary>
		private void SetKey (XmlNode sectionNode, string key, string value)
		{
			string search = "Key[@Name='" + key + "']";
			XmlNode node = sectionNode.SelectSingleNode (search);
			
			if (node == null) {
				CreateKey (sectionNode, key, value);
			} else {
				node.Attributes["Value"].Value = value;
			}
		}
		
		/// <summary>
		/// Creates a key node and adds it to the collection at the end.
		/// </summary>
		private void CreateKey (XmlNode sectionNode, string key, string value)
		{
			XmlNode node = configDoc.CreateElement ("Key");
			XmlAttribute keyAttr = configDoc.CreateAttribute ("Name");
			XmlAttribute valueAttr = configDoc.CreateAttribute ("Value");
			keyAttr.Value = key;
			valueAttr.Value = value;

			node.Attributes.Append (keyAttr);
			node.Attributes.Append (valueAttr);

			sectionNode.AppendChild (node);
		}
		
		/// <summary>
		/// Returns a new section node.
		/// </summary>
		private XmlNode SectionNode (string name)
		{
			XmlNode result = configDoc.CreateElement ("Section");
			XmlAttribute nameAttr = configDoc.CreateAttribute ("Name");
			nameAttr.Value = name;
			result.Attributes.Append (nameAttr);
			
			return result;
		}
		
		/// <summary>
		/// Returns true if this instance is savable.
		/// </summary>
		private bool IsSavable ()
		{
			return (this.savePath != null
					&& configDoc != null);
		}
		#endregion
	}
}