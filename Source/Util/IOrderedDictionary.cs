using System;

namespace Nini.Util
{
	/// <include file='IOrderedDictionary.xml' path='//Interface[@name="IOrderedDictionary"]/docs/*' />
	public interface IOrderedDictionary
	{
		/// <include file='IOrderedDictionary.xml' path='//Method[@name="Insert"]/docs/*' />
		void Insert (int index, object key, object value);

		/// <include file='IOrderedDictionary.xml' path='//Method[@name="RemoveAt"]/docs/*' />
		void RemoveAt (int index);
	}
}