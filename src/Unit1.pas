unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit2: TEdit;
    Label2: TLabel;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    Label1: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation

uses
  Math;

type
  SimpleArr = array [1..50] of integer;
var
  pathToOriginalFile : string;  


{$R *.dfm}


{
�������� ������ ���������� (���������� ���� ������� �����) �� ����� maxEl.
����� � ����� ����� ���������� ����������� � ������������ B 
}
procedure reshErat(maxEl : integer; var B : SimpleArr);
var
  A: array of boolean;
  n, x, y: integer;
begin
  SetLength(A, maxEl);
  A[1] := false;
  n := maxEl;
  for x := 2 to n do
    A[x] := true;
  for x := 2 to n div 2 do
    for y := 2 to n div x do
      A[x * y] := false;
  y := 1;
  // ���� �� ������������� �������� �����, ���� �� �������� B
  x:= n;
  while (y <= Length(B)) and (x > 0) do
  begin
    if A[x] then
    begin
      B[y] := x;
      inc(y);
    end;
    x := x-1;
  end;
end;

{
������� ������� �� integer � ������� ������ string (������ ��� �������������)
}
function ToBin(x: integer): string;
var
  res: string;
  d: 0..1;
begin
  res := '';
  while (x <> 0) do
  begin
    d := x mod 2;
    res := IntToStr(d) + res;
    x := x div 2;
  end;
  Result := res;
end;

{
������� ���������� � ������� �� ������  (��������)
(x^y mod n)
x - ���������
y - �������
n - ������
}
function modexp(x,y,n:int64):Int64;
var z, k : int64;
begin
  if (y = 0) then
    Result:= 1
  else
  begin
    k:= y;
    z := modexp(x, k div 2, n);
    if ((y mod 2) = 0) then
      Result:= (z*z) mod n
    else
      Result:= (x*z*z) mod n;
  end;
end;


// ����������� ������ ������� SDBM (�32) � ������� �������������� �� ���� �����
function SDBM(mess: string): integer;
var
  i: cardinal;
  hash: integer;
begin
  hash := 0;
  for i := 1 to Length(mess) do
    hash := ord(mess[i]) + (hash shl 6) + (hash shl 16) - hash;
  Result := hash;
end;

{
  ��� ����� �� ������������ ��������� ������� (��������)
  x - ��������� ��� a
  y - ��������� ��� b
  gcd - ��� �����
}
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


{
������� ���������� � ������� ��� ������������� ����� � ��������
base - ���������
up   - �������
}
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
        break;
      end;
    end;
  end;
end;

{
n - ������, ������������ ��������� ����� p � q
eiler -  ������� ������ �� n
minimalN - ����������� N, ������� ����� ����
(�� ������ ���� �� ������ ���-������� ��������� ���������)
eexp, dexp - �������� � �������� �����
}
procedure generateKeys(minimalN: integer; var n : Int64; var eexp : integer; var dexp : integer; B : SimpleArr);
var
  aa, bb, nod: integer;
  k1, k2, p, q  : Cardinal;
  eiler : int64;
begin
  Randomize();
  p := 0;
  q := 0;
  k1 := 0;
  k2 := 1;
  // ������������ ��������� ����� � ��������� �� minimalN �� minimalN * 50
  // ����� ������ ���� ������ �������
  while ((p = q) or (p = 0) or (q = 0) or (n < minimalN) or (n > minimalN * 50) or (k1 <> k2)) do
  begin
    // ����� ����� �� ������� � ����� ���������� ������ ����������
    p := RandomFrom(B);
    q := RandomFrom(B);
    k1 := Length(toBin(p));
    k2 := Length(toBin(q));
    if (k1 = k2) then
      n := p * q;
  end;
  // ������� ������ �� n
  eiler := (p - 1) * (q - 1);
  eexp := 1;
  nod := 0;

  // ������������ ��������� ����� e,
  // ���� ��� �� ������������ ��������� �������
  // ����� ����� � ������� ������ �� ����� 1 (����� ��� ������� �������)
  while (nod <> 1) do
  begin
    inc(eexp);
    gcd_ext(eexp, eiler, aa, bb, nod);
  end;
  // ��������� ���� d - �������� � ��������� ����� e �� ������ n
  // ����������� �� ������� (A mod E(n) + E(n)) mod E(n),
  // ��� A - ��������� � ��������� ����� �������� ������ e,
  // � E(n) - ������� ������ �� n
  dexp := (aa mod eiler + eiler) mod eiler;
end;

