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
	public class ArgvConfigSourceTests
	{
		#region Tests
		[Test]
		public void GetConfig ()
		{
			// add some switches here
			Assert.Fail ();
		}
		
		[Test]
		public void GetString ()
		{
			Assert.Fail ();
		}
		
		[Test]
		public void GetInt ()
		{
			Assert.Fail ();
		}

		[Test]
		public void SetAndSave ()
		{
			string[] arguments = new string[] { "--help", "/pets:", "cat", "dog" };
			ArgvConfigSource source = new ArgvConfigSource (arguments);
			Assert.IsTrue (source.IsReadOnly);
			
			source.AddSwitch ("help", "h", "Display help menu");
			source.AddSwitch ("pets", "p", "Add one or more pets");

			Assert.IsTrue (source.GetUsage ().Length > 0);
			
			IConfig config = source.Configs["SwitchList"];
			Assert.IsTrue (config.Get ("help") != null);
			Assert.IsTrue (config.Get ("h") != null);
		}
		#endregion

		#region Private methods
		#endregion
	}
}