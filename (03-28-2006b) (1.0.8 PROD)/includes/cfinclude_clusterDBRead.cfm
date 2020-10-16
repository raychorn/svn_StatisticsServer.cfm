<cfparam name="Request.modusOperandi" type="string" default="READ">
		
<cfset Request.clusterDBError = false>
<cfset Request.clusterDBErrorMsg = "">
<cftry>
	<cfscript>
		DSN = 'clusterDB';
	</cfscript>
	
	<cflock timeout="10" throwontimeout="No" name="clusterStatsDbActions" type="EXCLUSIVE">
		<cfscript>
			// name of ClusterStats is the wddx struct...
			// name of ClusterHistory_MMDDYYYY is the historical data...
			if (UCASE(Request.modusOperandi) eq 'READ') {
				safely_execSQL('qGetStats', DSN, "SELECT id, name, wddx FROM ClusterData WHERE (name = 'ClusterStats')");
			
				if (NOT Request.dbError) {
					if (qGetStats.recordCount eq 0) {
						aStruct = StructNew();
						aStruct.ComputerID = getComputerID();
						aStruct.server1 = StructNew();
						aStruct.server1.numHits = 0;
						aStruct.server1.isOnline = false; // allows a server to be taken offline for maintenance purposes.
						aStruct.server2 = StructNew();
						aStruct.server2.numHits = 0;
						aStruct.server2.isOnline = false;  // allows a server to be taken offline for maintenance purposes.
						// Some metric needs to be found to determine which server is being hit the hardest apart from the number of hits sent to each.
						_wddxPacket = toWDDX(aStruct);
			
						safely_execSQL('qPutStats', DSN, "INSERT INTO ClusterData (name, wddx) VALUES ('ClusterStats','#filterQuotesForSQL(_wddxPacket)#'); SELECT @@IDENTITY as 'id';");
					} else {
						// convert the wddx packet into a struct...
						aStruct = fromWDDX(qGetStats.wddx);
					}
				}
			} else if ( (UCASE(Request.modusOperandi) eq 'WRITE') AND (IsDefined("aStruct")) ) {
				_wddxPacket = toWDDX(aStruct);
				safely_execSQL('qUpdStats', DSN, "UPDATE ClusterData SET wddx = '#filterQuotesForSQL(_wddxPacket)#' WHERE (name = 'ClusterStats'); SELECT @@IDENTITY as 'id';");
			}
		</cfscript>
	</cflock>

<cfif 0>
	<cfdump var="#aStruct#" label="aStruct" expand="No">
</cfif>	

	<cfcatch type="Any">
		<cfset Request.clusterDBError = true>

		<cfsavecontent variable="Request.clusterDBErrorMsg">
			<cfoutput>
				<cfif (IsDefined("cfcatch.message"))>[#cfcatch.message#]<br></cfif>
				<cfif (IsDefined("cfcatch.detail"))>[#cfcatch.detail#]<br></cfif>
			</cfoutput>
		</cfsavecontent>
	</cfcatch>
</cftry>
