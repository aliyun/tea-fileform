import unittest
import os
from io import BytesIO
from alibabacloud_tea_fileform.client import Client
from alibabacloud_tea_fileform.models import FileField

# file1 = 'tests/test_file.json'
# file2 = 'tests/test.txt'
base_path = os.path.dirname(__file__)
file1 = os.path.join(base_path, 'test_file.json')
file2 = os.path.join(base_path, 'test.txt')


class TestClient(unittest.TestCase):
    def test_get_boundary(self):
        boundary = Client.get_boundary()
        self.assertEqual(14, len(boundary))

    def test_to_file_from(self):
        # Test 1
        body = Client.to_file_form({}, 'boundary')
        for i in body:
            self.assertEqual('--boundary--\r\n'.encode(), i)

        form = {
            'stringkey1': 'string1',
            'stringkey2': 'string2'
        }
        body = Client.to_file_form(form, 'boundary')
        content = "--boundary\r\n" + \
                  "Content-Disposition: form-data; name=\"stringkey1\"\r\n\r\n" + \
                  "string1\r\n" + \
                  "--boundary\r\n" + \
                  "Content-Disposition: form-data; name=\"stringkey2\"\r\n\r\n" + \
                  "string2\r\n" + \
                  "--boundary--\r\n"
        content = content.encode('utf-8')
        form_str = b''
        for i in body:
            form_str += i
        self.assertEqual(content, form_str)
        # length: 86
        self.assertEqual(len(content), body.__len__())

        # # Test 2
        f1 = open(file1)
        file_field1 = FileField(
            filename='test_file.json',
            content_type='application/json',
            content=f1
        )
        boundary = Client.get_boundary()
        form = {
            'stringkey': 'string',
            'filefield': file_field1
        }
        body = Client.to_file_form(form, boundary)

        content = "--{}\r\n".format(boundary) + \
                  "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n" + \
                  "string\r\n" + \
                  "--{}\r\n".format(boundary) + \
                  "Content-Disposition: form-data; name=\"filefield\"; filename=\"test_file.json\"\r\n" + \
                  "Content-Type: application/json\r\n" + \
                  "\r\n" + \
                  "{\"test\": \"tests1\"}" + \
                  "\r\n" + \
                  "--{}--\r\n".format(boundary)
        content = content.encode('utf-8')
        form_str = b''
        for i in body:
            form_str += i

        self.assertEqual(
            content,
            form_str
        )
        # length: 247
        self.assertEqual(len(content), body.__len__())

        # Test 3
        f2 = open(file2, 'rb')
        file_field2 = FileField(
            filename='test.txt',
            content_type='application/json',
            content=f2
        )
        form = {
            'stringkey': 'string',
            'filefield1': file_field1,
            'filefield2': file_field2
        }
        body = Client.to_file_form(form, boundary)

        content = "--{}\r\n".format(boundary) + \
                  "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n" + \
                  "string\r\n" + \
                  "--{}\r\n".format(boundary) + \
                  "Content-Disposition: form-data; name=\"filefield1\"; filename=\"test_file.json\"\r\n" + \
                  "Content-Type: application/json\r\n" + \
                  "\r\n" + \
                  "{\"test\": \"tests1\"}" + \
                  "\r\n" + \
                  "--{}\r\n".format(boundary) + \
                  "Content-Disposition: form-data; name=\"filefield2\"; filename=\"test.txt\"\r\n" + \
                  "Content-Type: application/json\r\n" + \
                  "\r\n" + \
                  "test1test2test3test4" + \
                  "\r\n" + \
                  "--{}--\r\n".format(boundary)
        content = content.encode('utf-8')
        form_str = b''
        for i in body:
            form_str += i
        self.assertEqual(content, form_str)
        self.assertEqual(len(content), body.__len__())
        form_str = b''
        while True:
            r = body.read(1)
            if r:
                form_str += r
            else:
                break
        self.assertEqual(content, form_str)
        self.assertEqual(len(content), body.__len__())
        f2.close()

        # TEST 4
        f2 = open(file2, 'rb')
        io = BytesIO(f2.read())
        file_field2 = FileField(
            filename='test.txt',
            content_type='application/json',
            content=io
        )
        form = {
            'stringkey': 'string',
            'filefield1': file_field1,
            'filefield2': file_field2
        }
        body = Client.to_file_form(form, boundary)

        form_str = b''
        for i in body:
            form_str += i
        self.assertEqual(content, form_str)
        self.assertEqual(len(content), body.__len__())
        form_str = b''
        while True:
            r = body.read(1)
            if r:
                form_str += r
            else:
                break
        self.assertEqual(content, form_str)
        self.assertEqual(len(content), body.__len__())
        f1.close()
        f2.close()
