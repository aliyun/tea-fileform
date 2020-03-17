<?php

namespace AlibabaCloud\Tea\FileForm;

use GuzzleHttp\Psr7\Stream;
use Psr\Http\Message\StreamInterface;
use AlibabaCloud\Tea\FileForm\FileForm\FileField;

class FileFormStream implements StreamInterface
{
    private $index     = 0;
    private $form      = [];
    private $boundary  = "";
    private $streaming = false;
    private $keys      = [];

    /**
     * @var Stream
     */
    private $currStream = null;

    /**
     * @var resource
     */
    public $stream;

    private $size;
    private $uri;
    private $seekable;

    public function __construct($map, $boundary)
    {
        $this->stream   = fopen('php://memory', 'a+');
        $this->form     = $map;
        $this->boundary = $boundary;
        $this->keys     = array_keys($map);
        sort($this->keys);
    }

    /**
     * @param int $length
     *
     * @return false|int|string
     */
    public function read($length)
    {
        if ($this->streaming) {
            if ($this->currStream !== null) {
                /* @var string $content */
                $content = $this->currStream->read($length);
                if (false !== $content && $content !== "") {
                    fwrite($this->stream, $content);
                    return strlen($content);
                } else {
                    return $this->next("\r\n");
                }
            } else {
                return $this->next("\r\n");
            }
        }
        $keysCount = count($this->keys);
        if ($this->index > $keysCount) {
            return 0;
        }
        if ($keysCount > 0) {
            if ($this->index < $keysCount) {
                $this->streaming = true;

                $name  = $this->keys[$this->index];
                $field = $this->form[$name];
                if (!empty($field) && $field instanceof FileField) {
                    $allNotEmpty = !empty($field->filename) && !empty($field->contentType) && $field->content;
                    if ($allNotEmpty) {
                        $this->currStream = $field->content;

                        $str = "--" . $this->boundary . "\r\n" .
                            "Content-Disposition: form-data; name=\"" . $name . "\"; filename=" . $field->filename . "\r\n" .
                            "Content-Type: " . $field->contentType . "\r\n\r\n";
                        $this->write($str);
                        return strlen($str);
                    } else {
                        return $this->next("\r\n");
                    }
                } else {
                    $val = rawurlencode($field);
                    $str = "--" . $this->boundary . "\r\n" .
                        "Content-Disposition: form-data; name=\"" . $name . "\"\r\n\r\n" .
                        $val . "\r\n\r\n";
                    fwrite($this->stream, $str);
                    return strlen($str);
                }
            } else if ($this->index == $keysCount) {
                return $this->next("--" . $this->boundary . "--\r\n");
            } else {
                return 0;
            }
        }
        return 0;
    }

    public function write($string)
    {
        fwrite($this->stream, $string);
        $this->rewind();
    }

    private function next($endStr)
    {
        $this->streaming = false;
        $this->index++;
        $this->write($endStr);
        $this->currStream = null;
        return strlen($endStr);
    }

    /**
     * @inheritDoc
     */
    public function __toString()
    {
        try {
            $this->seek(0);
            return (string)stream_get_contents($this->stream);
        } catch (\Exception $e) {
            return '';
        }
    }

    /**
     * @inheritDoc
     */
    public function close()
    {
        if (isset($this->stream)) {
            if (is_resource($this->stream)) {
                fclose($this->stream);
            }
            $this->detach();
        }
    }

    /**
     * @inheritDoc
     */
    public function detach()
    {
        if (!isset($this->stream)) {
            return null;
        }

        $result = $this->stream;
        unset($this->stream);
        $this->size = $this->uri = null;

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function getSize()
    {
        if ($this->size !== null) {
            return $this->size;
        }

        if (!isset($this->stream)) {
            return null;
        }

        // Clear the stat cache if the stream has a URI
        if ($this->uri) {
            clearstatcache(true, $this->uri);
        }

        $stats = fstat($this->stream);
        if (isset($stats['size'])) {
            $this->size = $stats['size'];
            return $this->size;
        }

        return null;
    }

    /**
     * @inheritDoc
     */
    public function tell()
    {
        if (!isset($this->stream)) {
            throw new \RuntimeException('Stream is detached');
        }

        $result = ftell($this->stream);

        if ($result === false) {
            throw new \RuntimeException('Unable to determine stream position');
        }

        return $result;
    }

    /**
     * @inheritDoc
     */
    public function eof()
    {
        if (!isset($this->stream)) {
            throw new \RuntimeException('Stream is detached');
        }

        return feof($this->stream);
    }

    /**
     * @inheritDoc
     */
    public function isSeekable()
    {
        return $this->seekable;
    }

    /**
     * @inheritDoc
     */
    public function seek($offset, $whence = SEEK_SET)
    {
        $whence = (int)$whence;

        if (!isset($this->stream)) {
            throw new \RuntimeException('Stream is detached');
        }
        if (!$this->seekable) {
            throw new \RuntimeException('Stream is not seekable');
        }
        if (fseek($this->stream, $offset, $whence) === -1) {
            throw new \RuntimeException('Unable to seek to stream position '
                . $offset . ' with whence ' . var_export($whence, true));
        }
    }

    /**
     * @inheritDoc
     */
    public function rewind()
    {
        rewind($this->stream);
    }

    /**
     * @inheritDoc
     */
    public function isWritable()
    {
        return true;
    }

    /**
     * @inheritDoc
     */
    public function isReadable()
    {
        return true;
    }

    /**
     * @inheritDoc
     */
    public function getContents()
    {
        return stream_get_contents($this->stream);
    }

    /**
     * @inheritDoc
     */
    public function getMetadata($key = null)
    {
        if (!isset($this->stream)) {
            return $key ? null : [];
        }

        $meta = stream_get_meta_data($this->stream);

        return isset($meta[$key]) ? $meta[$key] : null;
    }
}