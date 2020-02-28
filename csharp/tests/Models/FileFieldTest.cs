using System.IO;

using AlibabaCloud.SDK.TeaFileform.Models;

using Xunit;

namespace tests.Models
{
    public class FileFieldTest
    {
        [Fact]
        public void Test_FileField()
        {
            FileField fileField = new FileField();
            fileField.Content = new MemoryStream();
            fileField.ContentType = "contentType";
            fileField.Filename = "fileName";
            Assert.NotNull(fileField);
            Assert.Equal("contentType", fileField.ContentType);
            Assert.Equal("fileName", fileField.Filename);
            Assert.NotNull(fileField.Content);
        }
    }
}
