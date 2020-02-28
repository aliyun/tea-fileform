package com.aliyun.fileform;

import com.aliyun.fileform.models.FileField;
import org.junit.Assert;
import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.Map;

public class FileFormInputStreamTest {
    @Test
    public void readTest() throws Exception {
        FileFormInputStream fileFormInputStream = new FileFormInputStream(new HashMap<>(), "test");
        Assert.assertEquals(-1, fileFormInputStream.read());

        byte[] bytes = new byte[32];
        int index = fileFormInputStream.read(bytes);
        Assert.assertEquals(-1, index);

        Map<String, Object> map = new HashMap<>();
        map.put("body", "This is body test. This sentence must be long");
        map.put("query", "test");
        map.put("nullTest", null);
        FileField fileField = new FileField();
        fileField.content = new ByteArrayInputStream("This is file test. This sentence must be long".getBytes("UTF-8"));
        fileField.contentType = "txt";
        fileField.filename = "test.txt";
        map.put("file", fileField.toMap());
        fileField = new FileField();
        fileField.contentType = "txt";
        fileField.filename = "test.txt";
        map.put("nullContentFile", fileField.toMap());
        fileField = new FileField();
        fileField.filename = "test.txt";
        map.put("nullContentType", fileField.toMap());
        fileField = new FileField();
        map.put("nullFile", fileField.toMap());
        fileFormInputStream = new FileFormInputStream(map, "test");
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        while ((index = fileFormInputStream.read(bytes)) != -1) {
            byteArrayOutputStream.write(bytes, 0, index);
        }

        Assert.assertEquals("--test\r\n" +
                "Content-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\n" +
                "Content-Type: null\r\n\r\n" +
                "This is file test. This sentence must be long\r\n" +
                "--test\r\n" +
                "Content-Disposition: form-data; name=\"query\"\r\n\r\n" +
                "test\r\n" +
                "--test\r\n" +
                "Content-Disposition: form-data; name=\"body\"\r\n\r\n" +
                "This is body test. This sentence must be long\r\n" +
                "--test--\r\n", new String(byteArrayOutputStream.toByteArray(), "UTF-8"));
    }
}
