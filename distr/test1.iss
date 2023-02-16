[Setup]
AppName=Primo.Orchestrator
AppVersion=2.2.25.0
WizardStyle=modern
DisableWelcomePage=no
DefaultDirName={autopf}\PrimoOrchestrator
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\PrimoOrchestrator.exe
OutputDir=userdocs:Inno Setup Examples Output
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: rus; MessagesFile: compiler:Languages\Russian.isl

[Files]
Source: "copy.ps1"; DestDir: "{app}\tmp"
Source: "iis.ps1"; DestDir: "{app}\tmp"
//Source: "testps.ps1"; DestDir: "{app}\tmp"

[Run]
Filename: "powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -File ""{app}\tmp\copy.ps1"""; \
  WorkingDir: {app}; Flags: runhidden
Filename: "powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -File ""{app}\tmp\iis.ps1"" {code:GetWebServiceType} {code:GetCertPwd} {code:GetCertPath}"; \
  WorkingDir: {app}; Flags: runhidden;

  //разобраться как устанавливать компоненты!!!!!
[Code]
var
  WebServicePage: TInputOptionWizardPage;
  ProtocolPage: TInputOptionWizardPage;
  IISMsgPage: TInputQueryWizardPage;
  IISCertPwdPage: TInputQueryWizardPage;
  NginxMsgPage: TInputQueryWizardPage;
  NginxDirPage: TInputDirWizardPage;
  IISCertPage: TInputFileWizardPage;
  IISFileLicLocation: String;
  NginxCertPage: TInputFileWizardPage;
  NginxFileLicLocation: String;
  currentDir: string;

procedure InitializeWizard;
begin
  currentDir := GetCurrentDir;
  { создаем страницу выбора используемого web-сервиса }
  WebServicePage := CreateInputOptionPage(wpWelcome,
    'Выберите используемый Web сервис', 'Тут информация',
    'Тут тоже информация',
    True, False);
  WebServicePage.Add('IIS');
  WebServicePage.Add('Nginx');

  { создаем страницу выбора сертификата IIS }
  IISCertPage := CreateInputFilePage(WebServicePage.ID,
    'Выберите директорию', 'Тут информация',
    'Выберите файл сертификата и нажмите Next.');
  IISCertPage.Add('&Location of certificate:',      // caption
    '*.pfx|*.pfx|All files|*.*',                    // filters
    '.pfx');                                        // default extension

  // тут нужно создать страницу для ввода пароля на сертификат !!!
  IISCertPwdPage := CreateInputQueryPage(IISCertPage.ID, 
    'Введите пароль от сертификата', 
    'Тут информация', 
    'Тут тоже информация');
  IISCertPwdPage.Add('Введите пароль:', False);

  { создаем страницу для подключения к Nginx }
  NginxMsgPage := CreateInputQueryPage(WebServicePage.ID, 
    'Введите данные для подключения к Nginx', 
    'Тут информация', 
    'Тут тоже информация');
  NginxMsgPage.Add('Номер порта:', False);
  NginxMsgPage.Add('Тут надо запилить выбор расположения Nginx (каталог):', False);
  NginxMsgPage.Add('Тут надо запилить выбор файла сертификата:', False);
  
  { создаем страницу выбора директории Nginx }
  NginxDirPage := CreateInputDirPage(NginxMsgPage.ID,
    'Введите данные для подключения к Nginx', 'Тут тоже информация',
    'Выберите директорию расположения Nginx',
    False, '');
  NginxDirPage.Add('');

  { создаем страницу выбора сертификата Nginx }
  NginxCertPage := CreateInputFilePage(NginxDirPage.ID,
    'Выберите директорию', 'Тут информация',
    'Выберите директорию файл сертификата и нажмите Next.');
  NginxCertPage.Add('&Location of certificate:',      // caption
    '*.pfx|*.pfx|All files|*.*',                    // filters
    '.pfx');                                        // default extension

  { Set default values, using settings that were stored last time if possible }
  NginxMsgPage.Values[0] := GetPreviousData('Номер порта:', ExpandConstant('80'));

  case GetPreviousData('UsageMode', '') of
    'IIS': WebServicePage.SelectedValueIndex := 0;
    'Nginx': WebServicePage.SelectedValueIndex := 1;
  else
    WebServicePage.SelectedValueIndex := 1;
  end;

end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
var
  UsageMode: String;
  ProtocolMode: String;
begin
  { Store the settings so we can restore them next time }
  case WebServicePage.SelectedValueIndex of
    0: UsageMode := 'IIS';
    1: UsageMode := 'Nginx';
  end;
  SetPreviousData(PreviousDataKey, 'Номер порта:', NginxMsgPage.Values[0]);
  SetPreviousData(PreviousDataKey, 'UsageMode', UsageMode);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  { Skip pages that shouldn't be shown }
  if (PageID = IISCertPage.ID) and (WebServicePage.SelectedValueIndex <> 0) then
    Result := True
  else if (PageID = NginxMsgPage.ID) and (WebServicePage.SelectedValueIndex <> 1) then
    Result := True
  else if (PageID = NginxDirPage.ID) and (WebServicePage.SelectedValueIndex <> 1) then
    Result := True
  else if (PageID = IISCertPwdPage.ID) and (WebServicePage.SelectedValueIndex <> 0) then
    Result := True
  else if (PageID = NginxCertPage.ID) and (WebServicePage.SelectedValueIndex <> 1) then
    Result := True
  else
    Result := False;
end;

{ функция для определения типа web сервиса, передается в ps скрипт }
function GetWebServiceType(Value: string): string;
begin
  if WebServicePage.SelectedValueIndex = 0 then begin
    Result := 'IIS';
  end
  else begin
    Result := 'Nginx';
  end;
end;

{ функция для определения определения пароля сертификата, передается в ps скрипт }
function GetCertPwd(Value: string): string;
begin
  Result := IISCertPwdPage.Values[0];
end;

{ функция для определения определения пароля сертификата, передается в ps скрипт }
function GetCertPath(Value: string): string;
begin
  Result := IISCertPage.Values[0];
end;

