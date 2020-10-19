#include "gtest/gtest.h"
#include <darabonba/file_form.hpp>
#include <darabonba/core.hpp>

using namespace std;


int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

TEST(test_fileform, test_getBoundary) {
  string boundary = Darabonba_FileForm::Client::getBoundary();
  ASSERT_EQ(14, boundary.size());
}

TEST(test_fileform, test_toFileForm) {
  shared_ptr<string> boundary(new string("boundary"));

  shared_ptr<Darabonba_FileForm::FileFormStream> body = Darabonba_FileForm::Client::toFileForm(
        make_shared<map<string, boost::any>>(),
        boundary
  );
  string content = "--boundary--\r\n";
  ASSERT_EQ(content, body->read());

  //////////

  map<string, boost::any> form({
                              {"stringkey1", string("string1")},
                              {"stringkey2", string("string2")},
  });
  shared_ptr<Darabonba::Stream> body1 = Darabonba_FileForm::Client::toFileForm(
      make_shared<map<string, boost::any>>(form),
      boundary
  );
  string content1 = "--boundary\r\nContent-Disposition:"
                   " form-data; name=\"stringkey1\"\r\n\r\nstring1"
                   "\r\n--boundary\r\nContent-Disposition:"
                   " form-data; name=\"stringkey2\"\r\n\r\n"
                   "string2\r\n--boundary--\r\n";
  ASSERT_EQ(content1, body1->read());

  //////////

  Darabonba_FileForm::FileField ff;
  ff.filename = make_shared<string>("test_file.json");
  ff.contentType = make_shared<string>("application/json");
  ff.content = make_shared<Darabonba::Stream>(make_shared<stringstream>(R"({"test": "tests1"})"));
  map<string, boost::any> form1({
                                    {"stringkey", string("string")},
                                    {"filefield", ff},
  });
  shared_ptr<Darabonba::Stream> body2 = Darabonba_FileForm::Client::toFileForm(
      make_shared<map<string, boost::any>>(form1),
      boundary
  );
  string content2 = "--boundary\r\n"
                  "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n"
                  "string\r\n"
                  "--boundary\r\n"
                  "Content-Disposition: form-data; name=\"filefield\"; filename=\"test_file.json\"\r\n"
                  "Content-Type: application/json\r\n"
                  "\r\n"
                  "{\"test\": \"tests1\"}"
                  "\r\n"
                  "--boundary--\r\n";
  ASSERT_EQ(content2, body2->read());

  //////////

  Darabonba_FileForm::FileField ff1;
  ff1.filename = make_shared<string>("test.txt");
  ff1.contentType = make_shared<string>("application/json");
  ff1.content = make_shared<Darabonba::Stream>(make_shared<stringstream>("test1test2test3test4"));
  map<string, boost::any> form2({
                                    {"stringkey", string("string")},
                                    {"filefield1", ff},
                                    {"filefield2", ff1},
                                });
  shared_ptr<Darabonba::Stream> body3 = Darabonba_FileForm::Client::toFileForm(
      make_shared<map<string, boost::any>>(form2),
      boundary
  );
  string content3 = "--boundary\r\n"
                  "Content-Disposition: form-data; name=\"stringkey\"\r\n\r\n"
                  "string\r\n"
                  "--boundary\r\n"
                  "Content-Disposition: form-data; name=\"filefield1\"; filename=\"test_file.json\"\r\n"
                  "Content-Type: application/json\r\n"
                  "\r\n"
                  "{\"test\": \"tests1\"}"
                  "\r\n"
                  "--boundary\r\n"
                  "Content-Disposition: form-data; name=\"filefield2\"; filename=\"test.txt\"\r\n"
                  "Content-Type: application/json\r\n"
                  "\r\n"
                  "test1test2test3test4"
                  "\r\n"
                  "--boundary--\r\n";
  ASSERT_EQ(content3, body3->read());
}
