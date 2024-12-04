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

Imports System.ComponentModel
Imports System.Collections.Generic
Imports System.Reflection
Imports Aulix.Common7.Utils
Imports System.Data
Imports CookComputing.XmlRpc

Public Module DataUtils
    <RummageNoRemove()> <RummageKeepReflectionSafe()> Public SharedCon As AdvancedConnection
    Public ShouldUseAulixDataModel As Boolean = True
    Public NHAssemblyName As String

    Public Function TestConnection(ByVal ConStr As String) As Boolean
        TestConnection = False
        Try
            Dim Con As New System.Data.SqlClient.SqlConnection(ConStr)
            Con.Open()
            If Con.State = ConnectionState.Open Then
                'MsgBox("Successful connection!")
                TestConnection = True
            Else
                MsgBox("Connection state: " & Con.State.ToString)
            End If
            Con.Close()
        Catch ex As Exception
            MsgBox(ex.Message, MsgBoxStyle.Critical)
        End Try
    End Function

    Public Function [GetType]() As System.Type
        Return System.Reflection.Assembly.GetExecutingAssembly.GetType("Aulix.Common7.DataUtils")
    End Function

    'Sample: CallSharedMethod(Aulix.Common7.DataUtils.GetType, "OpenSharedCon", Type.Missing, Type.Missing, Type.Missing, Type.Missing)
    Function CallSharedMethod(ByVal T As Type, ByVal MethodName As String, ByVal ParamArray Args() As Object) As Object
        CallSharedMethod = T.GetMethod(MethodName).Invoke(Nothing, Args)
    End Function

    Public Function OpenSharedConWithNH(ByVal NHAssemblyName_ As String, Optional ByVal NHSF As NHibernate.ISessionFactory = Nothing, Optional ByVal StatusDisplayHandler As AdvancedConnection.ConnectionStatusDisplayDelegate = Nothing, Optional ByVal ConStr As String = "") As AdvancedConnection
        OpenSharedCon(ConStr, StatusDisplayHandler)
        NHAssemblyName = NHAssemblyName_
        If IsNothing(NHSF) Then
            If ShouldUseAulixDataModel Then
                If NHAssemblyName = "" Then
                    SharedCon.NHSF = SharedCon.CreateNHSF("Aulix.Common7.BL")
                Else
                    SharedCon.NHSF = SharedCon.CreateNHSF("Aulix.Common7.BL", NHAssemblyName)
                End If
            Else
                SharedCon.NHSF = SharedCon.CreateNHSF(Split(NHAssemblyName, ","))
            End If
        Else
            SharedCon.NHSF = NHSF
        End If
        SharedCon.NHS = SharedCon.OpenNHS()
    End Function

    Public Function OpenSharedCon(Optional ByVal ConStr As String = "", Optional ByVal StatusDisplayHandler As AdvancedConnection.ConnectionStatusDisplayDelegate = Nothing) As Object
        If ConStr = "" Then
            ConStr = ApplicationRegistryValue("ConStr")
        End If
        SharedCon = New AdvancedConnection(ConStr, StatusDisplayHandler)
        OpenSharedCon = SharedCon
    End Function

    Sub AllowAdHocDistributedQueries()
        SharedCon.Execute("sp_configure 'show advanced options',1" & vbNewLine & "reconfigure with override")
        SharedCon.Execute("sp_configure 'Ad Hoc Distributed Queries',1" & vbNewLine & "reconfigure with override")
        SharedCon.Execute("sp_configure go")
    End Sub

    Public Function Arg(ByVal V As Object) As String
        Arg = SharedCon.Arg(V).ToString
    End Function
    Function Params(ByVal ParamArray Parameters() As Object) As Collection
        Params = SharedCon.ParamsFromArray(Parameters)
    End Function
    Function LikeWC(ByVal FieldName As String, ByVal Value As String) As String
        If Not IsBlank(Value) Then
            LikeWC = FieldName & " like " & Arg(Value)
        End If
    End Function
    Function SmartLikeWC(ByVal FieldName As String, ByVal Value As String) As String
        SmartLikeWC = LikeWC(FieldName, Replace(Replace(Value, "*", "%"), "?", "_"))
    End Function
    Public Function WCArg(ByVal WC As String) As String
        If Not IsBlank(WC) Then
            WCArg = " where " & WC
        End If
    End Function
    Function NumberWC(ByVal FieldName As String, ByVal Value As Object) As String
        If IsNumeric(Value) Then
            NumberWC = "[" & FieldName & "] = " & Value.ToString
        End If
    End Function
    Public Function OpRow(ByVal OpName As String, ByVal ArgList As System.Array) As String
        Dim I As Integer, Res As String, Ops As Integer
        For I = LBound(ArgList) To UBound(ArgList)
            If Len(Trim(ArgList.GetValue(I).ToString)) > 0 Then
                If Len(Res) > 0 Then
                    Res = Res & " " & OpName & " " & Trim(ArgList.GetValue(I).ToString)
                    Ops += 1
                Else
                    Res = Trim(ArgList.GetValue(I).ToString)
                End If
            End If
        Next
        If Res = "" Then
            OpRow = ""
        Else
            If Ops >= 1 Then
                OpRow = " (" & Res & ") "
            Else
                OpRow = " " & Res & " "
            End If
        End If
    End Function
    Public Function AndRow(ByVal ParamArray ArgList() As Object) As String
        'Dim V As Object : V = ArgList
        AndRow = OpRow("and", ArgList)
    End Function
    Public Function OrRow(ByVal ParamArray ArgList() As Object) As String
        'Dim V As Object : V = ArgList
        OrRow = OpRow("or", ArgList)
    End Function

    Private Const ODBC_REMOVE_SYS_DSN As Int32 = 6
    Private Const vbAPINull As Long = 0
    Private Declare Function SQLConfigDataSource Lib "ODBCCP32.DLL" _
           (ByVal hwndParent As Int32, ByVal fRequest As Int32, _
           ByVal lpszDriver As String, ByVal lpszAttributes As String) _
           As Int32

    Public Function DeleteODBCSystemDSN(ByVal DSN As String) As Int32
        Dim strDriver As String = "SQL Server"
        Dim strAttributes As String = "DSN=" & DSN & Chr(0)
        DeleteODBCSystemDSN = SQLConfigDataSource(vbAPINull, ODBC_REMOVE_SYS_DSN, strDriver, strAttributes)
    End Function

End Module

