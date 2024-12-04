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

Imports Aulix.Common7.Data
Imports Aulix.Common7.Utils
Imports System.Reflection

'<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Class AulixUser
    Inherits _AulixUser
    'Function DoCommonSubstitutions(ByVal ForString As String) As String
    '    Dim CommonSubstitution() As String = { _
    '        "SupportEMail", ConfigurationValue("SupportEMail"), _
    '        "SalesEMail", ConfigurationValue("SalesEMail"), _
    '        "WebHost", ConfigurationValue("WebHost")}
    '    DoCommonSubstitutions = UseTemplate(ForString, CommonSubstitution)
    'End Function
    Shared Function SendTestMail(ByVal ToEMail As String) As Boolean
        SendTestMail = Aulix.Common7.Data.Declarations.SendMail(SupportUser.EMail, SupportUser.FullName, ToEMail, ToEMail, "Test message", "This is a test: " & CreateTempName())
    End Function

    <Obfuscation(Feature:="virtualization", Exclude:=False)> _
    Protected Friend Function SendMail(ByVal Subject As String, ByVal Body As String, Optional ByVal BCCToSales As Boolean = False, Optional ByVal PA() As String = Nothing) As Boolean
        Dim UserFullName As String = FirstName & " " & LastName
        Dim SM = SupportMailAddress()
        'Dim SupportEMail As String = SupportUser.EMail 'ConfigurationValue("SupportEMail")
        Dim CommonSubstitution() As String = { _
            "FullName", UserFullName, _
            "EMail", EMail, _
            "Password", Password, _
            "SupportEMail", SM.Address, _
            "SalesEMail", SM.Address, _
            "WebHost", ConfigurationValue("WebHost")}
        Body = Replace(Body, vbNewLine, "<br>" & vbNewLine) ' For HTML e-mail
        Body = UseTemplate(ConfigurationValue("CommonEMailTemplate"), "EMailBody", Body)
        Body = UseTemplate(Body, CommonSubstitution)
        Body = UseTemplate(Body, PA)
        Subject = UseTemplate(Subject, CommonSubstitution)
        Subject = UseTemplate(Subject, PA)
        Dim BCCAddress As System.Net.Mail.MailAddress
        If BCCToSales Then
            BCCAddress = SupportMailAddress() 'New System.Net.Mail.MailAddress(ConfigurationValue("SalesEMail"), Aulix.Common7.Data.ConfigurationValue("SalesEMailName"))
        End If
        SendMail = Aulix.Common7.Data.SendMail(SM.Address, SM.DisplayName, EMail, UserFullName, Subject, Body, BCCAddress)
    End Function

    Shared Function SupportUser() As AulixUser
        SupportUser = AulixUser.Load(ConfigurationValue("SupportMemberId"))
    End Function

    Shared Function SupportMailAddress() As System.Net.Mail.MailAddress
        Dim U As AulixUser = SupportUser()
        SupportMailAddress = New System.Net.Mail.MailAddress(U.EMail, U.FullName)
    End Function

    Public Function SendMailByTemplate(ByVal SpecificEMailTemplateName As String, Optional ByVal BCCToSales As Boolean = False, Optional ByVal PA() As String = Nothing) As Boolean
        Dim A() As String = Split(Aulix.Common7.Data.ConfigurationValue(SpecificEMailTemplateName), vbNewLine, 2)
        SendMail(A(0), A(1), BCCToSales, PA)
    End Function

    Public Shared Shadows Function Load(ByVal Id As Int32) As NHObject
        Load = SharedCon.Load(GetType(AulixUser), Id)
    End Function

    Public Function LogEvent(ByVal Description As String)
        Aulix.Common7.Data.LogEvent(Id, Description)
    End Function

    Private Function LoggedShell(ByVal CmdText As String, ByVal Args As String, Optional ByVal Timeout As Long = 0) As String
        LoggedShell = Aulix.Common7.Data.LoggedShell(CmdText, Args, Id, Timeout)
    End Function

    Shared ReadOnly Property FreeMemberGroup() As AulixUser
        Get
            FreeMemberGroup = AulixUser.Load(ConfigurationValue("FreeMemberGroupId"))
        End Get
    End Property

    Public ReadOnly Property FullName() As String
        Get
            FullName = FirstName & " " & LastName & IIf(Not IsBlank(EMail), " (" & EMail & ")", "")
        End Get
    End Property

    Public Shared Function TryToLogin(ByVal Login As String, ByVal Password As String) As AulixUser
        Dim T As AdvancedDataTable = SharedCon.OpenTable("select Id, Password from aulix_User where EMail=" & Arg(Login))
        If T.HasRows Then
            If StrComp(T.Row("Password"), Password, vbBinaryCompare) = 0 Then
                TryToLogin = AulixUser.Load(T.Row("Id"))
                TryToLogin.LastLoginDate = TryToLogin.ThisLoginDate
                TryToLogin.ThisLoginDate = Now
                TryToLogin.IsLoggedIn = True
                TryToLogin.Save()
            End If
        End If
    End Function
