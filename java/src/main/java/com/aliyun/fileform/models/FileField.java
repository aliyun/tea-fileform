// This file is auto-generated, don't edit it. Thanks.
package com.aliyun.fileform.models;

import com.aliyun.tea.*;

import java.lang.reflect.InvocationTargetException;

public class FileField extends TeaModel {
    @NameInMap("filename")
    @Validation(required = true)
    public String filename;

    @NameInMap("contentType")
    @Validation(required = true)
    public String contentType;

    @NameInMap("content")
    @Validation(required = true)
    public java.io.InputStream content;

    public static FileField build(java.util.Map<String, ?> map) {
        FileField self = new FileField();
        try {
            return TeaModel.build(map, self);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

}
