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
	/// <include file='AliasText.xml' path='//Class[@name="AliasText"]/docs/*' />
	public class AliasText
	{
		#region Private variables
		Hashtable intAlias = new Hashtable ();
		Hashtable booleanAlias = new Hashtable ();
		#endregion

		#region Constructors
		/// <include file='AliasText.xml' path='//Constructor[@name="AliasText"]/docs/*' />
		public AliasText ()
		{
		}
		#endregion
		
		#region Public methods
		/// <include file='AliasText.xml' path='//Method[@name="AddAliasInt"]/docs/*' />
		public void AddAlias (string key, string alias, int value)
		{
			string lowerAlias = alias.ToLower ();

			if (intAlias.Contains (key)) {
				Hashtable keys = (Hashtable)intAlias[key];
				if (keys.Contains (lowerAlias))
					throw new Exception ("Alias text already exists");
				
				keys[lowerAlias] = value;
			} else {
				Hashtable keys = new Hashtable ();
				keys[lowerAlias] = value;
				intAlias.Add (key, keys);
			}
		}
		
		/// <include file='AliasText.xml' path='//Method[@name="AddAliasBoolean"]/docs/*' />
		public void AddAlias (string alias, bool value)
		{
			booleanAlias.Add (alias.ToLower (), value);
		}
		
		/// <include file='AliasText.xml' path='//Method[@name="AddAliasEnum"]/docs/*' />
		public void AddAlias (string key, Enum enumAlias)
		{
			SetAliasTypes (key, enumAlias);
		}
		
		/// <include file='AliasText.xml' path='//Method[@name="ContainsBoolean"]/docs/*' />
		public bool ContainsBoolean (string key)
		{
			return booleanAlias.Contains (key.ToLower ());
		}
		
		/// <include file='AliasText.xml' path='//Method[@name="ContainsInt"]/docs/*' />
		public bool ContainsInt (string key, string alias)
		{
			bool result = false;

			if (intAlias.Contains (key)) {
				Hashtable keys = (Hashtable)intAlias[key];
				result = (keys.Contains (alias.ToLower ()));
			}
			
			return result;
		}
		
		/// <include file='AliasText.xml' path='//Method[@name="GetBoolean"]/docs/*' />
		public bool GetBoolean (string key)
		{
			string lowerAlias = key.ToLower ();
			if (!booleanAlias.Contains (lowerAlias)) {
				throw new Exception ("Alias does not exist for text");
			}
			
			return (bool)booleanAlias[lowerAlias];
		}
		
		/// <include file='AliasText.xml' path='//Method[@name="GetInt"]/docs/*' />
		public int GetInt (string key, string alias)
		{
			if (!intAlias.Contains (key)) {
				throw new Exception ("Alias does not exist for key");
			}

			string lowerAlias = alias.ToLower ();			
			Hashtable keys = (Hashtable)intAlias[key];

			if (!keys.Contains (lowerAlias)) {
				throw new Exception ("Config value does not match a " +
									 "supplied alias");
			}
			
			return (int)keys[lowerAlias];
		}
		#endregion
		
		#region Private methods
		/// <summary>
		/// Extracts and sets the alias types from an enumeration.
		/// </summary>
		private void SetAliasTypes (string key, Enum enumAlias)
		{
			string[] names = Enum.GetNames (enumAlias.GetType ());
			int[] values = (int[])Enum.GetValues (enumAlias.GetType ());
			
			for (int i = 0; i < names.Length; i++)
			{
				AddAlias (key, names[i], values[i]);
			}
		}
		#endregion
	}
}