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
Imports Aulix.Common7.Data
Imports Aulix.Common7.BL

Partial Class ServicePlanPage
    Inherits UserPageBase
    Dim T As AdvancedDataTable
    Function RefreshDS()
        T = SharedCon.OpenTable("select S.Id, IsActive from aulix_Subscription S where S.UserId=" & U.Id)
        EPMSubscription.FillSubscriptionTable(T)
        SubscriptionGrid.DataSource = T
        SubscriptionGrid.DataBind()
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not U.HasAgreedWithLicense Then
            Response.Redirect("/UserAgreement.aspx")
        End If
        SetFormHeader("Your Subscriptions")
        If Not IsPostBack Then
            RefreshDS()
            SubscriptionPlanLE.DataSource = SharedCon.OpenTable("select Id, Name from aulix_SubscriptionPlan where IsVisible=1")
            SubscriptionPlanLE.DataBind()
            SubscriptionPlanTypeRBL.DataSource = Aulix.Common7.Utils.Enum2BindableArray(GetType(SubscriptionPlanTypeEnum))
            SubscriptionPlanTypeRBL.DataBind()
            SubscriptionPlanTypeRBL.SelectedIndex = 0
            RefreshForm()
        End If
    End Sub

    Protected Sub AddCourseBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles AddCourseBtn.Click
        If AddCourseBtn.IsTrueClick Then
            Dim SP As AulixSubscriptionPlan
            Select Case CType(SubscriptionPlanTypeRBL.SelectedItem.Value, SubscriptionPlanTypeEnum)
                Case SubscriptionPlanTypeEnum.General
                    SP = AulixSubscriptionPlan.Load(SubscriptionPlanLE.SelectedValue)
                Case SubscriptionPlanTypeEnum.Token
                    'Dim Q As NHibernate.IQuery
                    'Q = SharedCon.NHS.CreateQuery("from AulixSubscriptionPlan SP where SP.TokenCode=? and SP.Owner=?")
                    'Q.SetString(0, TokenTB.Text)
                    'Q.SetEntity(1, U.Customer)
                    Dim Cr As NHibernate.ICriteria = SharedCon.NHS.CreateCriteria(GetType(AulixSubscriptionPlan), "SP")
                    If Not U.Customer Is AulixUser.FreeMemberGroup Then
                        'Cr.Add(New NHibernate.Expression.EqExpression("SP.Owner", U.Customer))
                        Cr.Add(NHibernate.Criterion.Expression.Eq("SP.Owner", U.Customer))
                    End If
                    'Cr.Add(New NHibernate.Expression.EqExpression("SP.TokenCode", TokenTB.Text))
                    Cr.Add(NHibernate.Criterion.Expression.Eq("SP.TokenCode", TokenTB.Text))
                    Dim L As IList = Cr.List
                    If L.Count = 1 Then
                        SP = L.Item(0)
                    Else
                        DisplayInfoMessage("Such token does not exist for your courses")
                    End If
            End Select
            If Not IsNothing(SP) Then
                Dim Subscr As EPMSubscription = SP.CreateSubscription(U, GetType(EPMSubscription))
                If IsNothing(Subscr) Then
                    DisplayInfoMessage("Subscription has not been created (most likely because more subscriptions of that type not allowed).")
                Else
                    Subscr.DBIsReloadable = True
                    Subscr.Save()
                    RefreshDS()
                    If U.Customer Is AulixUser.FreeMemberGroup And Not IsNothing(SP.Owner) And SP.PlanType = SubscriptionPlanTypeEnum.Token Then ' assign member's customer to token's owner
                        U.Customer = SP.Owner
                        RefreshForm()
                    End If
                End If
            End If
        End If
    End Sub

    Function RefreshForm()
        Select Case CType(SubscriptionPlanTypeRBL.SelectedItem.Value, SubscriptionPlanTypeEnum)
            Case SubscriptionPlanTypeEnum.General
                SubscriptionPlanTR.Visible = True
                TokenTR.Visible = False
            Case SubscriptionPlanTypeEnum.Token
                SubscriptionPlanTR.Visible = False
                TokenTR.Visible = True
        End Select
        If Not IsNothing(U.Customer) Then
            CustomerLbl.Text = U.Customer.FullName
        End If
    End Function

    Protected Sub SubscriptionPlanTypeRBL_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles SubscriptionPlanTypeRBL.SelectedIndexChanged
        RefreshForm()
    End Sub

    Protected Sub SubscriptionGrid_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles SubscriptionGrid.RowCommand
        Dim SubscriptionId As Long
        Select Case e.CommandName
            Case "ViewTour"
                SubscriptionId = SubscriptionGrid.Rows(e.CommandArgument).Cells(0).Text
                Response.Redirect("/TourSelection.aspx?SubscriptionId=" & SubscriptionId)
                'If Not S.IsActive And Now.Subtract(U.LastLoginDate).TotalDays >= 1 Then
                '    S.User.SendMail("You subscription is not active.", "Please contact <%=SalesEMail%> for information on activation of your subscription", True)
                'End If
            Case "Reload"
                SubscriptionId = e.CommandArgument
                Dim S As EPMSubscription = EPMSubscription.Load(SubscriptionId)
                If S.CanReload Then
                    S.MarkedForDBReloading = True
                    S.Save()
                    RefreshDS()
                End If
        End Select
    End Sub

    Protected Sub SubscriptionGrid_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles SubscriptionGrid.RowDataBound
        If T.HasRows And e.Row.RowIndex <> -1 Then
            e.Row.Cells(1).Enabled = T.Rows(e.Row.RowIndex).Item("IsProvisioned") And T.Rows(e.Row.RowIndex).Item("IsActive")
            e.Row.Cells(5).Enabled = T.Rows(e.Row.RowIndex).Item("CanReload")
            'e.Row.Cells(6).Enabled = T.Rows(e.Row.RowIndex).Item("CanReload")
        End If
    End Sub

    '            <asp:ButtonField ButtonType="Button" CommandName="Reload" Text="Reload">
    '                <ControlStyle CssClass="InputButton" />
    '            </asp:ButtonField>
End Class
