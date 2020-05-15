import unittest
from alibabacloud_tea_fileform.client import Client
from alibabacloud_tea_fileform.models import FileField


class TestClient(unittest.TestCase):
    def test_get_boundary(self):
        boundary = Client.get_boundary()
        self.assertEqual(14, len(boundary))

    def test_to_file_from(self):
        body = Client.to_file_from({}, 'boundary')
        for i in body:
            self.assertEqual('--boundary--\r\n'.encode(), i)

        form = {
            'stringkey': 'string'
        }
        body = Client.to_file_from(form, 'boundary')
        content = "--boundary\r\n" + \
                  "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n" + \
                  "string\r\n" + \
                  "" \
                  "--boundary--\r\n"
        form_str = b''
        for i in body:
            form_str += i
        self.assertEqual(content.encode(), form_str)
        self.assertEqual(len(content.encode()), body.__len__())

        f = open('test_file.json', encoding='utf-8')
        file_field = FileField(
            filename='test_file.json',
            content_type='application/json',
            content=f
        )
        boundary = Client.get_boundary()
        form = {
            'stringkey': 'string',
            'filefield': file_field
        }
        body = Client.to_file_from(form, boundary)

        content = f"--{boundary}\r\n" + \
                  "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n" + \
                  "string\r\n" + \
                  f"--{boundary}\r\n" + \
                  "Content-Disposition: form-data; name=\"filefield\"; filename=\"test_file.json\"\r\n" + \
                  "Content-Type: application/json\r\n" + \
                  "\r\n" + \
                  "{\"test\": \"tests1\"}" + \
                  "\r\n" + \
                  f"--{boundary}--\r\n"

        form_str = b''
        for i in body:
            form_str += i
        f.close()
        self.assertEqual(
            content.encode('utf-8'),
            form_str
        )
        self.assertEqual(len(content.encode()), body.__len__())