<RummageNoRemove()> <RummageKeepReflectionSafe()> Public Class AdvancedConnection
    Public Delegate Function ConnectionStatusDisplayDelegate(ByVal ACon As AdvancedConnection) As Object
    Public ConnectionStatusDisplayFunction As ConnectionStatusDisplayDelegate
    Public Con As System.Data.Common.DbConnection 'System.Data.IDbConnection
    Public ConStr As String
    Public ConnectionStatusDisplayTextObj As Object
    Public LastIsAliveResult As Boolean
    Private Reader As System.Data.Common.DbDataReader
    Public EOF As Boolean
    Public NHDriver As NHDriverEnum
    Public NHDialect As NHDialectEnum
    Public NHSF As NHibernate.ISessionFactory
    Public NHS As NHibernate.ISession
    Public ADOTransaction As System.Data.IDbTransaction

    Public Sub Enlist(ByVal Cmd As System.Data.IDbCommand)
        If IsNothing(NHS) Then
            Cmd.Transaction = ADOTransaction
        Else
            NHS.Transaction.Enlist(Cmd)
        End If
    End Sub

    Public Function BeginTransaction() As Object
        If IsNothing(NHS) Then
            ADOTransaction = Con.BeginTransaction()
            BeginTransaction = ADOTransaction
        Else
            BeginTransaction = NHS.BeginTransaction()
        End If
    End Function

    Public Sub CommitTransaction()
        If IsNothing(NHS) Then
            ADOTransaction.Commit()
        Else
            If NHS.Transaction.IsActive Then
                NHS.Flush()
                NHS.Transaction.Commit()
            End If
        End If
    End Sub

    Public Sub RollbackTransaction()
        If IsNothing(NHS) Then
            ADOTransaction.Rollback()
        Else
            If NHS.Transaction.IsActive Then
                NHS.Transaction.Rollback()
            End If
        End If
    End Sub

    Public Enum NHDriverEnum
        ODBC = 1
        OLEDB = 2
        ADONet = 3
        'SQLClient = 3
        'NPGSQLClient = 4
    End Enum

    Public Enum NHDialectEnum
        MsSql2000 = 1
        MsSql2005 = 2
        MySQL = 3
        PostgreSQL82 = 4
        JetDialect = 5
    End Enum

    Function NHDialectStr() As String
        NHDialectStr = "NHibernate.Dialect." & NHDialect.GetName(GetType(NHDialectEnum), NHDialect) & "Dialect"
    End Function

    'Function CreateSQLServerLink(ByVal OnServer As String, ByVal ToServer As String)
    '    Execute("if not exists (select * from master..sysservers where srvname = 'loopback') exec sp_addlinkedserver @server = N'loopback', @srvproduct = N'', @provider = N'SQLOLEDB', @datasrc = @@servername")
    '    'select * from OPENDATASOURCE('SQLOLEDB', 'Network Library=DBMSSOCN;Data Source=gts-sql2;Initial Catalog=master;User Id=sa2;Password=meimei;').PSI00147_Published.dbo.MSP_RESOURCES
    'End Function

    Sub CreateLoopbackServer()
        Execute("if not exists (select * from master..sysservers where srvname = 'loopback') exec sp_addlinkedserver @server = N'loopback', @srvproduct = N'', @provider = N'SQLOLEDB', @datasrc = @@servername")
    End Sub

    Sub DisconnectAllUsers(ByVal FromDatabase As String)
        CreateLoopbackServer()
        Dim SQLText As String
        With OpenTable("select spid from openquery(loopback, 'exec sp_who') where dbname=" & Arg(FromDatabase))
            For Each .Row In .Rows
                SQLText &= "kill " & .Row("spid").ToString & " "
            Next
        End With
        If Not IsBlank(SQLText) Then
            Execute(SQLText)
        End If
    End Sub

    Sub DropDatabase(ByVal DatabaseName As String)
        'DisconnectAllUsers(DatabaseName)
        'Execute("exec sp_dboption " & Arg(DatabaseName) & ", 'single user', 'TRUE'")
        Execute("ALTER DATABASE [" & DatabaseName & "] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE")
        Threading.Thread.Sleep(100)
        Execute("drop database " & DatabaseName)
    End Sub

    Public Function Arg(ByVal V As Object) As String
        Select Case TypeName(V)
            Case "Boolean"
                If CBool(V) Then
                    Arg = "1"
                Else
                    Arg = "0"
                End If
            Case "Date"
                Arg = "convert(datetime,'" & Month(CDate(V)) & "/" & Day(CDate(V)) & "/" & Year(CDate(V)) & "',101)"
            Case "String"
                Arg = "'" & Replace(V.ToString, "'", "''") & "'"
            Case "DBNull"
                Arg = "null"
            Case Else
                Arg = V.ToString
        End Select
    End Function

    Public Sub Close()
        Con.Close()
        If Not IsNothing(NHS) AndAlso NHS.IsOpen Then
            NHS.Flush()
            NHS.Close()
            NHS.Dispose()
            NHS = Nothing
        End If
    End Sub

    Public Shared Function ConnectionStatusDisplayFunctionForTextObj(ByVal ACon As AdvancedConnection) As Object
        '!!!With ACon.ConnectionStatusDisplayTextObj
        '    .Text = "Connection: " & IIf(ACon.LastIsAliveResult, "Alive", "Lost")
        '    .Owner.Refresh()
        'End With
    End Function

    Public Sub SpecifyStatusDisplayHandler(ByVal StatusDisplayHandler As ConnectionStatusDisplayDelegate)
        If Not IsNothing(StatusDisplayHandler) Then
            If TypeOf (StatusDisplayHandler) Is ConnectionStatusDisplayDelegate Then
                ConnectionStatusDisplayFunction = StatusDisplayHandler
            Else
                ConnectionStatusDisplayTextObj = StatusDisplayHandler
                ConnectionStatusDisplayFunction = AddressOf ConnectionStatusDisplayFunctionForTextObj
            End If
        End If
    End Sub

    Public Sub RestoreDatabase(ByVal DBName As String, ByVal BackupFileName As String, Optional ByVal DBPath As String = "", Optional ByVal DBLogPath As String = "")
        Dim SQLText As String = "restore database " & DBName & " from disk = '" & BackupFileName & "' with replace "
        Dim LogicalNameT As AdvancedDataTable = OpenTable("restore filelistonly from disk = '" & BackupFileName & "'")
        If DBPath <> "" Or DBLogPath <> "" Then
            SQLText &= ", "
        End If
        If DBPath <> "" Then
            With LogicalNameT.DefaultView
                .RowFilter = "Type='D'"
                SQLText &= " move '" & CType(.Item(0), DataRowView).Item("LogicalName").ToString & "' to '" & ConcatenatePathParts(DBPath, DBName & ".mdf', ")
            End With
        End If
        If DBLogPath <> "" Then
            With LogicalNameT.DefaultView
                .RowFilter = "Type='L'"
                SQLText &= " move '" & CType(.Item(0), DataRowView).Item("LogicalName").ToString & "' to '" & ConcatenatePathParts(DBLogPath, DBName & ".ldf'")
            End With
        End If
        Execute(SQLText)
    End Sub

    Sub New(ByVal ConStr_ As String, Optional ByVal StatusDisplayHandler As ConnectionStatusDisplayDelegate = Nothing, Optional ByVal EnsureIsAlive_ As Boolean = True)
        SpecifyStatusDisplayHandler(StatusDisplayHandler)
        Dim PS As New ParameterString(ConStr_, ";", "=")
        Select Case PS.Value("NHDriver")
            Case "ODBC"
                NHDriver = NHDriverEnum.ODBC
            Case "OLEDB"
                NHDriver = NHDriverEnum.OLEDB
                'Case "", "SQLClient"
                '    NHDriver = NHDriverEnum.SQLClient
            Case "ADONet", ""
                NHDriver = NHDriverEnum.ADONet
                Select Case PS.Value("NHDialect")
                    Case "", "MSSQL", "MsSql2005"
                        NHDialect = NHDialectEnum.MsSql2005
                    Case "PostgreSQL82", "PostgreSQL", "PGSQL"
                        NHDialect = NHDialectEnum.PostgreSQL82
                End Select
        End Select
        PS.Value("NHDriver") = ""
        PS.Value("NHDialect") = ""
        ConStr = PS.Value
        Select Case NHDriver
            Case NHDriverEnum.ODBC
                Con = New System.Data.Odbc.OdbcConnection(ConStr)
            Case NHDriverEnum.OLEDB
                Con = New System.Data.OleDb.OleDbConnection(ConStr)
            Case NHDriverEnum.ADONet
                Select Case NHDialect
                    Case NHDialectEnum.MsSql2005
                        Con = New System.Data.SqlClient.SqlConnection(ConStr)
                    Case NHDialectEnum.PostgreSQL82
                        Con = New Npgsql.NpgsqlConnection(ConStr)
                End Select
        End Select
        Try
            Con.Open()
        Catch ex As System.Exception
        End Try
        Select Case NHDriver
            Case NHDriverEnum.ODBC
                Select Case LCase(CType(Con, Odbc.OdbcConnection).Driver)
                    Case "myodbc3.dll"
                        NHDialect = NHDialectEnum.MySQL
                    Case "psqlodbc35w.dll"
                        NHDialect = NHDialectEnum.PostgreSQL82
                End Select
            Case NHDriverEnum.OLEDB
                Select Case LCase(CType(Con, OleDb.OleDbConnection).Provider)
                    Case "microsoft.jet.oledb.4.0"
                        NHDialect = NHDialectEnum.JetDialect
                End Select
        End Select
        If NHDialect <> NHDialectEnum.PostgreSQL82 Then
            If EnsureIsAlive_ Then
                EnsureIsAlive()
            End If
        End If
    End Sub

    Function IsAlive() As Boolean
        If Con.State = ConnectionState.Open Then
            Try
                IsAlive = CBool(GetScalar("select 1 as IsAlive"))
                Sleep(1)
            Catch ex As System.Data.Common.DbException
            End Try
        End If
        LastIsAliveResult = IsAlive
        If Not IsNothing(ConnectionStatusDisplayFunction) Then
            ConnectionStatusDisplayFunction(Me)
        End If
    End Function

    Sub TryReconnect()
        Try
            Con.Close()
            Con.Open()
        Catch ex As System.Exception
        End Try
        If Not IsNothing(ConnectionStatusDisplayFunction) Then
            ConnectionStatusDisplayFunction(Me)
        End If
    End Sub

    Sub EnsureIsAlive()
        Do Until IsAlive()
            TryReconnect()
        Loop
    End Sub

    Shared Sub UpdateCommandTimeout(ByVal Cmd As System.Data.IDbCommand)
        Const DefaultTimeOut As Integer = 5 * 60 ' seconds
        If Not IsNothing(Cmd) Then
            Cmd.CommandTimeout = DefaultTimeOut
        End If
    End Sub

    Private Function OpenReader(ByVal Cmd As System.Data.IDbCommand) As System.Data.Common.DbDataReader
        OpenReader = CType(Cmd.ExecuteReader(), System.Data.Common.DbDataReader)
        Reader = OpenReader
        Read()
        EOF = Not Reader.HasRows
    End Function

    Private Function Read() As Boolean
        Read = Reader.Read
        EOF = Not Read
    End Function

    Private Sub CloseReader()
        Reader.Close()
    End Sub

    Public Function Execute(ByVal CmdOrSQLText As Object, Optional ByVal Parameters As Collection = Nothing) As Integer
        Execute = CreateCommand(CmdOrSQLText, Parameters).ExecuteNonQuery
    End Function

    Public Function GetScalar(ByVal CmdOrSQLText As Object, Optional ByVal Parameters As Collection = Nothing, Optional ByVal FieldName As String = "") As Object
        With OpenReader(CreateCommand(CmdOrSQLText, Parameters))
            If Not EOF Then
                If FieldName = "" Then
                    GetScalar = Reader(0)
                Else
                    GetScalar = Reader(FieldName)
                End If
            End If
            CloseReader()
        End With
    End Function

    Public Function CreateAdapter(ByVal Cmd As System.Data.Common.DbCommand) As System.Data.Common.DbDataAdapter 'System.Data.IDbCommand) ' System.Data.IDbDataAdapter
        Select Case NHDriver
            Case NHDriverEnum.ODBC
                CreateAdapter = New System.Data.Odbc.OdbcDataAdapter(CType(Cmd, Odbc.OdbcCommand))
            Case NHDriverEnum.OLEDB
                CreateAdapter = New System.Data.OleDb.OleDbDataAdapter(CType(Cmd, OleDb.OleDbCommand))
            Case NHDriverEnum.ADONet
                Select Case NHDialect
                    Case NHDialectEnum.MsSql2005
                        CreateAdapter = New System.Data.SqlClient.SqlDataAdapter(CType(Cmd, SqlClient.SqlCommand))
                    Case NHDialectEnum.PostgreSQL82
                        CreateAdapter = New Npgsql.NpgsqlDataAdapter(CType(Cmd, Npgsql.NpgsqlCommand))
                End Select
        End Select
    End Function

    Public Function CreateCommand(ByVal CmdOrSQLText As Object, Optional ByVal Parameters As Collection = Nothing) As System.Data.Common.DbCommand ' System.Data.IDbCommand
        If TypeOf CmdOrSQLText Is System.Data.IDbCommand Then
            CreateCommand = CType(CmdOrSQLText, System.Data.Common.DbCommand)
        Else
            Select Case NHDriver
                Case NHDriverEnum.ODBC
                    CreateCommand = New Odbc.OdbcCommand(CmdOrSQLText.ToString, CType(Con, Odbc.OdbcConnection))
                Case NHDriverEnum.OLEDB
                    CreateCommand = New OleDb.OleDbCommand(CmdOrSQLText.ToString, CType(Con, OleDb.OleDbConnection))
                    If IsSingleWord(CmdOrSQLText.ToString) Then
                        CreateCommand.CommandType = CommandType.TableDirect
                    End If
                Case NHDriverEnum.ADONet
                    Select Case NHDialect
                        Case NHDialectEnum.MsSql2005, NHDialectEnum.PostgreSQL82
                            If IsSingleWord(CmdOrSQLText.ToString) Then
                                CmdOrSQLText = "select * from " & CmdOrSQLText.ToString
                            End If
                    End Select
                    Select Case NHDialect
                        Case NHDialectEnum.MsSql2005
                            CreateCommand = New SqlClient.SqlCommand(CmdOrSQLText.ToString, CType(Con, SqlClient.SqlConnection))
                        Case NHDialectEnum.PostgreSQL82
                            CreateCommand = New Npgsql.NpgsqlCommand(CmdOrSQLText.ToString, CType(Con, Npgsql.NpgsqlConnection))
                    End Select
            End Select
        End If
        UpdateCommandTimeout(CreateCommand)
        Enlist(CreateCommand)
        If Not IsNothing(Parameters) Then
            For Each P As IDbDataParameter In Parameters
                CreateCommand.Parameters.Add(P)
            Next
        End If
    End Function

    Public Function IsSingleWord(ByVal S As String) As Boolean
        IsSingleWord = CreateRegex("^\w*$").IsMatch(S)
    End Function
    Public Function Params(ByVal ParamArray Parameters() As Object) As Collection
        Params = ParamsFromArray(Parameters)
    End Function
    Friend Function ParamsFromArray(ByVal Parameters() As Object) As Collection
        ParamsFromArray = New Collection
        For I As Integer = 0 To Parameters.Length - 1
            Dim P As IDbDataParameter
            Select Case NHDriver
                Case AdvancedConnection.NHDriverEnum.ODBC
                    P = New Odbc.OdbcParameter("", Parameters(I))
                Case AdvancedConnection.NHDriverEnum.OLEDB
                    P = New OleDb.OleDbParameter("", Parameters(I))
                Case NHDriverEnum.ADONet
                    Select Case NHDialect
                        Case NHDialectEnum.MsSql2005
                            P = New SqlClient.SqlParameter(CStr(Parameters(I)), Parameters(I + 1))
                            I += 1
                        Case NHDialectEnum.PostgreSQL82
                            Throw New Exception("Not implemented yet!")
                    End Select
            End Select
            ParamsFromArray.Add(P)
        Next
    End Function

    <Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
    Public Function OpenTable(ByVal CmdOrSQLText As Object, Optional ByVal Parameters As Collection = Nothing, Optional ByVal TableName As String = "Table") As AdvancedDataTable
        OpenTable = New AdvancedDataTable(CmdOrSQLText, Parameters, TableName, Me)
    End Function

    Function CreateDataSet() As AdvancedDataSet
        CreateDataSet = New AdvancedDataSet
        CreateDataSet.Con = Me
    End Function

    Public Shared ShouldUseAttributeMapper As Boolean = False
    Public Shared ShouldSaveDebugHBM As Boolean = False

    Public Function CreateNHSF(ByVal ParamArray AssemblyNames() As String) As NHibernate.ISessionFactory
        Dim Cfg As New NHibernate.Cfg.Configuration
        Cfg.SetProperty(NHibernate.Cfg.Environment.ProxyFactoryFactoryClass, "NHibernate.ByteCode.Castle.ProxyFactoryFactory, NHibernate.ByteCode.Castle")
        Cfg.SetProperty(NHibernate.Cfg.Environment.Dialect, NHDialectStr)

        '----------Use one of them: no preconnection --------
        Cfg.SetProperty(NHibernate.Cfg.Environment.Hbm2ddlKeyWords, "none")
        '--- or preconnection keywords test
        'Cfg.SetProperty(NHibernate.Cfg.Environment.ConnectionProvider, "NHibernate.Connection.DriverConnectionProvider")
        'Cfg.SetProperty(NHibernate.Cfg.Environment.ConnectionString, ConStr)
        '----------------------------------------------------

        Cfg.SetProperty(NHibernate.Cfg.Environment.PropertyUseReflectionOptimizer, "true")
        Cfg.Properties("SkipOrdering") = CStr(True)

        For Each BLNamespace As String In AssemblyNames
            If ShouldUseAttributeMapper Then
                Dim A As Assembly = Assembly.Load(BLNamespace)
                With NHibernate.Mapping.Attributes.HbmSerializer.Default
                    .Validate = True
                    .HbmAssembly = A.FullName
                    .HbmNamespace = BLNamespace
                    .HbmDefaultLazy = False
                    If ShouldSaveDebugHBM Then
                        .Serialize(System.Environment.CurrentDirectory, A) ' Save to hbm file
                    End If
                    Dim MemStream = .Serialize(A)
                    Cfg.AddInputStream(MemStream)
                End With
            Else ' Read ready mapping from an assembly resource
                Try
                    Cfg.AddAssembly(BLNamespace) 'read from BLNamespace.dll
                Catch ex As NHibernate.MappingException
                    ' For ILMerged executable containing all DLLs need renaming of assemblyname
                    If TypeOf ex.InnerException Is System.IO.FileNotFoundException Then
                        AddMappingFromMergedExecutableResource(Cfg, BLNamespace)
                    End If
                End Try
            End If
        Next

        '==== Following code needs changed assemblyname in the each *.hbm.xml which is inconvenient
        'Try
        '    'MsgBox("Assembly name: " & Me.GetType.Assembly.FullName)
        '    Cfg.AddAssembly(Me.GetType.Assembly)
        'Catch ex As Exception
        '    MsgBox(ex.ToString)
        'End Try
        '=======

        'Cfg.AddDirectory(New System.IO.DirectoryInfo(System.Environment.CurrentDirectory)) ' parse *.hbm files
        Try
            CreateNHSF = Cfg.BuildSessionFactory()
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try
    End Function

    Sub AddMappingFromMergedExecutableResource(ByVal Cfg As NHibernate.Cfg.Configuration, ByVal BLNamespace As String)
        Dim MergedExecutable = Assembly.GetExecutingAssembly
        Dim MappingText = New IO.StreamReader(MergedExecutable.GetManifestResourceStream(BLNamespace & ".HibernatedObjects.hbm.xml")).ReadToEnd()

        'Replace in <hibernate-mapping xxx assembly="Aulix.Common7.BL" xxx>
        Dim RegEx = CreateRegex("(?<Before>[<\s].*assembly="")(?<AN>[\S]*)(?<After>"".*[>\s])")
        MappingText = RegEx.Replace(MappingText, "${Before}" & MergedExecutable.FullName & "${After}")

        Cfg.AddXml(MappingText)
    End Sub

    Public Function OpenNHS() As NHibernate.ISession
        OpenNHS = NHSF.OpenSession(Con)
    End Function

    Public Function Load(<RummageAssumeTypeSafeAttribute()> ByVal T As Type, ByVal Id As Int32) As NHObject
        If Id = 0 Then
            Return Nothing
        End If
        Load = CType(NHS.Load(T, Id), NHObject)
        With Load
            .Con = Me
            .Reload()
        End With
    End Function

    Public Function Load(<RummageAssumeTypeSafeAttribute()> ByVal T As Type, ByVal CmdOrSQLText As Object, Optional ByVal Parameters As Collection = Nothing, Optional ByVal FieldName As String = "") As NHObject
        Load = Load(T, CLng(GetScalar(CmdOrSQLText, Parameters, FieldName)))
    End Function

    Public Sub Test()
        Test(ConStr)
    End Sub

    Public Shared Function Test(ByVal ConStr As String, Optional ByVal Verbose As Boolean = True) As Boolean
        Test = False
        Try
            Dim Con As New AdvancedConnection(ConStr, , False)
            If Con.Con.State = ConnectionState.Open Then
                If Verbose Then
                    MsgBox("Successful connection!")
                End If
                Test = True
            Else
                MsgBox("Connection state: " & Con.Con.State.ToString)
            End If
            Con.Close()
        Catch ex As Exception
            MsgBox(ex.Message, MsgBoxStyle.Critical)
        End Try
    End Function
