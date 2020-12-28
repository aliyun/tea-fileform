import unittest

from alibabacloud_tea_fileform.models import FileField


class TestModels(unittest.TestCase):
    def test_to_map(self):
        ff = FileField(
            filename='file1',
            content_type='application/json',
            content='openfile'
        )
        result = ff.to_map()
        self.assertEqual('file1', result.get('filename'))
        self.assertEqual('application/json', result.get('contentType'))
        self.assertEqual('openfile', result.get('content'))

    def test_from_map(self):
        ff = FileField(
            filename='file2',
            content_type='json',
            content='open'
        )
        dic = {
            'filename': 'file1',
            'contentType': 'application/json',
            'content': 'openfile'
        }
        ff.from_map(dic)
        self.assertEqual('file1', ff.filename)
        self.assertEqual('application/json', ff.content_type)
        self.assertEqual('openfile', ff.content)
