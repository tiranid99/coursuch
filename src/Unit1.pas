unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Button3: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Edit3: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  // ������ ��������� ������� ����� ��� p � q
  B: array[1..50] of integer;
  // ��� ������
  hashCode: Int64;
  messager: string;
  // �������� ����������
  eexp: integer;
  // ��������� ����������
  dexp: integer;
  // ����������� ������� (Digital signature)
  s: int64;
  p, q: integer;
  n, eiler: Int64;
  flag: boolean;
  res: integer;
  MArray: array of integer;
  SignArray: array of int64;
  maxInt64: Int64;
  maxM: integer;   // 2^21 -1

  //testers:
  tried: cardinal;
  trigger: boolean;

implementation

uses
  Math;

{$R *.dfm}

procedure reshErat(maxEl : integer);
var
  BB: array[1..50] of Integer;
  A: array of boolean;
  n, x, y: integer;
begin
  SetLength(A, maxEl);
  A[1] := false;
  n := maxEl;
  Form1.Label2.Caption := ' ';
  for x := 2 to n do
    A[x] := true;
  for x := 2 to n div 2 do
    for y := 2 to n div x do
      A[x * y] := false;
  y := 1;
  x:= n;
  while (y < Length(B)) and (x > 0) do
  begin
    if A[x] then
    begin
      B[y] := x;
      inc(y);
    end;
    x := x-1;
  end;

end;


// ������ ���������� ��� ��������� ������ ������� ������� �����
procedure reshetoErat();
var
  A: array[1..232] of boolean;
  n, x, y: integer;
begin
  A[1] := false;
  n := 232;
  Form1.Label2.Caption := ' ';
  for x := 2 to n do
    A[x] := true;
  for x := 2 to n div 2 do
    for y := 2 to n div x do
      A[x * y] := false;
  y := 1;
  for x := n downto n - 200 do
    if A[x] then
    begin
      B[y] := x;
      inc(y);
    end;
end;


// ��� 16 ������ ���
function hashH37(s: string): integer;
var
  hash: integer;
  i: cardinal;
begin
  hash := 139062143;
  for i := 1 to length(s) do
  begin
    hash := 37 * hash + ord(s[i]);
  end;
  hash := hash shr 16;
  hashH37 := hash;

end;

function crc16(s: string): integer;
var
  i, crc: integer;
begin
  crc := 0;
  for i := 1 to length(s) do
  begin
    crc := crc + ord(s[i]) * 44111;
    //crc:= crc xor (crc shr 8);

  end;

  Result := crc;
end;

function eightbitxorsum(mess: string): integer;
var
  i, sum, scode: integer;
begin
  sum := ord(mess[1]);
  for i := 2 to length(mess) do
    sum := sum xor ord(mess[i]);

  Result := sum;
end;

function ToBin(x: integer): string;
const
  t: array[0..1] of char = ('0', '1');
var
  res: string;
  d: 0..1;
begin
  res := '';
  while (x <> 0) do
  begin
    d := x mod 2;
    res := t[d] + res;
    x := x div 2;
  end;
  Result := res;
end;


//   http://granitnayki.com/?p=212
// ��� ����� ���������� ��������
function niceLongPow(a : int64; n : Int64; m: int64):int64;
var c, S, y : Int64;
    i, k : integer;
    strUp : string;
begin
  if (n = 1) then
    Result:= a mod m
  else
  begin
    strUp := ToBin(n);
    k := length(strUp);
    y:= a mod m;
    for i:=k downto 2 do
    begin
      y:= (y*y) mod m;
      if (strUp[i] = '1') then
      begin
        y:= y*a mod m;
      end;
    end;
    Result:= y;
  end;
end;

// ����������� ������ ������� SDBM (�32) � ������� �������������� �� ���� ����� (���� ��������)
function SDBM(mess: string): int64;
var
  i: cardinal;
  hash: int64;
begin
  hash := 0;
  for i := 1 to Length(mess) do
    hash := ord(mess[i]) + (hash shl 6) + (hash shl 16) - hash;
  Result := hash;
