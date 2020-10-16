<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfoutput>
	<html>
	<head>
		<title>Cluster Stats Interface v1.0</title>
		<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
		<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
	</head>
	
	<body>
	
	<cfinclude template="includes/cfinclude_clusterDBFunctions.cfm">
	
	<table width="100%" cellpadding="-1" cellspacing="-1">
		<tr>
			<td align="center" valign="top" bgcolor="silver">
				<span class="normalBigStatusBoldClass">
					Cluster Stats
				</span>
			</td>
		</tr>
		<tr>
			<td align="left" valign="top">
				<cfscript>
					DSN = 'clusterDB';

					safely_execSQL('qGetHistory', DSN, "SELECT serverNum, elapsedMs FROM ClusterStats WHERE (jobStep = 'T') GROUP BY serverNum, elapsedMs");
				</cfscript>

				<cfif (NOT Request.dbError)>
					<cfdump var="#qGetHistory#" label="qGetHistory" expand="No">
					
					<cfchart format="flash" name="historicalChart" chartwidth="800" chartheight="400" xaxistitle="X-Axis" yaxistitle="Y-Axis">
						<cfchartseries type="bar" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
					</cfchart>
				<cfelse>
					<span class="textYellowBoldClass">
						ERROR: Unable to display Cluster Stats due to the following Database Error.<br>
						#Request.moreErrorMsg#
					</span>
				</cfif>
			</td>
		</tr>
	</table>
	
	</body>
	</html>
</cfoutput>

