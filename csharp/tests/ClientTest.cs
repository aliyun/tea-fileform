using System.IO;

using AlibabaCloud.SDK.TeaFileform;

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
            Stream fileFormStream = Client.ToFileForm(new System.Collections.Generic.Dictionary<string, object>(), "");
            Assert.NotNull(fileFormStream);
        }
    }
}
