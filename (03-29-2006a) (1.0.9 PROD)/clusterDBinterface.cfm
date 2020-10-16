<cfparam name="debugMode" type="string" default="1">

<cfif (debugMode eq 0)>
	<cfsetting showdebugoutput="No">
<cfelse>
	<cfsetting showdebugoutput="Yes">
</cfif>

<cfparam name="serverNum" type="string" default="">
<cfparam name="serverStatus" type="string" default="">

<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<html>
	<head>
		<title>Cluster Db Interface Panel v1.0</title>
		<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
		<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
		<script language="JavaScript1.2" type="text/javascript">
			function uuid() {
				var uuid = (new Date().getTime() + "" + Math.floor(1000 * Math.random()));
				return uuid;
			}

			function _$(id) {
				var obj = -1;
				if (typeof id == 'string') {
					obj = ((document.getElementById) ? document.getElementById(id) : ((document.all) ? document.all[id] : ((document.layers) ? document.layers[id] : null)));
				}
				return obj;
			}
			
			function changeServerStatus(sObj, serverNum) {
				if ( (!!sObj) && (!!sObj.options) && (sObj.selectedIndex > -1) ) {
					serverNum = ((typeof serverNum == 'number') ? serverNum : 1);
					document.location.href = '#CGI.SCRIPT_NAME#?serverNum=' + serverNum + '&serverStatus=' + sObj.options[sObj.selectedIndex].value + '&nocache=' + uuid() + '&debugMode=#debugMode#';
				}
			}
		</script>
	</head>
	
	<body>
	<cfset Request.modusOperandi = "READ">
	<cfinclude template="includes/cfinclude_clusterDBFunctions.cfm">
	<cfinclude template="includes/cfinclude_clusterDBRead.cfm">

	<cfif (Len(serverNum) gt 0) AND (Len(serverStatus) gt 0)>
		<cfif 0>
			<cfdump var="#aStruct#" label="aStruct A." expand="No">
		</cfif>
		<cfscript>
			if (serverNum eq 1) {
				aStruct.server1.isonline = (UCASE(serverStatus) eq UCASE('online'));
				if (aStruct.server1.isonline) {
					aStruct.server1.isonline = true;
				} else {
					aStruct.server1.isonline = false;
				}
			} else if (serverNum eq 2) {
				aStruct.server2.isonline = (UCASE(serverStatus) eq UCASE('online'));
				if (aStruct.server2.isonline) {
					aStruct.server2.isonline = true;
				} else {
					aStruct.server2.isonline = false;
				}
			}
		</cfscript>
		<cfif 0>
			<cfdump var="#aStruct#" label="aStruct B." expand="No">
		</cfif>

		<cfset Request.modusOperandi = "WRITE">
		<cfinclude template="includes/cfinclude_clusterDBRead.cfm">
	</cfif>

	<cfif (NOT Request.clusterDBError)>
		<cfset bool_debugMode = (Find("192.168.", CGI.REMOTE_ADDR) gt 0) OR (Find("127.0.0.1", CGI.REMOTE_ADDR) gt 0)>
		<cfif (bool_debugMode)>
			<cfdump var="#aStruct#" label="aStruct" expand="No">
		</cfif>
		<table width="100%" cellpadding="-1" cellspacing="-1" style="margin-bottom: 10px">
			<tr bgcolor="silver">
				<td align="center" colspan="3">
					<div id="div_timer_cluster"></div>
				</td>
			</tr>
			<tr>
				<td align="center">
					<span class="textYellowBoldClass">
						Server ##1 (Babylon5)
					</span>
				</td>
				<td align="center">
					<span class="textYellowBoldClass">
						<a href="clusterStats.cfm" target="_blank">Cluster Stats Interface</a>
					</span>
				</td>
				<td align="center">
					<span class="textYellowBoldClass">
						Server ##2 (CFServer2)
					</span>
				</td>
			</tr>
			<tr>
				<td align="center">
					<select name="selection_server1" class="textBoldClass" onchange="changeServerStatus(this, 1); return false;">
						<cfset _selected = "">
						<cfif (aStruct.server1.isonline)>
							<cfset _selected = " selected">
						</cfif>
						<option value="Online" style="background-color: Lime;"#_selected#>Online</option>
						<cfset _selected = "">
						<cfif (NOT aStruct.server1.isonline)>
							<cfset _selected = " selected">
						</cfif>
						<option value="Offline" style="background-color: Red;"#_selected#>Offline</option>
					</select>
				</td>
				<td align="center">
					&nbsp; <!--- stats interface goes here --->
				</td>
				<td align="center">
					<select name="selection_server2" class="textBoldClass" onchange="changeServerStatus(this, 2); return false;">
						<cfset _selected = "">
						<cfif (aStruct.server2.isonline)>
							<cfset _selected = " selected">
						</cfif>
						<option value="Online" style="background-color: Lime;"#_selected#>Online</option>
						<cfset _selected = "">
						<cfif (NOT aStruct.server2.isonline)>
							<cfset _selected = " selected">
						</cfif>
						<option value="Offline" style="background-color: Red;"#_selected#>Offline</option>
					</select>
				</td>
			</tr>
			<tr>
				<td align="center">
					<table width="100%" border="0" cellpadding="-1" cellspacing="-1">
						<tr bgcolor="silver">
							<td align="center">
								<div id="div_timer_server1">
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<iframe id="iframe_server1" src="clusterStatusInterface.cfm?debugMode=0&serverNum=1" width="100%" height="50" frameborder="0" scrolling="Auto"></iframe>
							</td>
						</tr>
					</table>
				</td>
				<td align="center">
					&nbsp;
				</td>
				<td align="center">
					<table width="100%" border="0" cellpadding="-1" cellspacing="-1">
						<tr bgcolor="silver">
							<td align="center">
								<div id="div_timer_server2">
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<iframe id="iframe_server2" src="clusterStatusInterface.cfm?debugMode=0&serverNum=2" width="100%" height="50" frameborder="0" scrolling="Auto"></iframe>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td align="center" valign="top" colspan="3">
					<table width="100%" border="0" cellpadding="-1" cellspacing="-1">
						<tr bgcolor="silver">
							<td align="center">
								<div id="div_timer_server0">
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<iframe id="iframe_server0" src="clusterStatusInterface.cfm?debugMode=0&serverNum=0" width="100%" height="50" frameborder="0" scrolling="Auto"></iframe>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	<cfelse>
		#Request.clusterDBErrorMsg#<br>
	</cfif>
	
	<script language="JavaScript1.2" type="text/javascript">
		function refreshServer(iNum) {
			iNum = ((typeof iNum == 'number') ? iNum : 1);
			var oObj = _$('iframe_server' + iNum);
			if (!!oObj) {
				oObj.src = 'clusterStatusInterface.cfm?debugMode=0&serverNum=' + iNum + '&nocache=' + uuid();
			}
		}
		
		var max_interval =60000 * 2 ;
		var ar_refreshTimers = [];
		ar_refreshTimers.push(max_interval);
		ar_refreshTimers.push(max_interval);
		ar_refreshTimers.push(max_interval);

		var cluster_refreshTimer = max_interval;
		
		function refreshTimerForServer(iNum) {
			iNum = ((typeof iNum == 'number') ? iNum : 1);
			var oObj = _$('div_timer_server' + iNum);
			if (!!oObj) {
				var _secs = ar_refreshTimers[iNum] / 1000;
				oObj.innerHTML = '<span class="normalStatusBoldClass">Refresh in ' + _secs + ' seconds.</span>';
				ar_refreshTimers[iNum] -= 1000;
			}
			if (ar_refreshTimers[iNum] == 0) {
				ar_refreshTimers[iNum] = max_interval;
				refreshServer(iNum);
			}
		}
		
		function refreshTimerForCluster() {
			var oObj = _$('div_timer_cluster');
			if (!!oObj) {
				var _secs = cluster_refreshTimer / 1000;
				oObj.innerHTML = '<span class="normalStatusBoldClass">Refresh in ' + _secs + ' seconds.</span>';
				cluster_refreshTimer -= 1000;
			}
			if (cluster_refreshTimer == 0) {
				cluster_refreshTimer = max_interval;
				parent.refreshClusterDBInterface();
			}
		}
		
		var procID = [];
	//	procID[0] = setInterval('refreshTimerForServer(0)', 1000);
	//	procID[1] = setInterval('refreshTimerForServer(1)', 1000);
	//	procID[2] = setInterval('refreshTimerForServer(2)', 1000);

		_procID = setInterval('refreshTimerForCluster()', 1000);
	</script>
	
	</body>
	</html>

</cfoutput>
