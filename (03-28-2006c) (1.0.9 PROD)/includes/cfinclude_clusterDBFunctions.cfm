<cfscript>
	const_computerID_exe = 'temp.exe';
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

<cffunction name="writeComputerIDExe" access="public" returntype="string">
	<cfset var fName = -1>
	<cfset var binimage = "">
	<cfset var exeName = const_computerID_exe>
	<cfset fName = ExpandPath(exeName)>
	<cfset binimage = BinaryDecode(binEncoded, "Hex")>
	<cflock timeout="10" throwontimeout="No" name="computerID" type="EXCLUSIVE">
		<cffile action="WRITE" file="#fName#" output="#binimage#" attributes="Normal" addnewline="No" fixnewline="No">
	</cflock>
</cffunction>

<cffunction name="readComputerIDExe" access="public" returntype="string">
	<cfset var fName = -1>
	<cfset var binimage = "">
	<cfset var binEncoded = "">
	<cfset var exeName = const_computerID_exe>
	<cfset fName = ExpandPath(exeName)>
	<cfif (FileExists(fName))>
		<cffile action="READBINARY" file="#fName#" variable="binimage">
		<cfset binEncoded = BinaryEncode(binimage, "Hex")>
	</cfif>
	<cfset fName = ExpandPath("computerID.dat")>
	<cflock timeout="10" throwontimeout="No" name="computerIDdat" type="EXCLUSIVE">
		<cffile action="WRITE" file="#fName#" output="#binEncoded#" attributes="Normal" addnewline="No" fixnewline="No">
	</cflock>
	<cfreturn binEncoded>
</cffunction>

<cffunction name="getComputerID" access="public" returntype="string">
	<cfset var fName = -1>
	<cfset var exeName = const_computerID_exe>
	<cfset var outName = "ComputerID_v1.0.0.out">
	<cfset var dllName = "WBDEG44I.DLL">
	<cfscript>
		writeComputerIDExe();
	</cfscript>
	<cfexecute name="#ExpandPath(exeName)#" timeOut="30"></cfexecute>
	<cfset fName = ExpandPath(outName)>
	<cfif (FileExists(fName))>
		<cffile action="READ" file="#fName#" variable="outText">
		<cflock timeout="10" throwontimeout="No" name="computerIDdelete" type="EXCLUSIVE">
			<cftry>
				<cffile action="DELETE" file="#fName#">

				<cfcatch type="Any">
				</cfcatch>
			</cftry>
		</cflock>
	</cfif>
	<cfset fName = ExpandPath(dllName)>
	<cfif (FileExists(fName))>
		<cflock timeout="10" throwontimeout="No" name="computerIDDLLdelete" type="EXCLUSIVE">
			<cftry>
				<cffile action="DELETE" file="#fName#">

				<cfcatch type="Any">
				</cfcatch>
			</cftry>
		</cflock>
	</cfif>
	<cfset fName = ExpandPath(exeName)>
	<cfif (FileExists(fName))>
		<cftry>
			<cflock timeout="10" throwontimeout="No" name="computerIDEXEdelete" type="EXCLUSIVE">
				<cffile action="DELETE" file="#fName#">
			</cflock>

			<cfcatch type="Any">
			</cfcatch>
		</cftry>
	</cfif>
	<cfreturn outText>
</cffunction>

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

<cffunction name="cf_log" access="public">
	<cfargument name="_logName_" type="string" required="yes">
	<cfargument name="_someText_" type="string" required="yes">
	
	<cflog file="#_logName_#" type="Information" text="#_someText_#">
</cffunction>

<cffunction name="toWDDX" access="public" returntype="string">
	<cfargument name="_datum_" type="any" required="yes">

	<cfset var _wddx = "">
	<cfset var _Key = "">
	<cfwddx action="CFML2WDDX" input="#_datum_#" output="_wddx" usetimezoneinfo="Yes">
	
	<cfscript>
		_Key = generateSecretKey('BLOWFISH');
		_wddx = Encrypt(_wddx, _Key, 'BLOWFISH', 'Hex');
	</cfscript>
	
	<cfreturn Chr(Len(_Key)) & _Key & _wddx>
</cffunction>

<cffunction name="fromWDDX" access="public" returntype="any">
	<cfargument name="_wddx_" type="string" required="yes">

	<cfset var _Key = "">
	<cfset var keyLen = -1>
	<cfset var aStruct = -1>
	<cfscript>
		keyLen = Asc(Left(_wddx_, 1));
		_Key = Mid(_wddx_, 2, keyLen);
		_wddx_ = Right(_wddx_, Len(_wddx_) - (keyLen + 1));
		_wddx_ = Decrypt(_wddx_, _Key, 'BLOWFISH', 'Hex');
	</cfscript>
	<cfwddx action="WDDX2CFML" input="#_wddx_#" output="aStruct" validate="yes">
	
	<cfreturn aStruct>
</cffunction>