using System;
using System.Collections.Generic;
using System.IO;

using AlibabaCloud.SDK.TeaFileform.Streams;

namespace AlibabaCloud.SDK.TeaFileform
{
    public class Client
    {
        /// <summary>
        /// Gets a boundary string
        /// </summary>
        /// <returns>random boundary string</returns>
        public static string GetBoundary()
        {
            long num = (long) Math.Floor((new Random()).NextDouble() * 100000000000000D);;
            return num.ToString();
        }

        /// <summary>
        /// Give a form and boundary string, wrap it to a readable stream
        /// </summary>
        /// <param name="dict"></param>
        /// <param name="boundary"></param>
        /// <returns></returns>
        public static Stream ToFileForm(Dictionary<string, object> form, string boundary)
        {
            return new FileFormStream(form, boundary);
        }
    }
}