End Class

Public Class AdvancedDataTable
    Inherits System.Data.DataTable
    Public Con As AdvancedConnection
    Public Adapter As System.Data.Common.DbDataAdapter 'System.Data.IDbDataAdapter
    Public CB As System.Data.Common.DbCommandBuilder
    Public Row As System.Data.DataRow

    Sub Close(Optional ByVal TableName As String = "Table")
        Adapter = Nothing
        If Not IsNothing(DataSet) Then
            Try
                DataSet.Tables.Remove(Me)
            Catch ex As System.Exception
            End Try
        End If
    End Sub

    Public ReadOnly Property IsLastRow() As Boolean
        Get
            If HasRows Then
                IsLastRow = Row Is Rows(Rows.Count - 1)
            End If
        End Get
    End Property

    Public ReadOnly Property HasRows() As Boolean
        Get
            HasRows = Rows.Count > 0
        End Get
    End Property

    Function AddNewRow() As System.Data.DataRow
        AddNewRow = NewRow()
        'PrimaryKey(0).AllowDBNull = True
        'Select Case PrimaryKey(0).DataType.
        '    Case is GetType(String)
        'End Select
        Rows.Add(AddNewRow)
        Row = AddNewRow
    End Function

    Default Public Property Item(ByVal FieldSpecifier As String) As Object
        Get
            Return Row.Item(FieldSpecifier)
        End Get
        Set(ByVal value As Object)
            Row.Item(FieldSpecifier) = value
        End Set
    End Property

    Default Public Property Item(ByVal FieldSpecifier As Integer) As Object
        Get
            Return Row.Item(FieldSpecifier)
        End Get
        Set(ByVal value As Object)
            Row.Item(FieldSpecifier) = value
        End Set
    End Property

    Sub Save()
        Try
            Adapter.Update(Me)
        Catch ex As System.Exception
        End Try
    End Sub

    'Function BatchUpdate()
    '    Select Case Con.NHDriver
    '        Case AdvancedConnection.NHDriverEnum.ODBC
    '            Dim ODBCAdapter As Odbc.OdbcDataAdapter = Adapter
    '            ODBCAdapter.Update(Me)
    '        Case AdvancedConnection.NHDriverEnum.SQLClient
    '            Dim SQLClientAdapter As SqlClient.SqlDataAdapter = Adapter
    '            SQLClientAdapter.Update(Me)
    '    End Select
    'End Function

    Public ShouldDisplayMessages As Boolean = True
    Friend Sub DA_RowUpdated(ByVal sender As Object, ByVal e As System.Data.Odbc.OdbcRowUpdatedEventArgs)
        CommonDA_RowUpdated(sender, e)
    End Sub
    Friend Sub DA_RowUpdated(ByVal sender As Object, ByVal e As System.Data.OleDb.OleDbRowUpdatedEventArgs)
        CommonDA_RowUpdated(sender, e)
    End Sub
    Friend Sub DA_RowUpdated(ByVal sender As Object, ByVal e As System.Data.SqlClient.SqlRowUpdatedEventArgs)
        CommonDA_RowUpdated(sender, e)
    End Sub
    Friend Sub DA_RowUpdated(ByVal sender As Object, ByVal e As NpgsqlRowUpdatedEventArgs)
        CommonDA_RowUpdated(sender, e)
    End Sub
    Public Function PKColumn() As System.Data.DataColumn
        PKColumn = Columns(0) 'PrimaryKey(0)
    End Function
    Public Function IsNumericPK() As Boolean
        IsNumericPK = PKColumn.DataType Is GetType(Int32) Or PKColumn.DataType Is GetType(Int64)
    End Function
    Private Sub CommonDA_RowUpdated(ByVal sender As Object, ByVal e As System.Data.Common.RowUpdatedEventArgs)
        'If e.RowCount > 1 Then !!! ' UpdateBatchSize>1
        'End If
        If e.StatementType = StatementType.Insert And e.Status = UpdateStatus.[Continue] Then
            If IsNumericPK() Then
                Dim IdentityValue As Object
                Select Case Con.NHDriver
                    Case AdvancedConnection.NHDriverEnum.ADONet
                        Select Case Con.NHDialect
                            Case AdvancedConnection.NHDialectEnum.MsSql2005
                                IdentityValue = Con.GetScalar("select @@identity")
                            Case AdvancedConnection.NHDialectEnum.PostgreSQL82
                                Throw New Exception("Not implemented yet!")
                        End Select
                    Case AdvancedConnection.NHDriverEnum.OLEDB
                        Select Case Con.NHDialect
                            Case AdvancedConnection.NHDialectEnum.JetDialect
                                IdentityValue = Con.GetScalar("SELECT @@IDENTITY")
                        End Select
                    Case AdvancedConnection.NHDriverEnum.ODBC
                        Select Case Con.NHDialect
                            Case AdvancedConnection.NHDialectEnum.MySQL
                                IdentityValue = Con.GetScalar("select LAST_INSERT_ID();")
                            Case AdvancedConnection.NHDialectEnum.PostgreSQL82
                                IdentityValue = Con.GetScalar("select lastval();")
                        End Select
                End Select
                If Not IsBlank(IdentityValue) Then
                    e.Row.Item(PKColumn.Ordinal) = CLng(IdentityValue)
                    e.Row.AcceptChanges()
                End If
            End If
        End If
        If (e.StatementType = StatementType.Delete Or e.StatementType = StatementType.Batch) And e.Status = UpdateStatus.ErrorsOccurred Then
            If TypeOf e.Errors Is DBConcurrencyException Then
                e.Status = UpdateStatus.ErrorsOccurred ' Generates an exception in Save: Adapter.Update 
                RejectChanges()
                DisplayMessageIfNeeded("ConcurrencyConflict", e.Errors)
            ElseIf TypeOf e.Errors Is System.Data.SqlClient.SqlException Then
                Dim SQLEx As System.Data.SqlClient.SqlException = CType(e.Errors, System.Data.SqlClient.SqlException)
                If SQLEx.ErrorCode = -2146232060 Then 'More info in the SQLEx.Errors (two items)
                    If SQLEx.Message.StartsWith("The DELETE statement conflicted with the SAME TABLE REFERENCE constraint") Then
                        e.Status = UpdateStatus.ErrorsOccurred     ' Generates an exception in Save: Adapter.Update 
                        RejectChanges()
                        DisplayMessageIfNeeded("DeleteSameTableReferenceConflict", SQLEx)
                    Else
                        e.Status = UpdateStatus.ErrorsOccurred ' Generates an exception in Save: Adapter.Update 
                        RejectChanges()
                        DisplayMessageIfNeeded("DeleteReferenceConflict", SQLEx)
                    End If
                End If
            End If
        End If
    End Sub

    Sub DisplayMessageIfNeeded(ByVal Key As String, Optional ByVal Ex As Exception = Nothing)
        If ShouldDisplayMessages Then
            MsgBox(Messages.GetMessage(Key))
        Else
            If IsNothing(Ex) Then
                Ex = New Exception
            End If
            Throw New System.Exception(Messages.GetMessage(Key) & "; " & Ex.ToString)
        End If
    End Sub

    'This is a fix for DataSet.GetChanges to work
    Public Sub New()
    End Sub

    'Shall be called AFTER DataSet.EnableServerSideDeleteCascades to override it for a specific table
    Public Sub EnableClientSideDeleteCascade()
        For Each R As DataRelation In Me.ParentRelations
            Dim C As System.Data.Constraint = R.ChildKeyConstraint
            If TypeOf C Is ForeignKeyConstraint Then
                Dim FKC = CType(C, ForeignKeyConstraint)
                FKC.DeleteRule = Rule.Cascade
                FKC.AcceptRejectRule = AcceptRejectRule.None
            End If
        Next
    End Sub

    Public Sub New(ByVal CmdOrSQLText As Object, Optional ByVal Parameters As Collection = Nothing, Optional ByVal TableName_ As String = "Table", Optional ByVal Con_ As AdvancedConnection = Nothing)
        TableName = TableName_
        If IsNothing(Con_) Then
            Con = SharedCon
        Else
            Con = Con_
        End If
        Adapter = Con.CreateAdapter(Con.CreateCommand(CmdOrSQLText, Parameters))
        Con.UpdateCommandTimeout(Adapter.SelectCommand)
        Select Case Con.NHDriver
            Case AdvancedConnection.NHDriverEnum.ODBC
                Dim ODBCAdapter As Odbc.OdbcDataAdapter = CType(Adapter, System.Data.Odbc.OdbcDataAdapter)
                ODBCAdapter.Fill(Me)
                AddHandler ODBCAdapter.RowUpdated, AddressOf DA_RowUpdated
            Case AdvancedConnection.NHDriverEnum.OLEDB
                Dim OLEDBAdapter As OleDb.OleDbDataAdapter = CType(Adapter, System.Data.OleDb.OleDbDataAdapter)
                OLEDBAdapter.Fill(Me)
                AddHandler OLEDBAdapter.RowUpdated, AddressOf DA_RowUpdated
            Case AdvancedConnection.NHDriverEnum.ADONet
                Select Case Con.NHDialect
                    Case AdvancedConnection.NHDialectEnum.MsSql2005
                        Dim SQLClientAdapter As SqlClient.SqlDataAdapter = CType(Adapter, System.Data.SqlClient.SqlDataAdapter)
                        SQLClientAdapter.UpdateBatchSize = 1000
                        SQLClientAdapter.Fill(Me)
                        AddHandler SQLClientAdapter.RowUpdated, AddressOf DA_RowUpdated
                    Case AdvancedConnection.NHDialectEnum.PostgreSQL82
                        Dim NPGSQLAdapter As Npgsql.NpgsqlDataAdapter = CType(Adapter, Npgsql.NpgsqlDataAdapter)
                        '!!!NPGSQLAdapter.UpdateBatchSize = 1000
                        NPGSQLAdapter.Fill(Me)
                        AddHandler NPGSQLAdapter.RowUpdated, AddressOf DA_RowUpdated
                        'Throw New Exception("Not implemented yet!")
                End Select
        End Select
        CreateCommandBuilder()
        If HasRows() Then
            Row = Rows(0)
        End If
    End Sub

    Public Sub CreateCommandBuilder()
        Select Case Con.NHDriver
            Case AdvancedConnection.NHDriverEnum.ODBC
                CB = New System.Data.Odbc.OdbcCommandBuilder(CType(Adapter, System.Data.Odbc.OdbcDataAdapter))
            Case AdvancedConnection.NHDriverEnum.OLEDB
                CB = New System.Data.OleDb.OleDbCommandBuilder(CType(Adapter, System.Data.OleDb.OleDbDataAdapter))
            Case AdvancedConnection.NHDriverEnum.ADONet
                Select Case Con.NHDialect
                    Case AdvancedConnection.NHDialectEnum.MsSql2005
                        CB = New System.Data.SqlClient.SqlCommandBuilder(CType(Adapter, System.Data.SqlClient.SqlDataAdapter))
                    Case AdvancedConnection.NHDialectEnum.PostgreSQL82
                        CB = New Npgsql.NpgsqlCommandBuilder(CType(Adapter, Npgsql.NpgsqlDataAdapter))
                End Select
        End Select
        CB.ConflictOption = ConflictOption.OverwriteChanges
        CB.SetAllValues = False
        Con.UpdateCommandTimeout(Adapter.UpdateCommand)
        Con.UpdateCommandTimeout(Adapter.DeleteCommand)
        Con.UpdateCommandTimeout(Adapter.InsertCommand)
    End Sub

    Public Sub UsePK()
        Dim DCA() As System.Data.DataColumn = {PKColumn()}
        PrimaryKey = DCA
        With PrimaryKey(0)
            .AllowDBNull = True
        End With
        CreateCommandBuilder()
    End Sub
