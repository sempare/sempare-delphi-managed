## Shared< T : class >
	
Simple implementation of a shared pointer container. Uses reference counting to control the lifetime of the object. 
When the reference count reaches 0, the contained object will be disposed of.

### Usage

```
var shared := Shared<TObject>.Create(TObject.Create);
//var shared : Shared<TObject> = TObject.Create; // using the implicit operator
	
Assert.IsNotNull(shared.Value);

var anotherShared : Shared<TObject> = shared;
Assert.IsNotNull(shared.Value);
Assert.IsNotNull(anotherShared.Value);

shared := nil;
Assert.IsNull(shared.Value);

anotherShared := nil;
Assert.IsNull(anotherShared.Value);
Assert.IsNull(anotherShared.Value);
```
