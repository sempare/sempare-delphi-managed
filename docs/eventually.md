## Eventually 

The eventually structure is used to a call a number of destructing type of actions.


### Usage

```
begin
	var e : Eventualy = procedure
		begin
			writeln('done');
		end;
	// do other things
end;
```


```
type 
	TMyObject = class
		public
			procedure doSomething();
	end;


var 
	e2 : Eventualy;
begin
	w2 := myobj.doSomething;
end;
```


```
Eventually.call<integer>(10, procedure (const AContext : integer)
	begin
		writeln('context value ' + IntToStr(AContext));
	end));


```



 