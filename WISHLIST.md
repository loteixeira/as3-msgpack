Things to create/fix:

* NumberWorker always encodes values as double: before assembling the value, NumberWorker must check if the value fits a float and use it whenever is possible. ([see the code here](/src_lib/org/msgpack/NumberWorker.as#L36))
* Support for the new version of MessagePack spec. (https://github.com/msgpack/msgpack/blob/master/spec.md)
* Support for MessagePack-RPC. (https://github.com/msgpack-rpc/msgpack-rpc/blob/master/spec.md)
* Avoid the issue of Number instances storing integer values (https://github.com/loteixeira/as3-msgpack/issues/4)
* Create a prototype using C++ (or should we try to port the existing msgpack for C++?)