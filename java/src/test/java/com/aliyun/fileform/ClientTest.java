// This file is auto-generated, don't edit it. Thanks.
package com.aliyun.fileform;

import org.junit.Assert;
import org.junit.Test;

import java.util.HashMap;

public class ClientTest {

    @Test
    public void getBoundaryTest() throws Exception {
        new Client();
        Assert.assertEquals(14, Client.getBoundary().length());
    }

    @Test
    public void toFileFormTest() throws Exception {
        Assert.assertTrue(Client.toFileForm(new HashMap<>(), "test") instanceof FileFormInputStream);
    }
}