procedure createSign(minimalN: integer; var n : Int64; var eexp : integer; var dexp : integer);
var simpleNumbersArray : SimpleArr;
begin
  //SetLength(simpleNumbersArray, minimalN);

  // ������� ��������� ������ ����������, ������� ��� ������������ �������,
  // �������� �� minimalN
  // (10minN)^(1/2) ��������� ~ 3.16minN^(1/2)
  reshErat(Round(Sqrt(minimalN*10)), simpleNumbersArray);
  // ��������� n, � ����� �������� � �������� �����
  generateKeys(minimalN, n, eexp, dexp, simpleNumbersArray);
end;


{
������ ���� ���� [one;two], �������� �� ��� one � two
���� neg = True, �� [;one;two] - ��������� �� ��,
��� ����������� hashCode ��� �����������, ������������ � neg
}
procedure parsePair(str : string; var one : Int64; var two : int64; var neg : boolean);
var i : Cardinal;
    Ch: Char;
    s1, s2 : string;
    index : Integer;
begin
  i:= Length(str);

  Ch := '0';
  s1 := '';
  s2 := '';
  // ������ � �����
  while (Ch <> '}') do
  begin
    Ch := str[i];
    i := i - 1;
  end;

  if (i = 0) then
  begin
    one := 0;
    two := 0;
    neg := False;
  end;
  Ch := str[i];
  i := i - 1;
  while (Ch <> ';') do
  begin
    s2 := Ch + s2;
    Ch := str[i];
    i := i - 1;
  end;


  Ch := str[i];
  i := i - 1;
  while (Ch <> '{') do
  begin
    // ���������� ����
    if (Ch = ';') then
    begin
      neg := True;
      Break;
    end;
    s1 := ch + s1;
    Ch := str[i];
    i := i - 1;
  end;

  // �������� �������� �� ����� � int64
  Val(s1, one, index);
  if (index <> 0) then
  begin
    ShowMessage('One �� �����');
  end;
  Val(s2, two, index);
  if (index <> 0) then
  begin
    ShowMessage('Two �� �����');
  end;

end;



procedure generateRSA();
var
  f : TextFile;
  newFilePath, mesage, newMessage, str, partOneStr, partTwoStr, strHashCode : string;
  nextIndex, indexOfDot : Cardinal;
  s1, s2, dexp, eexp, hashCode, partOne, partTwo  : integer;
  HashNumber, n : Int64;
  TStrList : TStringList;
  isHashNegative : Boolean;

begin
  if (pathToOriginalFile = '') then
  begin
    ShowMessage('�������� ����');
    exit;
  end;
  partTwo:= 0;
  isHashNegative := False;

  TStrList := TStringList.Create;
  TStrList.LoadFromFile(pathToOriginalFile);
  mesage := TStrList.Text;
  TStrList.Free;
  hashCode := SDBM(mesage);


  if (hashCode < 0) then
  begin
    // ��������, ��� ��� ��� �������������
    isHashNegative:= True;
  end;
  // ��� �������� �������� � ������������� hash
  HashNumber:= Abs(hashCode);
  partOne:= HashNumber;
  partOneStr := IntToStr(HashNumber);

  // ��������� ������� ���� �� 2
  if (HashNumber > 200000) then
  begin
    // ������� �� 2 ����� �������
    strHashCode:= IntToStr(HashNumber);
    nextIndex:= (Length(strHashCode) div 2) + 1;

    // 1 �� nextIndex-1
    partOneStr := copy(strHashCode, 1, nextIndex-1);
    partOne:= StrToInt(partOneStr);

    // �� nextIndex �� �����
    partTwoStr := copy(strHashCode, nextIndex, Length(strHashCode)-nextIndex+1);
    partTwo:= StrToInt(partTwoStr);
  end;


  // ��������� ����� �� ����������� �� 2� ��������
  createSign(Max(partOne, partTwo), n, eexp, dexp);

  // openedKey.txt
  str := '{' +IntToStr(eexp)+';'+IntToStr(n) + '}';
  AssignFile(f, 'openedKey.txt');
  Rewrite(f);
  Append(f);
  Writeln(f, str);
  CloseFile(f);

  // closedKey.txt
  str := '{'+IntToStr(dexp)+';'+IntToStr(n)+'}';
  AssignFile(f, 'closedKey.txt');
  Rewrite(f);
  Append(f);
  Writeln(f, str);
  CloseFile(f);

  // RSA.txt
  // ��������� �������� �������
  s1:= modexp(partOne, dexp, n);
  s2:= modexp(partTwo, dexp, n);
  str := '{';
  if (isHashNegative) then
    str := '{;';
  // ��������� ���� ������ {dexp;n}
  str := str+IntToStr(s1)+';'+IntToStr(s2)+'}';
  // ������� ����� (����� ����������� �����)
  indexOfDot := Pos('.', pathToOriginalFile);

  //from, to-from+1 (inclusively)
  newFilePath :=
  Copy(pathToOriginalFile, 1, indexOfDot-1-1+1)
    + '_copy'
    + Copy(pathToOriginalFile, indexOfDot, Length(pathToOriginalFile)-indexOfDot+1);

  newMessage := mesage + str;
  AssignFile(f, newFilePath);
  Rewrite(f);
  Append(f);
  Write(f, newMessage);
  CloseFile(f);

  ShowMessage('����������� ������� ������������! '
  + ' ���� � ����������� ������ �� ���� ' + newFilePath);
