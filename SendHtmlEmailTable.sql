 select  to_number(BALANCECLAWBACK )  from CLAWBACK_2016;
 

 select * from CLAWBACK_2016
 
 drop table CLAWBACKUPLOAD_2016_07_11
 
 
desc CLAWBACKUPLOAD_2016_07_11

     create Table CMRET_CREDACC_201600711_LK AS 
     select * from CMRETAILER_CREDITACCOUNT ;
     
     select * from CMRETAILER_CREDITACCOUNT where OUTLETUID = 57309; --3234.04
     
     select * from CMRETAILER_CREDITTXN where outletuid = 60515;
     
 select * from CMRETAILER_CREDITACCOUNT
 desc CMRETAILER_CREDITACCOUNT
 
   INSERT INTO CMRETAILER_CREDITACCOUNT(OUTLETUID,CREDITAMOUNT,APPLIEDCREDITAMOUNT,BALANCECREDITAMOUNT,CREATIONDATE,LASTMODIFIEDBY,LASTMODIFIEDDATE)
	 select   o.puid,TO_NUMBER(CL.BALANCECLAWBACK),0,TO_NUMBER(CL.BALANCECLAWBACK),SYSDATE,'$AxaInsert_20160711',NULL
	 from CLAWBACK_2016 cl
	 inner join outlet o on CL.RETAILERID = O.TLRNUMBER 
	 left outer join CMRETAILER_CREDITACCOUNT cc on cc.outletuid = o.puid
	 where cc.outletuid is null   ;
   
    INSERT INTO CMRETAILER_CREDITACCOUNT(OUTLETUID,CREDITAMOUNT,APPLIEDCREDITAMOUNT,BALANCECREDITAMOUNT,CREATIONDATE,LASTMODIFIEDBY,LASTMODIFIEDDATE)
    select   o.puid,TO_NUMBER(CL.BALANCECLAWBACK),0,TO_NUMBER(CL.BALANCECLAWBACK),SYSDATE,'$AxaInsert_20160711',NULL
	 from CLAWBACK_2016 cl
	 inner join outlet o on CL.RETAILERID = O.TLRNUMBER 
	 inner   join CMRETAILER_CREDITACCOUNT cc on cc.outletuid = o.puid
	 where cc.outletuid is not  null   and cc.BALANCECREDITAMOUNT > 0
   
   
 merge INTO CMRETAILER_CREDITACCOUNT  clm
   using (
     select   o.puid,CL.BALANCECLAWBACK,SYSDATE
     from CLAWBACK_2016 cl
     inner join outlet o on CL.RETAILERID = O.TLRNUMBER 
     left outer join CMRETAILER_CREDITACCOUNT cc on cc.outletuid = o.puid
     where cc.outletuid is not  null   
     
	 )kk on (clm.outletuid = kk.puid)
	 when matched then update
	 set clm.CREDITAMOUNT = kk.BALANCECLAWBACK
   ,clm.LASTMODIFIEDBY = '$AxaUpdate_20160711'
   ,clm.LASTMODIFIEDDATE = SYSDATE
   ,clm.BALANCECREDITAMOUNT =  kk.BALANCECLAWBACK
   WHERE clm.BALANCECREDITAMOUNT = 0; 
   
   
   update CMRETAILER_CREDITACCOUNT
   set APPLIEDCREDITAMOUNT = 0
   where OUTLETUID in (57309,1363,60515)
   
   commit;
   rollback
   
   
   ====================================
   
   D:\Releases\CMS\V2.13 Build990