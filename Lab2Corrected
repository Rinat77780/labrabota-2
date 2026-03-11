program Project2;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows;

const
  // Алфавит: 32 символа (А-Я + пробел, Й=И, Ё=Е)
  ALPHABET: string = 'АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ ';
  LOWERCASE_ALPHABET: string = 'абвгдежзиклмнопрстуфхцчшщъыьэюя ';

// Функция для шифрования/дешифрования текста с сохранением регистра
function CaesarTransform(const inputText: string; shift: Integer; decrypt: Boolean): string;
var
  i, idx, newPos: Integer;
  c: Char;
  isLowerCase: Boolean;
begin
  Result := '';

  // Если дешифровка - меняем знак сдвига
  if decrypt then
    shift := -shift;

  for i := 1 to Length(inputText) do
  begin
    c := inputText[i];
    isLowerCase := False;

    // Определяем регистр символа
    if (c >= 'а') and (c <= 'я') or (c = 'ё') or (c = 'й') or (c = ' ') then
      isLowerCase := True
    else if (c >= 'А') and (c <= 'Я') or (c = 'Ё') or (c = 'Й') or (c = ' ') then
      isLowerCase := False
    else
    begin
      // Если символ не из русского алфавита - оставляем как есть
      Result := Result + c;
      Continue;
    end;

    // Ищем позицию символа в соответствующем алфавите
    idx := 0;

    // Обработка специальных случаев для верхнего регистра
    if not isLowerCase then
    begin
      if c = ' ' then
        idx := 32  // пробел - последний символ
      else if c = 'Ё' then
        idx := 6   // Ё заменяем на Е (позиция 6)
      else if c = 'Й' then
        idx := 9   // Й заменяем на И (позиция 9)
      else
      begin
        // Ищем букву в алфавите верхнего регистра
        for idx := 1 to 32 do
          if ALPHABET[idx] = c then
            Break;
        // Если не нашли, idx станет 33
        if idx > 32 then
          idx := 0;
      end;
    end
    // Обработка специальных случаев для нижнего регистра
    else
    begin
      if c = ' ' then
        idx := 32  // пробел - последний символ
      else if c = 'ё' then
        idx := 6   // ё заменяем на е (позиция 6)
      else if c = 'й' then
        idx := 9   // й заменяем на и (позиция 9)
      else
      begin
        // Ищем букву в алфавите нижнего регистра
        for idx := 1 to 32 do
          if LOWERCASE_ALPHABET[idx] = c then
            Break;
        // Если не нашли, idx станет 33
        if idx > 32 then
          idx := 0;
      end;
    end;

    // Если символ найден в алфавите
    if idx > 0 then
    begin
      // Вычисляем новую позицию с учетом сдвига и размера алфавита (32)
      newPos := ((idx - 1 + shift) mod 32 + 32) mod 32 + 1;

      // Добавляем символ в соответствующем регистре
      if isLowerCase then
        Result := Result + LOWERCASE_ALPHABET[newPos]
      else
        Result := Result + ALPHABET[newPos];
    end
    else
    begin
      // Если символ не из алфавита - оставляем как есть
      Result := Result + c;
    end;
  end;
end;

// Функция для шифрования файла
procedure EncryptFile(const inputFile, outputFile: string; shift: Integer);
var
  fIn, fOut: TextFile;
  line, encryptedLine: string;
begin
  AssignFile(fIn, inputFile);
  AssignFile(fOut, outputFile);

  try
    Reset(fIn);
    Rewrite(fOut);

    while not Eof(fIn) do
    begin
      ReadLn(fIn, line);
      encryptedLine := CaesarTransform(line, shift, False);
      WriteLn(fOut, encryptedLine);
    end;

    CloseFile(fIn);
    CloseFile(fOut);

    Writeln('Файл успешно зашифрован!');
  except
    on E: Exception do
      Writeln('Ошибка при работе с файлом: ', E.Message);
  end;
end;

// Функция для дешифрования файла
procedure DecryptFile(const inputFile, outputFile: string; shift: Integer);
var
  fIn, fOut: TextFile;
  line, decryptedLine: string;
begin
  AssignFile(fIn, inputFile);
  AssignFile(fOut, outputFile);

  try
    Reset(fIn);
    Rewrite(fOut);

    while not Eof(fIn) do
    begin
      ReadLn(fIn, line);
      decryptedLine := CaesarTransform(line, shift, True);
      WriteLn(fOut, decryptedLine);
    end;

    CloseFile(fIn);
    CloseFile(fOut);

    Writeln('Файл успешно расшифрован!');
  except
    on E: Exception do
      Writeln('Ошибка при работе с файлом: ', E.Message);
  end;
end;

var
  choice: Integer;
  inputText, outputText: string;
  shift: Integer;
  inputFile, outputFile: string;
begin
  // Устанавливаем кодировку для консоли
  SetConsoleCP(1251);      // Для ввода
  SetConsoleOutputCP(1251); // Для вывода

  repeat
    Writeln('=======================================');
    Writeln('  ШИФР ЦЕЗАРЯ (лабораторная работа №2)');
    Writeln('=======================================');
    Writeln('1. Шифрование текста');
    Writeln('2. Дешифрование текста');
    Writeln('3. Шифрование файла');
    Writeln('4. Дешифрование файла');
    Writeln('0. Выход');
    Writeln;
    Write('Выбор: ');
    ReadLn(choice);

    case choice of
      0: Break;

      1: begin
           Write('Введите текст для шифрования: ');
           ReadLn(inputText);
           Write('Введите сдвиг (1-31): ');
           ReadLn(shift);

           // Проверка сдвига
           shift := shift mod 32;
           if shift < 1 then shift := 1;

           outputText := CaesarTransform(inputText, shift, False);
           Writeln;
           Writeln('Исходный текст: ', inputText);
           Writeln('Зашифрованный:  ', outputText);

           // Покажем дешифровку для проверки
           Writeln('Проверка (расшифр.): ', CaesarTransform(outputText, shift, True));
         end;

      2: begin
           Write('Введите текст для дешифрования: ');
           ReadLn(inputText);
           Write('Введите сдвиг (1-31): ');
           ReadLn(shift);

           shift := shift mod 32;
           if shift < 1 then shift := 1;

           outputText := CaesarTransform(inputText, shift, True);
           Writeln;
           Writeln('Шифрованный текст: ', inputText);
           Writeln('Расшифрованный:    ', outputText);
         end;

      3: begin
           Write('Введите имя входного файла: ');
           ReadLn(inputFile);
           Write('Введите имя выходного файла: ');
           ReadLn(outputFile);
           Write('Введите сдвиг (1-31): ');
           ReadLn(shift);

           shift := shift mod 32;
           if shift < 1 then shift := 1;

           EncryptFile(inputFile, outputFile, shift);
         end;

      4: begin
           Write('Введите имя входного файла: ');
           ReadLn(inputFile);
           Write('Введите имя выходного файла: ');
           ReadLn(outputFile);
           Write('Введите сдвиг (1-31): ');
           ReadLn(shift);

           shift := shift mod 32;
           if shift < 1 then shift := 1;

           DecryptFile(inputFile, outputFile, shift);
         end;
    else
      Writeln('Неверный выбор!');
    end;

    if choice <> 0 then
    begin
      Writeln;
      Write('Нажмите Enter для продолжения...');
      ReadLn;
    end;

  until choice = 0;
end.
