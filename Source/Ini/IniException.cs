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

namespace Nini.Ini
{
	/// <include file='IniException.xml' path='//Class[@name="IniException"]/docs/*' />
	public class IniException : Exception
	{
		#region Private variables
		IniReader iniReader = null;
		string message = "";
		#endregion

		#region Public properties
		/// <include file='IniException.xml' path='//Property[@name="LinePosition"]/docs/*' />
		public int LinePosition
		{
			get
			{
				return (iniReader == null) ? 0 : iniReader.LinePosition;
			}
		}
		
		/// <include file='IniException.xml' path='//Property[@name="LineNumber"]/docs/*' />
		public int LineNumber
		{
			get
			{
				return (iniReader == null) ? 0 : iniReader.LineNumber;
			}
		}
		
		/// <include file='IniException.xml' path='//Property[@name="Message"]/docs/*' />
		public override string Message
		{
			get { return this.message; }
		}
		#endregion

		#region Constructors
		/// <include file='IniException.xml' path='//Constructor[@name="ConstructorMessage"]/docs/*' />
		public IniException (string message)
		{
			this.message  = message;
		}
		
		/// <include file='IniException.xml' path='//Constructor[@name="ConstructorTextReader"]/docs/*' />
		internal IniException (IniReader reader, string message)
		{
			iniReader = reader;
			this.message = message;
		}
		#endregion
	}
}