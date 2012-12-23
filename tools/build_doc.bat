rmdir /Q /S %CD%\doc
mkdir %CD%\doc
asdoc -main-title=as3-msgpack0.4.1 -warnings=false -output=%CD%/doc/ -doc-sources+=%CD%/src/ -library-path+=%CD%/lib/as3console.swc