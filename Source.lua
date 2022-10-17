--!strict

export type NetworkParameter = {
	Enum: number,
	MinLength: number?,
	MaxLength: number?,
	Typed: boolean?,
	TypeObject: NetworkParameter?,
	Class: string?,
	Tree: {NetworkParameter}?,
	KeyValue: string?,
	ValueType: NetworkParameter?,

	Value: any?,
}

export type NetworkEventObject = {
	_remote: RemoteEvent,
	OnTypedEvent: ((NetworkEventObject, {NetworkParameter}, any) -> ()),
	OnEvent: ((NetworkEventObject, any) -> ()),
}

export type NetworkFunctionObject = {
	_remote: RemoteFunction,
	OnTypedInvoke: ((NetworkFunctionObject, {NetworkParameter}, any) -> ()),
	OnInvoke: ((NetworkFunctionObject, any) -> ())
}

export type NaNet = {
	--/* Types */
	String: NetworkParameter,
	Double: NetworkParameter,
	Integer: NetworkParameter,
	Boolean: NetworkParameter,
	Table: NetworkParameter,
	Instance: NetworkParameter,
	UserData: NetworkParameter,
	Array: NetworkParameter,
	Nil: NetworkParameter,
	Real: NetworkParameter,
	Vararg: NetworkParameter,
	Any: NetworkParameter,

	ConstrainedString: (number, number?) -> NetworkParameter,
	ConstrainedDouble: (number, number?) -> NetworkParameter,
	DataStoreString: NetworkParameter,
	ConstrainedReal: (number, number?) -> NetworkParameter,
	InstanceOfClass: (string) -> NetworkParameter,
	TypedVararg: (NetworkParameter) -> NetworkParameter,
	TypedArray: (NetworkParameter) -> NetworkParameter,
	ConstrainedArray: (number, number?) -> NetworkParameter,
	ConstrainedAndTypedArray: (NetworkParameter, number, number?) -> NetworkParameter,
	
	DictionaryTree: ({NetworkParameter}) -> NetworkParameter,
	KeyValuePair: (string, NetworkParameter) -> NetworkParameter,
	OptionalKeyValuePair: (string, NetworkParameter) -> NetworkParameter,
	
	Value: (any) -> NetworkParameter,

	--/* Wrapper API */
	CreateRemoteEvent: ((string, Instance) -> NetworkEventObject),
	CreateRemoteFunction: ((string, Instance) -> NetworkFunctionObject),
	ConnectTypedEvent: ((RemoteEvent, {NetworkParameter}, any) -> ()),
	ConnectTypedInvoke: ((RemoteFunction, {NetworkParameter}, any) -> ()),
	
	--/* Standalone API */
	IsArray: ({any}) -> boolean,
	IsInteger: (number) -> boolean,
	IsReal: (number) -> boolean,
	IsRealWithinBoundary: (number, number, number?) -> boolean,
	IsStringSafeForDataStore: (string) -> boolean
}

local function CreateRangeType(enum, minLength, maxLength, typeObject: NetworkParameter?): NetworkParameter
	if maxLength == nil then --/* if only Types.ConstrainedType(100) is passed */
		return table.freeze{
			Enum = enum,
			MinLength = 0,
			MaxLength = minLength,
			TypeObject = typeObject
		}
	end

	return table.freeze{ 
		Enum = enum, 
		MinLength = minLength,
		MaxLength = maxLength,
		TypeObject = typeObject
	}
end

local InternalUserdata = newproxy() --/* Using userdata is a secure way to have a server-only piece of data that can be used if nil is in the table */ 