End Class

Public Class AdvancedDataSet
    Inherits System.Data.DataSet
    Public Con As AdvancedConnection

    Public Function T(Optional ByVal TableName As String = "Table") As AdvancedDataTable
        T = CType(Tables(TableName), AdvancedDataTable)
    End Function

    Public Sub CloseTables()
        Relations.Clear()
        For Each Table As AdvancedDataTable In Tables
            Table.Constraints.Clear()
        Next
        Tables.Clear()
    End Sub
    Public Function OpenTable(ByVal CmdOrSQLText As Object, Optional ByVal Parameters As Collection = Nothing, Optional ByVal TableName As String = "Table") As AdvancedDataTable
        Try
            T(TableName).Close()
        Catch ex As System.Exception
        End Try
        OpenTable = Con.OpenTable(CmdOrSQLText, Parameters, TableName)
        Tables.Add(OpenTable)
    End Function

    Public Sub Save()
        If HasChanges() Then
            For Each T As AdvancedDataTable In Tables
                T.Save()
            Next
        End If
    End Sub


    'Shall be called BEFORE AdvancedDataTable.EnableClientSideDeleteCascade, 
    'otherwise it overrides the settings in all tables in the whole dataset
    Sub EnableServerSideDeleteCascades() ' For all the tables having it on the SQL server side
        For Each T As System.Data.DataTable In Me.Tables
            For Each R As DataRelation In T.ParentRelations
                Dim C As System.Data.Constraint = R.ChildKeyConstraint
                If TypeOf C Is ForeignKeyConstraint Then
                    Dim FKC = CType(C, ForeignKeyConstraint)
                    If FKC.DeleteRule = Rule.Cascade Then
                        FKC.AcceptRejectRule = AcceptRejectRule.Cascade
                    End If
                End If
            Next
        Next
    End Sub
