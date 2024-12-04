'============================== The Beginning of the Copyright Notice =================================
' THE AULIX.COMMON7 LIBRARY SOFTWARE PRODUCT
' The AUTHOR of this file is Alexander Borisovich Prokopyev, Kurgan, Russia
' More info can be found at the AUTHOR's website: http://www.aulix.com/resume
' Contact: alexander.prokopyev at aulix dot com
' 
' Copyright (c) Alexander Prokopyev, 2006-2013
' 
' All materials contained in this file are protected by copyright law.
' Nobody except the AUTHOR may alter or remove this copyright notice from copies of the content.
' 
' The AUTHOR explicitly prohibits to use this content by any method without a prior 
' written hand-signed permission of the AUTHOR. 
'================================= The End of the Copyright Notice ====================================
Imports Nini.Config

Public Module AulixDeclarations2
    Function UseTemplate(ByVal TemplateText As String, ByVal ParamArray PA() As String) As String
        UseTemplate = TemplateText
        Dim I As Long
        If Not IsNothing(PA) Then
            For I = LBound(PA) To UBound(PA) Step 2
                UseTemplate = Replace(UseTemplate, "<%=" & CStr(PA(I)) & "%>", NZ(PA(I + 1)))
            Next
        End If
    End Function

    Function RandomString(ByVal length As Long, Optional ByVal StartCode As Long = 65, Optional ByVal EndCode As Long = 90) As String
        Randomize()
        Dim I As Long, Dif As Long : Dif = EndCode - StartCode
        For I = 1 To length
            RandomString = RandomString & Chr(StartCode + Dif * Rnd())
        Next
    End Function

End Module