local function TypecheckParameters(parameters: {NetworkParameter}, ...)
	local parametersLength = #parameters	

	if parametersLength == 0 then 
		return true
	end

	local packed = table.pack(...)

	local nilParameters = 0

	for i,v in ipairs(parameters) do 
		if v.Enum == 9 then 
			nilParameters += 1
		end
	end

	local packedHashLength = 0
	for i,v in packed do 
		packedHashLength += 1
	end

	local safeLength = packedHashLength + nilParameters 

	if safeLength < parametersLength then 
		return false	
	end

	if parameters[1].Enum == 106 then --/* Typed Vararg */ 
		local typeObject = parameters[1].TypeObject
		parameters = table.create(safeLength, (typeObject :: NetworkParameter))
	end

	for i, parameter in ipairs(packed) do
		local _type = parameters[i]

		if _type == nil then 
			return false	
		end

		local _enum = _type.Enum

		if parameter == InternalUserdata then --/* Nil */
			if _enum == 9 then 
				continue;
			end

			return false;
		end

		--/* This may look ugly but its faster than keeping a table of functions, could use a binary search tree but it'd require modifications for the different gaps */	

		--/* Primitive types /*
		if _enum == 1 then --/* String */
			if type(parameter) ~= "string" then 
				return false
			end
		elseif _enum == 2 then --/* Double */
			if type(parameter) ~= "number" then 
				return false
			end
		elseif _enum == 3 then --/* Integer */
			if type(parameter) ~= "number" then
				return false
			end
			if math.floor(parameter) ~= parameter then 
				return false
			end
		elseif _enum == 4 then --/* Boolean */
			if type(parameter) ~= "boolean" then 
				return false
			end
		elseif _enum == 5 then --/* Table */
			if type(parameter) ~= "table" then
				return false
			end
		elseif _enum == 6 then --/* Instance */
			if typeof(parameter) ~= "Instance" then 
				return false
			end 
		elseif _enum == 7 then --/* UserData */
			if type(parameter) ~= "userdata" then 
				return false
			end
		elseif _enum == 8 then --/* Array */
			if type(parameter) ~= "table" then 
				return false
			end

			local t = table.pack(table.unpack(parameter)) --/* Unpack only unpacks the array part so we can use this to exclude anything else */ 
			local existingParameters = 0
			for i,v in ipairs(t) do  --/* ipairs will stop at nil */ 
				existingParameters += 1
			end

			if existingParameters ~= t.n then 
				return false
			end
		elseif _enum == 9 then --/* Nil */
			if InternalUserdata ~= parameter then
				return false
			end
		elseif _enum == 10 then --/* Real */ 
			if type(parameter) ~= "number" then 
				return false
			end
			if parameter ~= parameter then 
				return false
			end
		elseif _enum == 11 then --/* Vararg*/
			return true --/* This vararg is untyped so there is nothing left to do */

		--/* Any (12) doesn't need handling apart from where nil is supported */

		--/* Structure types */
		elseif _enum == 101 then --/* ConstrainedString */
			if type(parameter) ~= "string" then
				return false
			end 

			local length = #parameter

			if (length < (_type.MinLength :: number)) or (length > (_type.MaxLength :: number)) then 
				return false
			end
		elseif _enum == 102 then --/* ConstrainedDouble */
			if type(parameter) ~= "number" then 
				return false
			end
			if (parameter < (_type.MinLength :: number)) or (parameter > (_type.MaxLength :: number)) then 
				return false
			end
		elseif _enum == 103 then --/* DataStoreString */ 
			if type(parameter) ~= "string" then 
				return false 
			end
			if (utf8.len(parameter) == nil) or (#parameter > 65536) then
				return false
			end
		elseif _enum == 104 then --/* ConstrainedReal */
			if type(parameter) ~= "number" then 
				return false
			end
			if (parameter ~= parameter) or (parameter < (_type.MinLength :: number)) or (parameter > (_type.MaxLength :: number)) then 
				return false
			end
		elseif _enum == 105 then --/* InstanceOfClass */
			if typeof(parameter) ~= "Instance" then 
				return false 
			end
			if parameter:IsA(_type.Class :: string) == false then 
				return false
			end
			
		--/* Typed varargs (107) dont need handling apart from the snippet below */
		elseif _enum == 107 then --/* TypedArray */
			if type(parameter) ~= "table" then 
				return false
			end
		
			local t = table.pack(table.unpack(parameter)) --/* Unpack only unpacks the array part so we can use this to exclude anything else */ 
			local existingParameters = 0
			for i,v in ipairs(t) do  --/* ipairs will stop at nil */ 
				existingParameters += 1
			end

			if existingParameters ~= t.n then 
				return false
			end
			
			local arrayParameters = table.create(existingParameters, _type.TypeObject)
			
			if TypecheckParameters(arrayParameters, table.unpack(t)) == false then 
				return false
			end
		elseif _enum == 108 then --/* ConstrainedArray */
			if type(parameter) ~= "table" then 
				return false
			end

			local t = table.pack(table.unpack(parameter)) --/* Unpack only unpacks the array part so we can use this to exclude anything else */ 
			local existingParameters = 0
			for i,v in ipairs(t) do  --/* ipairs will stop at nil */ 
				existingParameters += 1
			end

			if existingParameters ~= t.n then 
				return false
			end
			
			if (existingParameters < (_type.MinLength :: number)) or (existingParameters > (_type.MaxLength :: number)) then
				return false
			end 
		elseif _enum == 109 then --/* ConstraintedAndTypedArray */
			if type(parameter) ~= "table" then 
				return false
			end

			local t = table.pack(table.unpack(parameter)) --/* Unpack only unpacks the array part so we can use this to exclude anything else */ 
			local existingParameters = 0
			for i,v in ipairs(t) do  --/* ipairs will stop at nil */ 
				existingParameters += 1
			end

			if existingParameters ~= t.n then 
				return false
			end

			if (existingParameters < (_type.MinLength :: number)) or (existingParameters > (_type.MaxLength :: number)) then
				return false
			end 
			
			local arrayParameters = table.create(existingParameters, _type.TypeObject)
			
			if TypecheckParameters(arrayParameters, table.unpack(t)) == false then 
				return false
			end
			
		--/* Tree types */
		elseif _enum == 501 then --/* DictionaryTree */
			if type(parameter) ~= "table" then 
				return false
			end

			local dictionaryParameters, values = {}, {}

			for _, KeyValuePair in (_type.Tree :: {NetworkParameter}) do
				local value = parameter[KeyValuePair.KeyValue]
			
				if (value == nil) and (KeyValuePair.Enum ~= 503) then --/* 503 is the optional KeyValuePair */ 
					return false
				end

				table.insert(dictionaryParameters, KeyValuePair.ValueType)
				table.insert(values, value)
			end

			if TypecheckParameters((dictionaryParameters :: {NetworkParameter}), table.unpack(values)) == false then --/* Type checks table values 
				return false
			end
		end

		local _next = packed[i+1]
		local _nextParameter = parameters[i+1]

		if (_nextParameter == nil) then 
			continue
		end

		local _nextEnum = _nextParameter.Enum

		if _next == nil then 
			if (_nextEnum == 9) or (_nextEnum == 12) then
				packed[i+1] = InternalUserdata		
				continue
			end
		else
			if _nextEnum == 106 then
				local varargParameters = table.create(packedHashLength-(i+1), _nextParameter.TypeObject)
				local t = table.pack(table.unpack(packed, i+1, packed.n))

				if TypecheckParameters(varargParameters, table.unpack(t)) == false then --/* Type checks varargs */
					return false
				end
			end
		end
	end

	return true
end

local function ConnectEvent(self: NetworkEventObject, parameters: {NetworkParameter}, listener)
	(self._remote :: RemoteEvent).OnServerEvent:Connect(function(player, ...)
		return listener(TypecheckParameters(parameters, ...), player, ...)
	end)
end

local function ConnectEventWithNoParameters(self: NetworkEventObject, listener)
	(self._remote :: RemoteEvent).OnServerEvent:Connect(listener)
end

local function ConnectFunction(self: NetworkFunctionObject, parameters: {NetworkParameter}, listener) 
	(self._remote :: RemoteFunction).OnServerInvoke = function(player, ...)
		return listener(TypecheckParameters(parameters, ...), player, ...)
	end
end

local function ConnectFunctionWithNoParameters(self: NetworkFunctionObject, listener) 
	(self._remote :: RemoteFunction).OnServerInvoke = listener
end

local NaNet: NaNet = {
	--/* Primitive Types 1 - 100 */
	String = table.freeze{ Enum = 1	}, --/* Basic string type, accepts any string of any length and any type of byte */
	Double = table.freeze{ Enum = 2	}, --/* Basic double type, accepts any number in the IEEE 754 standard */
	Integer = table.freeze{ Enum = 3 }, --/* Basic integer type, accepts any signed integer */
	Boolean = table.freeze{ Enum = 4 }, --/* Basic boolean type, accepts true and false */
	Table = table.freeze{ Enum = 5 }, --/* Basic table type, the decision to make it a primitive type is because of its later uses */
	Instance = table.freeze{ Enum = 6 }, --/* Basic Instance type, accepts any instance */ 
	UserData = table.freeze{ Enum = 7 }, --/* Basic userdata type, a useless type in many cases */
	Array = table.freeze{ Enum = 8 }, --/* Basic array type, accepts any array with an ordered list */
	Nil = table.freeze{ Enum = 9}, --/* Basic nil type, a lot of jank comes with this type so I recommend against using it */
	Real = table.freeze{ Enum = 10 }, --/* Basic real type, any number that is real, rational */
	Vararg = table.freeze{ Enum = 11 }, --/* Basic vararg type, if placed at the end of the parameter list the vararg 
	Any = table.freeze{ Enum = 12 }, --/* Basic any type, disables type-checking for the specific parameter */

	--/* Structure types 101 - 500 */
	ConstrainedString = function(minLength, maxLength) --/* String with a limited length */
		assert(type(minLength) == "number", "NaNet.ConstrainedString expected `number` for argument #1")
		if maxLength then 
			assert(type(maxLength) == "number", "NaNet.ConstrainedString expected `number` for argument #2")
		end
		
		return CreateRangeType(101, minLength, maxLength)
	end,
	ConstrainedDouble = function(minLength, maxLength) --/* Double with a limited range */
		assert(type(minLength) == "number", "NaNet.ConstrainedDouble expected `number` for argument #1")
		if maxLength then
			assert(type(maxLength) == "number", "NaNet.ConstrainedDouble expected `number` for argument #2")
		end
		
		return CreateRangeType(102, minLength, maxLength)
	end,
	DataStoreString = table.freeze{ Enum = 103 }, --/* Special string type that is safe to save in a data store */
	ConstrainedReal = function(minLength, maxLength) --/* Real with a limited range */
		assert(type(minLength) == "number", "NaNet.ConstrainedReal expected `number` for argument #1")
		if maxLength then 
			assert(type(maxLength) == "number", "NaNet.ConstrainedReal expected `number` for argument #2")
		end
		
		return CreateRangeType(104, minLength, maxLength)
	end,
	InstanceOfClass = function(name) --/* Instance type that only lets instances with a specific class through */
		assert(type(name) == "string", "NaNet.InstanceOfClass expected `string` for argument #1")
		
		return table.freeze{ Enum = 105, Class = name }
	end,
	TypedVararg = function(_type) --/* Special structure type that acts as a primitive, all varargs will be type-checked */
		assert((type(_type) == "table") and (_type.Enum), "NaNet.DictionaryTree expected `NaNet.NetworkParameter` for argument #1")
		
		return table.freeze{
			Enum = 106,
			TypeObject = _type
		}
	end,
	TypedArray = function(_type) --/* Accepts any ordered array with a specific type */
		assert((type(_type) == "table") and (_type.Enum), "NaNet.TypedArray expected `NaNet.NetworkParameter` for argument #1")
		
		return table.freeze{
			Enum = 107,
			TypeObject = _type
		}
	end,
	ConstrainedArray = function(minLength, maxLength) --/* Accepts any ordered array with a size limit */
		assert(type(minLength) == "number", "NaNet.ConstraintedArray expected `number` for argument #1")
		if maxLength then 
			assert(type(maxLength) == "number", "NaNet.ConstraintedArray expected `number` for argument #2")
		end
		
		return CreateRangeType(108, minLength, maxLength)
	end,
	ConstrainedAndTypedArray = function(_type, minLength, maxLength) --/* Accepts any ordered array with a specific type and size limit */
		assert((type(_type) == "table") and (_type.Enum), "NaNet.ConstraintedAndTypedArray expected `NaNet.NetworkParameter` for argument #1")
		
		assert(type(minLength) == "number", "NaNet.ConstraintedArray expected `number` for argument #2")
		if maxLength then 
			assert(type(maxLength) == "number", "NaNet.ConstraintedArray expected `number` for argument #3")
		end

		return CreateRangeType(109, minLength, maxLength, _type)
	end,

	--/* Tree types 501 - 999 */
	DictionaryTree = function(tree) --/* Dictionary tree type, allows for type-checking an entire dictionary */
		assert(type(tree) == "table", "NaNet.DictionaryTree expected `table` for argument #1")
		
		return table.freeze{
			Enum = 501,
			Tree = tree
		}
	end,
	KeyValuePair = function(keyValue, valueType) --/* Key and value pair for dictionary trees, the value can be set to a DictionaryTree */
		assert(type(keyValue) == "string", "NaNet.KeyValuePair expected `string` for argument #1")
		assert((type(valueType) == "table") and (valueType.Enum), "NaNet.KeyValuePair expected `NaNet.NetworkParameter` for argument #2")
		
		return table.freeze{
			Enum = 502, 
			KeyValue = keyValue,
			ValueType = valueType
		}
	end,
	OptionalKeyValuePair = function(keyValue, valueType) --/* An optional version of the KeyValuePair */
		assert(type(keyValue) == "string", "NaNet.OptionalKeyValuePair expected `string` for argument #1")
		assert((type(valueType) == "table") and (valueType.Enum), "NaNet.OptionalKeyValuePair expected `NaNet.NetworkParameter` for argument #2")
		
		return table.freeze{
			Enum = 503, 
			KeyValue = keyValue,
			ValueType = valueType
		}
	end,
	
	InstanceTree = function() error("Not implemented") end,
	PropertyTree = function() error("Not implemented") end,
	
	--/* Value buffer */
	Value = function(value) --/* Buffer in NaNet for any static value that isn't a type */
		return table.freeze{
			Enum = 1000,
			Value = value
		}
	end,
	Union = function() error("Not implemented") end,


	--/* Wrapper API */
	CreateRemoteEvent = function(Name, Parent)
		assert(Name == "string", "NaNet.CreateRemoteEvent expected `string` for argument #1")
		assert(typeof(Parent) == "Instance", "NaNet.CreateRemoteEvent expected `Instance` for argument #2")

		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = Name
		remoteEvent.Parent = Parent

		return table.freeze{
			_remote = remoteEvent,
			OnTypedEvent = ConnectEvent,
			OnEvent = ConnectEventWithNoParameters
		}
	end,
	CreateRemoteFunction = function(Name, Parent)
		assert(Name == "string", "NaNet.CreateRemoteFunction expected `string` for argument #1")
		assert(typeof(Parent) == "Instance", "NaNet.CreateRemoteFunction expected `Instance` for argument #2")

		local remoteFunction = Instance.new("RemoteFunction")
		remoteFunction.Name = Name
		remoteFunction.Parent = Parent

		return table.freeze{
			_remote = remoteFunction,
			OnTypedInvoke = ConnectFunction,
			OnInvoke = ConnectFunctionWithNoParameters
		}
	end,
	ConnectTypedEvent = function(remote: RemoteEvent, parameters: {NetworkParameter}, listener)
		assert((typeof(remote) == "Instance") and (remote:IsA("RemoteEvent")), "NaNet.ConnectTypedEvent expected `RemoteEvent` for argument #1")
		assert(type(parameters) == "table", "NaNet.ConnectTypedEvent expected `table` for argument #2")
		assert(type(listener) == "function", "NaNet.ConnectTypedEvent expected `function` for argument #3");

		remote.OnServerEvent:Connect(function(player, ...)
			return listener(TypecheckParameters(parameters, ...), player, ...)
		end)
	end,
	ConnectTypedInvoke = function(remote: RemoteFunction, parameters: {NetworkParameter}, listener)
		assert((typeof(remote) == "Instance") and remote:IsA("RemoteFunction"), "NaNet.ConnectTypedEvent expected `RemoteFunction` for argument #1")
		assert(type(parameters) == "table", "NaNet.ConnectTypedEvent expected `table` for argument #2")
		assert(type(listener) == "function", "NaNet.ConnectTypedEvent expected `function` for argument #3");

		remote.OnServerInvoke = function(player, ...)
			return listener(TypecheckParameters(parameters, ...), player, ...)
		end
	end,
	
	--/* Standalone API */
	IsArray = function(parameter)
		if type(parameter) ~= "table" then 
			return false
		end

		local t = table.pack(table.unpack(parameter)) --/* Unpack only unpacks the array part so we can use this to exclude anything else */ 
		local existingParameters = 0
		for i,v in ipairs(t) do  --/* ipairs will stop at nil */ 
			existingParameters += 1
		end

		if existingParameters ~= t.n then 
			return false
		end
		
		return true
	end,
	IsInteger = function(parameter)
		if type(parameter) ~= "number" then
			return false
		end
		if math.floor(parameter) ~= parameter then 
			return false
		end
		
		return true
	end,
	IsReal = function(parameter)
		if type(parameter) ~= "number" then 
			return false
		end
		if parameter ~= parameter then 
			return false
		end
		
		return true
	end,
	IsRealWithinBoundary = function(parameter, minLength, maxLength)
		if type(parameter) ~= "number" then 
			return false
		end
		if parameter ~= parameter then 
			return false
		end
		if maxLength then
			if (parameter < minLength) or (parameter > maxLength) then 
				return false
			end
		else 
			if (parameter < 0) or (parameter > minLength) then 
				return false
			end
		end

		
		return true
	end,
	IsStringSafeForDataStore = function(parameter)
		if type(parameter) ~= "string" then 
			return false 
		end
		if (utf8.len(parameter) == nil) or (#parameter > 65536) then
			return false
		end
		
		return true
	end
}


return table.freeze(NaNet)