End Class

Public MustInherit Class NHObject
    Protected Id_ As Integer

    <Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
    Public Overridable Property Id() As Integer
        Get
            Return Id_
        End Get
        Set(ByVal value As Integer)
            Id_ = value
        End Set
    End Property

    Private Con_ As AdvancedConnection
    Public Overridable Property Con() As AdvancedConnection
        Get
            If IsNothing(Con_) Then
                Con = SharedCon
            Else
                Con = Con_
            End If
        End Get
        Set(ByVal value As AdvancedConnection)
            Con_ = value
        End Set
    End Property

    Public Overrides Function Equals(ByVal Obj As Object) As Boolean
        If ReferenceEquals(Me, Obj) Then
            Return True
        End If
        If IsNothing(Obj) OrElse Not Equals(Obj.GetType(), Me.GetType()) Then
            Return False
        End If
        Dim castObj As NHObject = CType(Obj, NHObject)
        Return Not IsNothing(castObj) AndAlso Me.Id = castObj.Id
    End Function

    Public Overrides Function GetHashCode() As Integer
        GetHashCode = 27 * 57 * Id.GetHashCode
    End Function

    Public Shared Function Load(<RummageAssumeTypeSafeAttribute()> ByVal T As Type, ByVal Id As Int32) As NHObject
        Load = SharedCon.Load(T, Id)
    End Function

    Public Overridable Sub Reload()
        Con.NHS.Refresh(Me)
    End Sub

    Public Overridable Sub Save(Optional ByVal ConForNewObject As AdvancedConnection = Nothing)
        If IsNothing(Con_) And Not IsNothing(ConForNewObject) Then
            Con_ = ConForNewObject
        End If
        Con.NHS.SaveOrUpdate(Me)
        Con.NHS.Flush()
    End Sub

    Public Overridable Sub Flush()
        Con.NHS.Flush()
    End Sub

    Public Overridable Sub Evict(Optional ByVal T As Type = Nothing)
        Con.NHS.Evict(Me)
        If Not IsNothing(T) Then
            Con.NHS.SessionFactory.Evict(T, Id)
        End If
    End Sub
