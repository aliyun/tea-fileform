// This file is auto-generated, don't edit it. Thanks.

#include <darabonba/file_form.hpp>
#include <boost/any.hpp>
#include <iostream>
#include <map>
#include <boost/random.hpp>


#define MIN 10000000000000
#define MAX 99999999999999
using namespace std;

string Darabonba_FileForm::Client::getBoundary() {
  typedef boost::uniform_int<long long int> NumberDistribution;
  typedef boost::mt19937 RandomNumberGenerator;
  typedef boost::variate_generator<RandomNumberGenerator&,NumberDistribution> Generator;

  NumberDistribution distribution(MIN, MAX);
  RandomNumberGenerator generator;
  Generator numberGenerator(generator, distribution);
  generator.seed(time(nullptr)); // seed with the current time
  long long int A=numberGenerator();
  return to_string(A);
}

shared_ptr<Darabonba_FileForm::FileFormStream> Darabonba_FileForm::Client::toFileForm(shared_ptr<map<string, boost::any>> form,
                                                                                      shared_ptr<string> boundary) {
  if (boundary && form) {
    return make_shared<Darabonba_FileForm::FileFormStream>(*form, *boundary);
  }
  return make_shared<Darabonba_FileForm::FileFormStream>();
}


string Darabonba_FileForm::FileFormStream::read() {
  vector<string> stream_keys;
  vector<string> str_keys;
  for (const auto& i : _form) {
    if (typeid(Darabonba_FileForm::FileField) == i.second.type()) {
      stream_keys.push_back(i.first);
    } else {
      str_keys.push_back(i.first);
    }
  }

  sort(str_keys.begin(), str_keys.end());
  string form_str;
  for (const auto& k : str_keys) {
    if (typeid(string) == _form[k].type()) {
      string value = boost::any_cast<string>(_form[k]);
      form_str.append("--")
      .append(_boundary)
      .append("\r\nContent-Disposition: form-data; name=\"")
      .append(k).append("\"\r\n\r\n").append(value)
      .append("\r\n");
    }
  }

  for (const auto& k : stream_keys) {
    if (typeid(Darabonba_FileForm::FileField) == _form[k].type()) {
      Darabonba_FileForm::FileField file_field = boost::any_cast<Darabonba_FileForm::FileField>(_form[k]);
      string content = file_field.content->read();
      form_str.append("--")
      .append(_boundary)
      .append("\r\nContent-Disposition: form-data; name=\"")
      .append(k).append("\"; filename=\"").append(*file_field.filename)
      .append("\"\r\nContent-Type: ").append(*file_field.contentType)
      .append("\r\n\r\n").append(content).append("\r\n");
    }
  }
  form_str.append("--").append(_boundary).append("--\r\n");
  return form_str;
}