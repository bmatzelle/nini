#region Copyright
//
// Nini Configuration Project.
// Copyright (C) 2006 Brent R. Matzelle.  All rights reserved.
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
        SambaStyle,
        /// <include file='IniDocument.xml' path='//Enum[@name="IniFileType"]/Value[@name="MysqlStyle"]/docs/*' />
        MysqlStyle,
        /// <include file='IniDocument.xml' path='//Enum[@name="IniFileType"]/Value[@name="WindowsStyle"]/docs/*' />
        WindowsStyle
    }
    #endregion

    /// <include file='IniDocument.xml' path='//Class[@name="IniDocument"]/docs/*' />
    public class IniDocument
    {
        #region Private variables
        IniSectionCollection sections = new IniSectionCollection ();
        ArrayList initialComment = new ArrayList ();
        IniFileType fileType = IniFileType.Standard;
        bool extended = false;
        #endregion
        
        #region Public properties
        /// <include file='IniDocument.xml' path='//Property[@name="FileType"]/docs/*' />
        public IniFileType FileType
        {
            get { return fileType; }
            set { fileType = value; }
        }
        #endregion

        #region Constructors
        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorPath"]/docs/*' />
        public IniDocument(string filePath)
        {
            fileType = IniFileType.Standard;
            Load(filePath);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorPath"]/docs/*' />
        public IniDocument(string filePath, bool supportExtended)
        {
            fileType = IniFileType.Standard;
            extended = supportExtended;
            Load(filePath);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorPathType"]/docs/*' />
        public IniDocument(string filePath, IniFileType type)
        {
            fileType = type;
            Load(filePath);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorPathType"]/docs/*' />
        public IniDocument(string filePath, IniFileType type, bool supportExtended)
        {
            fileType = type;
            extended = supportExtended;
            Load(filePath);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorTextReader"]/docs/*' />
        public IniDocument(TextReader reader)
        {
            fileType = IniFileType.Standard;
            Load(reader);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorTextReader"]/docs/*' />
        public IniDocument(TextReader reader, bool supportExtended)
        {
            fileType = IniFileType.Standard;
            extended = supportExtended;
            Load(reader);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorTextReaderType"]/docs/*' />
        public IniDocument(TextReader reader, IniFileType type)
        {
            fileType = type;
            Load(reader);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorTextReaderType"]/docs/*' />
        public IniDocument(TextReader reader, IniFileType type, bool supportExtended)
        {
            fileType = type;
            extended = supportExtended;
            Load(reader);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorStream"]/docs/*' />
        public IniDocument(Stream stream)
        {
            fileType = IniFileType.Standard;
            Load(stream);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorStream"]/docs/*' />
        public IniDocument(Stream stream, bool supportExtended)
        {
            fileType = IniFileType.Standard;
            extended = supportExtended;
            Load(stream);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorStreamType"]/docs/*' />
        public IniDocument(Stream stream, IniFileType type)
        {
            fileType = type;
            Load(stream);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorStreamType"]/docs/*' />
        public IniDocument(Stream stream, IniFileType type, bool supportExtended)
        {
            fileType = type;
            extended = supportExtended;
            Load(stream);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorIniReader"]/docs/*' />
        public IniDocument(IniReader reader)
        {
            fileType = IniFileType.Standard;
            Load(reader);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="ConstructorIniReader"]/docs/*' />
        public IniDocument(IniReader reader, bool supportExtended)
        {
            fileType = IniFileType.Standard;
            extended = supportExtended;
            Load(reader);
        }

        /// <include file='IniDocument.xml' path='//Constructor[@name="Constructor"]/docs/*' />
        public IniDocument ()
        {
        }
        #endregion
        
        #region Public methods
        /// <include file='IniDocument.xml' path='//Method[@name="LoadPath"]/docs/*' />
        public void Load (string filePath)
        {
            Load (new StreamReader (filePath));
        }

        /// <include file='IniDocument.xml' path='//Method[@name="LoadTextReader"]/docs/*' />
        public void Load (TextReader reader)
        {
            Load (GetIniReader (reader, fileType));
        }

        /// <include file='IniDocument.xml' path='//Method[@name="LoadStream"]/docs/*' />
        public void Load (Stream stream)
        {
            Load (new StreamReader (stream));
        }

        /// <include file='IniDocument.xml' path='//Method[@name="LoadIniReader"]/docs/*' />
        public void Load (IniReader reader)
        {
            LoadReader (reader);
        }

        /// <include file='IniSection.xml' path='//Property[@name="Comment"]/docs/*' />
        public IniSectionCollection Sections
        {
            get { return sections; }
        }

        /// <include file='IniDocument.xml' path='//Method[@name="SaveTextWriter"]/docs/*' />
        public void Save (TextWriter textWriter)
        {
            IniWriter writer = GetIniWriter (textWriter, fileType);
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

        /// <include file='IniDocument.xml' path='//Method[@name="SaveStream"]/docs/*' />
        public void Save (Stream stream)
        {
            Save (new StreamWriter (stream));
        }
        #endregion
        
        #region Private methods
        /// <summary>
        /// Loads the file not saving comments.
        /// </summary>
        private void LoadReader (IniReader reader)
        {
            reader.IgnoreComments = false;
            bool sectionFound = false;
            IniSection section = null;
            
            try {
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
                        // If section already exists then overwrite it
                        if (sections[reader.Name] != null) {
                            sections.Remove (reader.Name);
                        }
                        section = new IniSection (reader.Name, reader.Comment);
                        sections.Add (section);

                        break;
                    case IniType.Key:
                        if (section.GetValue (reader.Name) == null) { 
                            section.Set (reader.Name, reader.Value, reader.Comment); 
                        } 
                        break;
                    }
                }
            } catch (Exception ex) {
                throw ex;
            } finally {
                // Always close the file
                reader.Close ();
            }

            MergeSections();
        }

        /// <summary>
        /// Supports section merging where a colon is in the key, e.g. ExtendedSection : BaseSection
        /// </summary>
        private void MergeSections()
        {
            if(!extended)
            {
                return;
            }

            foreach (DictionaryEntry entry in sections)
            {
                IniSection section = (IniSection)entry.Value;

                if (!section.Name.Contains(":"))
                {
                    continue;
                }

                var parts = section.Name.Split(new char[] { ':' });
                var newName = parts[0].TrimEnd();
                var extendedSectionName = parts[1].TrimStart();

                if (sections[newName] != null)
                {
                    sections.Remove(newName);
                }

                if (sections[extendedSectionName] == null)
                {
                    throw new ArgumentException(String.Format("Section {0} is trying to extend section {1} but it does not exist.", newName, extendedSectionName));
                }

                IniSection baseSection = sections[extendedSectionName];
                var baseKeys = baseSection.GetKeys();

                var newSection = new IniSection(newName, section.Comment);

                for (var i = 0; i < baseSection.ItemCount; i++)
                {
                    var item = baseSection.GetItem(i);

                    if (item.Value != null)
                    {
                        newSection.Set(item.Name, item.Value, item.Comment);
                    }
                }

                for (var i = 0; i < section.ItemCount; i++)
                {
                    var item = section.GetItem(i);

                    if (item.Value != null)
                    {
                        newSection.Set(item.Name, item.Value, item.Comment);
                    }
                }

                sections.Add(newSection);
                sections.Remove(section.Name);
            }
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
                result.SetCommentDelimiters (new char[] { ';', '#' });
                result.SetAssignDelimiters (new char[] { ':' });
                break;
            case IniFileType.SambaStyle:
                result.AcceptCommentAfterKey = false;
                result.SetCommentDelimiters (new char[] { ';', '#' });
                result.LineContinuation = true;
                break;
            case IniFileType.MysqlStyle:
                result.AcceptCommentAfterKey = false;
                result.AcceptNoAssignmentOperator = true;
                result.SetCommentDelimiters (new char[] { '#' });
                result.SetAssignDelimiters (new char[] { ':', '=' });
                break;
            case IniFileType.WindowsStyle:
                result.ConsumeAllKeyText = true;
                break;
            }

            return result;
        }

        /// <summary>
        /// Returns a proper IniWriter depending upon the type parameter.
        /// </summary>
        private IniWriter GetIniWriter (TextWriter reader, IniFileType type)
        {
            IniWriter result = new IniWriter (reader);

            switch (type)
            {
            case IniFileType.Standard:
            case IniFileType.WindowsStyle:
                // do nothing
                break;
            case IniFileType.PythonStyle:
                result.AssignDelimiter = ':';
                result.CommentDelimiter = '#';
                break;
            case IniFileType.SambaStyle:
            case IniFileType.MysqlStyle:
                result.AssignDelimiter = '=';
                result.CommentDelimiter = '#';
                break;
            }

            return result;
        }
        #endregion
    }
}

