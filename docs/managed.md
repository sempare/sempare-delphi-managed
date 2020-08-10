
## Managed< T : class >

Simple implementation of a unique pointer container. When the container goes out of scope, the contained object will be disposed of.

On assignment, the source container is cleared and the target container disposes of whatever it was managing to own the new value.

### Methods


### Properties

* _Value : T_

    The contained property

### Usage


```
begin
	var managedVal := Managed<TObject>.Create(TObject.Create);
	Assert.IsNotNull(managedVal.Value);
end;

```


```
type
	TMyClass = class
	public
		procedure doSomething();
	end;

var 
	container : Managed<TObject>;
begin
	container := TObject.Create;
	Assert.IsNotNull(container.Value);
	with container.value do 
	begin
		doSomething();
	end;
end;

```
