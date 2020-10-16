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

					safely_execSQL('qGetHistory', DSN, "SELECT serverNum, elapsedMs FROM ClusterStats WHERE (jobStep = 'T')");
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
</cfif>
						<cfdump var="#qGetHistory#" label="A. qGetHistory" expand="No">
					
						<cfscript>
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
						</cfscript>

						<cfdump var="#qGetHistory1#" label="B. qGetHistory1" expand="No">
						<cfdump var="#qGetHistory2#" label="B. qGetHistory2" expand="No">

						<cfchart format="flash" title="#qGetHistory.recordCount# Hits" xaxistitle="Servers" yaxistitle="Ms per Hit" show3d="Yes" chartwidth="800" chartheight="400"> 
							<cfchartseries type="scatter" query="qGetHistory1" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
							<cfchartseries type="scatter" query="qGetHistory2" itemcolumn="serverNum" valuecolumn="elapsedMs"></cfchartseries>
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
	</table>

	<cfif 0>
		<!--- The following example analyzes the salary data in the cfdocexamples
		database and generates a bar chart showing average salary by department. --->
		
		<!--- Get the raw data from the database. --->
		<cfquery name="GetSalaries" datasource="cfdocexamples">
		SELECT Departmt.Dept_Name, 
		Employee.Dept_ID, 
		Employee.Salary
		FROM Departmt, Employee
		WHERE Departmt.Dept_ID = Employee.Dept_ID
		</cfquery>
		
		<!--- Use a query of queries to generate a new query with --->
		<!--- statistical data for each department. --->
		<!--- AVG and SUM calculate statistics. --->
		<!--- GROUP BY generates results for each department. --->
		<cfquery dbtype = "query" name = "DataTable">
		SELECT 
		Dept_Name,
		AVG(Salary) AS avgSal,
		SUM(Salary) AS sumSal
		FROM GetSalaries
		GROUP BY Dept_Name
		</cfquery>
		
		<!--- Reformat the generated numbers to show only thousands. --->
		<cfloop index = "i" from = "1" to = "#DataTable.RecordCount#">
		<cfset DataTable.sumSal[i] = Round(DataTable.sumSal[i]/1000)*1000>
		<cfset DataTable.avgSal[i] = Round(DataTable.avgSal[i]/1000)*1000>
		</cfloop>
		
		<h1>Employee Salary Analysis</h1> 
		<!--- Bar graph, from Query of Queries --->
		<cfchart format="flash" 
		xaxistitle="Department" 
		yaxistitle="Salary Average"> 
		
		<cfchartseries type="bar" 
		query="DataTable" 
		itemcolumn="Dept_Name" 
		valuecolumn="avgSal" />
		</cfchart>
	</cfif>
	
	</body>
	</html>
</cfoutput>

