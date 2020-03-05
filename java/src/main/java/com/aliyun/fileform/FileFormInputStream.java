package com.aliyun.fileform;

import com.aliyun.fileform.models.FileField;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Map;

public class FileFormInputStream extends InputStream {
    private Map<String, Object> form;
    private String boundary;
    private String[] keys;
    private int keyIndex = 0;
    private int fileNumber = 0;
    private ArrayList<FileField> files = new ArrayList<>();
    private ByteArrayInputStream fileBodyStream = new ByteArrayInputStream(new byte[]{});
    private InputStream temporaryStream = new ByteArrayInputStream(new byte[]{});
    private ByteArrayInputStream temporaryEndStream = new ByteArrayInputStream(new byte[]{});

    private ByteArrayInputStream endInputStream;


    public FileFormInputStream(Map<String, Object> form, String boundary) throws UnsupportedEncodingException {
        this.boundary = boundary;
        this.form = form;
        keys = form.keySet().toArray(new String[]{});
        this.endInputStream = new ByteArrayInputStream(("--" + boundary + "--\r\n").getBytes("UTF-8"));
    }

    @Override
    public void reset() {
        this.keyIndex = 0;
        this.fileNumber = 0;
        this.files.clear();
        this.fileBodyStream = new ByteArrayInputStream(new byte[]{});
        this.temporaryStream = new ByteArrayInputStream(new byte[]{});
        this.temporaryEndStream = new ByteArrayInputStream(new byte[]{});
        this.endInputStream.reset();
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
            StringBuilder stringBuilder = new StringBuilder();
            if (value instanceof FileField) {
                FileField fileMap = (FileField) value;
                files.add(fileMap);
                fileNumber++;
            } else {
                stringBuilder.append("--").append(boundary).append("\r\n");
                stringBuilder.append("Content-Disposition: form-data; name=\"").append(keys[keyIndex]).append("\"\r\n\r\n");
                stringBuilder.append(value).append("\r\n");
            }
            this.fileBodyStream = new ByteArrayInputStream(stringBuilder.toString().getBytes("UTF-8"));
            keyIndex++;
            return this.read(bytes);
        }
        if (this.keyIndex >= this.keys.length && fileNumber > 0) {
            FileField fileMap = files.get(fileNumber - 1);
            fileNumber--;
            if (fileMap.content instanceof InputStream) {
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.append("--").append(this.boundary).append("\r\n");
                stringBuilder.append("Content-Disposition: form-data; name=\"file\"; filename=\"").append(fileMap.filename).append("\"\r\n");
                stringBuilder.append("Content-Type: ").append(fileMap.contentType).append("\r\n\r\n");
                this.temporaryStream = fileMap.content;
                this.temporaryEndStream = new ByteArrayInputStream("\r\n".getBytes("UTF-8"));
                this.fileBodyStream = new ByteArrayInputStream(stringBuilder.toString().getBytes("UTF-8"));
            }
            return this.read(bytes);
        }
        while ((index = this.endInputStream.read(bytes)) != -1) {
            return index;
        }
        return -1;
    }

}