End Class

<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Enum SubscriptionPlanTypeEnum
    General = 1
    Token = 2
End Enum

<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Enum SubscriptionPeriodUnitEnum
    Day = 1
    Week = 7
    Month = 30
    Year = 365
End Enum

<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Enum SubscriptionTokenTypeEnum
    Unused = 1
    Activated = 2
    Prolonging = 3
    Closed = 4
End Enum


Public Interface ISubscriptionFactory
    Function CreateToken(ByVal Owner_ As AulixUser) As AulixSubscriptionPlan
    Function CreatePlan() As AulixSubscriptionPlan
End Interface

' "Number of uses" specifies the amount of times the plan is referenced from Subscriptions
' "Number of Subscriptions" is a better alias for that topic
' There are two types of related limits:
' SubscriptionPlan.MaxSubscriptions - maximum number of subscriptions can be created using that plan by all users in total
'   for tokens it specifies how many times the token can be used by different students
' SubscriptionPlan.MaxSubscriptionsPerUser - maximum number of subscriptions can be created using that plan by any single user
'   for tokens MaxUsesPerUser is generally equal to 1
' SubscriptionPlan.DoneSubscriptions is a calculated field = number of references - may be optimization by a cached value can be needed later
' Actual value of available subscriptions aliased as 
'    SubscriptionPlan.RestSubscriptionsPerUser=Min(SubscriptionPlan.MaxSubscriptions-SubscriptionPlan.DoneSubscriptions, SubscriptionPlan.MaxSubscriptionsPerUser)

' Subscription.DoneUses should be eliminated as long 
'   as any SubscriptionPlan is allowed to be used by a single Subscription only once, 
'   and therefore Subscription.DoneUses=1 always

' Note: Rucursions<>NumberOfUses
' Any number of payment recursions of a recurrent plan is treated as a single use.
' SubscriptionPlan.MaxRecursions specifies how many times a subscription can be prolonged and billed each time. 
' Subscription.DoneRecursions specifies how many payment recursions have already been done for that subscription.
'
' For MaxUses or MaxRecursions value of -1 means there is no limit