End Class

Public Module Declarations
    Function StartProcess(ByVal P As System.Diagnostics.Process, Optional ByVal ShouldLog As Boolean = False, Optional ByVal UserId As Object = Nothing, Optional ByVal Timeout As Long = 0) As String
        With P.StartInfo
            If Not IsRunningUnderUnix() Then
                Dim UserName As String = CStr(Microsoft.VisualBasic.Interaction.CallByName(P.StartInfo, "UserName", CallType.Get))
                If Not IsBlank(UserName) And IsBlank(.WorkingDirectory) Then
                    .WorkingDirectory = InstallDir()
                End If
            End If
            P.Start()
            If .RedirectStandardOutput Then
                StartProcess = P.StandardOutput.ReadToEnd()
                StartProcess &= vbNewLine & P.StandardError.ReadToEnd()
            End If
        End With
        If Timeout = 0 Then
            P.WaitForExit()
        Else
            P.WaitForExit(CInt(Timeout * 1000))
            If Not P.HasExited Then
                Try
                    P.Kill()
                Catch ex As System.Exception
                End Try
            End If
        End If
        If ShouldLog Then
            If CInt(ConfigurationValue("DebugLevel")) > 0 Then
                Aulix.Common7.Data.Declarations.LogEvent(UserId, "Debug: Shell: " & P.StartInfo.FileName & " " & P.StartInfo.Arguments & vbNewLine & StartProcess)
            End If
        End If
    End Function
    Public ShellProcess As System.Diagnostics.Process
    Function Shell2(ByVal CmdText As String, ByVal Args As String, Optional ByVal Redirect As Boolean = True) As String
        ShellProcess = Nothing
        ShellProcess = Aulix.Common7.Utils.AulixDeclarations.CreateProcess(CmdText, Args, Redirect)
        Shell2 = StartProcess(ShellProcess, False)
    End Function

    Function LoggedShell(ByVal CmdText As String, ByVal Args As String, Optional ByVal UserId As Object = Nothing, Optional ByVal Timeout As Long = 0) As String
        Dim P As System.Diagnostics.Process = CreateProcess(CmdText, Args, True)
        LoggedShell = StartProcess(P, True, UserId, Timeout)
    End Function

    Function Bash(ByVal CmdText As String, Optional ByVal RedirectStandardOutput As Boolean = False) As String
        Bash = Shell2("/bin/bash", CmdText, RedirectStandardOutput)
    End Function
    Public Sub AddDirectorySecurity(ByVal FileName As String, ByVal Account As String, Optional ByVal UserId As Long = Nothing)
        LoggedShell("cacls", FileName & " /E /P " & Account & ":F /T /C", UserId)
    End Sub

    Property ConfigurationValue(ByVal KeyName As String) As String
        Get
            If Not IsNothing(SharedCon) Then 'AndAlso SharedCon.IsAlive 
                ConfigurationValue = NZ(SharedCon.GetScalar("select Value from aulix_Configuration where Name=" & Arg(KeyName))).ToString
            End If
        End Get
        Set(ByVal Value As String)
            With SharedCon.OpenTable("select Id, Name, Value from aulix_Configuration where Name=" & Arg(KeyName))
                If Not .HasRows Then
                    .AddNewRow()
                    .Row("Name") = KeyName
                End If
                .Row("Value") = Value
                .Save()
            End With
        End Set
    End Property
    Public Class HostAndPort
        Private HostAndPortArray() As String

        Public Sub New(ByVal KeyName As String, Optional ByVal DefaultPort As Integer = 0)
            HostAndPortArray = ReadFromConfigAsArray(KeyName, DefaultPort)
        End Sub

        Public Sub New()
        End Sub

        'Public Sub New(ByVal Host As String, ByVal Port As Integer)
        '    With Me
        '        .HostAndPortArray = New String() {"", ""}
        '        .HostAndPortArray(0) = Host
        '        .HostAndPortArray(1) = Port
        '    End With
        'End Sub

        Public Shared Function Create(ByVal Host As String, ByVal Port As Integer) As HostAndPort
            Create = New HostAndPort()
            With Create
                .HostAndPortArray = New String() {"", ""}
                .HostAndPortArray(0) = Host
                .HostAndPortArray(1) = Port.ToString
            End With
        End Function

        'Public Shared Function ReadFromConfig(ByVal KeyName As String, Optional ByVal DefaultPort As Integer = 0) As HostAndPort
        '    ReadFromConfig = New HostAndPort(KeyName, DefaultPort)
        '    'ReadFromConfig.HostAndPortArray = ReadFromConfigAsArray(KeyName, DefaultPort)
        'End Function

        Public ReadOnly Property Host() As String
            Get
                Host = HostAndPortArray(0)
            End Get
        End Property
        Public ReadOnly Property Port() As Integer
            Get
                Port = CInt(HostAndPortArray(1))
            End Get
        End Property

        Private Shared Function ReadFromConfigAsArray(ByVal KeyName As String, ByVal DefaultPort As Integer) As String()
            Dim Result() As String = {"", ""}
            Dim HostAndPort = ConfigurationValue(KeyName)
            Dim A = Split(HostAndPort, ":")
            Result(0) = A(0)
            Try
                Result(1) = A(1)
            Catch ex As System.IndexOutOfRangeException
                Result(1) = DefaultPort.ToString
            End Try
            Return Result
        End Function

    End Class

    Public SendMailCredential As System.Net.NetworkCredential
    Function SendMail(ByVal FromEMail As String, ByVal FromName As String, ByVal ToEMail As String, ByVal ToName As String, ByVal Subject As String, ByVal Body As String, Optional ByVal BCCAddress As System.Net.Mail.MailAddress = Nothing) As Boolean
        SendMail = False
        Try
            Dim M As New System.Net.Mail.MailMessage(New System.Net.Mail.MailAddress(FromEMail, FromName), New System.Net.Mail.MailAddress(ToEMail, ToName))
            If Not IsNothing(BCCAddress) Then
                M.Bcc.Add(BCCAddress)
            End If
            M.Subject = Subject
            M.Body = Body
            M.IsBodyHtml = True
            M.BodyEncoding = System.Text.Encoding.ASCII
            Dim SMTPHost As String = ConfigurationValue("SMTPHost")
            Dim SMTPClient As New System.Net.Mail.SmtpClient(SMTPHost)
            If IsNothing(SendMailCredential) Then
                SMTPClient.UseDefaultCredentials = True
            Else
                SMTPClient.Credentials = SendMailCredential
            End If
            SMTPClient.Send(M)
            SendMail = True
        Catch ex As System.Exception
            LogEvent(Nothing, ex.ToString)
        End Try
    End Function

    Sub LogEvent(ByVal UserId As Object, ByVal Description As String)
        Try
            With SharedCon.OpenTable("select * from aulix_EventLog where 1=0")
                .AddNewRow()
                .Row("Date") = Now
                If Not IsBlank(UserId) Then
                    .Row("UserId") = CInt(UserId)
                Else
                    .Row("UserId") = DBNull.Value
                End If
                .Row("Host") = System.Net.Dns.GetHostName()
                .Row("Description") = Description
                .Save()
            End With
        Catch ex As Exception
            Static EL As EventLog
            If IsNothing(EL) Then
                If Not EventLog.SourceExists("AulixCommon7") Then
                    EventLog.CreateEventSource("AulixCommon7", "AulixCommon7")
                End If
                EL = New EventLog("AulixCommon7")
                EL.Source = "AulixCommon7"
            End If
            EL.WriteEntry(Description)
        End Try
    End Sub
