#define MyAppBuildDir AddBackslash(SourcePath) + "..\..\build\windows\x64\runner\Release"
#define MyAppExeName "BetterBilibili.exe"
#define MyAppExe MyAppBuildDir + "\" + MyAppExeName

#if !FileExists(MyAppExe)
  #error "Flutter Release executable not found."
#endif

#define MyAppName GetStringFileInfo(MyAppExe, "ProductName")
#define MyAppVersion GetFileProductVersionString(MyAppExe)
#define MyAppFileVersion GetVersionNumbersString(MyAppExe)

#define MyAppPublisher "SmallZombie"
#define MyAppAUMID "SmallZombie.BetterBilibili"


[Setup]
AppId={{18D0D2AC-49C4-4F43-85B3-AE13B64BB036}

AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}

VersionInfoProductName={#MyAppName}
VersionInfoDescription={#MyAppName} Setup

VersionInfoVersion={#MyAppFileVersion}
VersionInfoProductVersion={#MyAppFileVersion}
VersionInfoProductTextVersion={#MyAppVersion}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

PrivilegesRequired=admin

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; 卸载信息
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}

SetupIconFile=..\runner\resources\app_icon.ico

; 显示许可证
LicenseFile=..\..\LICENSE

OutputDir=..\..\build\installer
OutputBaseFilename=BetterBilibiliSetup

; 压缩
Compression=lzma2
SolidCompression=yes

; 使用现代安装向导样式
WizardStyle=modern

; 修改协议关联后通知 Windows
ChangesAssociations=yes


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"


[Tasks]
; 桌面快捷方式
Name: "desktopicon"; \
    Description: "创建桌面快捷方式"; \
    GroupDescription: "附加快捷方式："; \
    Flags: unchecked


[Files]
Source: "{#MyAppBuildDir}\*"; \
    DestDir: "{app}"; \
    Flags: ignoreversion recursesubdirs createallsubdirs


[Icons]
; 开始菜单快捷方式
Name: "{autoprograms}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    WorkingDir: "{app}"; \
    AppUserModelID: "{#MyAppAUMID}"

; 桌面快捷方式
Name: "{autodesktop}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    WorkingDir: "{app}"; \
    AppUserModelID: "{#MyAppAUMID}"; \
    Tasks: desktopicon


[Registry]
; 注册 URI Scheme
Root: HKCR; \
    Subkey: "bilibili"; \
    ValueType: string; \
    ValueName: ""; \
    ValueData: "URL:Bilibili Protocol"; \
    Flags: uninsdeletekey

Root: HKCR; \
    Subkey: "bilibili"; \
    ValueType: string; \
    ValueName: "URL Protocol"; \
    ValueData: ""

Root: HKCR; \
    Subkey: "bilibili\DefaultIcon"; \
    ValueType: string; \
    ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"",0"

Root: HKCR; \
    Subkey: "bilibili\shell\open\command"; \
    ValueType: string; \
    ValueName: ""; \
    ValueData: """{app}\{#MyAppExeName}"" ""%1"""


[Run]
; runasoriginaluser: 避免安装程序以管理员权限启动应用
Filename: "{app}\{#MyAppExeName}"; \
    Description: "启动 {#MyAppName}"; \
    WorkingDir: "{app}"; \
    Flags: nowait postinstall skipifsilent runasoriginaluser
