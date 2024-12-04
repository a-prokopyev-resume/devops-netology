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
Imports Aulix.Common7.Data
Imports Aulix.Common7.BL

Partial Class Profile
    Inherits UserPageBase
    'Dim U As EPMUser !!!
    Dim IsNewProfile As Boolean

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        CType(Master, MainMasterPage).IsClockVisible = True
        IsNewProfile = Not IsLoggedIn()
        If IsNewProfile Then
            SetFormHeader("Create New Profile:")
        Else
            SetFormHeader("Edit Your Profile:")
        End If
        If Not IsPostBack Then
            If Not IsNewProfile Then
                U = EPMUser.Load(Session("UserId"))
                FirstNameTB.Text = NZ(U.FirstName)
                LastNameTB.Text = NZ(U.LastName)
                EMailTB.Text = NZ(U.EMail)
                PasswordTB.Text = NZ(U.Password)
                PasswordConfirmationTB.Text = NZ(U.Password)
            End If
        End If
    End Sub
    Private Sub SaveBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles SaveBtn.Click
        Dim SuchEMailAlreadyExist As Boolean = IsNumeric(SharedCon.GetScalar("select Id from aulix_User where EMail=" & Arg(EMailTB.Text)))
        If Not IsEMailValid(EMailTB.Text) Then
            DisplayInfoMessage("E-mail address you entered looks incorrect. Please fix it and try again.")
        ElseIf Not IsEMailDomainValid(EMailTB.Text) Then
            DisplayInfoMessage("E-mail addresses registered at free mail servers are prohibited. Please use your company e-mail address.")
        ElseIf PasswordTB.Text <> PasswordConfirmationTB.Text Then
            DisplayInfoMessage("Password confirmation differes from the password. Please correct.")
        ElseIf Not IsLoggedIn() And SuchEMailAlreadyExist Then
            DisplayInfoMessage("Such e-mail already exists in the database. Please specify different e-mail.")
        Else
            If IsNewProfile Then
                U = EPMUser.Create()
                U.Customer = AulixUser.FreeMemberGroup
                U.IsMember = True
                If IsBlank(MACAddress.MACAddress) Then
                    DisplayCrossPageInfoMessage("It is not possible to determine your MAC address. In 24 hours you will be able to login only with MAC address. Please contact admin.")
                Else
                    U.MACAddress = MACAddress.MACAddress
                End If
            Else
                U = EPMUser.Load(Session("UserId"))
            End If
            U.FirstName = FirstNameTB.Text
            U.LastName = LastNameTB.Text
            U.EMail = EMailTB.Text
            If PasswordTB.Text <> "" Then
                U.Password = PasswordTB.Text
            End If
            U.Save()
            If IsNewProfile Then
                Session("UserId") = U.Id
            End If
            If U.HasAgreedWithLicense Then
                Response.Redirect("/ACommon/Subscription.aspx")
            Else
                Response.Redirect("/UserAgreement.aspx")
            End If
        End If
    End Sub

    Public Sub New()
        AutoLogin = False
    End Sub
End Class