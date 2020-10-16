<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfoutput>
	<html>
	<head>
		<title>Cluster Stats Reports v1.0</title>
		<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
		<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
	</head>
	
	<body>
	
	<cfinclude template="includes/cfinclude_clusterDBFunctions.cfm">
	
	<table width="100%" cellpadding="-1" cellspacing="-1">
		<tr>
			<td>
				<table width="100%" cellpadding="-1" cellspacing="-1">
					<tr bgcolor="silver">
						<td width="10%" align="center" valign="top">
							<span class="normalStatusBoldClass">
								<a href="#CGI.SCRIPT_NAME#?nocache=#CreateUUID()#" target="_top">[New Chart]</a>
							</span>
						</td>
						<td width="*" align="center" valign="top">
							<span class="normalBigStatusBoldClass">
								Cluster Stats
							</span>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<cfif (UCASE(CGI.REQUEST_METHOD) eq "GET")>
			<cfscript>
				DSN = 'clusterDB';

				safely_execSQL('qGetHistory', DSN, "SELECT serverNum, elapsedMs, beginDt FROM ClusterStatsHits WHERE (jobStep = 'T') ORDER BY beginDt;");
			</cfscript>

			<cfif (NOT Request.dbError)>
				<tr>
					<td align="left" valign="top">
						<cfform name="myForm" method="POST" action="#CGI.SCRIPT_NAME#" height="300" width="1200" format="Flash" skin="haloBlue" style="background-color: silver;" onload="formOnLoad()">
						<cfformitem type="script">
							function formOnLoad(){ 
								// set first start date to disable
								var startDate1 = mx.formatters.DateFormatter.parseDateString('01/01/#DateFormat(DateAdd("yyyy", -50, qGetHistory.beginDt[1]), "YYYY")#');
								
								// set first end date to disable
								var endDate1 = mx.formatters.DateFormatter.parseDateString('#DateFormat(DateAdd("d", -1, qGetHistory.beginDt[1]), "MM/DD/YYYY")#');
								
								// set second start date to disable
								var startDate2 = mx.formatters.DateFormatter.parseDateString('#DateFormat(DateAdd("d", 1, qGetHistory.beginDt[qGetHistory.recordCount]), "MM/DD/YYYY")#');
								
								// set second end date to disable
								var endDate2 = mx.formatters.DateFormatter.parseDateString('12/31/#DateFormat(DateAdd("yyyy", 50, qGetHistory.beginDt[qGetHistory.recordCount]), "YYYY")#');
								
								beginDt.disabledRanges=[{rangeStart:startDate1,rangeEnd:endDate1},{rangeStart:startDate2,rangeEnd:endDate2}];
								endDt.disabledRanges=[{rangeStart:startDate1,rangeEnd:endDate1},{rangeStart:startDate2,rangeEnd:endDate2}];
							}
						</cfformitem>
							<cfformgroup  type="horizontal" visible="Yes" enabled="Yes">
								<cfinput type="DateField" name="beginDt" width="100" firstdayofweek="0" label="Begin Date:" validate="USdate" required="Yes" visible="Yes" enabled="Yes" value="#DateFormat(qGetHistory.beginDt[1], "mm/dd/yyyy")#">
								<cfinput type="DateField" name="endDt" width="100" firstdayofweek="0" label="End Date:" validate="USdate" required="Yes" visible="Yes" enabled="Yes" value="#DateFormat(qGetHistory.beginDt[qGetHistory.recordCount], "mm/dd/yyyy")#">
							</cfformgroup>
							<cfinput type="Checkbox" name="cbSortByDate" label="By Date:" visible="Yes" enabled="Yes">
							<cfinput type="Submit" name="btn_submit" value="[Submit]" visible="Yes" enabled="Yes">
						</cfform>
					</td>
				</tr>
			</cfif>
		<cfelseif (IsDefined("FORM.BEGINDT")) AND (IsDefined("FORM.ENDDT")) AND (IsDefined("FORM.CBSORTBYDATE"))>
			<tr>
				<td align="left" valign="top">
					<cfif 0>
						<cfdump var="#CGI#" label="CGI Scope" expand="No">
						<cfdump var="#FORM#" label="FORM Scope" expand="No">
					</cfif>

					<cfscript>
						DSN = 'clusterDB';
	
						_orderByClause = '';
						if (IsDefined("FORM.CBSORTBYDATE")) {
							_orderByClause = ' ORDER BY beginDt';
						}
				
						safely_execSQL('qGetHistory', DSN, "SELECT serverNum, elapsedMs FROM ClusterStatsHits WHERE (jobStep = 'T') AND (beginDt >= CAST('00:00:00.0 #FORM.BEGINDT#' as datetime)) AND (beginDt <= CAST('23:59:59.9 #FORM.ENDDT#' as datetime))#_orderByClause#");
					</cfscript>
	
					<cfif (NOT Request.dbError)>
						<cftry>
							<cfif 0>
								<cfchart format="flash" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes"> 
									<cfchartseries type="area" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfchart>
							
								<cfchart format="flash" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes"> 
									<cfchartseries type="cone" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfchart>
							
								<cfchart format="flash" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes"> 
									<cfchartseries type="curve" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfchart>
							
								<cfchart format="flash" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes"> 
									<cfchartseries type="cylinder" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfchart>
							
								<cfchart format="flash" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes"> 
									<cfchartseries type="horizontalbar" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfchart>
							
								<cfchart format="flash" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes"> 
									<cfchartseries type="line" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfchart>
							
								<cfchart format="flash" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes"> 
									<cfchartseries type="pyramid" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfchart>
							
								<cfchart format="flash" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes"> 
									<cfchartseries type="step" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfchart>
	
								<cfdump var="#qGetHistory#" label="A. qGetHistory" expand="No">
							</cfif>
						
							<cfscript>
								if (FORM.CBSORTBYDATE) {
									cntNum = ArrayNew(1);
									ArraySet(cntNum, 1, qGetHistory.recordCount, 0);
									for (i = 1; i lte qGetHistory.recordCount; i = i + 1) {
										cntNum[qGetHistory.serverNum[i]] = cntNum[qGetHistory.serverNum[i]] + 1;
										qGetHistory.serverNum[i] = qGetHistory.serverNum[i] & '.' & cntNum[qGetHistory.serverNum[i]];
									}
								} else {
									safely_execSQL('qGetHistory1', '', "SELECT serverNum, elapsedMs FROM qGetHistory WHERE (serverNum = 1)");
									safely_execSQL('qGetHistory2', '', "SELECT serverNum, elapsedMs FROM qGetHistory WHERE (serverNum = 2)");
		
									cntNum1 = ArrayNew(1);
									ArraySet(cntNum1, 1, qGetHistory1.recordCount, 0);
									for (i = 1; i lte qGetHistory1.recordCount; i = i + 1) {
										cntNum1[qGetHistory1.serverNum[i]] = cntNum1[qGetHistory1.serverNum[i]] + 1;
										qGetHistory1.serverNum[i] = qGetHistory1.serverNum[i] & '.' & cntNum1[qGetHistory1.serverNum[i]];
									}
		
									cntNum2 = ArrayNew(1);
									ArraySet(cntNum2, 1, qGetHistory2.recordCount, 0);
									for (i = 1; i lte qGetHistory2.recordCount; i = i + 1) {
										cntNum2[qGetHistory2.serverNum[i]] = cntNum2[qGetHistory2.serverNum[i]] + 1;
										qGetHistory2.serverNum[i] = qGetHistory2.serverNum[i] & '.' & cntNum2[qGetHistory2.serverNum[i]];
									}
								}
							</cfscript>
	
							<cfif 0>
								<cfdump var="#qGetHistory1#" label="B. qGetHistory1" expand="No">
								<cfdump var="#qGetHistory2#" label="B. qGetHistory2" expand="No">
							</cfif>
	
							<cfchart format="flash" title="#qGetHistory.recordCount# Hits" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes" chartwidth="800" chartheight="400"> 
								<cfif (FORM.CBSORTBYDATE)>
									<cfchartseries type="scatter" query="qGetHistory" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>7
								<cfelse>
									<cfchartseries type="scatter" query="qGetHistory1" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
									<cfchartseries type="scatter" query="qGetHistory2" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
								</cfif>
							</cfchart>
	
							<cfcatch type="Any">
								<cfdump var="#cfcatch#" label="cfcatch" expand="No">
							</cfcatch>
						</cftry>
					<cfelse>
						<span class="textYellowBoldClass">
							ERROR: Unable to display Cluster Stats due to the following Database Error.<br>
							#Request.moreErrorMsg#
						</span>
					</cfif>
				</td>
			</tr>
		</cfif>
	</table>

	</body>
	</html>
</cfoutput>

