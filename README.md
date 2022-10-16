# NaNet "Not another Networking library!"
A small, type-checked networking library for Roblox

# API
```lua
function NaNet.CreateRemoteEvent(Name: string, Parent: Instance): NetworkObject
```

```lua
function NaNet.CreateRemoteFunction(Name: string, Parent: Instance): NetworkObject
```

```lua
function NetworkObject.OnEvent(self: NetworkObject, parameters: {NetworkParameter}, listener)
```

```lua
function NetworkObject.OnInvoke(self: NetworkObject, parameters: {NetworkParameter}, listener) 
```

```lua
function NaNet.ConnectTypedEvent(remote: RemoteEvent, parameters: {NetworkParameter}, listener)
```


```lua
function NaNet.ConnectTypedInvoke(remote: RemoteFunction, parameters: {NetworkParameter}, listener)
```

# Types

### Primitive Types

```lua
NaNet.String
NaNet.Double
NaNet.Integer
NaNet.Boolean
NaNet.Table
NaNet.Instance
NaNet.UserData
NaNet.Array
NaNet.Nil
NaNet.Real
NaNet.Vararg
```

### Structure Types

```lua
NaNet.ConstrainedString(maxLength: number)
NaNet.ConstrainedString(minLength: number, maxLength: number)
NaNet.ConstrainedDouble(maxLength: number)
NaNet.ConstrainedDouble(minLength: number, maxLength: number)
NaNet.DataStoreString
NaNet.ConstrainedReal(maxLength: number)
NaNet.ConstrainedReal(minLength: number, maxLength: number)
NaNet.InstanceOfClass(name: NetworkParameter)
NaNet.TypedVararg(Type: )
```
