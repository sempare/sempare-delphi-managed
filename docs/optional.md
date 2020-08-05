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
//var optional : Optional<boolean> = true; // using the implicit operator

optional.IsManaged := true;

Assert.IsTrue(optional.HasValue);
Assert.IsTrue(optional.Value);
optional.Clear();
Assert.IsFalse(optional.HasValue);
```