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
using System.Reflection;
using System.Collections;
using System.Configuration;
using System.Collections.Specialized;

namespace Nini.Config
{
	/// <include file='DotNetConfigSource.xml' path='//Class[@name="DotNetConfigSource"]/docs/*' />
	public class DotNetConfigSource : ConfigSourceBase
	{
		#region Private variables
		string[] sections = null;
		XmlDocument configDoc = null;
		string savePath = null;
		#endregion

		#region Constructors
		/// <include file='DotNetConfigSource.xml' path='//Constructor[@name="ConstructorWeb"]/docs/*' />
		public DotNetConfigSource (string[] sections)
		{
			this.sections = sections;
			Load ();
		}

		/// <include file='DotNetConfigSource.xml' path='//Constructor[@name="Constructor"]/docs/*' />
		public DotNetConfigSource ()
		{
			configDoc = new XmlDocument ();
			configDoc.LoadXml ("<configuration><configSections/></configuration>");
			PerformLoad (configDoc);
		}

		/// <include file='DotNetConfigSource.xml' path='//Constructor[@name="ConstructorPath"]/docs/*' />
		public DotNetConfigSource (string path)
		{
			savePath = path;
			configDoc = new XmlDocument ();
			configDoc.Load (savePath);
			PerformLoad (configDoc);
		}
		
		/// <include file='DotNetConfigSource.xml' path='//Constructor[@name="ConstructorXmlReader"]/docs/*' />
		public DotNetConfigSource (XmlReader reader)
		{
			configDoc = new XmlDocument ();
			configDoc.Load (reader);
			PerformLoad (configDoc);
		}
		#endregion
		
		#region Public properties
		/// <include file='DotNetConfigSource.xml' path='//Property[@name="SavePath"]/docs/*' />
		public string SavePath
		{
			get { return savePath; }
		}
		#endregion
		
		#region Public methods
		/// <include file='DotNetConfigSource.xml' path='//Method[@name="Save"]/docs/*' />
		public override void Save ()
		{
			if (!IsSavable ()) {
				throw new ArgumentException ("Source cannot be saved in this state");
			}
			MergeConfigsIntoDocument ();
		
			configDoc.Save (savePath);
			base.Save ();
		}
		
		/// <include file='DotNetConfigSource.xml' path='//Method[@name="SavePath"]/docs/*' />
		public void Save (string path)
		{
			if (!IsSavable ()) {
				throw new ArgumentException ("Source cannot be saved in this state");
			}

			savePath = path;
			this.Save ();
		}
		
		/// <include file='DotNetConfigSource.xml' path='//Method[@name="SaveTextWriter"]/docs/*' />
		public void Save (TextWriter writer)
		{
			if (!IsSavable ()) {
				throw new ArgumentException ("Source cannot be saved in this state");
			}

			MergeConfigsIntoDocument ();
			configDoc.Save (writer);
			savePath = null;
		}

		/// <include file='IConfigSource.xml' path='//Method[@name="Reload"]/docs/*' />
		public override void Reload ()
		{
			if (savePath == null) {
				throw new ArgumentException ("Error reloading: You must have "
							+ "the loaded the source from a file");
			}

			this.Configs.Clear ();
			configDoc = new XmlDocument ();
			configDoc.Load (savePath);
			PerformLoad (configDoc);
			base.Reload ();
		}

		/// <include file='DotNetConfigSource.xml' path='//Method[@name="ToString"]/docs/*' />
		public override string ToString ()
		{
			MergeConfigsIntoDocument ();
			StringWriter writer = new StringWriter ();
			configDoc.Save (writer);

			return writer.ToString ();
		}

#if (NET_COMPACT_1_0)
#else
		/// <include file='DotNetConfigSource.xml' path='//Method[@name="GetFullConfigPath"]/docs/*' />
		public static string GetFullConfigPath ()
		{
			return (Assembly.GetEntryAssembly().Location + ".config");
		}
#endif
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
				
				XmlNode node = GetChildElement (configDoc.DocumentElement, 
												config.Name);
				if (node == null) {
					node = SectionNode (config.Name);
				}
				RemoveKeys (config.Name);
				
