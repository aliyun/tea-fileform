import random

from alibabacloud_tea_fileform.models import FileField


class Client:
    @staticmethod
    def get_boundary():
        result = '%s' % int(random.random() * 100000000000000)
        return result.zfill(14)

    @staticmethod
    def to_file_from(form, boundary):
        form_str = ''
        forms = {}
        files = {}
        for k, v in form.items():
            if isinstance(v, FileField):
                file_field = {
                    'filename':  v.filename,
                    'content_type': v.content_type,
                    'content': v.content
                }
                files[k] = file_field
            else:
                forms[k] = v
        for k, v in forms.items():
            # handle str
            form_str += '--%s\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n%s\r\n' %\
                        (boundary, k, v)
        for k, v in files.items():
            # handle file object
            start = '--%s\r\nContent-Disposition: form-data; name=\"%s\";' % (boundary, k)
            content = ' filename: \"%s\"\r\nContent-Type: %s\r\n\r\n%s\r\n' % (v['filename'], v['content_type'], v['content'].read())
            content = start + content
            form_str += content
        form_str += '--{}--\r\n'.format(boundary)
        return form_str.encode('utf-8')

