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
using System.Collections;
using Nini.Util;

namespace Nini.Ini
{
	#region IniFileType enumeration
	/// <include file='IniDocument.xml' path='//Enum[@name="IniFileType"]/docs/*' />
	public enum IniFileType
	{
		/// <include file='IniDocument.xml' path='//Enum[@name="IniFileType"]/Value[@name="Standard"]/docs/*' />
		Standard,
		/// <include file='IniDocument.xml' path='//Enum[@name="IniFileType"]/Value[@name="PythonStyle"]/docs/*' />
		PythonStyle,
		/// <include file='IniDocument.xml' path='//Enum[@name="IniFileType"]/Value[@name="SambaStyle"]/docs/*' />
		SambaStyle
	}
	#endregion

	/// <include file='IniDocument.xml' path='//Class[@name="IniDocument"]/docs/*' />
	public class IniDocument
	{
		#region Private variables
		IniSectionCollection sections = new IniSectionCollection ();
		ArrayList initialComment = new ArrayList ();
		#endregion
		
		#region Public properties
		#endregion

		#region Constructors
		/// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorPath"]/docs/*' />
		public IniDocument (string filePath)
			: this (new StreamReader (filePath))
		{
		}

		/// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorPathType"]/docs/*' />
		public IniDocument (string filePath, IniFileType type)
			: this (new StreamReader (filePath), type)
		{
		}

		/// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorTextReader"]/docs/*' />
		public IniDocument (TextReader reader)
			: this (reader, IniFileType.Standard)
		{
		}

		/// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorTextReader"]/docs/*' />
		public IniDocument (TextReader reader, IniFileType type)
		{
			Load (GetIniReader (reader, type));
		}
		
		/// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorStream"]/docs/*' />
		public IniDocument (Stream stream)
			: this (new StreamReader (stream))
		{
		}

		/// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorStreamType"]/docs/*' />
		public IniDocument (Stream stream, IniFileType type)
			: this (new StreamReader (stream), type)
		{
		}

		/// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorIniReader"]/docs/*' />
		public IniDocument (IniReader reader)
		{
			Load (reader);
		}

		/// <include file='IniDocument.xml' path='//Constructor[@name="Constructor"]/docs/*' />
		public IniDocument ()
		{
		}
		#endregion
		
		#region Public methods
		/// <include file='IniSection.xml' path='//Property[@name="Comment"]/docs/*' />
		public IniSectionCollection Sections
		{
			get { return sections; }
		}

		/// <include file='IniDocument.xml' path='//Method[@name="SaveTextWriter"]/docs/*' />
		public void Save (TextWriter textWriter)
		{
			IniWriter writer = new IniWriter (textWriter);
			IniItem item = null;
			IniSection section = null;
			
			foreach (string comment in initialComment)
			{
				writer.WriteEmpty  (comment);
			}

			for (int j = 0; j < sections.Count; j++)
			{
				section = sections[j];
				writer.WriteSection (section.Name, section.Comment);
				for (int i = 0; i < section.ItemCount; i++)
				{
					item = section.GetItem (i);
					switch (item.Type)
					{
					case IniType.Key:
						writer.WriteKey (item.Name, item.Value, item.Comment);
						break;
					case IniType.Empty:
						writer.WriteEmpty (item.Comment);
						break;
					}
				}
			}

			writer.Close ();
		}
		
		/// <include file='IniDocument.xml' path='//Method[@name="SavePath"]/docs/*' />
		public void Save (string filePath)
		{
			StreamWriter writer = new StreamWriter (filePath);
			Save (writer);
			writer.Close ();
		}
		#endregion
		
		#region Private methods
		/// <summary>
		/// Loads the file not saving comments.
		/// </summary>
		private void Load (IniReader reader)
		{
			reader.IgnoreComments = false;
			bool sectionFound = false;
			IniSection section = null;
			
			while (reader.Read ())
			{
				switch (reader.Type)
				{
				case IniType.Empty:
					if (!sectionFound) {
						initialComment.Add (reader.Comment);
					} else {
						section.Set (reader.Comment);
					}

					break;
				case IniType.Section:
					sectionFound = true;
					section = new IniSection (reader.Name, reader.Comment);
					sections.Add (section);
					break;
				case IniType.Key:
					section.Set (reader.Name, reader.Value, reader.Comment);
					break;
				}
			}

			reader.Close ();
		}

		/// <summary>
		/// Returns a proper INI reader depending upon the type parameter.
		/// </summary>
		private IniReader GetIniReader (TextReader reader, IniFileType type)
		{
			IniReader result = new IniReader (reader);

			switch (type)
			{
			case IniFileType.Standard:
				// do nothing
				break;
			case IniFileType.PythonStyle:
				result.AcceptCommentAfterKey = false;
				result.CommentDelimiter = new char[] { ';', '#' };
				result.AssignDelimiter = new char[] { ':' };
				break;
			case IniFileType.SambaStyle:
				result.AcceptCommentAfterKey = false;
				result.CommentDelimiter = new char[] { ';', '#' };
				result.LineContinuation = true;
				break;
			}

			return result;
		}
		#endregion
	}
}

