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
using System.Collections;

namespace Nini.Config
{
	/// <include file='ConfigCollection.xml' path='//Class[@name="ConfigCollection"]/docs/*' />
	public class ConfigCollection : ICollection, IEnumerable, IList
	{
		#region Private variables
		ArrayList configList = new ArrayList ();
		#endregion
		
		#region Public properties
		/// <include file='ConfigCollection.xml' path='//Property[@name="Count"]/docs/*' />
		public int Count
		{
			get { return configList.Count; }
		}
		
		/// <include file='ConfigCollection.xml' path='//Property[@name="IsSynchronized"]/docs/*' />
		public bool IsSynchronized
		{
			get { return false; }
		}
		
		/// <include file='ConfigCollection.xml' path='//Property[@name="SyncRoot"]/docs/*' />
		public object SyncRoot
		{
			get { return this; }
		}
		
		/// <include file='ConfigCollection.xml' path='//Property[@name="ItemIndex"]/docs/*' />
		public IConfig this[int index]
		{
			get { return (IConfig)configList[index]; }
		}

		/// <include file='ConfigCollection.xml' path='//Property[@name="ItemIndex"]/docs/*' />
		object IList.this[int index]
		{
			get { return configList[index]; }
			set {  }
		}
		
		/// <include file='ConfigCollection.xml' path='//Property[@name="ItemName"]/docs/*' />
		public IConfig this[string configName]
		{
			get
			{
				IConfig result = null;

				foreach (IConfig config in configList)
				{
					if (config.Name == configName) {
						result = config;
						break;
					}
				}
				
				return result;
			}
		}

		/// <include file='ConfigCollection.xml' path='//Property[@name="IsFixedSize"]/docs/*' />
		public bool IsFixedSize
		{
			get { return false; }
		}

		/// <include file='ConfigCollection.xml' path='//Property[@name="IsReadOnly"]/docs/*' />
		public bool IsReadOnly
		{
			get { return false; }
		}
		#endregion
		
		#region Public methods
		/// <include file='ConfigCollection.xml' path='//Method[@name="Add"]/docs/*' />
		public void Add (IConfig config)
		{
			if (configList.Contains (config)) {
				throw new ArgumentException ("IConfig already exists");
			}
			IConfig existingConfig = this[config.Name];

			if (existingConfig != null) {
				// Set all new keys
				string[] keys = config.GetKeys ();
				for (int i = 0; i < keys.Length; i++)
				{
					existingConfig.Set (keys[i], config.Get (keys[i]));
				}
			} else {
				configList.Add (config);
			}
		}

		/// <include file='ConfigCollection.xml' path='//Method[@name="Add"]/docs/*' />
		int IList.Add (object config)
		{
			IConfig newConfig = config as IConfig;

			if (newConfig == null) {
				throw new Exception ("Must be an IConfig");
			} else {
				this.Add (newConfig);
				return IndexOf (newConfig);
			}
		}

		/// <include file='ConfigCollection.xml' path='//Method[@name="Remove"]/docs/*' />
		public void Remove (IConfig config)
		{
			configList.Remove (config);
		}

		/// <include file='ConfigCollection.xml' path='//Method[@name="Remove"]/docs/*' />
		public void Remove (object config)
		{
			configList.Remove (config);
		}

		/// <include file='ConfigCollection.xml' path='//Method[@name="RemoveAt"]/docs/*' />
		public void RemoveAt (int index)
		{
			configList.RemoveAt (index);
		}

		/// <include file='ConfigCollection.xml' path='//Method[@name="Clear"]/docs/*' />
		public void Clear ()
		{
			configList.Clear ();
		}
		
		/// <include file='ConfigCollection.xml' path='//Method[@name="GetEnumerator"]/docs/*' />
		public IEnumerator GetEnumerator ()
		{
			return configList.GetEnumerator ();
		}
		
		/// <include file='ConfigCollection.xml' path='//Method[@name="CopyTo"]/docs/*' />
		public void CopyTo (Array array, int index)
		{
			configList.CopyTo (array, index);
		}
		
		/// <include file='ConfigCollection.xml' path='//Method[@name="CopyToStrong"]/docs/*' />
		public void CopyTo (IConfig[] array, int index)
		{
			((ICollection)configList).CopyTo (array, index);
		}

		/// <include file='ConfigCollection.xml' path='//Method[@name="Contains"]/docs/*' />
		public bool Contains (object config)
		{
			return configList.Contains (config);
		}

		/// <include file='ConfigCollection.xml' path='//Method[@name="IndexOf"]/docs/*' />
		public int IndexOf (object config)
		{
			return configList.IndexOf (config);
		}

		/// <include file='ConfigCollection.xml' path='//Method[@name="Insert"]/docs/*' />
		public void Insert (int index, object config)
		{
			configList.Insert (index, config);
		}
		#endregion
		
		#region Private methods
		#endregion
	}
}