import unittest
from alibabacloud_tea_fileform import client


class TestClient(unittest.TestCase):
    def test_get_boundary(self):
        boundary = client.get_boundary()
        self.assertEqual(14, len(boundary))

    def test_to_file_from(self):
        body = client.to_file_from({}, 'boundary')
        self.assertEqual('--boundary--\r\n'.encode(), body)

        form = {
            'stringkey': 'string'
        }
        body = client.to_file_from(form, 'boundary')
        content = "--boundary\r\n" +\
                "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n" +\
                "string\r\n" +\
                "--boundary--\r\n"
        self.assertEqual(content.encode(), body)

        f = open('test_file.json', encoding='utf-8')
        file_field = client.FileField(
            filename='test_file.json',
            content_type='application/json',
            content=f
        )
        boundary = client.get_boundary()
        form = {
            'stringkey': 'string',
            'filefield': file_field
        }
        body = client.to_file_from(form, boundary)
        f.close()
        content = f"--{boundary}\r\n" +\
            "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n" +\
            "string\r\n" +\
            f"--{boundary}\r\n" +\
            "Content-Disposition: form-data; name=\"filefield\"; filename: \"test_file.json\"\r\n" +\
            "Content-Type: application/json\r\n" +\
            "\r\n" +\
            "{\"test\": \"tests1\"}" +\
            "\r\n" +\
            f"--{boundary}--\r\n"
        self.assertEqual(
            content.encode('utf-8'),
            body
        )
