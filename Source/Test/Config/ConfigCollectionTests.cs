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
	public class ConfigCollectionTests
	{
		[Test]
		public void GetConfig ()
		{
			ConfigBase config1 = new ConfigBase ("Test1", null);
			ConfigBase config2 = new ConfigBase ("Test2", null);
			ConfigBase config3 = new ConfigBase ("Test3", null);
			ConfigCollection collection = new ConfigCollection ();
			
			collection.Add (config1);
			Assert.AreEqual (1, collection.Count);
			Assert.AreEqual (config1, collection[0]);
			
			collection.Add (config2);
			collection.Add (config3);
			Assert.AreEqual (3, collection.Count);
			
			Assert.AreEqual (config2, collection["Test2"]);
			Assert.AreEqual (config3, collection["Test3"]);
			Assert.AreEqual (config3, collection[2]);
		}
		
		[Test]
		[ExpectedException (typeof (ArgumentException))]
		public void AlreadyExistsException ()
		{
			ConfigBase config = new ConfigBase ("Test", null);
			ConfigCollection collection = new ConfigCollection ();
			collection.Add (config);
			collection.Add (config); // exception
		}
		
		[Test]
		[ExpectedException (typeof (ArgumentException))]
		public void NameAlreadyExistsException ()
		{
			ConfigBase config1 = new ConfigBase ("Test", null);
			ConfigBase config2 = new ConfigBase ("Test", null);
			ConfigCollection collection = new ConfigCollection ();
			collection.Add (config1);
			collection.Add (config2); // exception
		}
	}
}