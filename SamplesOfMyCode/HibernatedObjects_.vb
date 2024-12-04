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


Public Class _AulixConfiguration
    Inherits Aulix.Common7.Data.NHObject
    Public [Group] As System.String
    Public [Name] As System.String
    Public [Value] As System.String
    Public [Description] As System.String
End Class
Public Class _AulixEventLog
    Inherits Aulix.Common7.Data.NHObject
    Public [Date] As System.DateTime = #1/1/1900#
    Public [User] As AulixUser
    Public [Description] As System.String
End Class
Public Class _AulixProperty
    Inherits Aulix.Common7.Data.NHObject
    Public [ParentProperty] As AulixProperty
    Public [LocalId] As System.Int32
    Public [Name] As System.String
    Public [Description] As System.String
End Class
Public Class _AulixServicePlan
    Inherits Aulix.Common7.Data.NHObject
    Public [Name] As System.String
    Public [Description] As System.String
End Class
Public Class _AulixSubscription
    Inherits Aulix.Common7.Data.NHObject
    Public [User] As AulixUser
    Public [SubscriptionPlan] As AulixSubscriptionPlan
    Public [LastSubscriptionPayment] As AulixSubscriptionPayment
    Public [IsActive] As System.Boolean
    Public [IsFailed] As System.Boolean
    Public [ActivationDate] As System.DateTime = #1/1/1900#
    Public [DoneRecursions] As System.Int32
    Public [ExpirationEMailSent] As System.Boolean
    Public [ManualExpirationDate] As System.DateTime?
End Class
Public Class _AulixSubscriptionPayment
    Inherits Aulix.Common7.Data.NHObject
    Public [Subscription] As AulixSubscription
    Public [PaymentDate] As System.DateTime = #1/1/1900#
    Public [Amount] As System.Decimal
    Public [TransactionReferenceNumber] As System.String
    Public [TransactionResponseCode] As System.String
    Public [Note] As System.String
    Public [PayPalPayerEmail] As System.String
    Public [PayPalPayerID] As System.String
    Public [TxnId] As System.String
End Class
Public Class _AulixSubscriptionPlan
    Inherits Aulix.Common7.Data.NHObject
    Public [Owner] As AulixUser
    Public [PlanType] As SubscriptionPlanTypeEnum
    Public [IsDefault] As System.Boolean
    Public [IsVisible] As System.Boolean
    Public [Name] As System.String
    Public [SetupPrice] As System.Decimal
    Public [TrialPeriod] As System.Int32
    Public [TrialPeriodUnit] As SubscriptionPeriodUnitEnum
    Public [TrialPeriodPrice] As System.Decimal
    Public [MaxRecursions] As System.Int32
    Public [Period] As System.Int32
    Public [PeriodUnit] As SubscriptionPeriodUnitEnum
    Public [PeriodPrice] As System.Decimal
    Public [WarnBeforeDays] As System.Int32
    Public [UnprovisionAfterDays] As System.Int32
    Public [HasBeenSent] As System.Boolean
    Public [TokenType] As SubscriptionTokenTypeEnum
    Public [TokenCode] As System.String
    Public [MaxSubscriptions] As System.Int32
    Public [MaxSubscriptionsPerUser] As System.Int32
    Public [DoneSubscriptions] As System.Int32
    Public [ServicePlan] As AulixServicePlan
End Class
Public Class _AulixUser
    Inherits Aulix.Common7.Data.NHObject
    Public [FirstName] As System.String
    Public [LastName] As System.String
    Public [EMail] As System.String
    Public [Password] As System.String
    Public [CountryId] As System.Int32
    Public [AmericanStateId] As System.Int32
    Public [HasAgreedWithLicense] As System.Boolean
    Public [Customer] As AulixUser
    Public [IsMember] As System.Boolean
    Public [IsCustomer] As System.Boolean
    Public [IsAdmin] As System.Boolean
    Public [IsManager] As System.Boolean
    Public [SignupDate] As System.DateTime = #1/1/1900#
    Public [ThisLoginDate] As System.DateTime = #1/1/1900#
    Public [LastLoginDate] As System.DateTime = #1/1/1900#
    Public [IsLoggedIn] As System.Boolean

    'Public MACAddress As String ' Is not used anymore

End Class