Public Class ParameterString

    Public Class ParameterPair
        Public Name As String
        Public Value As String
    End Class

    Public Delimiter, PairDelimiter As String, Count As Long
    Private Parameters() As ParameterPair

    Sub New(ByVal PS As String, Optional ByVal D As String = " ", Optional ByVal PairDelimiter_ As String = "=")
        PairDelimiter = PairDelimiter_
        Delimiter = D
        Parse(PS)
    End Sub

    Function Parse(ByVal PS As String)
        Dim I As Long
        Dim PairsArray() As String = Split(PS, Delimiter)

        Count = UBound(PairsArray) + 1
        ReDim Parameters(Count)
        For I = 0 To Count
            Parameters(I) = New ParameterPair
        Next
        Parameters(0).Name = ""
        Parameters(0).Value = ""
        For I = 1 To Count
            Dim OnePair() As String = Split(PairsArray(I - 1), PairDelimiter, 2)
            If UBound(OnePair) = 1 Then
                Parameters(I).Name = OnePair(0)
                Parameters(I).Value = OnePair(1)
            ElseIf UBound(OnePair) = 0 Then
                Parameters(I).Name = OnePair(0)
                Parameters(I).Value = ""
            Else
                Parameters(I).Name = ""
                Parameters(I).Value = ""
            End If
            Parameters(I).Name = Trim(Parameters(I).Name)
            Parameters(I).Value = Trim(Parameters(I).Value)
        Next
    End Function

    Function Index(ByVal ParameterName As String) As Long
        Dim I As Long = 0
        For I = 1 To Count
            If String.Compare(Parameters(I).Name, ParameterName, True) = 0 Then
                Index = I
                Exit Function
            End If
        Next
    End Function

    Public Overrides Function ToString() As String
        ToString = Value("")
    End Function

    Default Property Value(ByVal ParameterName) As String
        Get
            If ParameterName = "" Then
                Value = ""
                Dim I As Long
                For I = 1 To Count
                    If Not IsBlank(Parameters(I).Value) Then
                        Value &= Parameters(I).Name & PairDelimiter & Parameters(I).Value & Delimiter
                    End If
                Next
                Value = Left(Value, Len(Value) - Len(Delimiter))
            Else
                Value = Parameters(Index(ParameterName)).Value
            End If
        End Get
        Set(ByVal V As String)
            If ParameterName = "" Then
                Parse(V)
            Else
                Dim I As Long : I = Index(ParameterName)
                If I = 0 Then
                    Count = Count + 1
                    ReDim Preserve Parameters(Count)
                    Parameters(Count) = New ParameterPair
                    With Parameters(Count)
                        .Name = ParameterName
                        .Value = V
                    End With
                Else
                    Parameters(I).Value = V
                End If
            End If
        End Set
    End Property

    Property [Key](ByVal Index As Long) As String
        Get
            Key = Parameters(Index).Name
        End Get
        Set(ByVal NewKey As String)
            Parameters(Index).Name = NewKey
        End Set
    End Property

    Property Item(ByVal Index As Long) As String
        Get
            Item = Parameters(Index).Value
        End Get
        Set(ByVal V As String)
            Parameters(Index).Value = V
        End Set
    End Property

    Function GetConfigValue(ByVal CfgSrc As IConfigSource, ByVal ValueName As String)
        If Not IsNothing(CfgSrc) Then
            Dim Cfg As IConfig = CfgSrc.Configs("CLI")
            GetConfigValue = Cfg.[Get](ValueName)
        End If
    End Function

    '<System.Reflection.Obfuscation(Feature:="virtualization", Exclude:=False)> _
    Public Function DetermineArgs(ByVal Args() As String, ByVal ParamArray Definitions() As String)
        Dim CLICfgSrc As ArgvConfigSource = New ArgvConfigSource(Args)

        Dim INICfgSrc = New IniConfigSource()
        INICfgSrc.CaseSensitive = False

        Dim N As Integer = (Definitions.Length) / 2

        For I As Integer = 0 To N - 1 ' First pass: find INI file name
            Dim J = I * 2
            Dim Name = Definitions(J)
            Dim ShortName = Name.Substring(0, 1)
            Dim DefaultValue = Definitions(J + 1)
            CLICfgSrc.AddSwitch("CLI", Name, ShortName)
            If Name = "inifile" Then
                Dim CLICfgValue = GetConfigValue(CLICfgSrc, Name)
                Me(Name) = NZ(CLICfgValue, DefaultValue)
                Try
                    INICfgSrc.Load(Me("inifile"))
                Catch ex As Exception
                    INICfgSrc = Nothing
                    Me(Name) = ""
                End Try
            End If
        Next

        For I As Integer = 0 To N - 1 ' Second pass: load values
            Dim J = I * 2
            Dim Name = Definitions(J)
            Dim DefaultValue = Definitions(J + 1)
            Dim CLICfgValue = GetConfigValue(CLICfgSrc, Name)

            Dim INICfgValue = GetConfigValue(INICfgSrc, Name)
            If Name <> "inifile" Then
                Me(Name) = NZ(NZ(CLICfgValue, INICfgValue), DefaultValue)
            End If
        Next
    End Function
End Class


