// This file is auto-generated, don't edit it. Thanks.
package com.aliyun.fileform.models;

import org.junit.Assert;
import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

public class FileFieldTest{

    @Test
    public void buildTest() throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("filename", "test");
        map.put("contentType", "type");
        InputStream byteArrayInputStream = new ByteArrayInputStream("hello".getBytes("UTF-8"));
        map.put("content", byteArrayInputStream);
        FileField fileField = FileField.build(map);
        Assert.assertEquals("test", fileField.filename);
        Assert.assertEquals("type", fileField.contentType);
        byteArrayInputStream = fileField.content;
        byte[] bytes = new byte[byteArrayInputStream.available()];
        byteArrayInputStream.read(bytes);
        Assert.assertEquals("hello", new String(bytes, "UTF-8"));
    }

}
