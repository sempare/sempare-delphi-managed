(*%****************************************************************************
 *                 ___                                                        *
 *                / __|  ___   _ __    _ __   __ _   _ _   ___                *
 *                \__ \ / -_) | '  \  | '_ \ / _` | | '_| / -_)               *
 *                |___/ \___| |_|_|_| | .__/ \__,_| |_|   \___|               *
 *                                    |_|                                     *
 ******************************************************************************
 *                                                                            *
 *                        Sempare Managed                                     *
 *                                                                            *
 *                                                                            *
 *          https://www.github.com/sempare/sempare-managed                    *
 ******************************************************************************
 *                                                                            *
 * Copyright (c) 2020 Sempare Limited,                                        *
 *                    Conrad Vermeulen <conrad.vermeulen@gmail.com>           *
 *                                                                            *
 * Contact: info@sempare.ltd                                                  *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *   http://www.apache.org/licenses/LICENSE-2.0                               *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 *                                                                            *
 ****************************************************************************%*)
unit Sempare.Managed;

interface

uses
  SysUtils;

// NOTE: No promises of thread safety right now

{$I Sempare.Managed.inc}

type
  (*
    Optional<T> is fairly simple. Using FFlags, it tracks what it needs
    to do. The developer must be aware that setting ofManaged on a
    non-pointer T will cause trouble.

  *)
  Optional<T> = record
  type
    TOptionalFlag = (ofHasValue, ofManaged, ofFreeMem);
    TOptionalFlags = set of TOptionalFlag;
    TOptionalManaged = (opUnmanaged, opManaged);
  strict private
    FValue: T;
    FFlags: TOptionalFlags;
    procedure SetValue(const AValue: T); inline;
    function GetHasValue: boolean;
    function GetManaged: boolean;
    procedure SetManaged(const Value: boolean);
    function GetUseFreeMem: boolean;
    procedure SetUseFreeMem(const Value: boolean);
  public
    constructor Create(const AValue: T;
      const AManaged: TOptionalManaged = opUnmanaged);
    procedure Clear(); inline;

{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
    class operator Initialize(out AValue: Optional<T>);
    class operator Finalize(var AValue: Optional<T>);
{$ENDIF}
    class operator Implicit(const AValue: T): Optional<T>; static; inline;

    property Value: T read FValue write SetValue;
    property HasValue: boolean read GetHasValue;
    property IsManaged: boolean read GetManaged write SetManaged;
    property UseFreeMem: boolean read GetUseFreeMem write SetUseFreeMem;
  end;
{$IFDEF USE_INTERFACE}

  IManaged<T: class> = interface
    function GetValue: T;
    property Value: T read GetValue;
  end;
{$ENDIF}

  Managed<T: class> = record
  private
{$IFDEF USE_INTERFACE}
    FManaged: IManaged<T>;
{$ELSE}
    FValue: T;
{$ENDIF}
    function GetValue: T;

  public
    class operator Implicit(const AValue: T): Managed<T>; static;
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
    class operator Assign(var AValue: Managed<T>;
      var AOther: Managed<T>); static;
    class operator Initialize(out AValue: Managed<T>);
    class operator Finalize(var AValue: Managed<T>);
{$ENDIF}
    constructor Create(const AValue: T);
    procedure Clear();
    property Value: T read GetValue;
  end;

  Shared<T: class> = record
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  type
    TCounter = class
    strict private
      FValue: T;
      FCount: integer;
    public
      constructor Create(const AValue: T); overload;
      destructor Destroy; override;
      procedure Inc(); inline;
      procedure Dec(); inline;
      property Count: integer read FCount;
      property Value: T read FValue write FValue;
    end;
  strict private
    FCounter: TCounter;
    function GetCount: integer;
  public
    class operator Assign(var AValue: Shared<T>; const [ref] AOther: Shared<T>);
    class operator Initialize(out AValue: Shared<T>);
    class operator Finalize(var AValue: Shared<T>);
    property UseCount: integer read GetCount;
{$ELSE}
  strict private
    FManaged: IManaged<T>;
{$ENDIF}
  strict private
    function GetValue: T;
  public
    class operator Implicit(const AValue: T): Shared<T>;
    property Value: T read GetValue;
  end;

  IEventually = interface
    ['{A3B09B57-7001-4D58-AD78-699ED543CC17}']
  end;

  Eventually = record
  type
    TEventuallyProc = reference to procedure();
    TEventuallyMethod = procedure() of object;

    TEventuallyProcHelper = class(TInterfacedObject, IEventually)
    strict private
      FEventually: TEventuallyProc;
    public
      constructor Create(const AValue: TEventuallyProc);
      destructor Destroy; override;
    end;

    TEventuallyMethodHelper = class(TInterfacedObject, IEventually)
    strict private
      FEventually: TEventuallyMethod;
    public
      constructor Create(const AValue: TEventuallyMethod);
      destructor Destroy; override;
    end;

  strict private
    FEventually: IEventually;
  public
    constructor Create(const AValue: TEventuallyProc); overload;
    constructor Create(const AValue: TEventuallyMethod); overload;
    class operator Implicit(const AValue: TEventuallyProc): Eventually; static;
    class operator Implicit(const AValue: TEventuallyMethod)
      : Eventually; static;
  end;

{$IFDEF USE_INTERFACE}

  // _TManaged_ is named this way so it is not used.

  _TManaged_<T: class> = class(TInterfacedObject, IManaged<T>)
  private
    FValue: T;
  public
    constructor Create(const AValue: T);
    destructor Destroy(); override;

    function GetValue: T;
    property Value: T read GetValue;
  end;

{$ENDIF}

implementation

{$IFDEF USE_INTERFACE}
{ _TManaged_<T> }

constructor _TManaged_<T>.Create(const AValue: T);
begin
  FValue := AValue;
end;

destructor _TManaged_<T>.Destroy();
begin
  if FValue <> nil then
  begin
    FValue.Free();
    FValue := nil;
  end;
end;

function _TManaged_<T>.GetValue: T;
begin
  result := FValue;
end;

{$ENDIF}
{ Optional<T> }

{$IFDEF HAS_MANAGED_RECORD_SUPPORT}

class operator Optional<T>.Initialize(out AValue: Optional<T>);
begin
  AValue.FFlags := [];
end;

class operator Optional<T>.Finalize(var AValue: Optional<T>);
begin
  AValue.Clear();
end;

{$ENDIF}

class operator Optional<T>.Implicit(const AValue: T): Optional<T>;
begin
  result := Optional<T>.Create(AValue);
end;

constructor Optional<T>.Create(const AValue: T;
  const AManaged: TOptionalManaged);
begin
  IsManaged := opManaged = AManaged;
  SetValue(AValue);
end;

function Optional<T>.GetHasValue: boolean;
begin
  result := ofHasValue in FFlags;
end;

function Optional<T>.GetManaged: boolean;
begin
  result := ofManaged in FFlags;
end;

function Optional<T>.GetUseFreeMem: boolean;
begin
  result := ofFreeMem in FFlags;
end;

procedure Optional<T>.Clear();
var
  v: TObject;
begin
  if IsManaged then
  begin
    v := TObject(pointer(@FValue)^);
    if v <> nil then
    begin
      v.Free;
    end;
  end;
  exclude(FFlags, ofHasValue);
end;

procedure Optional<T>.SetManaged(const Value: boolean);
begin
  if Value then
    include(FFlags, ofManaged)
  else
    exclude(FFlags, ofManaged);
end;

procedure Optional<T>.SetUseFreeMem(const Value: boolean);
begin
  if Value then
    include(FFlags, ofFreeMem)
  else
    exclude(FFlags, ofFreeMem);
end;

procedure Optional<T>.SetValue(const AValue: T);
begin
  include(FFlags, ofHasValue);
  FValue := AValue;
end;

{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
{ Shared<T>.TCounter }

procedure Shared<T>.TCounter.Inc();
begin
  System.AtomicIncrement(FCount);
end;

procedure Shared<T>.TCounter.Dec();
begin
  System.AtomicDecrement(FCount);
end;

constructor Shared<T>.TCounter.Create(const AValue: T);
begin
  FValue := AValue;
  if AValue <> nil then
    Inc();
end;

destructor Shared<T>.TCounter.Destroy();
begin
  if (FValue <> nil) and (FCount = 0) then
  begin
    FValue.Free();
    FValue := nil;
  end;
end;

{$ENDIF}
{ Shared<T> }

{$IFDEF HAS_MANAGED_RECORD_SUPPORT}

function Shared<T>.GetCount: integer;
begin
  result := FCounter.Count;
end;

{$ENDIF}

function Shared<T>.GetValue: T;
begin
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  if UseCount = 0 then
    result := nil
  else
    result := FCounter.Value;
{$ELSE}
  if FManaged = nil then
    result := nil
  else
    result := FManaged.Value;
{$ENDIF}
end;

{$IFDEF HAS_MANAGED_RECORD_SUPPORT}

class operator Shared<T>.Assign(var AValue: Shared<T>;
  const [ref] AOther: Shared<T>);
begin
  if @AValue = @AOther then
    exit;
  AValue.FCounter.Dec;
  if AValue.UseCount = 0 then
    AValue.FCounter.Free;
  AValue.FCounter := AOther.FCounter;
  AValue.FCounter.Inc;
end;

{$ENDIF}

class operator Shared<T>.Implicit(const AValue: T): Shared<T>;
begin
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  result.FCounter := TCounter.Create(AValue);
{$ELSE}
  if AValue = nil then
    result.FManaged := nil
  else
    result.FManaged := _TManaged_<T>.Create(AValue);
{$ENDIF}
end;

{$IFDEF HAS_MANAGED_RECORD_SUPPORT}

class operator Shared<T>.Initialize(out AValue: Shared<T>);
begin
  AValue.FCounter := TCounter.Create();
end;

class operator Shared<T>.Finalize(var AValue: Shared<T>);
begin
  AValue.FCounter.Dec;
  if (AValue.FCounter.Count = 0) and (AValue.FCounter <> nil) then
  begin
    AValue.FCounter.Free;
    AValue.FCounter := nil;
  end;
end;
{$ENDIF}
{ Managed<T> }

{$IFDEF HAS_MANAGED_RECORD_SUPPORT}

class operator Managed<T>.Assign(var AValue: Managed<T>;
  var AOther: Managed<T>);
begin
  if @AValue = @AOther then
    exit;
  AValue.Clear;
  AValue.FValue := AOther.FValue;
  AOther.FValue := nil;
end;

class operator Managed<T>.Finalize(var AValue: Managed<T>);
begin
  AValue.Clear();
end;

class operator Managed<T>.Initialize(out AValue: Managed<T>);
begin
  AValue.FValue := nil;
end;

{$ENDIF}

function Managed<T>.GetValue(): T;
begin
{$IFDEF USE_INTERFACE}
  if FManaged = nil then
    exit(nil);
  result := FManaged.Value;
{$ELSE}
  result := FValue;
{$ENDIF}
end;

class operator Managed<T>.Implicit(const AValue: T): Managed<T>;
begin
  result := Managed<T>.Create(AValue);
end;

constructor Managed<T>.Create(const AValue: T);
begin
{$IFDEF HAS_MANAGED_RECORD_SUPPORT}
  FValue := AValue;
{$ELSE}
  FManaged := _TManaged_<T>.Create(AValue);
{$ENDIF}
end;

procedure Managed<T>.Clear;
begin
{$IFDEF USE_INTERFACE}
  FManaged := nil;
{$ELSE}
  if FValue <> nil then
  begin
    FValue.Free;
    FValue := nil;
  end;
{$ENDIF}
end;

{ Eventually }

constructor Eventually.Create(const AValue: TEventuallyProc);
begin
  FEventually := TEventuallyProcHelper.Create(AValue);
end;

constructor Eventually.Create(const AValue: TEventuallyMethod);
begin
  FEventually := TEventuallyMethodHelper.Create(AValue);
end;

class operator Eventually.Implicit(const AValue: TEventuallyProc): Eventually;
begin
  result := Eventually.Create(AValue);
end;

class operator Eventually.Implicit(const AValue: TEventuallyMethod): Eventually;
begin
  result := Eventually.Create(AValue);
end;

{ Eventually.TEventuallyProcHelper }

constructor Eventually.TEventuallyProcHelper.Create(const AValue
  : TEventuallyProc);
begin
  FEventually := AValue;
end;

destructor Eventually.TEventuallyProcHelper.Destroy;
begin
  if assigned(FEventually) then
    FEventually();
end;

{ Eventually.TEventuallyMethodHelper }

constructor Eventually.TEventuallyMethodHelper.Create
  (const AValue: TEventuallyMethod);
begin
  FEventually := AValue;
end;

destructor Eventually.TEventuallyMethodHelper.Destroy;
begin
  if assigned(FEventually) then
    FEventually();
end;

end.
