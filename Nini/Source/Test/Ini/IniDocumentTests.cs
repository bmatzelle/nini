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
using Nini.Ini;
using NUnit.Framework;

namespace Nini.Test.Ini
{
	[TestFixture]
	public class IniDocumentTests
	{
		[Test]
		public void GetSection ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("; Test");
			writer.WriteLine ("[Nini Thing]");
			IniDocument doc = new IniDocument (new StringReader (writer.ToString ()));
			
			Assert.AreEqual (1, doc.Sections.Count);
			Assert.AreEqual ("Nini Thing", doc.Sections["Nini Thing"].Name);
			Assert.AreEqual ("Nini Thing", doc.Sections[0].Name);
			Assert.IsNull (doc.Sections["Non Existant"]);
		}
		
		[Test]
		public void GetKey ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[Nini]");
			writer.WriteLine (" my key = something");
			IniDocument doc = new IniDocument (new StringReader (writer.ToString ()));
			
			IniSection section = doc.Sections["Nini"];
			Assert.IsTrue (section.Contains ("my key"));
			Assert.AreEqual ("something", section.GetValue ("my key"));
			Assert.IsFalse (section.Contains ("not here"));
		}

		[Test]
		public void SetSection ()
		{
			IniDocument doc = new IniDocument ();

			IniSection section = new IniSection ("new section");
			doc.Sections.Add (section);
			Assert.AreEqual ("new section", doc.Sections[0].Name);
			Assert.AreEqual ("new section", doc.Sections["new section"].Name);
			
			section = new IniSection ("a section", "a comment");
			doc.Sections.Add (section);
			Assert.AreEqual ("a comment", doc.Sections[1].Comment);
		}

		[Test]
		public void SetKey ()
		{
			IniDocument doc = new IniDocument ();
			
			IniSection section = new IniSection ("new section");
			doc.Sections.Add (section);

			section.Set ("new key", "some value");
			
			Assert.IsTrue (section.Contains ("new key"));
			Assert.AreEqual ("some value", section.GetValue ("new key"));
		}

		[Test]
		[ExpectedException (typeof (IniException))]
		public void ParserError ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[Nini Thing");
			writer.WriteLine (" my key = something");
			IniDocument doc = new IniDocument (new StringReader (writer.ToString ()));
		}

		[Test]
		public void RemoveSection ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[Nini Thing]");
			writer.WriteLine (" my key = something");
			writer.WriteLine ("[Parser]");
			IniDocument doc = new IniDocument (new StringReader (writer.ToString ()));
			
			Assert.IsNotNull (doc.Sections["Nini Thing"]);
			doc.Sections.Remove ("Nini Thing");
			Assert.IsNull (doc.Sections["Nini Thing"]);
		}

		[Test]
		public void RemoveKey ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[Nini]");
			writer.WriteLine (" my key = something");
			IniDocument doc = new IniDocument (new StringReader (writer.ToString ()));
			
			Assert.IsTrue (doc.Sections["Nini"].Contains ("my key"));
			doc.Sections["Nini"].Remove ("my key");
			Assert.IsFalse (doc.Sections["Nini"].Contains ("my key"));
		}

		[Test]
		public void GetAllKeys ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[Nini]");
			writer.WriteLine (" ; a comment");
			writer.WriteLine (" my key = something");
			writer.WriteLine (" dog = rover");
			writer.WriteLine (" cat = muffy");
			IniDocument doc = new IniDocument (new StringReader (writer.ToString ()));
			
			IniSection section = doc.Sections["Nini"];
			
			Assert.AreEqual (4, section.ItemCount);
			Assert.AreEqual (3, section.GetKeys ().Length);
			Assert.AreEqual ("my key", section.GetKeys ()[0]);
			Assert.AreEqual ("dog", section.GetKeys ()[1]);
			Assert.AreEqual ("cat", section.GetKeys ()[2]);
		}

		[Test]
		public void SaveDocumentWithComments ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("; some comment");
			writer.WriteLine (""); // empty line
			writer.WriteLine ("[new section]");
			writer.WriteLine (" dog = rover");
			writer.WriteLine (""); // Empty line
			writer.WriteLine ("; a comment");
			writer.WriteLine (" cat = muffy");
			IniDocument doc = new IniDocument (new StringReader (writer.ToString ()));
			
			StringWriter newWriter = new StringWriter ();
			doc.Save (newWriter);

			StringReader reader = new StringReader (newWriter.ToString ());
			Assert.AreEqual ("; some comment", reader.ReadLine ());
			Assert.AreEqual ("", reader.ReadLine ());
			Assert.AreEqual ("[new section]", reader.ReadLine ());
			Assert.AreEqual ("dog = rover", reader.ReadLine ());
			Assert.AreEqual ("", reader.ReadLine ());
			Assert.AreEqual ("; a comment", reader.ReadLine ());
			Assert.AreEqual ("cat = muffy", reader.ReadLine ());
			
			writer.Close ();
		}
	}
}