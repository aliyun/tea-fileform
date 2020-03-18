<?php

namespace AlibabaCloud\Tea\FileForm\Tests;

use AlibabaCloud\Tea\FileForm\FileForm;
use AlibabaCloud\Tea\FileForm\FileForm\FileField;
use AlibabaCloud\Tea\FileForm\FileFormStream;
use GuzzleHttp\Psr7\Stream;
use PHPUnit\Framework\TestCase;

/**
 * @internal
 * @coversNothing
 */
class FileFormTest extends TestCase
{
    public function testFileFromStream()
    {
        $boundary = FileForm::getBoundary();
        $stream   = FileForm::toFileForm([], $boundary);
        $this->assertTrue($stream instanceof FileFormStream);
        $stream->write($boundary);
        $this->assertTrue(\strlen($boundary) === $stream->getSize());
    }

    public function testRead()
    {
        $fileField              = new FileField();
        $fileField->filename    = 'haveContent';
        $fileField->contentType = 'contentType';
        $fileField->content     = new Stream(fopen('data://text/plain;base64,' . base64_encode('This is file test. This sentence must be long'), 'r'));

        $fileFieldNoContent              = new FileField();
        $fileFieldNoContent->filename    = 'noContent';
        $fileFieldNoContent->contentType = 'contentType';
        $fileFieldNoContent->content     = null;

        $map = [
            'key'      => 'value',
            'testKey'  => 'testValue',
            'haveFile' => $fileField,
            'noFile'   => $fileFieldNoContent,
        ];

        $stream = FileForm::toFileForm($map, 'testBoundary');
        do {
            $readLength = $stream->read(1024);
        } while (0 != $readLength);

        $result = $stream->getContents();
        $target = "--testBoundary\r\nContent-Disposition: form-data; name=\"haveFile\"; filename=haveContent\r\nContent-Type: contentType\r\n\r\nThis is file test. This sentence must be long\r\n--testBoundary\r\nContent-Disposition: form-data; name=\"key\"\r\n\r\nvalue\r\n\r\n\r\n\r\n--testBoundary\r\nContent-Disposition: form-data; name=\"testKey\"\r\n\r\ntestValue\r\n\r\n\r\n--testBoundary--\r\n";

        $this->assertEquals($target, $result);
    }
}
