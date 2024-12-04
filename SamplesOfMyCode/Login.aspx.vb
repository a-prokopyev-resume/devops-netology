'============================== The Beginning of the Copyright Notice =================================
' THE AULIX.COMMON7 LIBRARY SOFTWARE PRODUCT
' The AUTHOR of this file is Alexander Borisovich Prokopyev, Kurgan, Russia
' More info can be found at the AUTHOR's website: http://www.aulix.com/resume
' Contact: alexander.prokopyev at aulix dot com
' 
' Copyright (c) Alexander Prokopyev, 2006-2010
' 
' All materials contained in this file are protected by copyright law.
' Nobody except the AUTHOR may alter or remove this copyright notice from copies of the content.
' 
' The AUTHOR explicitly prohibits to use this content by any method without a prior 
' written hand-signed permission of the AUTHOR. Examples of the prohibited methods of usage:
' reproduction, distribution, transmition, displaying, publishing, broadcasting or any other.
'
' Simple non-exclusive licenses pending parties' signatures:
'   ACX2010 http://www.aulix.com/ACX2010
'================================= The End of the Copyright Notice ====================================
Imports Aulix.Common7.WebForms
Imports Aulix.Common7.Utils
Imports Aulix.Common7.BL

Partial Class Login
    Inherits UserPageBase
    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        SetFormHeader("Please enter your login information:")
        CType(Master, MainMasterPage).IsClockVisible = True
        If Request.QueryString("EMail") <> "" And Request.QueryString("Password") <> "" Then
            EMail.Text = Request.QueryString("EMail")
            Password.Text = Request.QueryString("Password")
            If Not IsPostBack Then
                With Page.ClientScript
                    .RegisterStartupScript(Page.GetType, "LoginScript", "<script>function ClickLoginBtn(){document.all['" & LoginBtn.ClientID & "'].click(); } setTimeout(ClickLoginBtn, 5000); </script>")
                    DisplayCrossPageInfoMessage("Please wait a few seconds for automatic logon.")
                End With
            End If
        Else
            If Not IsBlank(Request.QueryString("InfoMessage")) Then
                DisplayCrossPageInfoMessage(Request.QueryString("InfoMessage"))
            End If
        End If
    End Sub

    Private Overloads Sub LoginBtn_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles LoginBtn.Click
        U = TryToLogin(EMail.Text, Password.Text, "")
        If Not IsNothing(U) Then
            Application.Lock()
            Dim SessionsHT As Hashtable = Application("Sessions")
            For Each S As HttpSessionState In SessionsHT.Values
                If Session.SessionID <> S.SessionID AndAlso IsNumeric(S("UserId")) AndAlso CLng(S("UserId")) = U.Id Then
                    S("ShouldLogout") = True
                End If
            Next
            SessionsHT(Session.SessionID) = Session
            Application.UnLock()
            If U.IsMember Then
                If IsBlank(MACAddress.MACAddress) Then
                    If Now < U.SignupDate.AddHours(24) Then ' MAC address is blank during first 24 hours
                        Response.Redirect("/ACommon/Subscription.aspx")
                    Else
                        DisplayInfoMessage("Only 24 hours are allowed with blank MAC address and they have expired. Please contact admin to enable your MAC address.")
                        Logout(False)
                    End If
                Else
                    If IsBlank(U.MACAddress) Then 'MAC is supplied for first time
                        U.MACAddress = MACAddress.MACAddress
                        U.Save()
                    End If
                    If U.MACAddress = MACAddress.MACAddress Then 'MAC address is correct
                        Response.Redirect("/ACommon/Subscription.aspx")
                    Else
                        DisplayInfoMessage("It seems you are trying to access the website from a different computer. Please contact admin to update your MAC address.")
                        Logout(False)
                    End If
                End If
            ElseIf U.IsAdmin Or U.IsManager Then
                Response.Redirect("/Admin.aspx")
            Else
                DisplayInfoMessage("Only administrators, managers and students can login to the website.")
                Logout(False)
            End If
        End If
    End Sub
End Class