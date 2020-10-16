<cfsetting showdebugoutput="No" enablecfoutputonly="Yes">

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

	<cfinclude template="includes/cfinclude_clusterDBFunctions.cfm">
	
	<html>
	<head>
		<title>Cluster Status Interface v1.0</title>
		<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
		<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
		<cfparam name="enableMetaRefresh" type="string" default="0">
		<cfscript>
			cfm_nocache(GetHttpTimeString(DateAdd("yyyy", -50, Now())));
		</cfscript>
		<cfoutput>
			<cfif (enableMetaRefresh gt 0)>
				<meta http-equiv="refresh" content="#enableMetaRefresh#">
			</cfif>
		</cfoutput>
	</head>
	
	<body>
	<cfset Request.modusOperandi = "READ">
	<cfinclude template="includes/cfinclude_clusterDBRead.cfm">
	
	<cfset serverError = false>
	<cfset serverErrorMsg = "">
	<cftry>
		<cfif (serverNum eq "0")>
			<cfhttp url="http://www.contentopia.net/test.htm" method="GET" port="#CGI.SERVER_PORT#" result="rHTTP1" resolveurl="yes"></cfhttp>
			<cfhttp url="http://www.contentopia.net/test.cfm" method="GET" port="#CGI.SERVER_PORT#" result="cfHTTP1" resolveurl="yes"></cfhttp>
		<cfelse>
			<cfhttp url="http://#serverNum#.contentopia.net/test.htm" method="GET" port="#CGI.SERVER_PORT#" result="rHTTP1" resolveurl="yes"></cfhttp>
			<cfhttp url="http://#serverNum#.contentopia.net/test.cfm" method="GET" port="#CGI.SERVER_PORT#" result="cfHTTP1" resolveurl="yes"></cfhttp>
		</cfif>

		<cfcatch type="Any">
			<cfset serverError = true>
			<cfset serverErrorMsg = "Server Number (#serverNum#) is Offline.">
		</cfcatch>
	</cftry>

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
							<span class="textYellowBoldClass">
							<cfif (IsDefined("rHTTP1")) AND (IsDefined("rHTTP1.Responseheader.server"))>
								#rHTTP1.Responseheader.server#&nbsp;
							</cfif>
							(#serverNum#)&nbsp;is&nbsp;
							</span>
							<cfif (IsDefined("rHTTP1")) AND (IsDefined("rHTTP1.Statuscode")) AND (rHTTP1.Statuscode eq "200 OK")>
								<span class="textOnlineClass">Online</span>
							<cfelse>
								<span class="textOfflineClass">Offline</span>
							</cfif>
						</td>
					</tr>
				</table>
			</td>
			<td width="50%" align="left" valign="top">
				<cfset _totalText = "">
				<cfset _serverIDText = "">
				<cfif (serverNum eq 0)>
					<cfset _totalText = " Cluster">
					<cfset _totalNum = (aStruct.server1.numHits + aStruct.server2.numHits) + (aStruct.server1._numHits + aStruct.server2._numHits)>
					<cfset _partialNum = (aStruct.server1.numHits + aStruct.server2.numHits)>
				<cfelse>
					<cfset _serverIDText = " for Server (#serverNum#)">
					<cfset _totalNum = aStruct["server#serverNum#"].numHits + aStruct["server#serverNum#"]._numHits>
					<cfset _partialNum = aStruct["server#serverNum#"].numHits>
				</cfif>

				<cfif (IsDefined("cfHTTP1")) AND (IsDefined("cfHTTP1.Statuscode")) AND (IsDefined("cfHTTP1.Filecontent"))>
				</cfif>

				<cfset wddxError = false>
				<cftry>
					<cfwddx action="WDDX2CFML" input="#cfHTTP1.Filecontent#" output="cfStruct" validate="yes">

					<cfcatch type="Any">
						<cfset wddxError = true>
					</cfcatch>
				</cftry>
				<cfif (NOT wddxError)>
				</cfif>

				<span class="textYellowBoldClass"><NOBR>Total#_totalText# Hits#_serverIDText#: #_totalNum# [#_partialNum#]</NOBR> <NOBR>ColdFusion <cfif (IsDefined("cfStruct")) AND (IsStruct(cfStruct))>#cfStruct.COLDFUSION.PRODUCTLEVEL# #cfStruct.COLDFUSION.PRODUCTVERSION#</NOBR> for <NOBR>#cfStruct.OS.NAME# #cfStruct.OS.ARCH#</NOBR></cfif> is </span>
				<cfif (IsDefined("cfHTTP1")) AND (IsDefined("cfHTTP1.Statuscode")) AND (cfHTTP1.Statuscode eq "200 OK") AND (IsDefined("cfStruct")) AND (IsStruct(cfStruct))>
					<span class="textOnlineClass">Online</span>
				<cfelse>
					<span class="textOfflineClass">Offline</span>
				</cfif>
			</td>
		</tr>
	</table>
	
	</body>
	</html>
</cfoutput>
