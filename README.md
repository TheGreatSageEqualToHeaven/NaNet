# NaNet "Not another Networking library!"
A small, type-checked networking library for Roblox

# API

```lua
function NaNet.CreateRemoteEvent(Name: string, Parent: Instance): NetworkObject
```
Creates a `NetworkEventObject` which lets you use `OnEvent` and `OnTypedEvent` and creates a `RemoteEvent` in the passed parent instance.

```lua
function NaNet.CreateRemoteFunction(Name: string, Parent: Instance): NetworkObject
```
Creates a `NetworkFunctionObject` which lets you use `OnInvoke` and `OnTypedEvent` and creates a `RemoteFunction` in the passed parent instance.

```lua
function NetworkObject.OnTypedEvent(self: NetworkObject, parameters: {NetworkParameter}, listener)
```
A `NetworkEventObject`'s `OnEvent` function which lets you connect a listener with type-checked parameters

```lua
function NetworkObject.OnEvent(self: NetworkObject, listener)
```
A `NetworkEventObject`'s OnEvent function which lets you connect a listener without type-checked parameters

```lua
function NetworkObject.OnTypedInvoke(self: NetworkObject, parameters: {NetworkParameter}, listener) 
```
A `NetworkFunctionObject`'s `OnInvoke` function which lets you set a listener with type-checked parameters

```lua
function NetworkObject.OnInvoke(self: NetworkObject, listener) 
```
A `NetworkFunctionObject`'s `OnInvoke` function which lets you set a listener without type-checked parameters

```lua
function NaNet.ConnectTypedEvent(remote: RemoteEvent, parameters: {NetworkParameter}, listener)
```
Accepts a `RemoteEvent` and connects a listener with type-checked parameters

```lua
function NaNet.ConnectTypedInvoke(remote: RemoteFunction, parameters: {NetworkParameter}, listener)
```
Accepts a `RemoteFunction` and connects a listener with type-checked parameters

# Types
All types in `NaNet` are typed with `NetworkParameter`. 

### Primitive Types

```lua
NaNet.String --/* Basic string type, accepts any string of any length and any type of byte */
NaNet.Double --/* Basic double type, accepts any number in the IEEE 754 standard */
NaNet.Integer --/* Basic integer type, accepts any signed integer */
NaNet.Boolean --/* Basic boolean type, accepts true and false */
NaNet.Table --/* Basic table type, accepts any type of table */
NaNet.Instance --/* Basic Instance type, accepts any instance */ 
NaNet.UserData --/* Basic userdata type, a useless type in many cases, will not accept `Instance` for security reasons */
NaNet.Array --/* Basic array type, accepts any array with an ordered list */
NaNet.Nil --/* Basic nil type, a lot of jank comes with this type so I recommend against using it */
NaNet.Real --/* Basic real type, any number that is real, rational */
NaNet.Vararg --/* Basic vararg type, if placed at the end of the parameter list the vararg 
NaNet.Any --/* Basic any type, disables type-checking for the specific parameter */
```

### Structure Types

```lua
NaNet.ConstrainedString(maxLength: number) --/* String with a limited length */
NaNet.ConstrainedString(minLength: number, maxLength: number) 
NaNet.ConstrainedDouble(maxLength: number) --/* Double with a limited range */
NaNet.ConstrainedDouble(minLength: number, maxLength: number)
NaNet.DataStoreString --/* Special string type that is safe to save in a data store */
NaNet.ConstrainedReal(maxLength: number) --/* Real with a limited range */
NaNet.ConstrainedReal(minLength: number, maxLength: number)
NaNet.InstanceOfClass(name: NetworkParameter) --/* Instance type that only lets instances with a specific class through */
NaNet.TypedVararg(_type: NetworkParameter) --/* Special structure type that acts as a primitive, all varargs will be type-checked */
```

### Tree types
```lua
NaNet.DictionaryTree --/* Dictionary tree type, allows for type-checking an entire dictionary */
NaNet.KeyValuePair --/* Key and value pair for dictionary trees, the value can be set to a DictionaryTree */
NaNet.OptionalKeyValuePair --/* An optional version of the KeyValuePair */
```

### Extra
```lua
NaNet.Value --/* Buffer in NaNet for any static value that isn't a type */
```