end;

// ��� ����� ���������� 
procedure gcd_ext(a, b: integer; var x, y, gcd: integer);
var
  x1, y1: integer;
begin
  if b = 0 then
  begin
    gcd := a;
    x := 1;
    y := 0;
    Exit
  end;
  gcd_ext(b, a mod b, x1, y1, gcd);
  x := y1;
  y := x1 - (a div b) * y1
end;

// ����� ��� �����
function Znak(Val: Integer): Char;
begin
  if Val >= 0 then
    Result := '+'
  else
    Result := '-';
end;


// ������� ���������� � ������� (��� ������������� ����� � ��������.
// ������� ����������
function pow(base, up: int64): int64;
var
  i: cardinal;
begin
  if (base = 1) or (up = 0) then
    Result := 1
  else
  begin
    Result := base;
    for i := 2 to up do
    begin
      Result := base * Result;
      if (result < 0) then
      begin
        flag := true;
        break;
      end;
    end;
  end;
end;

// ������� � �����
function toInt(ch: char): integer;
begin
  if ch = '0' then
    Result := 0
  else if ch = '1' then
    Result := 1
  else
    Result := 9999;
end;



procedure genDigitalSignature();
var
  strdexp: string;
  i, k: integer;
  m: int64;
begin
//949666443
  s := niceLongPow(hashCode, dexp, n);
  Form1.Label1.Caption:= IntToStr(s);
  Form1.Label1.Visible:= True;

end;



procedure generateKeys(minimalN: integer);
var
  aa, bb, nod: integer;
  k1, k2 : Cardinal;
begin
  Randomize();
  p := 0;
  q := 0;

  k1 := 0;
  k2 := 1;
  {
  while ((p = q) or (p = 0) or (q = 0) or (n < minimalN) or (n > minimalN * 50) or (k1 <> k2)) do
  begin
    p := RandomFrom(b);
    q := RandomFrom(b);
    k1 := Length(toBin(p));
    k2 := Length(toBin(q));
    n := p * q;

  end;
  }

  {}
  p:= 19;    // 19 3
  q:= 31;   // 31  11
  n:= p*q;
  {}

  eiler := (p - 1) * (q - 1);
  eexp := 1;
  nod := 0;
  while (nod <> 1) do
  begin
    inc(eexp);
    gcd_ext(eexp, eiler, aa, bb, nod);
  end;
  dexp := (aa mod eiler + eiler) mod eiler;

end;

procedure createSign(minimalN: integer);
var
  start, endd, full: integer;
  hsh: int64;
begin
  {
  full:= 0;
  start:= GetTickCount();
   }

  //reshetoErat(minimalN*100);
  {}
  //reshetoErat();
  reshErat(Round(Sqrt(minimalN*10)));
  generateKeys(minimalN);
  {}
{
  n := 33;
  eexp := 3;
  dexp := 7;
}

  //s := getProizvCheck(hashCode, dexp);
  {
  p := 337;
  q := 449;
  n := 151313;
  eiler := 150528;
  eexp := 5;
  dexp := 90317;

  }
  genDigitalSignature();

  endd := GetTickCount();
  full := full + (endd - start);
  //Form1.Label3.Caption:= Form1.Label3.Caption +   '  public and private keys: ' + IntToStr(endd - start);
  Form1.Label3.Caption := '';
end;


function checkIt() : int64;
var
  proizv: int64;
begin
  proizv := niceLongPow(s, eexp, n);
  Form1.Label6.Caption := IntToStr(proizv);
  Form1.Label6.Visible := True;
  Result:= proizv;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  b, c, d, z, index, llength: integer;
  a: Int64;
    // ��� ��������� �� ����� m
  currentM: integer;
    // ������� ��� ���������
  k, i: Cardinal;
  el, elements: integer;
  mesage: string;
  proizv : int64;
  f, f1 : TextFile;
  str : string;
