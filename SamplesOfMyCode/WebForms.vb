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


Public Class MasterPageBase
    Inherits System.Web.UI.MasterPage

    Public IsNavigationVisible As Boolean = False
    Public IsInfoMessageVisible As Boolean = True
    Public IsBottomInfoVisible As Boolean = True
    Public IsMainMenuVisible As Boolean = True
    Public IsPageHeaderVisible As Boolean = True

    Public Shadows ReadOnly Property Page() As PageBase
        Get
            Try
                Return MyBase.Page
            Catch
            End Try
        End Get
    End Property

    Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        CObj(FindControl("PageHeader")).Text = Application("PageHeader")
        CObj(FindControl("InfoMessage")).Text = ""
        If Session("InfoMessage") <> "" Then
            Page.DisplayInfoMessage(Session("InfoMessage"))
            Session("InfoMessage") = ""
        End If
        'CObj(FindControl("PageFooter")).Text = Application("PageFooter")
    End Sub
End Class


Public Class PageBase
    Inherits System.Web.UI.Page

    Public Delegate Function MemberTrackerDelegate(ByVal Page As PageBase, ByVal Parameter1 As Object)
    Public Shared MemberTracker As MemberTrackerDelegate

    Function IsLoggedIn()
        If IsNumeric(Session("UserId")) Then
            IsLoggedIn = Session("UserId") <> 0
        End If
    End Function

    Public Shared Function GetControlById(ByVal Id As String, ByVal Container As Object) As Web.UI.Control
        Dim C As Web.UI.Control
        For Each C In Container.Controls
            If C.ID = Id Then
                Return C
            End If
        Next
    End Function

    Public Function GetControlById(ByVal Id As String) As Object
        GetControlById = GetControlById(Id, Me)
    End Function

    Public Shared Function LoadConfiguration(ByVal Application As System.Web.HttpApplicationState)
        Application.Lock()
        With SharedCon.OpenTable("select * from aulix_Configuration")
            For Each .Row In .Rows
                Dim KeyName As String
                Try
                    KeyName = .Row("Name")
                    Application(KeyName) = CStr(.Row("Value"))
                Catch ex As Exception
                End Try
            Next
        End With
        Application.UnLock()
    End Function

    Public Function DisplayInfoMessage(ByVal Message As String)
        CObj(Page.Form.FindControl("InfoMessage")).Text &= Message
    End Function
    Public Function DisplayCrossPageInfoMessage(ByVal Message As String)
        Session("InfoMessage") &= Message
    End Function
    Public Function SetFormHeader(ByVal Header As String)
        CObj(Page.Form.FindControl("FormHeader")).Text = Header
    End Function

    Public Function ClearInfoMessage(ByVal Message As String)
        CObj(Page.Form.FindControl("InfoMessage")).Text = ""
    End Function
    Public Function DisplayBottomInfo(ByVal Message As String)
        CObj(Page.Form.FindControl("BottomInfo")).Text = Message
    End Function

    Private Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Error
        If TypeOf Context.Error Is System.FormatException Then
            DisplayCrossPageInfoMessage(Messages.GetMessage("IncorrectDataEntered"))
            Response.Redirect(Request.Url.AbsoluteUri)
        End If
    End Sub

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        With Response
            .Expires = 0
            .ExpiresAbsolute = #1/1/1900#
            .AddHeader("pragma", "no-cache")
            .AddHeader("cache-control", "private")
            .CacheControl = "no-cache"
        End With
        If IsBlank(Session("UserId")) Then
            Session("UserId") = 0
        Else
            CheckShouldLogout()
        End If
    End Sub

    'Private Sub Page_PreInit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreInit
    '    Theme = "Default"
    'End Sub
    Public Function Logout(Optional ByVal RedirectToLogin As Boolean = True, Optional ByVal InfoMessage As String = "")
        Application.Lock()
        CType(Application("Sessions"), Hashtable).Remove(Session.SessionID)
        Application.UnLock()
        Session.Clear()
        Session.Abandon()
        If RedirectToLogin Then
            Response.Redirect("/ACommon/Login.aspx?InfoMessage=" & InfoMessage, True)
        Else
            DisplayInfoMessage(InfoMessage)
        End If
    End Function

    Public Function CheckShouldLogout() As Boolean
        CheckShouldLogout = Session("ShouldLogout")
        If CheckShouldLogout Then
            Logout(True, "Your account has been used from another computer. Your session has been closed.")
        End If
    End Function

    Public Function CreateDHTMLMenuItem(ByVal Text As String, Optional ByVal URL As String = "", Optional ByVal Icon As String = "", Optional ByVal Submenu As String = "") As String
        CreateDHTMLMenuItem = "[""" & Text & """,""" & URL & ""","
        If Not IsBlank(Icon) Then
            CreateDHTMLMenuItem &= """" & Icon & """"
        End If
        If Not IsBlank(Submenu) Then
            CreateDHTMLMenuItem &= "," & Submenu
        End If
        CreateDHTMLMenuItem &= "]"
    End Function

    Function CreateDHTMLMenuArray(ByVal ParamArray MenuArray() As String) As String
        CreateDHTMLMenuArray = "["
        For Each M As String In MenuArray
            CreateDHTMLMenuArray &= M & ","
        Next
        Mid(CreateDHTMLMenuArray, CreateDHTMLMenuArray.Length, 1) = "]"
    End Function

    'Public Function CreateDHTMLMenu(ByVal MenuName As String, ByVal ParamArray MenuArray() As String) As String
    '    CreateDHTMLMenu = "<script>CreateDHTMLMenu(" & MenuName & "," & CreateDHTMLMenuArray(MenuArray) & ")</script>"
    'End Function

    Public Function WriteDHTMLMenuItem(ByVal Text As String, Optional ByVal URL As String = "", Optional ByVal Icon As String = "", Optional ByVal Submenu As String = "") As String
        Response.Write(CreateDHTMLMenuItem(Text, URL, Icon, Submenu) & "," & vbNewLine)
    End Function
End Class

Public Class WebcontrolBase
    Inherits WebControl
    Public Shadows ReadOnly Property Page() As PageBase
        Get
            Try
                Return MyBase.Page
            Catch
            End Try
        End Get
    End Property
End Class


Public Class ClickButton
    Inherits UI.WebControls.Button

    Public IsTrueClick As Boolean
    Protected OldHFValue As Long

    Private Sub ClickButton_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Click
        IsTrueClick = Page.Request.Form(HFName) = OldHFValue
    End Sub

    Private Sub ClickButton_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        Page.ClientScript.RegisterHiddenField(HFName, 1)
    End Sub

    Function HFName() As String
        HFName = ClientID & "_HF"
    End Function

    Private Sub ClickButton_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        OldHFValue = Page.Session(HFName)
        Randomize()
        Page.Session(HFName) = CInt(Rnd() * 30000) + 3
        Page.ClientScript.RegisterStartupScript(Me.GetType, ClientID & "Handler", "<script>document.all['" & HFName() & "'].value=" & Page.Session(HFName) & "; </script>")
    End Sub
End Class

'Public Function SpecifyDefaultButtonForTextBox(ByRef TB As System.Web.UI.WebControls.TextBox, ByRef DefaultButton As System.Web.UI.WebControls.Button)
'    Dim sScript As New System.Text.StringBuilder
'    sScript.Append("<SCRIPT language=""javascript"">" & vbCrLf)
'    sScript.Append("function fnTrapKD(btn){" & vbCrLf)
'    sScript.Append(" if (event.keyCode == 13)" & vbCrLf)
'    sScript.Append(" { " & vbCrLf)
'    sScript.Append(" event.returnValue=false;" & vbCrLf)
'    sScript.Append(" event.cancel = true;" & vbCrLf)
'    sScript.Append(" btn.click();" & vbCrLf)
'    sScript.Append(" } " & vbCrLf)
'    sScript.Append("}" & vbCrLf)
'    sScript.Append("</SCRIPT>" & vbCrLf)
'    TB.Attributes.Add("onkeydown", "fnTrapKD(document.all." & DefaultButton.ClientID & ")")
'    Page.RegisterStartupScript("ForceDefaultToScript", sScript.ToString) '''! renew depricated
'End Function

'Public Function RootURL(Optional ByVal Protocol As String = "http") As String
'    RootURL = Protocol & "://" & Application("all_host")
'    If Not IsBlank(Application("all_virt_dir")) Then
'        RootURL &= "/" & Application("all_virt_dir")
'    End If
'    RootURL &= "/"
'End Function
