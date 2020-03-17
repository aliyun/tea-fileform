<?php

namespace AlibabaCloud\Tea\FileForm\FileForm;

use AlibabaCloud\Tea\Model;

class FileField extends Model
{
    public $filename;
    public $contentType;
    public $content;

    public function __construct()
    {
        $this->_required = [
            "filename"    => true,
            "contentType" => true,
            "content"     => true
        ];
    }
}