end;


procedure checkDoc();
var e, n, hashPart1, hashPart2 : int64;
    indexer, hashLen : cardinal;
    hashCode, h1, h2, hsum, proizv1, proizv2 : integer;
    ne, neg : Boolean;
    TStrList : TStringList;
    mesage, mes, openKeyString : string;
begin
  if (pathToOriginalFile = '') then
  begin
    ShowMessage('�������� ����');
    exit;
  end;
  if (Length(Form1.Edit2.Text) < 1) then
  begin
    showMessage('������� �������� ����');
    exit;
  end;
  openKeyString := Form1.Edit2.Text;
  if (openKeyString[Length(openKeyString)] <> '}') or (openKeyString[1] <> '{') then
  begin
    showMessage('���� �� ������������ �������');
    exit;
  end;

  hashPart1 := 0;
  hashPart2 := 0;
  e := 0;
  n := 0;
  neg := False;

  TStrList := TStringList.Create;
  TStrList.LoadFromFile(pathToOriginalFile);
  mesage := TStrList.Text;
  TStrList.Free;

  if (mesage = '') then
  begin
    ShowMessage('���� ����');
    exit;
  end;
  parsePair(mesage, hashPart1, hashPart2, neg);
  indexer := Length(mesage) - (Length(IntToStr(hashPart1)) + Length(IntToStr(hashPart2)) + 4);
  if (neg) then
  indexer := indexer - 1;

  mes := Copy(mesage, 1, indexer-1-1+1);
  hashCode := SDBM(mes);

  parsePair(openKeyString, e, n, ne);
  // ������������ ��������
  if (e = 0) then
    Exit;
  proizv1 := modexp(hashPart1, e, n);
  proizv2 := modexp(hashPart2, e, n);

  hashLen := Length(IntToStr(hashCode));
  if (hashCode < 0) then
    dec(hashLen);
  h1 := proizv1 * pow(10, hashLen - Length(IntToStr(proizv1)));
  h2 := proizv2;
  hsum := h1 + h2;
  if (neg) then
    hsum := -hsum;
  if (hsum = hashCode) then
    ShowMessage('�������� ���������')
  else
    ShowMessage('�������� �� ���������');
end;

procedure chooseFile();
begin
 if Form1.OpenDialog1.Execute then
 begin
   pathToOriginalFile := Form1.OpenDialog1.FileName;
   Form1.Label1.Caption:= '������ ����';
   Form1.Label3.Caption:= pathToOriginalFile;
 end;
end;

{
�������� ����������-�������� ������� RSA ��� ���������� �����
}
procedure TForm1.Button1Click(Sender: TObject);
begin
  generateRSA();
end;

{
�������� ����������-�������� ������� RSA ��� ���������� �����
}
procedure TForm1.Button2Click(Sender: TObject);
begin
  checkDoc();
end;


{
����� ����� �� OpenDialog
}
procedure TForm1.Button3Click(Sender: TObject);
begin
 chooseFile();
end;



// ������� �������
procedure TForm1.N2Click(Sender: TObject);
begin
  Button1.Visible:=True;
  Button3.Visible:=True;
  Button2.Visible:=False;
  Label2.Visible:=False;
  Edit2.Visible:=False;

end;

// ��������� ��. �������
procedure TForm1.N3Click(Sender: TObject);
begin
  Button2.Visible:=True;
  Button3.Visible:=True;
  Label2.Visible:=True;
  Edit2.Visible:=True;
  Button1.Visible:=False;
end;

// �����
procedure TForm1.N4Click(Sender: TObject);
begin
  Close;
end;


end.