begin
  maxInt64 := 9223372036854775807;
// 2^21 -1 ��� m^3 ������ ���� <= maxInt64
  maxM := 2097151;

  if not (Form1.Edit3.Text = '') then
  begin
    Val(Form1.Edit3.Text, hashCode, index);
    if (index <> 0) then
    begin
      hashCode := SDBM(Form1.Edit3.Text);
    end;
  end;

  Form1.Label3.Caption := '';

  Randomize();
  currentM := hashCode;
  if (hashCode > maxM) then
  begin
    k := 1;
    elements := 0;
    currentM := hashCode;
    while (currentM > maxM) do
    begin
      Inc(k);
      currentM := hashCode div k;
    end;
    SetLength(MArray, k);
    if ((maxM - currentM) > 100) then
    begin
      for i := 0 to k - 2 do
      begin
        el := currentM + (Random(200) - 100);
        elements := elements + el;
        MArray[i] := el;
      end;
    // ��������� �������
      MArray[k - 1] := hashCode - elements;
    end;

  end
// m < maxM
  else
  begin
    SetLength(MArray, 1);
    MArray[0] := hashCode;
  end;


  AssignFile(f, 'text.txt');
  Append(f);
  AssignFile(f1, 'bad.txt');
  Append(f1);

  z:= hashCode;
  for i := 1 to z do
  begin
    hashCode:= i;
    createSign(currentM);
    proizv := checkIt();
    str :=
    'm = ' + IntToStr(hashCode)
    + ' ; m` = ' + IntToStr(proizv)
    + ' ; p = ' + IntToStr(p)
    + ' ; q = ' + IntToStr(q)
    + ' ; n = ' + IntToStr(n)
    + ' ; eiler = ' + IntToStr(eiler)
    + ' ; eexp = ' + IntToStr(eexp)
    + ' ; dexp = ' + IntToStr(dexp);


    if (proizv = hashCode) then
    begin
     Writeln(f, str);
     //Break;
    end
    else
      Writeln(f1, str);
  end;

  CloseFile(f);
  CloseFile(f1);
end;

// http://www.cyberforum.ru/delphi-beginners/thread1116790.html

// �����:
// http://sumk.ulstu.ru/docs/mszki/Zavgorodnii/9.4.html

// ��������:
// http://teh-box.ru/informationsecurity/algoritm-shifrovaniya-rsa-na-palcax.html
// https://planetcalc.ru/3311/



procedure TForm1.Button2Click(Sender: TObject);
var
  mm, nn, x, y, g, dex: integer;
  z1: Int64;
  z2: Int64;
begin
  {}
  mm := StrToInt(Edit1.Text);
  nn := StrToInt(Edit2.Text);
  if (mm < 0) or (nn < 0) then
  begin
    ShowMessage('����� ������ ���� ������������');
    Exit;
  end;
  // 46390487073556736
  // 9222710978872688896
  {}
  //gcd_ext(mm, nn, x, y, g);
  //n := 144;
  //dex := longPow(10, 6);
  n := 9223372036854775807;
  z1 := pow(mm,nn) mod n;
  z2 := niceLongPow(mm,nn, n);


  Form1.Label6.Caption:= IntToStr(z1) + ' ' + IntToStr(z2);
  Form1.Label6.Visible:= True;
  {

  dex := (x mod n + n) mod n;
 // Form1.Label6.Caption := '  before first ' +  IntToStr(x) + '  before second   ' + IntToStr(y) + ' dex = ' + IntToStr(dex);
  Form1.Label6.Caption:= IntToStr(dex);
  Form1.Label6.Visible:= True;
  ShowMessage(Format('gcd(%d, %d) = %d', [m, n, g]) + #13#10 + Format('%d * %d %s %d * %d = %d', [x, m, Znak(y), Abs(y), n, g]));

  }
end;


// �������� �. �. ������������� ������� � ��������� �������� �������

procedure TForm1.Button3Click(Sender: TObject);
begin
checkIt();
end;
end.

