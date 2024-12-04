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


Partial Class ACommon_MACAddress
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        With Page.ClientScript
            .RegisterStartupScript(Page.GetType, "FillMACAddress", "<script>document.all['" & MACAddressHF.ClientID & "'].value=GetMACAddress2();</script>")
        End With
    End Sub

    Public Function MACAddress() As String
        MACAddress = MACAddressHF.Value
    End Function
End Class