				for (int i = 0; i < keys.Length; i++)
				{
					SetKey (node, keys[i], config.Get (keys[i]));
				}
			}
		}

		/// <summary>
		/// Loads all collection classes.
		/// </summary>
		private void Load ()
		{
#if (NET_COMPACT_1_0)
			throw new NotSupportedException ("This loading method is not supported");
#else
			this.Merge (this); // required for SaveAll
			for (int i = 0; i < sections.Length; i++)
			{
				LoadCollection (sections[i], (NameValueCollection)ConfigurationSettings
								.GetConfig (sections[i]));
			}
#endif
		}
		
		/// <summary>
		/// Loads all sections and keys.
		/// </summary>
		private void PerformLoad (XmlDocument document)
		{
			this.Merge (this); // required for SaveAll

			if (document.DocumentElement.Name != "configuration") {
				throw new ArgumentException ("Did not find configuration node");
			}

			LoadSections (document.DocumentElement);
		}
		
		/// <summary>
		/// Loads all configuration sections.
		/// </summary>
		private void LoadSections (XmlNode rootNode)
		{
			XmlNode sections = GetChildElement (rootNode, "configSections");
			ConfigBase config = null;
			
			foreach (XmlNode node in sections.ChildNodes)
			{
				if (node.NodeType == XmlNodeType.Element
					&& node.Name == "section") {
					config = new ConfigBase 
							(node.Attributes["name"].Value, this);
				
					this.Configs.Add (config);
					LoadKeys (rootNode, config);
				}
			}
			LoadOtherSection (rootNode, "appSettings");
		}
		
		/// <summary>
		/// Loads special sections that are not loaded in the configSections
		/// node.  This includes such sections such as appSettings.
		/// </summary>
		private void LoadOtherSection (XmlNode rootNode, string nodeName)
		{
			XmlNode section = GetChildElement (rootNode, nodeName);
			ConfigBase config = null;
			
			if (section != null) {
				config = new ConfigBase (section.Name, this);
				
				this.Configs.Add (config);
				LoadKeys (rootNode, config);
			}
		}
		
		/// <summary>
		/// Loads all keys for a config.
		/// </summary>
		private void LoadKeys (XmlNode rootNode, ConfigBase config)
		{
			XmlNode section = GetChildElement (rootNode, config.Name);

			foreach (XmlNode node in section.ChildNodes)
			{
				if (node.NodeType == XmlNodeType.Element
					&& node.Name == "add") {
					config.Add (node.Attributes["key"].Value,
								node.Attributes["value"].Value);
				}
			}
		}
		
		/// <summary>
		/// Removes all XML sections that were removed as configs.
		/// </summary>
		private void RemoveConfigs ()
		{
			XmlAttribute attr = null;
			XmlNode sections = GetChildElement (configDoc.DocumentElement, 
												"configSections");
			
			// TODO, remove the other section node as well - /configuration/sectionname

			foreach (XmlNode node in sections.ChildNodes)
			{
				if (node.NodeType == XmlNodeType.Element
					&& node.Name == "section") {
					attr = node.Attributes["name"];
					if (attr != null) {
						if (this.Configs[attr.Value] == null) {
							node.ParentNode.RemoveChild (node);
						}
					} else {
						throw new ArgumentException ("Section name attribute not found");
					}
				}
			}
		}
		
		/// <summary>
		/// Removes all XML keys that were removed as config keys.
		/// </summary>
		private void RemoveKeys (string sectionName)
		{
			XmlNode node = GetChildElement (configDoc.DocumentElement, 
											sectionName);
			XmlAttribute keyName = null;
			
			if (node != null) {
				foreach (XmlNode key in node.ChildNodes)
				{
					if (node.NodeType == XmlNodeType.Element
						&& node.Name == "add") {
						keyName = key.Attributes["key"];
						if (keyName != null) {
							if (this.Configs[sectionName].Get (keyName.Value) == null) {
								node.RemoveChild (key);
							}
						} else {
							throw new ArgumentException ("Key attribute not found in node");
						}
					}
				}
			}
		}
		
		/// <summary>
		/// Sets an XML key.  If it does not exist then it is created.
		/// </summary>
		private void SetKey (XmlNode sectionNode, string key, string value)
		{
			XmlNode keyNode = null;

			foreach (XmlNode node in sectionNode.ChildNodes)
			{
				if (node.NodeType == XmlNodeType.Element
					&& node.Name == "add"
					&& node.Attributes["key"].Value == key) {
					keyNode = node;
					break;
				}
			}
			
			if (keyNode == null) {
				CreateKey (sectionNode, key, value);
			} else {
				keyNode.Attributes["value"].Value = value;
			}
		}
		
		/// <summary>
		/// Creates a key node and adds it to the collection at the end.
		/// </summary>
		private void CreateKey (XmlNode sectionNode, string key, string value)
		{
			XmlNode node = configDoc.CreateElement ("add");
			XmlAttribute keyAttr = configDoc.CreateAttribute ("key");
			XmlAttribute valueAttr = configDoc.CreateAttribute ("value");
			keyAttr.Value = key;
			valueAttr.Value = value;

			node.Attributes.Append (keyAttr);
			node.Attributes.Append (valueAttr);

			sectionNode.AppendChild (node);
		}

		/// <summary>
		/// Loads a collection class.
		/// </summary>
		private void LoadCollection (string name, NameValueCollection collection)
		{
			ConfigBase config = new ConfigBase (name, this);

			if (collection == null) {
				throw new ArgumentException ("Section was not found");
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
		/// Returns a new section node.
		/// </summary>
		private XmlNode SectionNode (string name)
		{
			// Add node for configSections node
			XmlNode node = configDoc.CreateElement ("section");
			XmlAttribute attr = configDoc.CreateAttribute ("name");
			attr.Value = name;
			node.Attributes.Append (attr);
			
			attr = configDoc.CreateAttribute ("type");
			attr.Value = "System.Configuration.NameValueSectionHandler";
			node.Attributes.Append (attr);

			XmlNode section = GetChildElement (configDoc.DocumentElement, 
												"configSections");
			section.AppendChild (node);
		
			// Add node for configuration node
			XmlNode result = configDoc.CreateElement (name);
			configDoc.DocumentElement.AppendChild (result);
			
			return result;
		}
		
		/// <summary>
		/// Returns true if this instance is savable.
		/// </summary>
		private bool IsSavable ()
		{
			return (this.savePath != null
					|| configDoc != null);
		}

		/// <summary>
		/// Returns the single named child element.
		/// </summary>
		private XmlNode GetChildElement (XmlNode parentNode, string name)
		{
			XmlNode result = null;

			foreach (XmlNode node in parentNode.ChildNodes)
			{
				if (node.NodeType == XmlNodeType.Element
					&& node.Name == name) {
					result = node;
					break;
				}
			}

			return result;
		}
		#endregion
	}
}