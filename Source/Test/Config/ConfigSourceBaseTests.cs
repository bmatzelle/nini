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
using Nini.Config;
using NUnit.Framework;

namespace Nini.Test.Config
{
	[TestFixture]
	public class ConfigSourceBaseTests
	{
		#region Tests
		[Test]
		public void Merge ()
		{
			StringWriter textWriter = new StringWriter ();
			XmlTextWriter xmlWriter = NiniWriter (textWriter);
			WriteSection (xmlWriter, "Pets");
			WriteKey (xmlWriter, "cat", "muffy");
			WriteKey (xmlWriter, "dog", "rover");
			WriteKey (xmlWriter, "bird", "tweety");
			xmlWriter.WriteEndDocument ();
			
			XmlDocument doc = new XmlDocument ();
			doc.LoadXml (textWriter.ToString ());

			XmlConfigSource xmlSource = new XmlConfigSource (doc);
			
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[People]");
			writer.WriteLine (" woman = Jane");
			writer.WriteLine (" man = John");
			IniConfigSource iniSource = 
					new IniConfigSource (new StringReader (writer.ToString ()));
			
			xmlSource.Merge (iniSource);
			
			IConfig config = xmlSource.Configs["Pets"];
			Assert.AreEqual (3, config.GetKeys ().Length);
			Assert.AreEqual ("muffy", config.Get ("cat"));
			Assert.AreEqual ("rover", config.Get ("dog"));
			
			config = xmlSource.Configs["People"];
			Assert.AreEqual (2, config.GetKeys ().Length);
			Assert.AreEqual ("Jane", config.Get ("woman"));
			Assert.AreEqual ("John", config.Get ("man"));
		}
		
		[ExpectedException (typeof (ArgumentException))]
		public void MergeItself ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[People]");
			writer.WriteLine (" woman = Jane");
			writer.WriteLine (" man = John");
			IniConfigSource iniSource = 
					new IniConfigSource (new StringReader (writer.ToString ()));
			
			iniSource.Merge (iniSource); // exception
		}
		
		[ExpectedException (typeof (ArgumentException))]
		public void MergeExisting ()
		{
			StringWriter textWriter = new StringWriter ();
			XmlTextWriter xmlWriter = NiniWriter (textWriter);
			WriteSection (xmlWriter, "Pets");
			WriteKey (xmlWriter, "cat", "muffy");
			xmlWriter.WriteEndDocument ();
			
			XmlDocument doc = new XmlDocument ();
			doc.LoadXml (textWriter.ToString ());

			XmlConfigSource xmlSource = new XmlConfigSource (doc);
			
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[People]");
			writer.WriteLine (" woman = Jane");
			IniConfigSource iniSource = 
					new IniConfigSource (new StringReader (writer.ToString ()));
			
			xmlSource.Merge (iniSource);
			xmlSource.Merge (iniSource); // exception
		}
		
		[Test]
		public void AutoSave ()
		{
			string filePath = "AutoSaveTest.ini";

			StreamWriter writer = new StreamWriter (filePath);
			writer.WriteLine ("# some comment");
			writer.WriteLine ("[new section]");
			writer.WriteLine (" dog = Rover");
			writer.WriteLine (""); // empty line
			writer.WriteLine ("# a comment");
			writer.WriteLine (" cat = Muffy");
			writer.Close ();
			
			IniConfigSource source = new IniConfigSource (filePath);
			source.AutoSave = true;
			IConfig config = source.Configs["new section"];
			Assert.AreEqual ("Rover", config.Get ("dog"));
			Assert.AreEqual ("Muffy", config.Get ("cat"));
			
			config.Set ("dog", "Spots");
			config.Set ("cat", "Misha");
			
			Assert.AreEqual ("Spots", config.Get ("dog"));
			Assert.AreEqual ("Misha", config.Get ("cat"));
			
			source = new IniConfigSource (filePath);
			config = source.Configs["new section"];
			Assert.AreEqual ("Spots", config.Get ("dog"));
			Assert.AreEqual ("Misha", config.Get ("cat"));
			
			File.Delete (filePath);
		}
		
		[Test]
		public void AddConfig ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[Test]");
			writer.WriteLine (" bool 1 = TrUe");
			IniConfigSource source = new IniConfigSource 
									(new StringReader (writer.ToString ()));

