# WINDOWS WORK-AROUND (don't ask me)
# if you're not using windows you can comment the following line
SHELL=c:/windows/system32/cmd.exe

# external apps
SWF_COM=mxmlc
SWC_COM=compc
AS_DOC=asdoc
RM=rm -rf
MK=mkdir

# library stuff
LIB_FLAGS=-debug=false
LIB_SOURCE=src_lib/
LIB_BIN=bin/msgpack.swc

# test stuff
TEST_FLAGS=-debug=false -static-link-runtime-shared-libraries=true
TEST_LIBS=lib/
TEST_SOURCE=src_test/

LIB_TEST_BIN=bin/lib_test.swf
LIB_TEST_MAIN=src_test/LibTest.as

STRM_TEST_BIN=bin/stream_test.swf
STRM_TEST_MAIN=src_test/StreamTest.as

# documentation stuff
DOC_FLAGS=-warnings=false
DOC_TITLE=as3-msgpack1.0.1
DOC_OUTPUT=doc
DOC_SOURCE=src_lib/
DOC_LIBS=lib/as3console.swc


# recipes
all: library librarytest streamtest documentation

library:
	$(SWC_COM) $(LIB_FLAGS) -include-sources=$(LIB_SOURCE) -output=$(LIB_BIN)

librarytest:
	$(SWF_COM) $(TEST_FLAGS) -library-path+=$(TEST_LIBS) -source-path+=$(LIB_SOURCE) -source-path+=$(TEST_SOURCE) -output=$(LIB_TEST_BIN) -- $(LIB_TEST_MAIN)

streamtest:
	$(SWF_COM) $(TEST_FLAGS) -library-path+=$(TEST_LIBS) -source-path+=$(LIB_SOURCE) -source-path+=$(TEST_SOURCE) -output=$(STRM_TEST_BIN) -- $(STRM_TEST_MAIN)

documentation:
	$(RM) $(DOC_OUTPUT)
	$(MK) $(DOC_OUTPUT)
	$(AS_DOC) $(DOC_FLAGS) -main-title=$(DOC_TITLE) -output=$(DOC_OUTPUT) -doc-sources+=$(DOC_SOURCE) -library-path+=$(DOC_LIBS)