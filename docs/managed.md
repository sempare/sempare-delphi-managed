
## Managed< T : class >

Simple implementation of a unique pointer container. When the container goes out of scope, the contained object will be disposed of.

On assignment, the source container is cleared and the target container disposes of whatever it was managing to own the new value.

### Methods


### Properties

* _Value : T_

    The contained property

### Usage

```
var unique := Managed<TObject>.Create(TObject.Create);
//var unique : Managed<TObject> = TObject.Create; // using the implicit operator

Assert.IsNotNull(unique.Value);

var anotherUnique : Managed<TObject> = anotherUnique;
Assert.IsNull(unique.Value);
Assert.IsNotNull(anotherUnique.Value);


unique := TObject.Create;
with unique.value do 
begin
	// do something
end;
// object will be freed when the scope exists


```
