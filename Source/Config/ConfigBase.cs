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
using Nini.Util;

namespace Nini.Config
{
	/// <include file='IConfig.xml' path='//Interface[@name="IConfig"]/docs/*' />
	public class ConfigBase : IConfig
	{
		#region Private variables
		string configName = null;
		OrderedList keys = new OrderedList ();
		IConfigSource configSource = null;
		AliasText aliasText = null;
		#endregion
		
		#region Constructors
		/// <include file='ConfigBase.xml' path='//Constructor[@name="ConfigBase"]/docs/*' />
		public ConfigBase (string name, IConfigSource source)
		{
			configName = name;
			configSource = source;
			aliasText = new AliasText ();
		}
		#endregion

		#region Public properties
		/// <include file='IConfig.xml' path='//Property[@name="Name"]/docs/*' />
		public string Name
		{
			get { return configName; }
		}
		
		/// <include file='IConfig.xml' path='//Property[@name="ConfigSource"]/docs/*' />
		public IConfigSource ConfigSource
		{
			get { return configSource; }
		}
		
		/// <include file='IConfig.xml' path='//Property[@name="Alias"]/docs/*' />
		public AliasText Alias
		{
			get { return aliasText; }
			set { aliasText = value; }
		}
		#endregion

		#region Public methods
		/// <include file='IConfig.xml' path='//Method[@name="Get"]/docs/*' />
		public string Get (string key)
		{
			return GetValue (key);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetDefault"]/docs/*' />
		public string Get (string key, string defaultValue)
		{
			string result = Get (key);
			
			return (result == null) ? defaultValue : result;
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="Get"]/docs/*' />
		public string GetString (string key)
		{
			return Get (key);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetDefault"]/docs/*' />
		public string GetString (string key, string defaultValue)
		{
			return Get (key, defaultValue);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetInt"]/docs/*' />
		public int GetInt (string key)
		{
			string text = GetValue (key);
			
			if (text == null) {
				throw new Exception ("Integer value not found");
			}

			return Convert.ToInt32 (text);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetIntAlias"]/docs/*' />
		public int GetInt (string key, bool fromAlias)
		{
			if (!fromAlias) {
				return GetInt (key);
			}

			string result = Get (key);
			
			if (result == null) {
				throw new Exception ("Integer value not found");
			}

			return aliasText.GetInt (key, result);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetIntDefault"]/docs/*' />
		public int GetInt (string key, int defaultValue)
		{
			string result = GetValue (key);
			
			return (result == null) ? defaultValue : Convert.ToInt32 (result);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetIntDefaultAlias"]/docs/*' />
		public int GetInt (string key, int defaultValue, bool fromAlias)
		{
			if (!fromAlias) {
				return GetInt (key, defaultValue);
			}

			string result = GetValue (key);
			
			return (result == null) ? defaultValue : aliasText.GetInt (key, result);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetLong"]/docs/*' />
		public long GetLong (string key)
		{
			string text = GetValue (key);
			
			if (text == null) {
				throw new Exception ("Long value not found");
			}
			
			return Convert.ToInt64 (text);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetLongDefault"]/docs/*' />
		public long GetLong (string key, long defaultValue)
		{
			string result = GetValue (key);
			
			return (result == null) ? defaultValue : Convert.ToInt64 (result);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetBoolean"]/docs/*' />
		public bool GetBoolean (string key)
		{
			string text = GetValue (key);
			
			if (text == null) {
				throw new Exception ("Boolean value not found");
			}
			
			return aliasText.GetBoolean (text);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetBooleanDefault"]/docs/*' />
		public bool GetBoolean (string key, bool defaultValue)
		{
			string text = GetValue (key);
			
			return (text == null) ? defaultValue : aliasText.GetBoolean (text);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetFloat"]/docs/*' />
		public float GetFloat (string key)
		{
			string text = GetValue (key);
			
			if (text == null) {
				throw new Exception ("Float value not found");
			}
			
			return Convert.ToSingle (text);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetFloatDefault"]/docs/*' />
		public float GetFloat (string key, float defaultValue)
		{
			string result = GetValue (key);
			
			return (result == null) ? defaultValue : Convert.ToSingle (result);
		}

		/// <include file='IConfig.xml' path='//Method[@name="GetDouble"]/docs/*' />
		public double GetDouble (string key)
		{
			string text = GetValue (key);
			
			if (text == null) {
				throw new Exception ("Double value not found");
			}
			
			return Convert.ToDouble (text);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="GetDoubleDefault"]/docs/*' />
		public double GetDouble (string key, double defaultValue)
		{
			string result = GetValue (key);
			
			return (result == null) ? defaultValue : Convert.ToDouble (result);
		}

		/// <include file='IConfig.xml' path='//Method[@name="GetKeys"]/docs/*' />
		public string[] GetKeys ()
		{
			string[] result = new string[keys.Keys.Count];
			
			keys.Keys.CopyTo (result, 0);
			
			return result;
		}
		
		/// <include file='ConfigBase.xml' path='//Method[@name="Add"]/docs/*' />
		public void Add (string key, string value)
		{
			keys.Add (key, value);
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="Set"]/docs/*' />
		public void Set (string key, object value)
		{
			if (!keys.Contains (key)) {
				keys.Add (key, value);
			} else {
				keys[key] = value.ToString ();
			}

			if (ConfigSource.AutoSave) {
				ConfigSource.Save ();
			}
		}
		
		/// <include file='IConfig.xml' path='//Method[@name="Remove"]/docs/*' />
		public void Remove (string key)
		{
			if (key == null) {
				throw new ArgumentNullException ("Key may not be null");
			}
			
			keys.Remove (key);
		}
		#endregion
		
		#region Private methods
		/// <summary>
		/// Returns the value if the given key.
		/// </summary>
		private string GetValue (string key)
		{
			string result = null;
			
			if (keys.Contains (key)) {
				result = (string)keys[key];
			}

			return result;
		}
		
		
		#endregion
	}
}