package com.aliyun.fileform;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Map;

public class FileFormInputStream extends InputStream {
    private Map<String, Object> form;
    private String boundary;
    private String[] keys;
    private int keyIndex = 0;

    private ByteArrayInputStream fileBodyStream = new ByteArrayInputStream(new byte[]{});
    private InputStream temporaryStream = new ByteArrayInputStream(new byte[]{});
    private ByteArrayInputStream temporaryEndStream = new ByteArrayInputStream(new byte[]{});

    private ByteArrayInputStream endInputStream = new ByteArrayInputStream(new byte[]{});
    private boolean onlyOnce = true;


    public FileFormInputStream(Map<String, Object> form, String boundary) throws UnsupportedEncodingException {
        this.boundary = boundary;
        this.form = form;
        keys = form.keySet().toArray(new String[]{});
    }


    @Override
    public int read() throws IOException {
        return -1;
    }


    @Override
    public int read(byte[] bytes) throws IOException {
        int index;
        while ((index = this.fileBodyStream.read(bytes)) != -1) {
            return index;
        }
        while ((index = this.temporaryStream.read(bytes)) != -1) {
            return index;
        }
        while ((index = this.temporaryEndStream.read(bytes)) != -1) {
            return index;
        }
        if (this.keyIndex < this.keys.length) {
            Object value = form.get(keys[keyIndex]);
            if (null == value) {
                keyIndex++;
                return this.read(bytes);
            }
            if (onlyOnce) {
                this.endInputStream = new ByteArrayInputStream(("--" + boundary + "--\r\n").getBytes("UTF-8"));
                onlyOnce = false;
            }
            StringBuilder stringBuilder = new StringBuilder();
            if (value instanceof Map) {
                Map<String, Object> fileMap = (Map<String, Object>) value;
                if (null != fileMap.get("filename") && null != fileMap.get("contentType") && fileMap.get("content") instanceof InputStream) {
                    stringBuilder.append("--").append(this.boundary).append("\r\n");
                    stringBuilder.append("Content-Disposition: form-data; name=\"file\"; filename=\"").append(fileMap.get("filename")).append("\"\r\n");
                    stringBuilder.append("Content-Type: ").append(fileMap.get("content-type")).append("\r\n\r\n");
                    this.temporaryStream = (InputStream) fileMap.get("content");
                    this.temporaryEndStream = new ByteArrayInputStream("\r\n".getBytes("UTF-8"));
                }
            } else {
                stringBuilder.append("--").append(boundary).append("\r\n");
                stringBuilder.append("Content-Disposition: form-data; name=\"").append(keys[keyIndex]).append("\"\r\n\r\n");
                stringBuilder.append(value).append("\r\n");
            }
            this.fileBodyStream = new ByteArrayInputStream(stringBuilder.toString().getBytes("UTF-8"));
            keyIndex++;
            return this.read(bytes);
        }
        while ((index = this.endInputStream.read(bytes)) != -1) {
            return index;
        }
        return -1;
    }

}