'<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Class AulixSubscriptionPlan
    Inherits _AulixSubscriptionPlan
    '    Implements ISubscriptionFactory

    'Public Shared Function GetDefaultSubscriptionPlan() As AulixSubscriptionPlan
    '    GetDefaultSubscriptionPlan = SharedCon.Load(GetType(AulixSubscriptionPlan), "select Id from aulix_SubscriptionPlan where IsDefault=1")
    'End Function

    Public Shared Function IncreaseDateBy(ByVal D As Date, ByVal Amount As Integer, ByVal Unit As SubscriptionPeriodUnitEnum) As Date
        Select Case Unit
            Case SubscriptionPeriodUnitEnum.Day
                IncreaseDateBy = D.AddDays(Amount)
            Case SubscriptionPeriodUnitEnum.Week
                IncreaseDateBy = D.AddDays(Amount * 7)
            Case SubscriptionPeriodUnitEnum.Month
                IncreaseDateBy = D.AddMonths(Amount)
            Case SubscriptionPeriodUnitEnum.Year
                IncreaseDateBy = D.AddYears(Amount)
        End Select
    End Function

    ' How many subscriptions of that plan can be created for a user who has no subscriptions of that plan
    Public Function ActualMaxSubscriptionsPerUser() As Long
        If MaxSubscriptions = -1 And MaxSubscriptionsPerUser = -1 Then
            ActualMaxSubscriptionsPerUser = -1
        Else
            If MaxSubscriptions = -1 Then
                ActualMaxSubscriptionsPerUser = MaxSubscriptionsPerUser
            ElseIf MaxSubscriptionsPerUser = -1 Then
                ActualMaxSubscriptionsPerUser = MaxSubscriptions - DoneSubscriptions
            Else
                ActualMaxSubscriptionsPerUser = Math.Min(MaxSubscriptions - DoneSubscriptions, MaxSubscriptionsPerUser)
            End If
        End If
    End Function

    ' How many subscriptions of that plan can be created for a user who may have subscriptions of that plan
    Public Function LeftSubscriptionsForUser(ByVal User As AulixUser) As Long
        Dim AMSPerUser As Long = ActualMaxSubscriptionsPerUser()
        If AMSPerUser = -1 Then
            LeftSubscriptionsForUser = AMSPerUser
        Else
            Dim Q As NHibernate.IQuery = SharedCon.NHS.CreateQuery("select count(*) from AulixSubscription S where S.User=? and S.SubscriptionPlan=?") ' 
            Q.SetEntity(0, User)
            Q.SetEntity(1, Me)
            Dim DoneSubscriptionsForUser As Long = Q.UniqueResult()
            LeftSubscriptionsForUser = AMSPerUser - DoneSubscriptionsForUser
        End If
    End Function

    Function AreSubscriptionsForUserLeft(ByVal User As AulixUser) As Boolean
        Dim LU As Long = LeftSubscriptionsForUser(User)
        AreSubscriptionsForUserLeft = (LU = -1) Or LU > 0
    End Function

    Public Function CreateSubscription(ByVal User As AulixUser, ByVal SubscriptionClass As Type) As AulixSubscription
        If AreSubscriptionsForUserLeft(User) Then
            CreateSubscription = System.Activator.CreateInstance(SubscriptionClass)
            DoneSubscriptions += 1
            Save()
            With CreateSubscription
                .IsFailed = False
                .User = User
                .SubscriptionPlan = Me
                .Save()
                .Activate()
            End With
        End If
    End Function

    Public Sub New()
    End Sub

    Public Sub New(ByVal PlanType_ As SubscriptionPlanTypeEnum, Optional ByVal Owner_ As AulixUser = Nothing)
        HasBeenSent = False
        WarnBeforeDays = 3
        UnprovisionAfterDays = 2
        MaxRecursions = 1
        MaxSubscriptionsPerUser = 1
        Period = 30
        PeriodUnit = SubscriptionPeriodUnitEnum.Day
        TrialPeriod = 0
        TrialPeriodUnit = SubscriptionPeriodUnitEnum.Day
        PlanType = PlanType_
        Select Case PlanType_
            Case SubscriptionPlanTypeEnum.General
                MaxSubscriptions = -1
            Case SubscriptionPlanTypeEnum.Token
                TokenType = SubscriptionTokenTypeEnum.Unused
                Owner = Owner_
                MaxSubscriptions = 10
                Save() ' To get id
                TokenCode = Aulix.Common7.Utils.RandomString(4) & Id
        End Select
        Save() '!!!
    End Sub

    'Public Shared Function CreateToken(ByVal Owner_ As AulixUser) As AulixSubscriptionPlan
    '    CreateToken = New AulixSubscriptionPlan(SubscriptionPlanTypeEnum.Token, Owner_)
    'End Function

    'Public Shared Function CreatePlan() As AulixSubscriptionPlan
    '    CreatePlan = New AulixSubscriptionPlan(SubscriptionPlanTypeEnum.General)
    'End Function

    Public Function Mail()
        Owner.SendMailByTemplate("TokenEMailTemplate", False, New String() { _
            "CourseName", ServicePlan.Name, _
            "MaxUses", MaxSubscriptions, _
            "TokenCode", TokenCode})
        HasBeenSent = True
        Save()
    End Function

    Public Shared Function MailUnsentTokens(Optional ByVal Owner As AulixUser = Nothing)
        'Dim Q As NHibernate.IQuery = SharedCon.NHS.CreateQuery("from AulixSubscriptionPlan SP where SP.HasBeenSent=0 and PlanType=" & SubscriptionPlanTypeEnum.Token & IIf(Not IsNothing(Owner), " and Owner=:Owner", ""))
        'If Not IsNothing(Owner) Then
        '    Q.SetEntity("Owner", Owner)
        'End If
        Dim Cr As NHibernate.ICriteria = SharedCon.NHS.CreateCriteria(GetType(AulixSubscriptionPlan))

        'Cr.Add(New NHibernate.Expression.EqExpression("HasBeenSent", False))
        'Cr.Add(New NHibernate.Expression.EqExpression("PlanType", SubscriptionPlanTypeEnum.Token))
        'If IsNothing(Owner) Then
        '    Cr.Add(New NHibernate.Expression.NotNullExpression("Owner"))
        'Else
        '    Cr.Add(New NHibernate.Expression.EqExpression("Owner", Owner))
        'End If

        'New NH
        Cr.Add(NHibernate.Criterion.Restrictions.Eq("HasBeenSent", False))
        Cr.Add(NHibernate.Criterion.Restrictions.Eq("PlanType", SubscriptionPlanTypeEnum.Token))
        If IsNothing(Owner) Then
            Cr.Add(NHibernate.Criterion.Restrictions.IsNotNull("Owner"))
        Else
            Cr.Add(NHibernate.Criterion.Restrictions.Eq("Owner", Owner))
        End If

        Dim TokenList As IList = Cr.List
        For Each T As AulixSubscriptionPlan In TokenList
            T.Mail()
        Next
    End Function
    Public ReadOnly Property FullName() As String
        Get
            Select Case PlanType
                Case SubscriptionPlanTypeEnum.General
                    FullName = Name
                Case SubscriptionPlanTypeEnum.Token
                    FullName = TokenCode
            End Select
            FullName &= " - " & ServicePlan.Name
        End Get
    End Property

    'Function MailUnsentTokensTogether()
    'Dim TokenTable As AdvancedDataTable = SharedCon.OpenTable("select OwnerId, Id from aulix_SubscriptionPlan where PlanType=" & SubscriptionPlanTypeEnum.Token & " and HasBeenSent=0 order by OwnerId,Id")
    'Dim LastOwnerId As Long
    'Dim TokenList As String
    'For Each TokenTable.Row In TokenTable.Rows
    '    Dim Token As AulixSubscriptionPlan = AulixSubscriptionPlan.Load(GetType(AulixSubscriptionPlan), TokenTable("Id"))
    '    If LastOwnerId = Token.Id Then
    '        TokenList &= Token.TokenCode & "; "
    '    Else
    '        TokenList = Token.TokenCode & "; "
    '    End If
    '    If LastOwnerId = Token.Id Or TokenTable.IsLastRow Then
    '        Token.Owner.SendMailByTemplate("TokenEMailTemplate", True, CreateArray( _
    '            "CourseName", Token.Service.Name, _
    '            "MaxUses", Token.MaxUses, _
    '            "TokenCode", Token.TokenCode))
    '    End If
    '    LastOwnerId = Token.Id
    'Next
    'End Function

    'Public Shared Function GenerateTokens(ByVal ForCustomer As AulixUser, ByVal OfService As AulixService, ByVal Duration As Integer, ByVal Amount As Integer) As String
    '    For I As Integer = 1 To Amount
    '        Dim SP As AulixSubscriptionPlan = New AulixSubscriptionPlan
    '        SP.Owner = ForCustomer
    '        SP.Period = Duration
    '        SP.PeriodUnit = "d"
    '        SP.MaxUsesPerUser = 1
    '        SP.Service = OfService
    '        SP.SubscriptionPlanType_EID = SubscriptionPlanTypeEnum.Token
    '        SP.SubscriptionTokenType_EID = SubscriptionTokenTypeEnum.Unused
    '        SP.Save()
    '        SP.TokenCode = Aulix.Common7.Declarations.RandomString(4) & SP.Id
    '        GenerateTokens &= SP.TokenCode & vbNewLine
    '        SP.Save()
    '    Next
    'End Function
    Public Shared Shadows Function Load(ByVal Id As Int32) As AulixSubscriptionPlan
        Load = SharedCon.Load(GetType(AulixSubscriptionPlan), Id)
    End Function

