unit project6;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    EditPassword: TEdit;
    Label1: TLabel;
    LabelStatus: TLabel;
    ButtonEncrypt: TButton;
    ButtonDecrypt: TButton;
    ButtonExit: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;

    // Объявляем процедуры для кнопок
    procedure ButtonEncryptClick(Sender: TObject);
    procedure ButtonDecryptClick(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);

  private
    { Приватные методы }
    function Coding(C: Char; Key: string): Char;
    function Decoding(C: Char; Key: string): Char;
    procedure AddPassword(Key: string; var F: TFileStream);
    function CheckPassword(Key: string; var F: TFileStream): Boolean;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

// Функция шифрования (XOR)
function TForm1.Coding(C: Char; Key: string): Char;
var
  i: Integer;
  KeyByte: Byte;
begin
  KeyByte := 0;
  for i := 1 to Length(Key) do
    KeyByte := KeyByte xor Ord(Key[i]);
  Result := Char(Ord(C) xor KeyByte);
end;

// Функция дешифрования (такая же как шифрование)
function TForm1.Decoding(C: Char; Key: string): Char;
begin
  Result := Coding(C, Key);
end;

// Добавление зашифрованного пароля в начало файла
procedure TForm1.AddPassword(Key: string; var F: TFileStream);
var
  i: Integer;
  C: Char;
  Buffer: array of Byte;
begin
  SetLength(Buffer, Length(Key));
  for i := 1 to Length(Key) do
  begin
    C := Coding(Key[i], Key);
    Buffer[i-1] := Ord(C);
  end;
  F.Write(Buffer[0], Length(Key));
end;

// Проверка пароля при расшифровании
function TForm1.CheckPassword(Key: string; var F: TFileStream): Boolean;
var
  i: Integer;
  S: string;
  C: Char;
  Buffer: array of Byte;
begin
  Result := False;

  if Length(Key) = 0 then
  begin
    ShowMessage('Пароль не может быть пустым!');
    Exit;
  end;

  SetLength(S, Length(Key));
  SetLength(Buffer, Length(Key));

  try
    F.Read(Buffer[0], Length(Key));
  except
    ShowMessage('Ошибка чтения файла! Возможно файл поврежден.');
    Exit;
  end;

  for i := 1 to Length(Key) do
  begin
    C := Char(Buffer[i-1]);
    S[i] := Decoding(C, Key);
  end;

  Result := True;
  for i := 1 to Length(Key) do
  begin
    if S[i] <> Key[i] then
    begin
      Result := False;
      Break;
    end;
  end;
end;

// Кнопка "Зашифровать файл"
procedure TForm1.ButtonEncryptClick(Sender: TObject);
var
  SourceStream, DestStream: TFileStream;
  Key: string;
  Buffer: array[0..1023] of Byte;
  BytesRead: Integer;
  i: Integer;
begin
  // Получаем пароль
  Key := EditPassword.Text;

  // Проверяем пароль
  if Key = '' then
  begin
    ShowMessage('Введите пароль!');
    Exit;
  end;

  // Настраиваем диалог открытия файла
  OpenDialog1.Title := 'Выберите файл для шифрования';
  OpenDialog1.Filter := 'Все файлы|*.*';
  OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0)); // Папка программы

  // Показываем диалог выбора файла
  if not OpenDialog1.Execute then
  begin
    ShowMessage('Выбор файла отменен');
    Exit;
  end;

  // Настраиваем диалог сохранения
  SaveDialog1.Title := 'Сохранить зашифрованный файл';
  SaveDialog1.FileName := 'encrypted_' + ExtractFileName(OpenDialog1.FileName);
  SaveDialog1.Filter := 'Все файлы|*.*';
  SaveDialog1.InitialDir := ExtractFilePath(ParamStr(0));

  if not SaveDialog1.Execute then
  begin
    ShowMessage('Сохранение отменено');
    Exit;
  end;

  try
    // Открываем исходный файл
    SourceStream := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);

    // Создаем файл для шифрования
    DestStream := TFileStream.Create(SaveDialog1.FileName, fmCreate);

    // Добавляем зашифрованный пароль
    AddPassword(Key, DestStream);

    // Шифруем данные
    while True do
    begin
      BytesRead := SourceStream.Read(Buffer, SizeOf(Buffer));
      if BytesRead = 0 then Break;

      for i := 0 to BytesRead - 1 do
        Buffer[i] := Ord(Coding(Char(Buffer[i]), Key));

      DestStream.Write(Buffer, BytesRead);
    end;

    LabelStatus.Caption := 'Файл успешно зашифрован!';
    ShowMessage('Шифрование завершено!');

  except
    on E: Exception do
      ShowMessage('Ошибка: ' + E.Message);
  end;

  // Освобождаем ресурсы
  SourceStream.Free;
  DestStream.Free;
end;

// Кнопка "Расшифровать файл"
procedure TForm1.ButtonDecryptClick(Sender: TObject);
var
  SourceStream, DestStream: TFileStream;
  Key: string;
  Buffer: array[0..1023] of Byte;
  BytesRead: Integer;
  i: Integer;
begin
  // Получаем пароль
  Key := EditPassword.Text;

  // Проверяем пароль
  if Key = '' then
  begin
    ShowMessage('Введите пароль!');
    Exit;
  end;

  // Настраиваем диалог открытия файла
  OpenDialog1.Title := 'Выберите зашифрованный файл';
  OpenDialog1.Filter := 'Все файлы|*.*';
  OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));

  if not OpenDialog1.Execute then
  begin
    ShowMessage('Выбор файла отменен');
    Exit;
  end;

  // Настраиваем диалог сохранения
  SaveDialog1.Title := 'Сохранить расшифрованный файл';
  SaveDialog1.FileName := 'decrypted_' + ExtractFileName(OpenDialog1.FileName);
  SaveDialog1.Filter := 'Все файлы|*.*';
  SaveDialog1.InitialDir := ExtractFilePath(ParamStr(0));

  if not SaveDialog1.Execute then
  begin
    ShowMessage('Сохранение отменено');
    Exit;
  end;

  try
    // Открываем зашифрованный файл
    SourceStream := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);

    // Проверяем пароль
    if not CheckPassword(Key, SourceStream) then
    begin
      LabelStatus.Caption := 'Ошибка: Неправильный пароль!';
      ShowMessage('Неправильный пароль! Файл не может быть расшифрован.');
      SourceStream.Free;
      Exit;
    end;

    // Создаем файл для расшифровки
    DestStream := TFileStream.Create(SaveDialog1.FileName, fmCreate);

    // Пропускаем пароль
    SourceStream.Position := Length(Key);

    // Расшифровываем данные
    while True do
    begin
      BytesRead := SourceStream.Read(Buffer, SizeOf(Buffer));
      if BytesRead = 0 then Break;

      for i := 0 to BytesRead - 1 do
        Buffer[i] := Ord(Decoding(Char(Buffer[i]), Key));

      DestStream.Write(Buffer, BytesRead);
    end;

    LabelStatus.Caption := 'Файл успешно расшифрован!';
    ShowMessage('Расшифрование завершено!');

  except
    on E: Exception do
      ShowMessage('Ошибка: ' + E.Message);
  end;

  // Освобождаем ресурсы
  SourceStream.Free;
  DestStream.Free;
end;

// Кнопка "Выход"
procedure TForm1.ButtonExitClick(Sender: TObject);
begin
  Close;
end;

end.
