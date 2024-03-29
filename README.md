# NaNet "Not another Networking library!"
A small, type-checked networking library for Roblox

# Reporting Issues & Requesting Features
If you want to request a feature make an issue with the `enchancement` tag, if you want to report an issue make an issue with the `bug` tag.

# Contributing
If you wish to contribute, make a pull request and I will review it!

# Wrapper API

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

# Standalone API

```lua
function NaNet.IsArray(parameter: {any})
```

```lua
function NaNet.IsInteger(parameter: number)
```

```lua
function NaNet.IsReal(parameter: number)
```

```lua
function NaNet.IsRealWithinBoundary(parameter: number, minLength: number, maxLength: number)
```

```lua
function NaNet.IsStringSafeForDataStore(parameter: string) 
```

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
NaNet.TypedArray(_type: NetworkParameter) --/* Accepts any ordered array with a specific type */
NaNet.ConstrainedArray(minLength: number) --/* Accepts any ordered array with a size limit */
NaNet.ConstrainedArray(minLength: number, maxLength: number)
NaNet.ConstrainedArray(_type: NetworkParameter, minLength: number) --/* Accepts any ordered array with a specific type and size limit */
NaNet.ConstrainedArray(_type: NetworkParameter, minLength: number, maxLength: number)
NaNet.TypeOf(__type: string) --/* Accepts a type name, will compare parameters with `typeof` result and the type name */
```

### Tree types
```lua
NaNet.DictionaryTree(tree: {KeyValuePair | OptionalKeyValuePair}) --/* Dictionary tree type, allows for type-checking an entire dictionary */
NaNet.KeyValuePair(keyValue: string, valueType: NetworkParameter) --/* Key and value pair for dictionary trees, the value can be set to a DictionaryTree */
NaNet.OptionalKeyValuePair(keyValue: string, valueType: NetworkParameter) --/* An optional version of the KeyValuePair */
```

### Extra
```lua
NaNet.Value(value: any) --/* Allows any static value, can be used for remote keys and similar */
NaNet.Union(_type: NetworkParameter, merger: NetworkParameter) --/* Allows multiple types as one parameter, can be used on two unions to merge both. */
NaNet.Nullable(_type: NetworkParameter) --/* Allows a type to be nullable. */
```
