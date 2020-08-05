unit Sempare.Managed.Test;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils;

{$I Sempare.Managed.inc}

type
  ManagedTestException = class(Exception);

  [TestFixture]
  TMyTestObject = class

  public
    [Test]
    procedure TestOptional;

    [Test]
    procedure TestManagedOptional;

    [Test]
    procedure TestManaged;
    [Test]
    procedure TestShared;
    [Test, WillRaise(ManagedTestException)]
    procedure TestEventuallyProc;
    [Test, WillRaise(ManagedTestException)]
    procedure TestEventuallyMethod;
  end;

implementation

uses
  Sempare.Managed;

{ TMyTestObject }

procedure TMyTestObject.TestManagedOptional;
var
  O: Optional<TObject>;

begin
  Assert.IsFalse(O.HasValue);
  O := TObject.Create;
  O.IsManaged := true;
  Assert.IsTrue(O.HasValue);
  Assert.IsNotNull(O.Value);

  O.Clear;
  Assert.IsFalse(O.HasValue);
  O := nil;
  O.IsManaged := true;
  Assert.IsTrue(O.HasValue);
  Assert.IsNull(O.Value);
end;

procedure TMyTestObject.TestOptional;
var
  O: Optional<Boolean>;

begin
  Assert.IsFalse(O.HasValue);
  O := true;
  Assert.IsTrue(O.HasValue);
  Assert.IsTrue(O.Value);

  O.Clear;
  Assert.IsFalse(O.HasValue);
  O := false;
  Assert.IsTrue(O.HasValue);
  Assert.IsFalse(O.Value);
end;

procedure TMyTestObject.TestShared;
var
  s1, s2, s3: shared<TObject>;
begin
  s1 := TObject.Create;
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  Assert.AreEqual(1, s1.UseCount);
  Assert.AreEqual(0, s2.UseCount);
  Assert.AreEqual(0, s3.UseCount);
{$ENDIF}
  Assert.IsNotNull(s1.Value);
  Assert.IsNull(s2.Value);
  Assert.IsNull(s3.Value);

  s2 := s1;
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  Assert.AreEqual(2, s1.UseCount);
  Assert.AreEqual(2, s2.UseCount);
  Assert.AreEqual(0, s3.UseCount);
{$ENDIF}
  Assert.IsNotNull(s1.Value);
  Assert.IsNotNull(s2.Value);
  Assert.IsNull(s3.Value);

  s3 := s1;
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  Assert.AreEqual(3, s1.UseCount);
  Assert.AreEqual(3, s2.UseCount);
  Assert.AreEqual(3, s3.UseCount);
{$ENDIF}
  Assert.IsNotNull(s1.Value);
  Assert.IsNotNull(s2.Value);
  Assert.IsNotNull(s3.Value);

  s1 := nil;
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  Assert.AreEqual(0, s1.UseCount);
  Assert.AreEqual(2, s2.UseCount);
  Assert.AreEqual(2, s3.UseCount);
{$ENDIF}
  Assert.IsNull(s1.Value);
  Assert.IsNotNull(s2.Value);
  Assert.IsNotNull(s3.Value);

  s2 := nil;
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  Assert.AreEqual(0, s1.UseCount);
  Assert.AreEqual(0, s2.UseCount);
  Assert.AreEqual(1, s3.UseCount);
{$ENDIF}
  Assert.IsNull(s1.Value);
  Assert.IsNull(s2.Value);
  Assert.IsNotNull(s3.Value);

  s3 := nil;
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  Assert.AreEqual(0, s1.UseCount);
  Assert.AreEqual(0, s2.UseCount);
  Assert.AreEqual(0, s3.UseCount);
{$ENDIF}
  Assert.IsNull(s1.Value);
  Assert.IsNull(s2.Value);
  Assert.IsNull(s3.Value);

  s3 := TObject.Create;
  s1 := s3;
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  Assert.AreEqual(2, s1.UseCount);
  Assert.AreEqual(0, s2.UseCount);
  Assert.AreEqual(2, s3.UseCount);
{$ENDIF}
  Assert.IsNotNull(s1.Value);
  Assert.IsNull(s2.Value);
  Assert.IsNotNull(s3.Value);
end;

type
  TTestEventually = class
  public
    procedure RaiseException;
  end;

procedure TMyTestObject.TestEventuallyMethod;
var
  e: eventually;
  O: TTestEventually;
begin
  O := TTestEventually.Create;
  e := O.RaiseException;
end;

procedure TMyTestObject.TestEventuallyProc;

var
  e: eventually;
begin
  e := procedure
    begin
      raise ManagedTestException.Create('good');
    end;
end;

procedure TMyTestObject.TestManaged;
var
  O1, o2: Managed<TObject>;
begin
  O1 := Managed<TObject>.Create(TObject.Create());
  Assert.IsNotNull(O1.Value);
  Assert.IsNull(o2.Value);

  o2 := O1;
{$IFDEF USE_INTERFACE}
  Assert.IsNotNull(O1.Value);
{$ELSE}
  Assert.IsNull(O1.Value);
{$ENDIF}
  Assert.IsNotNull(o2.Value);

  o2.Clear;
{$IFDEF USE_INTERFACE}
  Assert.IsNotNull(O1.Value);
{$ELSE}
  Assert.IsNull(O1.Value);
{$ENDIF}
  Assert.IsNull(o2.Value);
end;

{ TTestEventually }

procedure TTestEventually.RaiseException;
begin
  self.Free;
  raise ManagedTestException.Create('good');
end;

initialization

TDUnitX.RegisterTestFixture(TMyTestObject);

end.
