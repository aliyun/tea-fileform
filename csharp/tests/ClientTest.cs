using System.Collections.Generic;
using System.IO;
using System.Text;

using AlibabaCloud.SDK.TeaFileform;
using AlibabaCloud.SDK.TeaFileform.Models;

using Xunit;

namespace tests
{
    public class ClientTest
    {
        [Fact]
        public void Test_GetBoundary()
        {
            Assert.Equal(14, Client.GetBoundary().Length);
        }

        [Fact]
        public void Test_ToFileForm()
        {
            Stream fileFormStream = Client.ToFileForm(new System.Collections.Generic.Dictionary<string, object>(), "boundary");
            Assert.NotNull(fileFormStream);

            string formStr = GetFormStr(fileFormStream);
            Assert.Equal("--boundary--\r\n", formStr);

            Dictionary<string, object> dict = new Dictionary<string, object>();
            dict.Add("stringkey", "string");
            fileFormStream = Client.ToFileForm(dict, "boundary");
            formStr = GetFormStr(fileFormStream);
            Assert.Equal("--boundary\r\n" +
                "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n" +
                "string\r\n" +
                "--boundary--\r\n", formStr);

            string path = System.AppDomain.CurrentDomain.BaseDirectory;
            FileStream file = File.OpenRead("./test.txt");
            FileField fileField = new FileField
            {
                Filename = "fakefilename",
                ContentType = "application/json",
                Content = file
            };
            dict = new Dictionary<string, object>();
            dict.Add("stringkey", "string");
            dict.Add("filefield", fileField);
            fileFormStream = Client.ToFileForm(dict, "boundary");
            formStr = GetFormStr(fileFormStream);
            Assert.Equal("--boundary\r\n" +
                "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n" +
                "string\r\n" +
                "--boundary\r\n" +
                "Content-Disposition: form-data; name=\"filefield\"; filename=\"fakefilename\"\r\n" +
                "Content-Type: application/json\r\n" +
                "\r\n" +
                "{\"key\":\"value\"}" +
                "\r\n" +
                "--boundary--\r\n", formStr);
        }

        private string GetFormStr(Stream stream)
        {
            string formStr = string.Empty;
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = stream.Read(buffer, 0, buffer.Length)) != 0)
            {
                formStr += Encoding.UTF8.GetString(buffer, 0, bytesRead);
            }

            return formStr;
        }
    }
}