End Class

'<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Class AulixSubscriptionPayment
    Inherits _AulixSubscriptionPayment

End Class

'!!!<Obfuscation(Feature:="Apply to member * when method: virtualization", Exclude:=False)> _
Public Class AulixSubscription
    Inherits _AulixSubscription

    Public Overridable ReadOnly Property IsProvisioned() As Boolean
        Get
            IsProvisioned = False
        End Get
    End Property

    Public Overridable ReadOnly Property IsProvisioningAllowed() As Boolean
        Get
            IsProvisioningAllowed = True
        End Get
    End Property


    'Public Function ChangeSubscriptionPlan(ByVal NewSubscriptionPlanId As Integer)
    '    Deactivate()
    '    SubscriptionPlan = SharedCon.Load(GetType(AulixSubscriptionPlan), NewSubscriptionPlanId)
    '    Save()
    '    Activate()
    'End Function

    Public Function ExpirationDate() As Date
        If IsBlank(ManualExpirationDate) Then
            If SubscriptionPlan.MaxRecursions = -1 Then
                ExpirationDate = #1/1/9999#
            Else
                ExpirationDate = AulixSubscriptionPlan.IncreaseDateBy(ActivationDate, SubscriptionPlan.Period * SubscriptionPlan.MaxRecursions, SubscriptionPlan.PeriodUnit)
            End If
        Else
            ExpirationDate = ManualExpirationDate
        End If
    End Function

    Function DaysLeftBeforeExpiration() As Double
        DaysLeftBeforeExpiration = (ExpirationDate() - Now()).TotalDays
    End Function

    Public Function UnprovisioningDate() As Date
        UnprovisioningDate = ExpirationDate.AddDays(SubscriptionPlan.UnprovisionAfterDays)
    End Function

    Function DaysLeftBeforeUnprovisioning() As Double
        DaysLeftBeforeUnprovisioning = (UnprovisioningDate() - Now()).TotalDays
    End Function

    Public Function NextRecursionDate() As Date
        NextRecursionDate = AulixSubscriptionPlan.IncreaseDateBy(ActivationDate, (DoneRecursions + 1) * SubscriptionPlan.Period, SubscriptionPlan.PeriodUnit)
    End Function

    Function DaysLeftBeforeNextRecursion() As Double
        DaysLeftBeforeNextRecursion = (NextRecursionDate() - Now()).TotalDays
    End Function

    Protected Friend Function Activate() ' generally called from subscription management GUI
        ActivationDate = Now
        DoneRecursions = 0
        IsActive = True
        'SendProvisionEMail()
        If IsProvisioningAllowed Then
            Provision()
        End If
        Save()
    End Function
    Public Function SendProvisionEMail()
        User.SendMailByTemplate("ActivationEMailTemplate", True, New String() { _
            "ExpirationDate", ExpirationDate().Date, _
            "SubscriptionPlan", SubscriptionPlan.Name, _
            "Course", SubscriptionPlan.ServicePlan.Name _
        })
    End Function
    Private Function Deactivate()
        IsActive = False
        Save()
        User.SendMailByTemplate("DeactivationEMailTemplate", True)
    End Function

    Public Overridable Function Provision()

    End Function

    Public Overridable Function Unprovision()
        SendUnprovisionEMail()
    End Function

    Public Function SendUnprovisionEMail()
        User.SendMail("The services under your subscription have been deleted", _
                                "The services under your subscription have been deleted.")
    End Function

    Public Function SendExpirationEMail()
        User.SendMail("Your subscription will expire soon", _
        "Your subscription will expire in " & Int(DaysLeftBeforeExpiration()) & " days. " & vbNewLine & _
        "The services under your subscription will be deleted in " & Int(DaysLeftBeforeUnprovisioning()) & " days. " & vbNewLine)
        ExpirationEMailSent = True
    End Function

    Public ReadOnly Property AreRecursionsLeft() As Boolean
        Get
            AreRecursionsLeft = SubscriptionPlan.MaxRecursions = -1 Or _
                                SubscriptionPlan.MaxRecursions > DoneRecursions
        End Get
    End Property

    <Obfuscation(Feature:="virtualization", Exclude:=False)> _
    Public Function ProcessWorkflow() ' Should be executed at least once per day
        If IsActive Then
            If Now > ExpirationDate() Then
                Deactivate()
            Else
                If DaysLeftBeforeNextRecursion() <= 0 Then 'It is time to bill
                    If AreRecursionsLeft Then
                        DoneRecursions += 1
                        'if TryToBill then
                        '
                        'else
                        '   Deactivate
                        'end if
                    Else ' No recursions left
                        'User.SendMail("Your subscription has expired", _
                        '"Your subscription has expired. " & vbNewLine & _
                        '"The services under your subscription will be deleted in " & Int(DaysLeftBeforeUnprovisioning()) & " days. " & vbNewLine)
                    End If
                End If
            End If
            If Not ExpirationEMailSent AndAlso DaysLeftBeforeExpiration() <= SubscriptionPlan.WarnBeforeDays Then
                SendExpirationEMail()
            End If
        Else 'If IsActive
            If IsProvisioned And DaysLeftBeforeUnprovisioning() <= 0 Then
                Unprovision()
            End If
        End If
        Save()
    End Function

    <Obfuscation(Feature:="virtualization", Exclude:=False)> _
    Public Shared Function ProcessWorkflowForAll()
        Dim L As IList = SharedCon.NHS.CreateQuery("from AulixSubscription S where S.IsActive=1").List 'or IsProvisioned=true
        For Each S As AulixSubscription In L
            S.ProcessWorkflow()
        Next
    End Function

    Public WorkflowItemStartedAt As Date
    Function WorkflowItemTime() As String
        WorkflowItemTime = " Time spent: " & (Now - WorkflowItemStartedAt).TotalSeconds & " sec."
    End Function

    Public Shared Shadows Function Load(ByVal Id As Int32) As AulixSubscription
        Load = SharedCon.Load(GetType(AulixSubscription), Id)
    End Function

    Public Overridable ReadOnly Property Status() As String
        Get
            Status = IIf(IsActive, "Active", "Not Active") & " - " & IIf(IsProvisioned, "Provisioned", "Not Provisioned") & IIf(IsProvisioningAllowed, "", " - Provisioning not allowed")
        End Get
    End Property

    Public Sub New()
        IsFailed = False
    End Sub
End Class

'<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Class AulixServicePlan ' Later change this to AulixServicePlan
    Inherits _AulixServicePlan
    Public Shared Shadows Function Load(ByVal Id As Int32) As AulixServicePlan
        Load = SharedCon.Load(GetType(AulixServicePlan), Id)
    End Function
End Class

'<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Class AulixProperty
    Inherits _AulixProperty
End Class

'<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
<System.Reflection.ObfuscationAttribute(Feature:="properties renaming")> _
<System.Reflection.ObfuscationAttribute(Feature:="fields renaming")> _
Public Class AulixConfiguration
    Inherits _AulixConfiguration

End Class

'<Obfuscation(ApplyToMembers:=True, Exclude:=True)> _
Public Class AulixEventLog
    Inherits _AulixEventLog
End Class

