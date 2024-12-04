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


Imports Aulix.Common7.Utils
Imports Aulix.Common7.Data
Imports Aulix.Common7.WebForms

Public Class UserPageBase
    Inherits PageBase
    Public U As AulixUser
    Public AutoLogin = True

    '!!!Rewrite
    Public Shared Function SendSiteMail(ByVal UserId As Integer, ByRef SpecificEMailTemplateName As String, ByVal ParamArray PA() As String) As Boolean
        CType(SharedCon.Load(GetType(AulixUser), UserId), AulixUser).SendMailByTemplate(SpecificEMailTemplateName, , PA)
        CType(SharedCon.Load(GetType(AulixUser), 155), AulixUser).SendMailByTemplate(SpecificEMailTemplateName, , PA)
    End Function

    Overridable Function TryToLogin(ByVal Login As String, ByVal Password As String, ByVal RedirectTo As String) As AulixUser
        TryToLogin = AulixUser.TryToLogin(Login, Password)
        If Not IsNothing(TryToLogin) Then
            Session("UserId") = TryToLogin.Id
            If Not IsBlank(RedirectTo) Then
                Response.Redirect(RedirectTo, False)
            End If
        Else
            DisplayInfoMessage(Messages.GetMessage("IncorrectLogin"))
        End If
    End Function

    Function RequireLoggedInUser(ByVal RedirectTo As String, Optional ByVal DocumentExpression As String = "")
        If Not IsLoggedIn() Then
            If IsBlank(DocumentExpression) Then
                DocumentExpression = "document"
            End If
            Response.Write("Test")
            ClientScript.RegisterStartupScript(Me.GetType, "RequireLoggedInUser", "<script>Redirect(" & DocumentExpression & ",'" & RedirectTo & "')</script>")
        End If
    End Function

    Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsLoggedIn() Then
            U = AulixUser.Load(Session("UserId")) '!!! should execute AFTER Aulix.Common7.WebForms.Page_Load
        Else
            If Not InStr(Request.Url.AbsolutePath, "Login.aspx", CompareMethod.Text) > 0 Then
                If AutoLogin Then
                    Response.Redirect("/ACommon/Login.aspx")
                End If
            End If
        End If
    End Sub
End Class

Public Class UserMasterPageBase
    Inherits Aulix.Common7.WebForms.MasterPageBase

    Public Shadows ReadOnly Property UserPage() As UserPageBase
        Get
            Try
                Return MyBase.Page
            Catch
            End Try
        End Get
    End Property
End Class