			IConfig newConfig = source.AddConfig ("NewConfig");
			newConfig.Set ("NewKey", "NewValue");
			newConfig.Set ("AnotherKey", "AnotherValue");
			
			IConfig config = source.Configs["NewConfig"];
			Assert.AreEqual (2, config.GetKeys ().Length);
			Assert.AreEqual ("NewValue", config.Get ("NewKey"));
			Assert.AreEqual ("AnotherValue", config.Get ("AnotherKey"));
		}
		
		[Test]
		public void ReplaceText ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[Test]");
			writer.WriteLine (" author = Brent");
			writer.WriteLine (" domain = ${protocol}://nini.sf.net/");
			writer.WriteLine (" apache = Apache implements ${protocol}");
			writer.WriteLine (" developer = author of Nini: ${author} !");
			writer.WriteLine (" love = We love the ${protocol} protocol");
			writer.WriteLine (" combination = ${author} likes ${protocol}");
			writer.WriteLine (" fact = fact: ${apache}");
			writer.WriteLine (" protocol = http");
			IniConfigSource source = new IniConfigSource 
									(new StringReader (writer.ToString ()));

			IConfig config = source.Configs["Test"];
			Assert.AreEqual ("http", config.Get ("protocol"));
			Assert.AreEqual ("fact: Apache implements http", config.Get ("fact"));
			Assert.AreEqual ("http://nini.sf.net/", config.Get ("domain"));
			Assert.AreEqual ("Apache implements http", config.Get ("apache"));
			Assert.AreEqual ("We love the http protocol", config.Get ("love"));
			Assert.AreEqual ("author of Nini: Brent !", config.Get ("developer"));
			Assert.AreEqual ("Brent likes http", config.Get ("combination"));
		}
		
		[Test]
		public void ReplaceTextOtherSection ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[web]");
			writer.WriteLine (" apache = Apache implements ${protocol}");
			writer.WriteLine (" protocol = http");
			writer.WriteLine ("[server]");
			writer.WriteLine (" domain = ${web|protocol}://nini.sf.net/");
			IniConfigSource source = new IniConfigSource 
									(new StringReader (writer.ToString ()));

			IConfig config = source.Configs["web"];
			Assert.AreEqual ("http", config.Get ("protocol"));
			Assert.AreEqual ("Apache implements http", config.Get ("apache"));
			config = source.Configs["server"];
			Assert.AreEqual ("http://nini.sf.net/", config.Get ("domain"));
		}
		
		[Test]
		public void AddNewConfigsAndKeys ()
		{
			// Add some new configs and keys here and test.
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[Pets]");
			writer.WriteLine (" cat = muffy");
			writer.WriteLine (" dog = rover");
			IniConfigSource source = new IniConfigSource 
									(new StringReader (writer.ToString ()));
			
			IConfig config = source.Configs["Pets"];
			Assert.AreEqual ("Pets", config.Name);
			Assert.AreEqual (2, config.GetKeys ().Length);
			
			IConfig newConfig = source.AddConfig ("NewTest");
			newConfig.Set ("Author", "Brent");
			newConfig.Set ("Birthday", "February 8th");
			
			newConfig = source.AddConfig ("AnotherNew");
			
			Assert.AreEqual (3, source.Configs.Count);
			config = source.Configs["NewTest"];
			Assert.IsNotNull (config);
			Assert.AreEqual (2, config.GetKeys ().Length);
			Assert.AreEqual ("February 8th", config.Get ("Birthday"));
			Assert.AreEqual ("Brent", config.Get ("Author"));
		}
		#endregion

		#region Private methods
		private XmlTextWriter NiniWriter (TextWriter writer)
		{
			XmlTextWriter result = new XmlTextWriter (writer);
			result.WriteStartDocument ();
			result.WriteStartElement ("Nini");
			
			return result;
		}
		
		private void WriteSection (XmlWriter writer, string sectionName)
		{
			writer.WriteStartElement ("Section");
			writer.WriteAttributeString ("Name", sectionName);
		}
		
		private void WriteKey (XmlWriter writer, string key, string value)
		{
			writer.WriteStartElement ("Key");
			writer.WriteAttributeString ("Name", key);
			writer.WriteAttributeString ("Value", value);
			writer.WriteEndElement ();
		}
		#endregion
	}
}
