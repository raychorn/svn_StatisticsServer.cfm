<cfparam name="debugMode" type="string" default="1">

<cfparam name="serverNum" type="string" default="1">

<cfif (debugMode eq 0)>
	<cfsetting showdebugoutput="No">
<cfelse>
	<cfsetting showdebugoutput="Yes">
</cfif>

<cfif (serverNum neq "0") AND (serverNum neq "1") AND (serverNum neq "2")>
	<cfset serverNum = "1">
</cfif>

<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<html>
	<head>
		<title>Cluster Status Interface v1.0</title>
		<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
		<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
	</head>
	
	<body>
	
	<cfif (serverNum eq "0")>
		<!--- Later make this www. instead of blog. --->
		<cfhttp url="http://blog.contentopia.net/test.htm" method="GET" port="#CGI.SERVER_PORT#" result="rHTTP1" resolveurl="yes"></cfhttp>
		<cfhttp url="http://blog.contentopia.net/test.cfm" method="GET" port="#CGI.SERVER_PORT#" result="cfHTTP1" resolveurl="yes"></cfhttp>
	<cfelse>
		<cfhttp url="http://#serverNum#.contentopia.net/test.htm" method="GET" port="#CGI.SERVER_PORT#" result="rHTTP1" resolveurl="yes"></cfhttp>
		<cfhttp url="http://#serverNum#.contentopia.net/test.cfm" method="GET" port="#CGI.SERVER_PORT#" result="cfHTTP1" resolveurl="yes"></cfhttp>
	</cfif>
	<table <cfif (serverNum eq "0")>align="center"</cfif> width="<cfif (serverNum eq "0")>50%<cfelse>100%</cfif>" cellpadding="-1" cellspacing="-1">
		<tr>
			<td width="50%" align="left" valign="top">
				<table width="100%" cellpadding="-1" cellspacing="-1">
					<tr>
						<td align="left" valign="top">
							<span class="textYellowBoldClass">#DateFormat(Now(), "MM/DD/YYYY")# #TimeFormat(Now(), "long")#</span>
						</td>
					</tr>
					<tr>
						<td align="left" valign="top">
							<cfset bool_debugMode = (Find("192.168.", CGI.REMOTE_ADDR) gt 0) OR (Find("127.0.0.1", CGI.REMOTE_ADDR) gt 0)>
							<cfif (IsDefined("rHTTP1")) AND (IsDefined("rHTTP1.Statuscode"))>
								<cfif (bool_debugMode AND 0)>
									<cfdump var="#rHTTP1#" label="rHTTP1" expand="No">
								</cfif>
								<span class="textYellowBoldClass">Apache (#serverNum#) is </span>
								<cfif (rHTTP1.Statuscode eq "200 OK")>
									<span class="textOnlineClass">Online</span>
								<cfelse>
									<span class="textOfflineClass">Offline</span>
								</cfif>
							</cfif>
						</td>
					</tr>
				</table>
			</td>
			<td width="50%" align="left" valign="top">
				<cfif (IsDefined("cfHTTP1")) AND (IsDefined("cfHTTP1.Statuscode"))>
					<cfif (bool_debugMode AND 0)>
						<cfdump var="#cfHTTP1#" label="cfHTTP1" expand="No">
					</cfif>
					<cfwddx action="WDDX2CFML" input="#cfHTTP1.Filecontent#" output="cfStruct" validate="yes">
					<cfif (bool_debugMode AND 0)>
						<cfdump var="#cfStruct#" label="cfStruct" expand="No">
					</cfif>
					<span class="textYellowBoldClass">ColdFusion (#serverNum#) <cfif (IsDefined("cfStruct")) AND (IsStruct(cfStruct))>#cfStruct.COLDFUSION.PRODUCTLEVEL# #cfStruct.COLDFUSION.PRODUCTVERSION# for #cfStruct.OS.NAME# #cfStruct.OS.ARCH#</cfif> is </span>
					<cfif (cfHTTP1.Statuscode eq "200 OK") AND (IsDefined("cfStruct")) AND (IsStruct(cfStruct))>
						<span class="textOnlineClass">Online</span>
					<cfelse>
						<span class="textOfflineClass">Offline</span>
					</cfif>
				</cfif>
			</td>
		</tr>
	</table>
	
	</body>
	</html>
</cfoutput>
