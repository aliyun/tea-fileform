// This file is auto-generated, don't edit it. Thanks.
package com.aliyun.fileform;

public class Client {

    public static String getBoundary() throws Exception {
        double num = Math.random() * 100000000000000D;
        return String.format("%014d", (long) num);
    }

    public static java.io.InputStream toFileForm(java.util.Map<String, Object> form, String boundary) throws Exception {
        return new FileFormInputStream(form, boundary);
    }
}
