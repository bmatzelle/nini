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
using Nini.Config;
using NUnit.Framework;

namespace Nini.Test.Config
{
	[TestFixture]
	public class AliasTextTests
	{
		[Test]
		public void GetBoolean ()
		{
			AliasText alias = new AliasText ();
			alias.AddAlias ("true", true);
			alias.AddAlias ("faLSe", false);
			alias.AddAlias ("oN", true);
			alias.AddAlias ("oFF", false);
			
			Assert.IsTrue (alias.GetBoolean ("tRUe"));
			Assert.IsTrue (alias.GetBoolean ("oN"));
			
			Assert.IsFalse (alias.GetBoolean ("Off"));
			Assert.IsFalse (alias.GetBoolean ("False"));
		}
		
		[Test]
		[ExpectedException (typeof (Exception))]
		public void NonExistantBooleanText ()
		{
			AliasText alias = new AliasText ();
			alias.AddAlias ("true", true);
			alias.AddAlias ("faLSe", false);
			
			Assert.IsTrue (alias.GetBoolean ("Not present"));
		}
		
		[Test]
		public void GetInt ()
		{
			AliasText alias = new AliasText ();
			alias.AddAlias ("error code", "WaRn", 100);
			alias.AddAlias ("error code", "ErroR", 200);
			
			Assert.AreEqual (100, alias.GetInt ("error code", "warn"));
			Assert.AreEqual (200, alias.GetInt ("error code", "ErroR"));
		}
		
		[Test]
		[ExpectedException (typeof (Exception))]
		public void GetIntNonExistantText ()
		{
			AliasText alias = new AliasText ();
			alias.AddAlias ("error code", "WaRn", 100);
			
			Assert.AreEqual (100, alias.GetInt ("error code", "not here"));
		}
		
		[Test]
		[ExpectedException (typeof (Exception))]
		public void GetIntNonExistantKey ()
		{
			AliasText alias = new AliasText ();
			alias.AddAlias ("error code", "WaRn", 100);
			
			Assert.AreEqual (100, alias.GetInt ("not exist", "warn"));
		}
		
		[Test]
		public void GetIntEnum ()
		{
			AliasText alias = new AliasText ();
			alias.AddAlias ("node type", new System.Xml.XmlNodeType ());
			
			Assert.AreEqual ((int)System.Xml.XmlNodeType.Text, 
							 alias.GetInt ("node type", "teXt"));
			Assert.AreEqual ((int)System.Xml.XmlNodeType.Attribute, 
							 alias.GetInt ("node type", "aTTribute"));
			
			try
			{
				alias.GetInt ("node type", "not here");
			}
			catch
			{
			}
		}
		
		[Test]
		public void SetGlobalAlias ()
		{
			StringWriter writer = new StringWriter ();
			writer.WriteLine ("[BooleanTest1]");
			writer.WriteLine (" bool 1 = TrUe");
			writer.WriteLine (" bool 2 = FalSe");
			writer.WriteLine ("[BooleanTest2]");
			writer.WriteLine (" bool 3 = ON");
			writer.WriteLine (" bool 4 = OfF");
			IniConfigSource source = new IniConfigSource 
									(new StringReader (writer.ToString ()));
			
			AliasText alias = new AliasText ();
			alias.AddAlias ("true", true);
			alias.AddAlias ("false", false);
			alias.AddAlias ("on", true);
			alias.AddAlias ("off", false);
			
			source.SetGlobalAlias (alias);
			
			IConfig config = source.Configs["BooleanTest1"];
			Assert.IsTrue (config.GetBoolean ("bool 1"));
			Assert.IsFalse (config.GetBoolean ("bool 2"));
			
			config = source.Configs["BooleanTest2"];
			Assert.IsTrue (config.GetBoolean ("bool 3"));
			Assert.IsFalse (config.GetBoolean ("bool 4"));
			Assert.IsTrue (config.GetBoolean ("Not Here", true));
		}
	}
}
