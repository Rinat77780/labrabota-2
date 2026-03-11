unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
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

implementation

{$R *.dfm}

// ========== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ==========
const
  a = 5;
  m = 4096;
var
  y: Integer;

// ========== ПРОЦЕДУРЫ ГЕНЕРАЦИИ ГАММЫ ==========
procedure RndInit;
begin
  y := 4003;  // Начальное значение Y0
end;

procedure Rnd(var Gamma: array of Byte);
var
  i: Integer;
begin
  // Генерируем 8 байт гаммы
  for i := 0 to 7 do
  begin
    y := (a * y) mod m;      // Yi = (5 * Yi-1) mod 4096
    Gamma[i] := y mod 256;    // Берем младший байт
  end;
end;

// ========== КНОПКА "ЗАШИФРОВАТЬ" ==========
procedure TForm1.Button1Click(Sender: TObject);
var
  SourceFile, CodedFile: TFileStream;
  TextBlock, GammaBlock: array[0..7] of Byte;
  BytesRead, i: Integer;
begin
  // Инициализируем генератор
  RndInit;

  // Открываем файлы
  try
    SourceFile := TFileStream.Create(Edit1.Text, fmOpenRead);
    CodedFile := TFileStream.Create(Edit2.Text, fmCreate);
  except
    ShowMessage('Ошибка открытия файлов! Проверьте, существует ли файл ' + Edit1.Text);
    Exit;
  end;

  // Читаем исходный файл блоками по 8 байт
  while SourceFile.Position < SourceFile.Size do
  begin
    // Генерируем гамму для этого блока
    Rnd(GammaBlock);

    // Читаем 8 байт из файла
    BytesRead := SourceFile.Read(TextBlock, 8);

    // Шифруем: XOR с гаммой
    for i := 0 to BytesRead - 1 do
      TextBlock[i] := TextBlock[i] xor GammaBlock[i];

    // Записываем зашифрованный блок
    CodedFile.Write(TextBlock, BytesRead);
  end;

  // Закрываем файлы
  SourceFile.Free;
  CodedFile.Free;

  ShowMessage('Файл успешно зашифрован!');
end;

// ========== КНОПКА "РАСШИФРОВАТЬ" ==========
procedure TForm1.Button2Click(Sender: TObject);
var
  CodedFile, DecodedFile: TFileStream;
  TextBlock, GammaBlock: array[0..7] of Byte;
  BytesRead, i: Integer;
begin
  // Инициализируем генератор (тем же значением!)
  RndInit;

  // Открываем файлы
  try
    CodedFile := TFileStream.Create(Edit2.Text, fmOpenRead);
    DecodedFile := TFileStream.Create(Edit3.Text, fmCreate);
  except
    ShowMessage('Ошибка открытия файлов! Проверьте, существует ли файл ' + Edit2.Text);
    Exit;
  end;

  // Читаем зашифрованный файл блоками
  while CodedFile.Position < CodedFile.Size do
  begin
    // Генерируем ТУ ЖЕ САМУЮ гамму
    Rnd(GammaBlock);

    // Читаем блок из зашифрованного файла
    BytesRead := CodedFile.Read(TextBlock, 8);

    // Расшифровываем: XOR с той же гаммой
    for i := 0 to BytesRead - 1 do
      TextBlock[i] := TextBlock[i] xor GammaBlock[i];

    // Записываем расшифрованный текст
    DecodedFile.Write(TextBlock, BytesRead);
  end;

  // Закрываем файлы
  CodedFile.Free;
  DecodedFile.Free;

  ShowMessage('Файл успешно расшифрован!');
end;

// ========== КНОПКА "ВЫХОД" ==========
procedure TForm1.Button3Click(Sender: TObject);
begin
  Close;
end;

end.