End Module
Public Class AdvancedNetworkCredential
    Inherits System.Net.NetworkCredential
    Function UserNameWithDomain() As String
        UserNameWithDomain = Domain & "\" & UserName
    End Function
    Public Sub New(ByVal ConfigurationUserName As String)
        MyBase.New(ConfigurationUserName, ConfigurationValue(ConfigurationUserName & "Password"), ConfigurationValue("NTDomainName"))
    End Sub
End Class

<Serializable()> Public MustInherit Class CSLAObject(Of T As CSLAObject(Of T))
    Inherits Csla.BusinessBase(Of T) ' or a polymorphic non generic Csla.BusinessBase? !!!

    'Public Id As Integer
    Protected Id_ As Integer
    '<NHibernate.Mapping.Attributes.Generator(1, Class:="sequence")> _
    '<NHibernate.Mapping.Attributes.Param(2, Name:="sequence", Content:="hibernate_sequence")> _
    '<NHibernate.Mapping.Attributes.Id(0, Name:="Id", Column:="id", Type:="System.Int32", UnsavedValue:="0")> _
    Public Overridable Property Id() As Integer
        Get
            Return Id_
        End Get
        Set(ByVal value As Integer)
            Id_ = value
        End Set
    End Property

    Private Con_ As AdvancedConnection
    Public Overridable Property Con() As AdvancedConnection
        Get
            If IsNothing(Con_) Then
                Con = SharedCon
            Else
                Con = Con_
            End If
        End Get
        Set(ByVal value As AdvancedConnection)
            Con_ = value
        End Set
    End Property

    Public Overrides Function Equals(ByVal Obj As Object) As Boolean
        If ReferenceEquals(Me, Obj) Then
            Return True
        End If
        If IsNothing(Obj) OrElse Not Equals(Obj.GetType(), Me.GetType()) Then
            Return False
        End If
        Dim castObj As NHObject = CType(Obj, NHObject)
        Return Not IsNothing(castObj) AndAlso Me.Id = castObj.Id
    End Function

    Public Overrides Function GetHashCode() As Integer
        GetHashCode = 27 * 57 * Id.GetHashCode
    End Function

    Public Shared Function Load(ByVal T As Type, ByVal Id As Int32) As NHObject
        Load = SharedCon.Load(T, Id)
    End Function

    Public Overridable Sub Reload()
        Con.NHS.Refresh(Me)
    End Sub

    Public Overridable Sub Save(Optional ByVal ConForNewObject As AdvancedConnection = Nothing)
        If IsNothing(Con_) And Not IsNothing(ConForNewObject) Then
            Con_ = ConForNewObject
        End If
        Con.NHS.SaveOrUpdate(Me)
        Con.NHS.Flush()
    End Sub

    Public Overridable Sub Flush()
        Con.NHS.Flush()
    End Sub

    Public Overridable Sub Evict(Optional ByVal T As Type = Nothing)
        Con.NHS.Evict(Me)
        If Not IsNothing(T) Then
            Con.NHS.SessionFactory.Evict(T, Id)
        End If
    End Sub

    Protected Overrides Function GetIdValue() As Object

    End Function
End Class

'Delegate Function ActionHandlerDelegate(ByVal MethodName As String, ByRef DataObject As Object) As Boolean
'Public ActionHandler As ActionHandlerDelegate

'Public Sub New(ByVal CBH As ActionHandlerDelegate, Optional ByVal HAP As HostAndPort = Nothing)
'    If Not HAP Is Nothing Then
'        URLHAP = HAP
'    End If
'    ActionHandler = CBH
'End Sub

