// This file is auto-generated, don't edit it
import * as $tea from '@alicloud/tea-typescript';
import { Readable } from 'stream';

export class FileField extends $tea.Model {
  filename: string;
  contentType: string;
  content: Readable;
  static names(): { [key: string]: string } {
    return {
      filename: 'filename',
      contentType: 'contentType',
      content: 'content',
    };
  }

  static types(): { [key: string]: any } {
    return {
      filename: 'string',
      contentType: 'string',
      content: 'Readable',
    };
  }

  constructor(map?: { [key: string]: any }) {
    super(map);
  }
}

class FileFormStream extends Readable {
  form: { [key: string]: any };
  boundary: string;
  keys: string[];
  index: number;
  streaming: boolean;

  constructor(form: { [key: string]: any }, boundary: string) {
    super();
    this.form = form;
    this.keys = Object.keys(form);
    this.index = 0;
    this.boundary = boundary;
    this.streaming = false;
  }

  _read() {
    if (this.streaming) {
      return;
    }

    const separator = this.boundary;
    if (this.index < this.keys.length) {
      const name = this.keys[this.index];
      const fieldValue = this.form[name];
      if (fieldValue.filename &&
        fieldValue.contentType &&
        fieldValue.content instanceof Readable) {
        let body =
          `--${separator}\r\n` +
          `Content-Disposition: form-data; name="${name}"; filename="${fieldValue.filename}"\r\n` +
          `Content-Type: ${fieldValue.contentType}\r\n\r\n`;
        this.push(Buffer.from(body));
        this.streaming = true;
        fieldValue.content.on('data', (chunk: any) => {
          this.push(chunk);
        });
        fieldValue.content.on('end', () => {
          this.index++;
          this.streaming = false;
          this.push('');
        });
      } else {
        this.push(Buffer.from(`--${separator}\r\n` +
          `Content-Disposition: form-data; name="${name}"\r\n\r\n` +
          `${fieldValue}\r\n`));
        this.index++;
      }
    } else {
      this.push(Buffer.from(`\r\n--${separator}--\r\n`));
      this.push(null);
    }
  }
}

export default class Client {

  static getBoundary(): string {
    return 'boundary' + Math.random().toString(16).slice(-12);
  }

  static toFileForm(form: { [key: string]: any }, boundary: string): Readable {
    return new FileFormStream(form, boundary);
  }

}
