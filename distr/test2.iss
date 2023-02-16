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

[Run]
Filename: "powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -File ""{app}\tmp\copy.ps1"""; \
  WorkingDir: {app}; Flags: runhidden
Filename: "powershell.exe"; \
  Parameters: "-ExecutionPolicy Bypass -File ""{app}\tmp\iis.ps1"""; \
  WorkingDir: {app}; Flags: runhidden

[Code]
var
  //UserPage: TInputQueryWizardPage;
  //UsagePage: TInputOptionWizardPage;
  WebServicePage: TInputOptionWizardPage;
  ProtocolPage: TInputOptionWizardPage;
  //LightMsgPage: TOutputMsgWizardPage;
  IISMsgPage: TInputQueryWizardPage;
  NginxMsgPage: TInputQueryWizardPage;
  //KeyPage: TInputQueryWizardPage;
  //ProgressPage: TOutputProgressWizardPage;
  NginxDirPage: TInputDirWizardPage;
  IISCertPage: TInputFileWizardPage;
  IISFileLicLocation: String;
  NginxCertPage: TInputFileWizardPage;
  NginxFileLicLocation: String;
  currentDir: string;
  webServiceType: string;
  isIIS: Boolean;
  IISIndex: Integer; // will be 0
  NginxIndex: Integer; // will be 1

procedure InitializeWizard;
begin
  { Create the pages }
  currentDir := GetCurrentDir;
  WebServicePage := CreateInputOptionPage(wpWelcome,
    'Выберите используемый Web сервис', 'Тут информация',
    'Тут тоже информация',
    True, False);

  WebServicePage.Add('IIS');
  WebServicePage.Add('Nginx');
  // Set initial values (optional)
  WebServicePage.Values[0] := True;
  //WebServicePage.Values[1] := False;

  isIIS := WebServicePage.Values[0];
  if isIIS then begin
     webServiceType := 'IIS';
  end
  else begin
    webServiceType := 'Nginx';
  end;

  IISMsgPage := CreateInputQueryPage(WebServicePage.ID, 
    'Введите данные для подключения к IIS', 
    IntToStr(WebServicePage.SelectedValueIndex), 
    webServiceType);
  IISMsgPage.Add('FQDN:', False);
  IISMsgPage.Add('Номер порта:', False);
  //IISMsgPage.Add('Протокол (https/http):', False);
  IISMsgPage.Add('Application pool:', False);

  // Create the page
  IISCertPage := CreateInputFilePage(IISMsgPage.ID,
    'Выберите директорию', 'Тут информация',
    'Выберите директорию файл сертификата и нажмите Next.');

  // Add item
  IISCertPage.Add('&Location of certificate:',      // caption
    '*.pfx|*.pfx|All files|*.*',                    // filters
    '.pfx');                                        // default extension

  NginxMsgPage := CreateInputQueryPage(WebServicePage.ID, 
    'Введите данные для подключения к Nginx', 
    IntToStr(WebServicePage.SelectedValueIndex), 
    webServiceType);
  
  NginxMsgPage.Add('Номер порта:', False);
  //NginxMsgPage.Add('Тут надо запилить выбор расположения Nginx (каталог):', False);
  //NginxMsgPage.Add('Тут надо запилить выбор файла сертификата:', False);


  //блок не нужен
  ProtocolPage := CreateInputOptionPage(IISMsgPage.ID,
    'Введите данные для подключения к IIS', 'Тут тоже информация',
    'Выберите используемый протокол',
    True, False);
  ProtocolPage.Add('https');
  ProtocolPage.Add('http');

  NginxDirPage := CreateInputDirPage(NginxMsgPage.ID,
    'Введите данные для подключения к Nginx', 'Тут тоже информация',
    'Выберите директорию расположения Nginx',
    False, '');
  NginxDirPage.Add('');

    // Create the page
  NginxCertPage := CreateInputFilePage(NginxDirPage.ID,
    'Выберите директорию', 'Тут информация',
    'Выберите директорию файл сертификата и нажмите Next.');

  // Add item
  NginxCertPage.Add('&Location of certificate:',      // caption
    '*.pfx|*.pfx|All files|*.*',                    // filters
    '.pfx');                                        // default extension

  { Set default values, using settings that were stored last time if possible }
  IISMsgPage.Values[0] := GetPreviousData('FQDN', ExpandConstant('primo.orch.local'));
  IISMsgPage.Values[1] := GetPreviousData('Номер порта:', ExpandConstant('80'));
  NginxMsgPage.Values[0] := GetPreviousData('Номер порта:', ExpandConstant('80'));

  //case GetPreviousData('UsageMode', '') of
  //  'IIS': WebServicePage.SelectedValueIndex := 0;
  //  'Nginx': WebServicePage.SelectedValueIndex := 1;
  //else
  //  WebServicePage.SelectedValueIndex := 1;
  //end;

  case GetPreviousData('ProtocolMode', '') of
    'https': ProtocolPage.SelectedValueIndex := 0;
    'http': ProtocolPage.SelectedValueIndex := 1;
  else
    ProtocolPage.SelectedValueIndex := 1;
  end;

end;

//procedure RegisterPreviousData(PreviousDataKey: Integer);
//var
//  UsageMode: String;
//  ProtocolMode: String;
//begin
  { Store the settings so we can restore them next time }
//  SetPreviousData(PreviousDataKey, 'FQDN', IISMsgPage.Values[0]);
//  SetPreviousData(PreviousDataKey, 'Номер порта:', IISMsgPage.Values[1]);
//  case WebServicePage.SelectedValueIndex of
//    0: UsageMode := 'IIS';
//    1: UsageMode := 'Nginx';
//  end;
//  SetPreviousData(PreviousDataKey, 'Номер порта:', NginxMsgPage.Values[0]);
//  SetPreviousData(PreviousDataKey, 'ProtocolMode', ProtocolMode);
//  case ProtocolPage.SelectedValueIndex of
//    0: ProtocolMode := 'https';
//    1: ProtocolMode := 'http';
//  end;
//  SetPreviousData(PreviousDataKey, 'UsageMode', UsageMode);
//  SetPreviousData(PreviousDataKey, 'ProtocolMode', ProtocolMode);
//end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  { Skip pages that shouldn't be shown }
  if (PageID = IISMsgPage.ID) and (WebServicePage.SelectedValueIndex <> 0) then
    Result := True
  else if (PageID = NginxMsgPage.ID) and (WebServicePage.SelectedValueIndex <> 1) then
    Result := True
  else if (PageID = ProtocolPage.ID) and (WebServicePage.SelectedValueIndex <> 0) then
    Result := True
  else if (PageID = NginxDirPage.ID) and (WebServicePage.SelectedValueIndex <> 1) then
    Result := True
  else if (PageID = IISCertPage.ID) and (WebServicePage.SelectedValueIndex <> 0) then
    Result := True
  else if (PageID = NginxCertPage.ID) and (WebServicePage.SelectedValueIndex <> 1) then
    Result := True
  else
    Result := False;
end;