<cfscript>
	const_PK_violation_msg = 'Violation of PRIMARY KEY constraint';

	function _isPKviolation(eMsg) {
		var bool = false;
		if (FindNoCase(const_PK_violation_msg, eMsg) gt 0) {
			bool = true;
		}
		return bool;
	}

	function filterQuotesForSQL(s) {
		return ReplaceNoCase(s, "'", "''", 'all');
	}
</cfscript>

<cffunction name="safely_execSQL" access="public">
	<cfargument name="_qName_" type="string" required="yes">
	<cfargument name="_DSN_" type="string" required="yes">
	<cfargument name="_sql_" type="string" required="yes">
	<cfargument name="_cachedWithin_" type="string" default="">
	
	<cfset Request.errorMsg = "">
	<cfset Request.moreErrorMsg = "">
	<cfset Request.explainError = "">
	<cfset Request.explainErrorHTML = "">
	<cfset Request.dbError = "False">
	<cfset Request.isPKviolation = "False">
	<cftry>
		<cfif (Len(Trim(arguments._qName_)) gt 0)>
			<cfif (Len(_DSN_) gt 0)>
				<cfif (Len(_cachedWithin_) gt 0) AND (IsNumeric(_cachedWithin_))>
					<cfquery name="#_qName_#" datasource="#_DSN_#" cachedwithin="#_cachedWithin_#">
						#PreserveSingleQuotes(_sql_)#
					</cfquery>
				<cfelse>
					<cfquery name="#_qName_#" datasource="#_DSN_#">
						#PreserveSingleQuotes(_sql_)#
					</cfquery>
				</cfif>
			<cfelse>
				<cfquery name="#_qName_#" dbtype="query">
					#PreserveSingleQuotes(_sql_)#
				</cfquery>
			</cfif>
		<cfelse>
			<cfset Request.errorMsg = "Missing Query Name which is supposed to be the first parameter.">
			<cfthrow message="#Request.errorMsg#" type="missingQueryName" errorcode="-100">
		</cfif>

		<cfcatch type="Any">
			<cfset Request.dbError = "True">

			<cfsavecontent variable="Request.errorMsg">
				<cfoutput>
					<cfif (IsDefined("cfcatch.message"))>[#cfcatch.message#]<br></cfif>
					<cfif (IsDefined("cfcatch.detail"))>[#cfcatch.detail#]<br></cfif>
					<cfif (IsDefined("cfcatch.SQLState"))>[<b>cfcatch.SQLState</b>=#cfcatch.SQLState#]</cfif>
				</cfoutput>
			</cfsavecontent>

			<cfsavecontent variable="Request.moreErrorMsg">
				<cfoutput>
					<UL>
						<cfif (IsDefined("cfcatch.Sql"))><LI>#cfcatch.Sql#</LI></cfif>
						<cfif (IsDefined("cfcatch.type"))><LI>#cfcatch.type#</LI></cfif>
						<cfif (IsDefined("cfcatch.message"))><LI>#cfcatch.message#</LI></cfif>
						<cfif (IsDefined("cfcatch.detail"))><LI>#cfcatch.detail#</LI></cfif>
						<cfif (IsDefined("cfcatch.SQLState"))><LI>#cfcatch.SQLState#</LI></cfif>
					</UL>
				</cfoutput>
			</cfsavecontent>

			<cfscript>
				if (Len(_DSN_) gt 0) {
					Request.isPKviolation = _isPKviolation(Request.errorMsg);
				}
			</cfscript>

			<cfset Request.dbErrorMsg = Request.errorMsg>
			<cfsavecontent variable="Request.fullErrorMsg">
				<cfoutput>
					#Request.moreErrorMsg#
				</cfoutput>
			</cfsavecontent>
			<cfsavecontent variable="Request.verboseErrorMsg">
				<cfif (IsDefined("Request.bool_show_verbose_SQL_errors"))>
					<cfif (Request.bool_show_verbose_SQL_errors)>
						<cfoutput>
							#Request.explainErrorHTML#
						</cfoutput>
					</cfif>
				</cfif>
			</cfsavecontent>
		</cfcatch>
	</cftry>
</cffunction>

<cffunction name="toWDDX" access="public" returntype="string">
	<cfargument name="_datum_" type="any" required="yes">

	<cfset var _wddx = "">
	<cfwddx action="CFML2WDDX" input="#_datum_#" output="_wddx" usetimezoneinfo="Yes">
	
	<cfreturn _wddx>
</cffunction>

<cffunction name="fromWDDX" access="public" returntype="any">
	<cfargument name="_wddx_" type="string" required="yes">

	<cfset var aStruct = -1>
	<cfwddx action="WDDX2CFML" input="#_wddx_#" output="aStruct" validate="yes">
	
	<cfreturn aStruct>
</cffunction>
