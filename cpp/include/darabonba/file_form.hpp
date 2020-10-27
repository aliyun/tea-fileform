// This file is auto-generated, don't edit it. Thanks.

#ifndef DARABONBA_FILEFORM_H_
#define DARABONBA_FILEFORM_H_

#include <boost/any.hpp>
#include <boost/throw_exception.hpp>
#include <darabonba/core.hpp>
#include <iostream>
#include <map>

using namespace std;

namespace Darabonba_FileForm {
class FileField : public Darabonba::Model {
public:
  FileField() {}
  explicit FileField(const std::map<string, boost::any> &config) : Darabonba::Model(config) {
    fromMap(config);
  };

  void validate() override {
    if (!filename) {
      BOOST_THROW_EXCEPTION(boost::enable_error_info(std::runtime_error("filename is required.")));
    }
    if (!contentType) {
      BOOST_THROW_EXCEPTION(boost::enable_error_info(std::runtime_error("contentType is required.")));
    }
    if (!content) {
      BOOST_THROW_EXCEPTION(boost::enable_error_info(std::runtime_error("content is required.")));
    }
  }

  map<string, boost::any> toMap() override {
    map<string, boost::any> res;
    if (filename) {
      res["filename"] = boost::any(*filename);
    }
    if (contentType) {
      res["contentType"] = boost::any(*contentType);
    }
    if (content) {
      res["content"] = boost::any(*content);
    }
    return res;
  }

  void fromMap(map<string, boost::any> m) override {
    if (m.find("filename") != m.end()) {
      filename = make_shared<string>(boost::any_cast<string>(m["filename"]));
    }
    if (m.find("contentType") != m.end()) {
      contentType = make_shared<string>(boost::any_cast<string>(m["contentType"]));
    }
    if (m.find("content") != m.end()) {
      content = make_shared<Darabonba::Stream>(boost::any_cast<Darabonba::Stream>(m["content"]));
    }
  }

  shared_ptr<string> filename{};
  shared_ptr<string> contentType{};
  shared_ptr<Darabonba::Stream> content{};

  ~FileField() = default;
};


class FileFormStream: public Darabonba::Stream {
public:
  FileFormStream()=default;
  ~FileFormStream()=default;
  FileFormStream(map<string, boost::any> form,
                      string boundary){
    _form = std::move(form);
    _boundary = std::move(boundary);
  }
  bool empty() override;
  string read() override;
private:
  string _boundary;
  map<string, boost::any> _form;
};


class Client {
public:
  static string getBoundary();
  static shared_ptr<FileFormStream> toFileForm(shared_ptr<map<string, boost::any>> form, shared_ptr<string> boundary);

  Client() {};
  ~Client() {};
};
} // namespace Darabonba_FileForm

#endif
