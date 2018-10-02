
CREATE OR REPLACE DIRECTORY EXPDPDIR AS '/tmp/expdp';

GRANT READ, WRITE ON DIRECTORY EXPDPDIR TO vaadmin;


--export/import  schema level
expdp vaadmin/12345 schemas=VAADMIN directory=EXPDPDIR dumpfile=VAADMIN_.dmp logfile=VAADMIN_.log


impdp vaadmin/12345 schemas=VAADMIN directory=EXPDPDIR dumpfile=VAADMIN_.dmp logfile=impdpVAADMIN_.log


--export/import  table level 
expdp vaadmin/12345 tables=Outlet directory=EXPDPDIR dumpfile=outlet.dmp logfile=outlet.log;

--import to different table
impdp vaadmin/12345 tables=Outlet remap_table=Outlet:Outlet_temp directory=EXPDPDIR dumpfile=outlet.dmp logfile=Newoutlet.log


--import to different table with query
expdp vaadmin/12345 tables=Outlet query=Outlet:"where CREATIONDATE \< \'01-JAN-2017\'"  directory=EXPDPDIR dumpfile=outlet.dmp logfile=outlet.log;




--add to a different schema
impdp vaadmin/12345 tables=vaadmin.Outlet remap_table=vaadmin.Outlet:cmsadmin.Outlet_temp directory=EXPDPDIR dumpfile=outlet.dmp logfile=Newoutlet.log


--with index re-create with remap_table


--ignore index and constraints

impdp vaadmin/12345 tables=Outlet remap_table=Outlet:Outlet_temp directory=EXPDPDIR dumpfile=outlet.dmp logfile=outletoutlet.log indexes=n constraints=n

--remove the folder contensts 

rm -rf *

--expdp with par file 

directory=DUMP_CMS
tables=vaadmin.I_UTIBA_AGENT_NEW_TMP_HTY_HRLY,vaadmin.UTIBA_PARENTCHILDLK_TMPHTYHRLY
dumpfile=expdp_vaadmin_20180125_%U.dmp
logfile=expdp_vaadmin_20180125.log
query=vaadmin.UTIBA_PARENTCHILDLK_TMPHTYHRLY:"where creationdate > sysdate-30"
query=vaadmin.I_UTIBA_AGENT_NEW_TMP_HTY_HRLY:"where creationdate > sysdate-30"

expdp parfile=exp.par parallel=4


-- import with replace
 
 
 
 expdp app_dms/12345 tables=Outlet,Item,Agent,Employee,Distributor directory=EXPDPDIR dumpfile=expdpdump.dmp logfile=expdpdump.log indexes=y triggers=y constraints=y parallel=4;
 expdp app_dms/12345 tables=AvLogin,AvSite,PriceList,ItemPriceList directory=EXPDPDIR dumpfile=expdpdump1.dmp logfile=expdpdump1.log indexes=y triggers=y constraints=y parallel=4;
 expdp app_dms/12345 tables=ALERT_CONFIG,ALERT_EMAIL,ALERT_SMS,APPLICATIONDEFAULT,APPLICATIONPARAMS,AREA,AUTHPAGE,AUTHPAGEPROFILE,AUTHPROFILE,AVCOREDEFAULT,AVLOGINEXT directory=EXPDPDIR dumpfile=expdpdump2.dmp logfile=expdpdump2.log indexes=y triggers=y constraints=y parallel=4;
  expdp app_dms/12345 tables=MULTIPURPOSETAG,DESIGNATIONHIERARCHY  directory=EXPDPDIR dumpfile=expdpdump3.dmp logfile=expdpdump3.log indexes=y triggers=y constraints=y parallel=4;
  expdp app_dms/12345 tables=OUTLETSHTNUMBER,AGENTOUTLET,AGENTROUTE,AGENTROUTEOUTLET,ROUTEOUTLET,OUTLETITEM,WHLOCITEM,WAREHOUSE,ITEMPRICELIST,DISTRIBUTORITEM  directory=EXPDPDIR dumpfile=expdpdump4.dmp logfile=expdpdump4.log indexes=y triggers=y constraints=y parallel=4;
  expdp app_dms/12345 tables=AGENTITEM,CALL,TXN,TXNLINE,TXNPO,TXNPOLINE,TXNINVOICE,TXNINVOICELINE,TXNGRN,TXNGRNLINE,TXNHORETURN,TXNHORETURNLINE  directory=EXPDPDIR dumpfile=expdpdump5.dmp logfile=expdpdump5.log indexes=y triggers=y constraints=y parallel=4;
     expdp app_dms/12345 tables=AGENTEXT   directory=EXPDPDIR dumpfile=expdpdump6.dmp logfile=expdpdump6.log indexes=y triggers=y constraints=y parallel=4;
     expdp app_dms/12345 tables=ROUTE   directory=EXPDPDIR dumpfile=expdpdump7.dmp logfile=expdpdump7.log indexes=y triggers=y constraints=y parallel=4;
  expdp app_dms/12345 tables=DistributorOutlet   directory=EXPDPDIR dumpfile=expdpdump8.dmp logfile=expdpdump8.log indexes=y triggers=y constraints=y parallel=4;
    expdp app_dms/12345 tables=OutletCategory   directory=EXPDPDIR dumpfile=expdpdump9dmp logfile=expdpdump9.log indexes=y triggers=y constraints=y parallel=4;
    expdp app_dms/12345 tables=AGENTTXNTYPE   directory=EXPDPDIR dumpfile=expdpdump10.dmp logfile=expdpdump10.log indexes=y triggers=y constraints=y parallel=4;
  
  impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump.dmp logfile=expdpdump.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4 
    impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump1.dmp logfile=expdpdump1.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4 
	 impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump2.dmp logfile=expdpdump2.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4 
	impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump3.dmp logfile=expdpdump3.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4 
 impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump4.dmp logfile=expdpdump4.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4 
  impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump5.dmp logfile=expdpdump5.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4
 impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump6.dmp logfile=expdpdump6.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4   
   impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump7.dmp logfile=expdpdump7.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4   
  impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump8.dmp logfile=expdpdump8.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4   
   impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump9.dmp logfile=expdpdump9.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4   
 impdp Telco/Telco  directory=EXPDPDIR dumpfile=expdpdump10.dmp logfile=expdpdump10.log table_exists_action=replace REMAP_TABLESPACE=DMS_DATA_TBS_01:USERS REMAP_TABLESPACE=DMS_INDEX_TBS_01:USERS  REMAP_SCHEMA=APP_DMS:TELCO parallel=4   
 