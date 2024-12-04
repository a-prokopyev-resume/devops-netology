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

Imports System.Text


Public Module AulixDeclarations

    Public Delegate Function EnumFilesDelegate(ByVal F As IO.FileInfo)
    Public Delegate Function EnumFilesErrorDelegate(ByVal Ex As Exception)
    'Public JSONTool As fastJSON.JSON = fastJSON.JSON.Instance
    Private Function ProcessEnumFilesError(ByVal E As Exception, ByVal ErrorAction As EnumFilesErrorDelegate)
        Debug.WriteLine(E.ToString)
        If Not IsNothing(ErrorAction) Then
            ErrorAction(E)
        End If
    End Function

    ''' <summary>
    ''' Use on a method or constructor parameter of type "Type". Instructs Rummage that this method uses the Type
    ''' passed in in a way that is fully compatible with all obfuscations, including removing members not directly
    ''' referenced, renaming members, unnesting types and so on.
    ''' </summary>
    <AttributeUsage(AttributeTargets.Parameter Or AttributeTargets.GenericParameter, Inherited:=False, AllowMultiple:=False)> _
    Public NotInheritable Class RummageAssumeTypeSafeAttribute
        Inherits Attribute
    End Class

    ''' <summary>
    ''' Instructs Rummage to keep a specific type, method, constructor or field.
    ''' </summary>
    <AttributeUsage(AttributeTargets.[Class] Or AttributeTargets.Struct Or AttributeTargets.[Enum] Or AttributeTargets.[Delegate] Or _
        AttributeTargets.[Interface] Or AttributeTargets.Constructor Or AttributeTargets.Method Or AttributeTargets.Field, _
        Inherited:=False, AllowMultiple:=False)> _
    Public NotInheritable Class RummageNoRemoveAttribute
        Inherits Attribute
    End Class


    ''' <summary>
    ''' Use only on custom-attribute class declarations. Instructs Rummage to keep everything reflection-safe that
    ''' uses the given custom attribute.
    ''' </summary>
    <AttributeUsage(AttributeTargets.[Class], Inherited:=False, AllowMultiple:=False)> _
    Public NotInheritable Class RummageKeepUsersReflectionSafeAttribute
        Inherits Attribute
    End Class

    ''' <summary>
    ''' Instructs Rummage to refrain from making any changes to a specific type.
    ''' </summary>
    <AttributeUsage(AttributeTargets.[Class] Or AttributeTargets.Struct Or AttributeTargets.[Enum] Or AttributeTargets.[Delegate] Or _
        AttributeTargets.[Interface] Or AttributeTargets.Method Or AttributeTargets.Field Or AttributeTargets.[Property] Or _
        AttributeTargets.[Event] Or AttributeTargets.Constructor Or AttributeTargets.Parameter Or AttributeTargets.GenericParameter, _
        Inherited:=False, AllowMultiple:=False), RummageKeepUsersReflectionSafe()> _
    Public NotInheritable Class RummageKeepReflectionSafeAttribute
        Inherits Attribute
    End Class

    Public Function CreateInstanceWithParameters(ByVal T As Type, ByVal ParamArray PA() As Object) As Object
        CreateInstanceWithParameters = Activator.CreateInstance(T, PA)
    End Function

    Public Function EnumFilesInDir(ByVal InDir As IO.DirectoryInfo, ByVal ShouldProcessSubdirs As Boolean, ByVal FileMask As String, ByVal Action As EnumFilesDelegate, Optional ByVal ErrorAction As EnumFilesErrorDelegate = Nothing, Optional ByVal ExcludeDirArray() As String = Nothing)
        If IsNothing(ExcludeDirArray) OrElse System.Array.IndexOf(ExcludeDirArray, InDir.FullName) = -1 Then ' not found
            Try
                For Each F As IO.FileInfo In InDir.GetFiles(FileMask)
                    Action(F)
                Next
            Catch E As Exception
                ProcessEnumFilesError(E, ErrorAction)
            End Try
            If ShouldProcessSubdirs Then
                Try
                    For Each D As IO.DirectoryInfo In InDir.GetDirectories
                        EnumFilesInDir(D, True, FileMask, Action, ErrorAction, ExcludeDirArray)
                    Next
                Catch E As Exception
                    ProcessEnumFilesError(E, ErrorAction)
                End Try
            End If
        End If
    End Function

    Public Function CreateRussianCulture() As System.Globalization.CultureInfo
        CreateRussianCulture = New System.Globalization.CultureInfo("ru-RU")
    End Function

    Public Function CreateEnglishCulture() As System.Globalization.CultureInfo
        CreateEnglishCulture = New System.Globalization.CultureInfo("en-US")
    End Function

    'Function TurnToOfficeCulture()
    '    Dim LCID As Integer = ExcelApp.LanguageSettings.LanguageID(2) 'msoLanguageIDUI
    '    System.Threading.Thread.CurrentThread.CurrentCulture = New System.Globalization.CultureInfo(LCID)
    'End Function

    Public Function SetRussionLocale() As System.Globalization.CultureInfo
        System.Threading.Thread.CurrentThread.CurrentUICulture = CreateRussianCulture()
        System.Threading.Thread.CurrentThread.CurrentCulture = CreateRussianCulture()
        'DevExpress.Utils.FormatInfo.AlwaysUseThreadFormat = True
    End Function

    Public Function SetEnglishLocale() As System.Globalization.CultureInfo
        System.Threading.Thread.CurrentThread.CurrentUICulture = CreateEnglishCulture()
        System.Threading.Thread.CurrentThread.CurrentCulture = CreateEnglishCulture()
        'DevExpress.Utils.FormatInfo.AlwaysUseThreadFormat = True
    End Function

    Public Function CreateRegex(ByVal Pattern As String) As Text.RegularExpressions.Regex
        CreateRegex = New Text.RegularExpressions.Regex(Pattern, _
        Text.RegularExpressions.RegexOptions.IgnoreCase Or _
        Text.RegularExpressions.RegexOptions.Singleline)
        'Or Text.RegularExpressions.RegexOptions.ECMAScript()
    End Function

    Public RegexPatterns As New System.Collections.Generic.Dictionary(Of String, String)
    Public Function CreatePredefinedRegex(ByVal PatternName As String) As Text.RegularExpressions.Regex
        If RegexPatterns.Count = 0 Then
            RegexPatterns.Add("IPAddress", "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b")
        End If
        CreatePredefinedRegex = CreateRegex(RegexPatterns.Item(PatternName))
    End Function

    Public Function Sleep(ByVal Seconds As Single)
        System.Threading.Thread.Sleep(Seconds * 1000)
    End Function

    'Function WaitKey(ByVal TimeoutInSeconds As Single, Optional ByVal CheckPeriodInSeconds As Single = 0.25) As ConsoleKeyInfo
    '    Dim N As Long = TimeoutInSeconds / CheckPeriodInSeconds
    '    For I As Long = 1 To N
    '        If Console.KeyAvailable Then
    '            WaitKey = Console.ReadKey(True)
    '            Exit Function
    '        End If
    '        Sleep(CheckPeriodInSeconds)
    '    Next
    'End Function

    Function CreateWebGUIId() As String
        Static Md5 As System.Security.Cryptography.MD5CryptoServiceProvider
        If IsNothing(Md5) Then
            Md5 = New System.Security.Cryptography.MD5CryptoServiceProvider()
            Md5.Initialize()
        End If
        Dim CA() As Char = Replace(Guid.NewGuid().ToString, "-", "").ToCharArray()
        Dim OriginalBA() As Byte = System.Text.ASCIIEncoding.ASCII.GetBytes(CA)
        Dim HashBA() As Byte = Md5.ComputeHash(OriginalBA)
        CreateWebGUIId = Left(Convert.ToBase64String(HashBA), 22)
    End Function

    Function UnixTimestamp(ByVal D As Date) As Long
        UnixTimestamp = D.Subtract(#1/1/1970#).TotalSeconds
    End Function
    
    Public Function SHA256Sum(Data As String) As String 
    	Static SHA256 As New System.Security.Cryptography.SHA256Managed
    	Dim Hash=SHA256.ComputeHash(Encoding.UTF8.GetBytes(Data))
    	SHA256Sum=Convert.ToBase64String(Hash)
    End Function 
    
    public Function ToBase64(S As String) As String
    	ToBase64=Convert.ToBase64String(System.Text.ASCIIEncoding.ASCII.GetBytes(S.ToCharArray))
    End Function
    
    public Function FromBase64(S As String) As String
    	FromBase64=New String(System.Text.ASCIIEncoding.ASCII.GetChars(Convert.FromBase64String(S))) 
    End Function

    Public Function Date2FileNameSuffix(ByVal D As Date) As String
        Dim MonthNames As Object : MonthNames = CreateArray("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
        Date2FileNameSuffix = Year(D) & "_" & Format(Month(D), "00") & "(" & MonthNames(Month(D) - 1) & ")_" & Format(Day(D), "00") & "__" & Format(Hour(D), "00") & "_" & Format(Minute(D), "00") & "_" & Format(Second(D), "00")
    End Function

    Public Function FileNameWithSuffix2Date(ByVal FileName As String) As Date
        Try
            Dim FI As New IO.FileInfo(FileName)
            'Dim Ext As String=right(FileName
            'If Right(FileName, Len(Ext) + 1) = "." & Ext Then
            '    FileName = Left(FileName, Len(FileName) - Len(Ext) - 1)
            'End If
            Dim FileNameWithoutExt As String = Mid(FI.Name, 1, Len(FI.Name) - Len(FI.Extension))
            Dim A() As String = Split(FileNameWithoutExt, "__")
            Dim A2() As String
            If UBound(A) >= 1 Then
                Dim ShortFileName As String = A(0)
                A2 = Split(A(1), "_")
                If UBound(A) = 2 Then
                    FileNameWithSuffix2Date = DateSerial(A2(0), Left(A2(1), 2), A2(2))
                End If
            End If
            If UBound(A) = 2 Then
                A2 = Split(A(2), "_")
                FileNameWithSuffix2Date = FileNameWithSuffix2Date.Add(TimeSerial(A2(0), A2(1), A2(2)).TimeOfDay)
            End If
        Catch ex As System.Exception
        End Try
    End Function

    'Public Function GenerateNewTimeStamp() As String
    '    TimeStamp = "__" & Date2FileNameSuffix(Now)
    '    GenerateNewTimeStamp = TimeStamp
    'End Function

    Public Function ResolveIPAddressByName(ByVal HostName As String) As Long
        Try
            For Each IPAddress In System.Net.Dns.GetHostEntry(HostName).AddressList
                If IPAddress.AddressFamily = Net.Sockets.AddressFamily.InterNetwork Then
                    ResolveIPAddressByName = IPAddress.Address
                End If
            Next

        Catch ex As Exception
            Exit Function
        End Try
    End Function

    Function IsCurrentHost(ByVal HostName As String) As Boolean
        IsCurrentHost = False
        Dim IPAddr As Long
        Try
            IPAddr = ResolveIPAddressByName(HostName)
        Catch ex As Exception
            Exit Function
        End Try
        For Each ThisHostIPAddress As Net.IPAddress In System.Net.Dns.GetHostEntry(System.Net.Dns.GetHostName).AddressList
            If ThisHostIPAddress.AddressFamily = Net.Sockets.AddressFamily.InterNetwork Then
                If IPAddr = ThisHostIPAddress.Address Then
                    IsCurrentHost = True
                    Exit Function
                End If
            End If
        Next
    End Function

    Function CreateProcess(ByVal CmdText As String, Optional ByVal Args As String = "", Optional ByVal RedirectStandardOutput As Boolean = True) As System.Diagnostics.Process
        CreateProcess = New System.Diagnostics.Process
        With CreateProcess.StartInfo
            .CreateNoWindow = True
            .UseShellExecute = False
            .WindowStyle = ProcessWindowStyle.Hidden
            .RedirectStandardOutput = RedirectStandardOutput
            .RedirectStandardError = RedirectStandardOutput
            .FileName = CmdText
            .Arguments = Args
        End With
    End Function

    Function IsRunningUnderUnix() As Boolean
        IsRunningUnderUnix = InStr(Environment.OSVersion.VersionString, "unix", CompareMethod.Text) > 0
    End Function


    Public Function CreateSecureString(ByVal S As String) As System.Security.SecureString
        CreateSecureString = New System.Security.SecureString()
        For I As Long = 0 To S.Length - 1
            CreateSecureString.AppendChar(S.Chars(I))
        Next
    End Function

    Function IsEMailValid(ByVal EMail As String) As Boolean
        Dim Pattern As String = "^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}" & _
        "\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\" & _
        ".)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$"
        IsEMailValid = (New Text.RegularExpressions.Regex(Pattern)).IsMatch(EMail)
    End Function

    Function RemoveDelimitersOnEdges(ByVal PathPart As String, ByVal Delimiter As String) As String
        RemoveDelimitersOnEdges = PathPart
        Dim DoesPartStartWithDelimiter As Boolean
        Dim DoesPartEndWithDelimiter As Boolean
        Do
            DoesPartStartWithDelimiter = RemoveDelimitersOnEdges.StartsWith(Delimiter)
            If DoesPartStartWithDelimiter Then
                RemoveDelimitersOnEdges = RemoveDelimitersOnEdges.Substring(Delimiter.Length)
            End If
        Loop While DoesPartStartWithDelimiter Or DoesPartEndWithDelimiter
        Do
            DoesPartEndWithDelimiter = RemoveDelimitersOnEdges.EndsWith(Delimiter)
            If DoesPartEndWithDelimiter Then
                RemoveDelimitersOnEdges = RemoveDelimitersOnEdges.Substring(0, RemoveDelimitersOnEdges.Length - Delimiter.Length)
            End If
        Loop While DoesPartStartWithDelimiter Or DoesPartEndWithDelimiter
    End Function

    Function ConcatenateParts(ByVal Parts() As String, ByVal Delimiter As String) As String
        For I As Integer = 0 To Parts.Length - 1
            ConcatenateParts &= RemoveDelimitersOnEdges(Parts(I), Delimiter)
            If I < Parts.Length - 1 Then
                ConcatenateParts &= Delimiter
            End If
        Next
    End Function

    Function ConcatenatePathParts(ByVal ParamArray PathParts() As String) As String
        ConcatenatePathParts = ConcatenateParts(PathParts, "\")
    End Function

    Function ConcatenateURLParts(ByVal ParamArray PathParts() As String) As String
        ConcatenateURLParts = ConcatenateParts(PathParts, "/")
    End Function


    'Public Function AddDirectorySecurity2(ByVal FileName As String, ByVal Account As String, ByVal Rights As FileSystemRights, ByVal ControlType As AccessControlType)
    '    Dim dInfo As New IO.DirectoryInfo(FileName)
    '    Dim dSecurity As System.Security.AccessControl.DirectorySecurity = dInfo.GetAccessControl()
    '    Dim FSAR As New FileSystemAccessRule(Account, Rights, InheritanceFlags.ContainerInherit And InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow)
    '    dSecurity.AddAccessRule(FSAR)
    '    dSecurity.SetAccessRule(FSAR)
    '    dInfo.SetAccessControl(dSecurity)
    'End Function

    Function Is64BitOS() As Boolean
        Static Is64BitOS_ As Object
        If IsNothing(Is64BitOS_) Then
            Is64BitOS_ = Not Microsoft.Win32.Registry.LocalMachine.OpenSubKey("Hardware\Description\System\CentralProcessor\0").GetValue("Identifier").ToString.Contains("x86")
        End If
        Is64BitOS = Is64BitOS_
    End Function

    Property LMRegistryValue(ByVal Path As String, ByVal Name As String, Optional ByVal Explicit64Bit As Boolean = False) As String
        Get
            If Is64BitOS() And Explicit64Bit Then
                LMRegistryValue = RegistryWOW6432.GetRegKey64(Aulix.Common7.Utils.RegistryWOW6432.HKEY_LOCAL_MACHINE, Path, RegistryWOW6432.RegSAM.WOW64_64Key, Name)
            Else
                LMRegistryValue = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(Path).GetValue(Name)
            End If
        End Get
        Set(ByVal Value As String)
            If Is64BitOS() And Explicit64Bit Then
                RegistryWOW6432.SetRegKey64(Aulix.Common7.Utils.RegistryWOW6432.HKEY_LOCAL_MACHINE, Path, RegistryWOW6432.RegSAM.WOW64_64Key, Name, Value)
                'Throw New NotImplementedException("Explicit64Bit is read only yet")
            Else
                Microsoft.Win32.Registry.LocalMachine.OpenSubKey(Path, True).SetValue(Name, Value)
            End If
        End Set
    End Property

    Public ApplicationRegistryPath As String
    Property ApplicationRegistryValue(ByVal Name As String) As String
        Get
            ApplicationRegistryValue = LMRegistryValue(ApplicationRegistryPath, Name, False)
        End Get
        Set(ByVal Value As String)
            LMRegistryValue(ApplicationRegistryPath, Name, False) = Value
        End Set
    End Property

    Function InstallDir() As String
        InstallDir = ApplicationRegistryValue("InstallDir")
    End Function

    Public Function PadL(ByVal S As String, ByVal C As String, ByVal N As Long) As String
        PadL = S.PadLeft(N, C)
    End Function

    Public Function PadR(ByVal S As String, ByVal C As String, ByVal N As Long) As String
        PadR = S.PadRight(N, C)
    End Function

    Public Function IsBlank(ByVal V As Object) As Boolean
        If IsNothing(V) Then
            Return True
        ElseIf IsDBNull(V) Then
            Return True
        ElseIf StrComp(TypeName(V), "String", CompareMethod.Text) = 0 Then
            If CStr(V) = "" Then
                Return True
            End If
        ElseIf IsDate(V) AndAlso V = #12:00:00 AM# Then
            Return True
        Else
            IsBlank = False
        End If
    End Function

    Public Function NZ(ByVal V As Object, Optional ByVal Replacement As Object = "") As Object
        If IsBlank(V) Then
            NZ = Replacement
        Else
            NZ = V
        End If
    End Function

    Private Declare Function GetWindowThreadProcessId Lib "user32.dll" (ByVal hWnd As IntPtr, ByRef lpdwProcessId As Integer) As Integer
    Public Function GetProcessIdByHWnd(ByVal HWnd As Int32) As Int32
        Dim Ptr As New IntPtr(HWnd)
        GetWindowThreadProcessId(Ptr, GetProcessIdByHWnd)
    End Function


    Public Function CreateTempName() As String
        Static I As Long
        I += 1
        CreateTempName = "TempName" & I
    End Function

    Function LoadWebPage(ByVal URL As String, Optional ByVal C As System.Net.NetworkCredential = Nothing, Optional ByRef RequestStatus As String = "") As String
        Try
            Dim WC As New System.Net.WebClient With {.Credentials = C}
            Dim S As System.IO.Stream = WC.OpenRead(URL)
            Dim SR As New System.IO.StreamReader(S)
            LoadWebPage = SR.ReadToEnd()
            SR.Close()
            S.Close()
            RequestStatus = System.Net.WebExceptionStatus.Success.ToString
        Catch Ex As Net.WebException
            RequestStatus = Ex.Status.ToString & " " & Ex.Message
        End Try
    End Function

    Function GetFileListAtURL(ByVal URL As String) As String()
        Dim S = LoadWebPage(URL)
        S = S.Replace(vbNewLine, vbCr)
        Dim RX = CreateRegex("\[To Parent Directory\](.*)</PRE>")
        S = RX.Matches(S).Item(0).Groups(1).Value
        RX = CreateRegex("<A href.*?>(.*?)</A>")
        Dim Ms = RX.Matches(S)
        Dim A(Ms.Count - 1) As String
        Dim I = 0
        For Each M As System.Text.RegularExpressions.Match In Ms
            A(I) = M.Groups(1).Value
            I += 1
        Next
        GetFileListAtURL = A
    End Function

    Function CreateMaxRecordsSQLText(ByVal MaxRecordsTE As Object, ByVal DefaultMaxRecords As Long) As String
        Dim TopValue As Long = DefaultMaxRecords
        If IsNumeric(MaxRecordsTE.Text) Then
            If MaxRecordsTE.Text > 0 Then
                TopValue = MaxRecordsTE.Text
            Else
                MaxRecordsTE.Text = TopValue
            End If
        Else
            MaxRecordsTE.Text = TopValue
        End If
        CreateMaxRecordsSQLText = " top " & TopValue & " "
    End Function

    Function IsHTMLFileName(ByVal FN As String) As Boolean
        IsHTMLFileName = FN.EndsWith(".htm") Or FN.EndsWith(".html")
    End Function

    Function CreateArray(ByVal ParamArray PA() As Object) As Object
        CreateArray = PA
    End Function

    Function ArrayOf(ByVal ParamArray PA() As Object) As Object
        ArrayOf = PA
    End Function

    Public Function Enum2BindableArray(ByVal ET As Type) As EnumRecord()
        Dim NameArray = System.Enum.GetNames(ET)
        Dim ValueArray = System.Enum.GetValues(ET)
        Dim A() As EnumRecord
        ReDim A(UBound(NameArray))
        For I As Long = 0 To UBound(NameArray)
            A(I) = New EnumRecord
            A(I).Id = ValueArray(I)
            A(I).Name = NameArray(I)
        Next
        Enum2BindableArray = A
    End Function
End Module

Public Class DotNetBridge
    Public Shared Function CreateObject(ByVal AssemblyName As String, ByVal TypeName As String) As Object
        If Right(AssemblyName, 4) = ".dll" Then
            CreateObject = CreateObjectFrom(AssemblyName, TypeName)
        Else
            CreateObject = Activator.CreateInstance(AssemblyName, TypeName).Unwrap()
        End If
    End Function
    Public Shared Function CreateObjectFrom(ByVal AssemblyFileName As String, ByVal TypeName As String) As Object
        CreateObjectFrom = Activator.CreateInstanceFrom(AssemblyFileName, TypeName).Unwrap()
    End Function
End Class


Public Class EnumRecord
    Public Id_ As Integer
    Public Name_ As String
    Public Property Name() As String
        Get
            Return (Name_)
        End Get
        Set(ByVal V As String)
            Name_ = V
        End Set
    End Property
    Public Property Id() As Integer
        Get
            Return (Id_)
        End Get
        Set(ByVal V As Integer)
            Id_ = V
        End Set
    End Property
End Class