Public Class AutoPenguin
    Public Vars As Aulix.Common7.Utils.ParameterString
    Public RemoteHost As String
    Public Sub New(ByVal Vars_ As Aulix.Common7.Utils.ParameterString)
        Vars = Vars_
    End Sub
    Public Function CreateProcess(ByVal CmdText As String, ByVal Args As String) As Process
        Dim SI As ProcessStartInfo = New ProcessStartInfo() With _
            {.CreateNoWindow = True, .UseShellExecute = False, .WindowStyle = ProcessWindowStyle.Hidden, .RedirectStandardError = True, .RedirectStandardOutput = True, .FileName = CmdText, .Arguments = Args}
        Return New Process() With {.StartInfo = SI}
    End Function

    Dim SSHClient As Renci.SshNet.SshClient
    Public LastCmdAfterSubst As String

    Function CleanLF(ByVal S As String, Optional ByVal ShallStopOnLF As Boolean = True) As String
        For I As Integer = 0 To S.Length - 1
            'LANG=en_US.ISO8859-1 LC_ALL=en_US.ISO8859-1
            Dim ChAsc As String = AscW(S.Chars(I))
            If ChAsc = 10 Then
                If ShallStopOnLF Then
                    Exit Function
                Else
                    CleanLF &= vbLf
                End If
            Else
                CleanLF &= ChrW(ChAsc)
            End If
        Next
    End Function

    Public Function Lines(ByVal S As String) As String()
        If Not IsBlank(S) Then
            Lines = S.Split(New Char() {vbLf}, StringSplitOptions.RemoveEmptyEntries)
        End If
    End Function

    Public Function LastLine(ByVal S As String) As String
        If Not IsBlank(S) Then
            Dim Lns = Lines(S)

            If Lns.Length > 0 Then
                LastLine = Lns(Lns.Length - 1)
            End If
        End If
    End Function

    Function StdOutLines() As String()
        StdOutLines = Lines(StdOut)
    End Function

    Function StdErrLines() As String()
        StdErrLines = Lines(StdErr)
    End Function

    Function StdOutLastLine() As String
        StdOutLastLine = LastLine(StdOut)
    End Function

    Function StdOutFirstLine() As String
        StdOutFirstLine = StdOutLines(0)
    End Function

    Function StdErrLastLine() As String
        StdErrLastLine = LastLine(StdErr)
    End Function

    '<System.Reflection.Obfuscation(Feature:="virtualization", Exclude:=False)> _
    Function VarSubstitution(ByVal S As String) As String
        Dim RegEx As New Text.RegularExpressions.Regex("(?<VarName>\$(\w){1,})") ' Find $Vars .*?
        Dim Ms As Text.RegularExpressions.MatchCollection = RegEx.Matches(S)
        VarSubstitution = S
        For Each M As Text.RegularExpressions.Match In Ms
            Dim VarName = M.Value
            Dim V = Vars(Mid(VarName, 2))
            If Not IsBlank(V) Then
                VarSubstitution = Replace(VarSubstitution, VarName, V)
            End If
        Next
    End Function

    Public StdOut As String
    Public StdErr As String
    Public ExitCode As Integer
    Public ShallStopOnLF As Boolean = False

    Public Function Exec(ByVal Cmd As String, Optional ByVal InteractiveShell As Boolean = False) As Boolean
        StdOut = ""
        StdErr = ""
        ExitCode = -1 ' was not executed yet

        LastCmdAfterSubst = VarSubstitution(Cmd)
        If SSHClient.IsConnected Then
            If InteractiveShell Then
                LastCmdAfterSubst = "bash -lc """ & LastCmdAfterSubst & """"
            End If

            Dim SSHCommand = SSHClient.RunCommand(LastCmdAfterSubst)
            With SSHCommand
                StdOut = CleanLF(.Result, ShallStopOnLF)
                StdErr = CleanLF(.Error, ShallStopOnLF)
                ExitCode = .ExitStatus
                Exec = (ExitCode = 0)
            End With
            SSHCommand.Dispose()
        Else
            With CreateProcess("bash", LastCmdAfterSubst)
                .Start()
                Exec = .StandardOutput.ReadToEnd()
            End With
        End If
    End Function

    Private RegEx As New Text.RegularExpressions.Regex("\e\d*;?\d+m")
    Private Function CleanoutTermEMUSymbols(ByVal S As String) As String
        CleanoutTermEMUSymbols = RegEx.Replace(S, "")
    End Function


    Public Function ReadInteractivePassword() As String
        Dim Password As String
        Console.Write("Enter your password: ")
        Dim KI As ConsoleKeyInfo
        Do
            KI = Console.ReadKey(True)
            If (KI.Key <> ConsoleKey.Backspace And KI.Key <> ConsoleKey.Enter) Then
                Password &= KI.KeyChar
                Console.Write("*")
            Else
                If KI.Key = ConsoleKey.Backspace And Password.Length > 0 Then
                    Password = Password.Substring(0, (Password.Length - 1))
                    Console.Write("\b \b")
                End If
            End If
        Loop While KI.Key <> ConsoleKey.Enter
        'Console.WriteLine("The Password You entered is : " + Password)
        ReadInteractivePassword = Password
    End Function

    Public Function OpenSSHConnection(ByVal Host As String, ByVal Port As Integer, ByVal UserName As String, ByVal Password As String) As Boolean
        SSHClient = New Renci.SshNet.SshClient(Host, Port, UserName, Password)
        'SSHClient.ConnectionInfo.Timeout = TimeSpan.FromSeconds(10)
        'SSHClient.ConnectionInfo.RetryAttempts = 3
        Try
            SSHClient.Connect()
        Catch ex As Renci.SshNet.Common.SshAuthenticationException
            Return OpenSSHConnection(Host, Port, UserName, ReadInteractivePassword())
        End Try
        OpenSSHConnection = SSHClient.IsConnected
    End Function

    Public Function OpenSSHConnection(ByVal Host As String, ByVal Port As Integer, ByVal UserName As String, ByVal PrivateKeyFileName As String, ByVal KeyPassword As String) As String
        Dim PK = New Renci.SshNet.PrivateKeyFile(PrivateKeyFileName, KeyPassword)
        SSHClient = New Renci.SshNet.SshClient(Host, Port, UserName, PK)
        Try
            SSHClient.Connect()
        Catch ex As Renci.SshNet.Common.SshAuthenticationException
            Return OpenSSHConnection(Host, Port, UserName, PrivateKeyFileName, ReadInteractivePassword())
        End Try
        OpenSSHConnection = SSHClient.IsConnected
    End Function

    Public Function CloseSSH()
        SSHClient.Disconnect()
        SSHClient.Dispose()
    End Function


    Public WithEvents Shell As Renci.SshNet.ShellStream
    Public SR As IO.StreamReader
    Public SW As IO.StreamWriter
    Public Function OpenShell()
        If SSHClient.IsConnected Then
            Try
                Shell = SSHClient.CreateShellStream("dumb", 80, 24, 800, 600, 1024)

                SR = New IO.StreamReader(Shell)

                SW = New IO.StreamWriter(Shell)
                SW.AutoFlush = True
            Catch ex As Exception
                Console.WriteLine(ex.ToString)
            End Try
        End If
    End Function

    Public Function OnExpectedTextFound(ByVal S As String)
        Debug.Print("F1_________!!!!!!!!!!!!!_________" & S)
    End Function

    Public StopOnText As String
    Public AR As IAsyncResult

    Function ExecAsync(ByVal CmdText As String, Optional ByVal ExpectedText As String = "")

        'Generate auto stop text
        Dim CommandSuffix = ""
        If ExpectedText = "" Then
            Randomize()
            Dim A = Int(Rnd() * 1000)
            Dim B = Int(Rnd() * 1000)
            CommandSuffix = "; echo stop$[" & A & "+" & B & "]; echo test2"
            ExpectedText = "stop" & A + B
        End If

        OpenShell()

        Dim ShellText = VarSubstitution(CmdText) & CommandSuffix

        Shell.WriteLine(ShellText)

        StopOnText = ExpectedText
        AR = Shell.BeginExpect(New Renci.SshNet.ExpectAction(StopOnText, AddressOf OnExpectedTextFound))
        AR.AsyncWaitHandle.WaitOne()
    End Function

    Public Event DataReceived(ByVal S As String)
    Private Sub Shell_DataReceived(ByVal sender As Object, ByVal e As Renci.SshNet.Common.ShellDataEventArgs) Handles Shell.DataReceived
        Dim S As String
        If Shell.DataAvailable Then
            S = Shell.Read()
            Debug.Write(S)
            RaiseEvent DataReceived(S)

            If InStr(S, StopOnText, CompareMethod.Text) > 0 Then
                System.Threading.WaitHandle.SignalAndWait(AR.AsyncWaitHandle, AR.AsyncWaitHandle, 1, False)
                Shell.EndExpect(AR)
            End If
        End If
    End Sub

    Public Event ErrorOccurred(ByVal e As Renci.SshNet.Common.ExceptionEventArgs)
    Private Sub ShStream_ErrorOccurred(ByVal sender As Object, ByVal e As Renci.SshNet.Common.ExceptionEventArgs) Handles Shell.ErrorOccurred
        Debug.Print("ErrorOccurred: " & e.ToString)
        RaiseEvent ErrorOccurred(e)
    End Sub

End Class
