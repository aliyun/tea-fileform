import os
import sys

from alibabacloud_tea_fileform.models import FileField


class FileFormInputStream:
    def __init__(self, form, boundary, size=1024):
        self.form = form
        self.boundary = boundary
        self.size = size
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
        for k, v in self.forms.items():
            # handle str
            form_str += str_fmt % (self.boundary, k, v)
        self.form_str = form_str

    def _get_stream_length(self):
        file_length = 0
        for k, ff in self.files.items():
            field_length = len(ff.filename) + len(ff.content_type) + len(k) + len(self.boundary) + 78
            file_length += os.path.getsize(ff.content.name) + field_length

        stream_length = self.str_length + file_length + len(self.boundary) + 6
        return stream_length

    def __len__(self):
        return self._get_stream_length()

    def __iter__(self):
        return self

    def __next__(self):
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
                if isinstance(file_content, bytes):
                    file_content = file_content.decode('utf-8')

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
                file_size = os.path.getsize(file_field.content.name)
                self.file_size_left = file_size
                file_content = file_field.content.read(size)
                if isinstance(file_content, bytes):
                    file_content = file_content.decode('utf-8')

                # build form_str
                start = start_fmt % (self.boundary, key)
                content = content_fmt % (
                    file_field.filename, file_field.content_type, file_content)
                if self.file_size_left < size:
                    form_str += '%s%s\r\n' % (start, content)
                    self.file_size_left = 0
                    size -= len(file_content)
                    self.files_keys.remove(key)
                else:
                    form_str += '%s%s' % (start, content)
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
            size = sys.maxsize

        if self.form_str:
            form_str = self.form_str[:size]
            self.form_str = self.form_str[size:]
            if len(form_str) < size:
                form_str += self.file_str(size)
        else:
            form_str = self.file_str(size)

        if not self.form_str and not self.files_keys:
            form_str += '--{}--\r\n'.format(self.boundary)
        return form_str.encode('utf-8')

    def refresh_cursor(self):
        for ff in self.files.values():
            ff.content.seek(0, 0)

    def refresh(self):
        self.file_size_left = 0
        self._to_map()
        self._build_str_forms()
        self.refresh_cursor()
