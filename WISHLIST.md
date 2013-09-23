Things to create/fix:

* NumberWorker always encodes values as double: before assembling the value, NumberWorker must check if the value fits a float and use it whenever is possible. (/src_lib/org/msgpack/NumberWorker.as#L36)
* Support for the new version of MessagePack spec. (https://github.com/msgpack/msgpack/blob/master/spec.md)
* Support for MessagePack-RPC. (https://github.com/msgpack-rpc/msgpack-rpc/blob/master/spec.md)