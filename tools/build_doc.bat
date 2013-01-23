rmdir /Q /S %CD%\doc
mkdir %CD%\doc
asdoc -main-title=as3-msgpack1.0.0 -warnings=false -output=%CD%/doc/ -doc-sources+=%CD%/src_lib/ -library-path+=%CD%/lib/as3console.swc