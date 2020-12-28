import os
import sys
from _io import BytesIO

from alibabacloud_tea_fileform.models import FileField
from Tea.stream import BaseStream
from Tea.converter import TeaConverter


class FileFormInputStream(BaseStream):
    MAX_SIZE = 2147483647

    def __init__(self, form, boundary, size=1024):
        super(FileFormInputStream, self).__init__(size)
        self.form = form
        self.boundary = boundary
        self.file_size_left = 0

        self.forms = {}
        self.files = {}
        self.files_keys = []
        self._to_map()

        self.form_str = ''
        self._build_str_forms()
        self.str_length = len(self.form_str)

    def _to_map(self):
        for k, v in self.form.items():
            if isinstance(v, FileField):
                self.files[k] = v
                self.files_keys.append(k)
            else:
                self.forms[k] = v

    def _build_str_forms(self):
        form_str = ''
        str_fmt = '--%s\r\nContent-Disposition: form-data; name="%s"\r\n\r\n%s\r\n'
        forms_list = sorted(list(self.forms))
        for key in forms_list:
            value = self.forms[key]
            form_str += str_fmt % (self.boundary, key, value)
        self.form_str = TeaConverter.to_str(form_str)

    def _get_stream_length(self):
        file_length = 0
        for k, ff in self.files.items():
            field_length = len(TeaConverter.to_str(ff.filename)) + len(ff.content_type) +\
                           len(TeaConverter.to_str(k)) + len(self.boundary) + 78
            if isinstance(ff.content, BytesIO):
                file_length += len(ff.content.getvalue()) + field_length
            else:
                file_length += os.path.getsize(ff.content.name) + field_length

        stream_length = self.str_length + file_length + len(self.boundary) + 6
        return stream_length

    def __len__(self):
        return self._get_stream_length()

    def __iter__(self):
        return self

    def next(self):
        return self.read(self.size, loop=True)

    def file_str(self, size):
        # handle file object
        form_str = ''
        start_fmt = '--%s\r\nContent-Disposition: form-data; name="%s";'
        content_fmt = ' filename="%s"\r\nContent-Type: %s\r\n\r\n%s'

        if self.file_size_left:
            for key in self.files_keys[:]:
                if size <= 0:
                    break
                file_field = self.files[key]
                file_content = file_field.content.read(size)

                if self.file_size_left <= size:
                    form_str += '%s\r\n' % file_content
                    self.file_size_left = 0
                    size -= len(file_content)
                    self.files_keys.remove(key)
                else:
                    form_str += file_content
                    self.file_size_left -= size
                    size -= len(file_content)
        else:
            for key in self.files_keys[:]:
                if size <= 0:
                    break
                file_field = self.files[key]

                if isinstance(file_field.content, BytesIO):
                    file_size = len(file_field.content.getvalue())
                else:
                    file_size = os.path.getsize(file_field.content.name)

                self.file_size_left = file_size
                file_content = file_field.content.read(size)

                # build form_str
                start = start_fmt % (self.boundary, key)
                content = content_fmt % (
                    TeaConverter.to_str(file_field.filename),
                    TeaConverter.to_str(file_field.content_type),
                    file_content
                )
                if self.file_size_left < size:
                    form_str += b'%s%s\r\n' % (TeaConverter.to_str(start), content)
                    self.file_size_left = 0
                    size -= len(file_content)
                    self.files_keys.remove(key)
                else:
                    form_str += '%s%s' % (TeaConverter.to_str(start), content)
                    self.file_size_left -= size
                    size -= len(file_content)

        return form_str

    def read(self, size=None, loop=False):
        if not self.files_keys and not self.form_str:
            self.refresh()
            if loop:
                raise StopIteration
            else:
                return b''

        if size is None:
            size = self.MAX_SIZE

        if self.form_str:
            form_str = self.form_str[:size]
            self.form_str = self.form_str[size:]
            if len(form_str) < size:
                form_str += self.file_str(size)
        else:
            form_str = self.file_str(size)

        if not self.form_str and not self.files_keys:
            form_str += '--%s--\r\n' % TeaConverter.to_str(self.boundary)
        return form_str

    def refresh_cursor(self):
        for ff in self.files.values():
            ff.content.seek(0, 0)

    def refresh(self):
        self.file_size_left = 0
        self._to_map()
        self._build_str_forms()
        self.refresh_cursor()
