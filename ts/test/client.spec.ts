import 'mocha';
import assert from 'assert';
import { Readable } from 'stream';
import { createReadStream } from 'fs';
import { join } from 'path';
import Client, { FileField } from '../src/client';
import * as $tea from '@alicloud/tea-typescript';

async function read(readable: Readable): Promise<string> {
    const buffers = [];
    for await (const chunk of readable) {
        buffers.push(chunk);
    }
    return Buffer.concat(buffers).toString();
}

describe('fileform', function () {
    it('getBoundary should ok', function () {
        assert.ok(Client.getBoundary().length > 10);
    });

    describe('toFileForm should ok', function () {
        it('empty fields)', async function () {
            const result = await read(Client.toFileForm({}, 'boundary'));
            assert.deepStrictEqual(result, '\r\n--boundary--\r\n');
        });

        it('normal field)', async function () {
            const result = await read(Client.toFileForm({
                stringkey: 'string'
            }, 'boundary'));
            assert.deepStrictEqual(result, '--boundary\r\n'
                + 'Content-Disposition: form-data; name="stringkey"\r\n\r\n'
                + 'string\r\n'
                + '\r\n'
                + '--boundary--\r\n');
        });

        it('file field)', async function () {
            const result = await read(Client.toFileForm({
                stringkey: 'string',
                filefield: new FileField({
                    filename: 'fakefilename',
                    contentType: 'application/json',
                    content: new $tea.BytesReadable(`{"key":"value"}\n`)
                }),
            }, 'boundary'));
            assert.deepStrictEqual(result, '--boundary\r\n'
                + 'Content-Disposition: form-data; name="stringkey"\r\n\r\n'
                + 'string\r\n'
                + '--boundary\r\n'
                + 'Content-Disposition: form-data; name="filefield"; filename="fakefilename"\r\n'
                + 'Content-Type: application/json\r\n'
                + '\r\n'
                + '{"key":"value"}\n'
                + '\r\n'
                + '--boundary--\r\n');
        });

        it('file field)', async function () {
            const fileStream = createReadStream(join(__dirname, 'test.txt'));
            const result = await read(Client.toFileForm({
                stringkey: 'string',
                filefield: new FileField({
                    filename: 'fakefilename',
                    contentType: 'application/json',
                    content: fileStream
                }),
            }, 'boundary'));
            console.log(result)
            assert.deepStrictEqual(result, '--boundary\r\n'
                + 'Content-Disposition: form-data; name="stringkey"\r\n\r\n'
                + 'string\r\n'
                + '--boundary\r\n'
                + 'Content-Disposition: form-data; name="filefield"; filename="fakefilename"\r\n'
                + 'Content-Type: application/json\r\n'
                + '\r\n'
                + '{"key":"value"}'
                + '\r\n'
                + '--boundary--\r\n');
        });
    });
});
