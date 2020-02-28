package service

import (
	"io/ioutil"
	"strings"
	"testing"

	"github.com/alibabacloud-go/tea/tea"
	"github.com/alibabacloud-go/tea/utils"
)

type TestForm struct {
	Ak    *string    `json:"ak"`
	File1 *FileField `json:"file1"`
	File2 *FileField `json:"file2"`
}

func Test_ToFileForm(t *testing.T) {
	body := map[string]interface{}{
		"ak": "accesskey",
		"file1": &FileField{
			Filename:    tea.String("a.jpg"),
			ContentType: tea.String("jpg"),
			Content:     strings.NewReader("ok"),
		},
	}
	res := ToFileForm(tea.ToMap(body), "28802961715230")
	byt, err := ioutil.ReadAll(res)
	utils.AssertNil(t, err)
	utils.AssertEqual(t, string(byt), "--28802961715230\r\nContent-Disposition: "+
		"form-data; name=\"ak\"\r\n\r\naccesskey\r\n--28802961715230\r\nContent-Disposition: "+
		"form-data; name=\"file1\"; filename=\"a.jpg\"\r\nContent-Type: jpg\r\n\r\nok\r\n\r\n--28802961715230--\r\n")

	body1 := &TestForm{
		Ak: tea.String("accesskey"),
		File1: &FileField{
			Filename:    tea.String("a.jpg"),
			ContentType: tea.String("jpg"),
			Content:     strings.NewReader("ok"),
		},
	}
	res = ToFileForm(tea.ToMap(body1), "28802961715230")
	byt, err = ioutil.ReadAll(res)
	utils.AssertNil(t, err)
	utils.AssertEqual(t, string(byt), "--28802961715230\r\nContent-Disposition: form-data; "+
		"name=\"ak\"\r\n\r\naccesskey\r\n--28802961715230\r\nContent-Disposition: "+
		"form-data; name=\"file1\"; filename=\"a.jpg\"\r\nContent-Type: jpg\r\n\r\nok\r\n\r\n--28802961715230--\r\n")
}
