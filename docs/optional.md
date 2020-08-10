## Optional< T >

A generic container for anything that should be optional.

This container does not free the contained object.

### Methods

* Clear() will free the value if IsManaged is true and sets HasValue to false.

### Properties

* _IsManaged : boolean_

	Read/write property to indicate if value should be freed when optional is finalised.

* _HasValue : boolean_

	Read only. Identifies if the container has a value or not.
      
* _Value : T_

	Read/write property for the contained value.
	
### Usage

```
var optional := Optional<boolean>.Create(true);
Assert.IsTrue(optional.HasValue);
```

```
var optional : Optional<boolean> = true; // using the implicit operator
Assert.IsTrue(optional.HasValue);
```

```
var optional : Optional<boolean>
Assert.IsFalse(optional.HasValue);
```

```
var optional := Optional<TObject>.Create(TObject.Create(), opManaged);
```

```
var optional : Optional<TObject>;

begin
	Assert.IsFalse(optional.HasValue);
	optional := TObject.Create;
	optional.IsManaged := true;
	Assert.IsTrue(optional.HasValue);
end;
```