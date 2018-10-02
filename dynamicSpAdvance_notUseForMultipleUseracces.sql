create or replace PROCEDURE rptNewSAF_StatusReport(
    P_StartDate IN TIMESTAMP,
    P_EndDate IN TIMESTAMP,
    P_DistributorUID IN NUMBER DEFAULT NULL,
    P_UserDesignationEnum IN NUMBER DEFAULT NULL,
    P_UserEmployeeUID IN NUMBER DEFAULT NULL,
    P_IsFreelanceAgent IN NUMBER DEFAULT NULL,
    P_ChanelUID IN NUMBER DEFAULT NULL,
    P_CURSOR OUT SYS_REFCURSOR)	
IS
    IsReportingUserLevel NUMBER(3);   
    P_StartDate1 DATE;
    P_EndDate1 DATE;
    P_PreviousStartDate DATE;
    P_PreviousEndDate DATE;
    P_ChanelUID1 NUMBER(10,0);
    P_SAFTHRESHHOLD_TOT NUMBER(10,2);
    P_SAF_REJECT_THRESHHOLD NUMBER(10,2);
BEGIN
    P_ChanelUID1 := P_ChanelUID;    
    IF(P_ChanelUID = -1)
    THEN
      P_ChanelUID1 := NULL;
    END IF;
    -----------------------------------------------------------------------------------------------
    --User Logging
    -----------------------------------------------------------------------------------------------
    P_StartDate1:= TRUNC(P_StartDate,'DDD');    
    P_EndDate1 := TRUNC(P_EndDate,'DDD');    
    P_PreviousStartDate :=  TRUNC(TRUNC(ADD_MONTHS(P_StartDate,-1),'MONTH'),'DDD');  
    P_PreviousEndDate := TRUNC(ADD_MONTHS(TO_DATE('01-'||to_char(P_PreviousStartDate,'MON-RR'),'DD-MON-RR'),1)-1,'DDD');  
    
    IsReportingUserLevel := 0;

	EXECUTE IMMEDIATE('TRUNCATE TABLE DistributorUIDs_SAFStatusRpt');
    
    IF(P_UserDesignationEnum = 2)
    THEN
      IsReportingUserLevel := 1;
      
      INSERT INTO DistributorUIDs_SAFStatusRpt(PUID)
      SELECT PUID
      FROM Distributor D
      WHERE D.emp_OwnerUID = P_UserEmployeeUID;
    
    ELSIF(P_UserDesignationEnum = 16)
    THEN
      IsReportingUserLevel := 1;
      
      INSERT INTO DistributorUIDs_SAFStatusRpt(PUID)
      SELECT D.PUID
      FROM Distributor D
        INNER JOIN Employee E ON D.emp_OwnerUID = E.PUID
      WHERE E.ParentUID = P_UserEmployeeUID;
    
	ELSIF(P_UserDesignationEnum = 76)
    THEN
      IsReportingUserLevel := 1;
      
      INSERT INTO DistributorUIDs_SAFStatusRpt(PUID)
      SELECT D.PUID
      FROM Distributor D
        INNER JOIN Agent A ON D.PUID = A.DistributorUID
        INNER JOIN Agent SE ON A.ParentUID = SE.PUID
      WHERE SE.EmployeeUID = P_UserEmployeeUID
        AND NVL(A.IsPromoSub,0) = 1;

	ELSIF(P_UserDesignationEnum = 76)
    THEN
      IsReportingUserLevel := 1;
      
      INSERT INTO DistributorUIDs_SAFStatusRpt(PUID)
      SELECT D.PUID
      FROM Distributor D
        INNER JOIN Agent A ON D.PUID = A.DistributorUID
        INNER JOIN Agent SE ON A.ParentUID = SE.PUID
      WHERE SE.EmployeeUID = P_UserEmployeeUID
        AND NVL(A.IsPromoSub,0) = 1;
    ELSIF (P_UserDesignationEnum = 15)
    THEN
      IsReportingUserLevel := 1;
      
      INSERT INTO DistributorUIDs_SAFStatusRpt(PUID)
      SELECT D.PUID
      FROM Distributor D
        INNER JOIN Employee E ON D.emp_OwnerUID = E.PUID
        INNER JOIN Employee FSC ON E.ParentUID = FSC.PUID
      WHERE FSC.ParentUID = P_UserEmployeeUID;
    
    ELSIF(P_UserDesignationEnum = 6)
    THEN
      IsReportingUserLevel := 1;
      
      INSERT INTO DistributorUIDs_SAFStatusRpt(PUID)
      SELECT D.PUID
      FROM Distributor D
        INNER JOIN Employee E ON D.emp_OwnerUID = E.PUID
        INNER JOIN Employee FSC ON E.ParentUID = FSC.PUID
        INNER JOIN Employee ASM ON FSC.ParentUID = ASM.PUID
      WHERE ASM.ParentUID = P_UserEmployeeUID;
    
    ELSIF(P_UserDesignationEnum = 14)
    THEN
      IsReportingUserLevel := 1;
      
      INSERT INTO DistributorUIDs_SAFStatusRpt(PUID)
      SELECT D.PUID
      FROM Distributor D
        INNER JOIN Employee E ON D.emp_OwnerUID = E.PUID
        INNER JOIN Employee FSC ON E.ParentUID = FSC.PUID
        INNER JOIN Employee ASM ON FSC.ParentUID = ASM.PUID
        INNER JOIN Employee SM ON ASM.ParentUID = SM.PUID
      WHERE SM.ParentUID = P_UserEmployeeUID;
    END IF;
    --- App Patameters ---------------------------------------------------------
    SELECT No_SAF_THRESHHOLD INTO P_SAFTHRESHHOLD_TOT FROM APPLICATIONPARAMS;  --rejected
    SELECT SAF_REJECT_THRESHHOLD INTO P_SAF_REJECT_THRESHHOLD FROM APPLICATIONPARAMS; -- pending
    
    --Data set Pivot for Reject reasons ----------------------------------------
    DECLARE
  SQL_STMTCURRENT     CLOB;
  SQL_STMTPREV CLOB;
  PIVOT_CLAUSE1 CLOB;  
   PIVOT_CLAUSE2 CLOB;  
  V_EXIST NUMBER;
  FIRST_DATE VARCHAR2(10);
  SECOND_DATE VARCHAR2(10);
  BEGIN
   SELECT LISTAGG( '''' ||  TO_CHAR(MISCDATA)    || '_P' || '''', ',') WITHIN GROUP (ORDER BY TO_CHAR(MISCDATA))  INTO PIVOT_CLAUSE1
    FROM MULTIPURPOSETAG
    WHERE TYPE = 109 AND EXPIRYDATE IS NULL;           
    
      SELECT LISTAGG( '''' ||  TO_CHAR(MISCDATA)    || '_C' || '''', ',') WITHIN GROUP (ORDER BY TO_CHAR(MISCDATA))  INTO PIVOT_CLAUSE2
    FROM MULTIPURPOSETAG
    WHERE TYPE = 109 AND EXPIRYDATE IS NULL;           
    
    
    SELECT COUNT(*) INTO V_EXIST     FROM USER_TABLES WHERE TABLE_NAME = 'PREV_REJECT_SAF';
    SELECT COUNT(*) INTO V_EXIST     FROM USER_TABLES WHERE TABLE_NAME = 'CURRENT_REJECT_SAF';
    IF V_EXIST = 1 THEN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE  PREV_REJECT_SAF';   
      EXECUTE IMMEDIATE 'DROP TABLE  PREV_REJECT_SAF';  
      EXECUTE IMMEDIATE 'TRUNCATE TABLE  CURRENT_REJECT_SAF';   
      EXECUTE IMMEDIATE 'DROP TABLE  CURRENT_REJECT_SAF';        
     
    END IF;
    
     SELECT COUNT(*) INTO V_EXIST     FROM USER_TABLES WHERE TABLE_NAME = 'PREV_REJECT_SAF_NORMAL';
    SELECT COUNT(*) INTO V_EXIST     FROM USER_TABLES WHERE TABLE_NAME = 'CURRENT_REJECT_SAF_NORMAL';
    IF V_EXIST = 1 THEN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE  PREV_REJECT_SAF_NORMAL';   
      EXECUTE IMMEDIATE 'DROP TABLE  PREV_REJECT_SAF_NORMAL';  
      EXECUTE IMMEDIATE 'TRUNCATE TABLE  CURRENT_REJECT_SAF_NORMAL';   
      EXECUTE IMMEDIATE 'DROP TABLE  CURRENT_REJECT_SAF_NORMAL';  
       END IF;
    --FIRST_DATE :=  TO_CHAR(TRUNC(ADD_MONTHS(SYSDATE,-1),'MONTH'));
    --SECOND_DATE := TO_CHAR(TRUNC(SYSDATE,'MONTH'));
  
      FIRST_DATE := '01-APR-17';
      SECOND_DATE  := '01-MAY-17';
  
    --DBMS_OUTPUT.PUT_LINE(FIRST_DATE);
    --DBMS_OUTPUT.PUT_LINE(SECOND_DATE);
      SQL_STMTPREV  := '
        CREATE GLOBAL TEMPORARY TABLE PREV_REJECT_SAF   
        ON COMMIT PRESERVE ROWS
        AS
          SELECT * FROM (
        SELECT 1,MONTH, S.DISTRIBUTORUID,S.REJECTP_REASON, SUM(S.REJECTCOUNTBYREASON ) REJECTCOUNTBYREASON
        FROM SAF_REJECTREASON_SUMMARY S
        WHERE S.MONTH = ''' || FIRST_DATE || '''
        AND ISFREELANCE = 1
        GROUP BY S.MONTH,S.DISTRIBUTORUID,S.REJECTP_REASON
      )
      PIVOT (SUM(REJECTCOUNTBYREASON) FOR REJECTP_REASON IN (' || PIVOT_CLAUSE1 || '))';
    -- DBMS_OUTPUT.PUT_LINE(SQL_STMTPREV);
     EXECUTE IMMEDIATE SQL_STMTPREV;
     
     SQL_STMTPREV  := '
        CREATE GLOBAL TEMPORARY TABLE PREV_REJECT_SAF_NORMAL   
        ON COMMIT PRESERVE ROWS
        AS
          SELECT * FROM (
        SELECT 0,MONTH, S.DISTRIBUTORUID,S.REJECTP_REASON, SUM(S.REJECTCOUNTBYREASON ) REJECTCOUNTBYREASON
        FROM SAF_REJECTREASON_SUMMARY S
        WHERE S.MONTH = ''' || FIRST_DATE || '''
         AND ISFREELANCE = 0
        GROUP BY S.MONTH,S.DISTRIBUTORUID,S.REJECTP_REASON
      )
      PIVOT (SUM(REJECTCOUNTBYREASON) FOR REJECTP_REASON IN (' || PIVOT_CLAUSE1 || '))';
    -- DBMS_OUTPUT.PUT_LINE(SQL_STMTPREV);
     EXECUTE IMMEDIATE SQL_STMTPREV;

     SQL_STMTCURRENT := '
        CREATE GLOBAL TEMPORARY TABLE CURRENT_REJECT_SAF   
        ON COMMIT PRESERVE ROWS
        AS
          SELECT * FROM (
        SELECT 1,MONTH, S.DISTRIBUTORUID,S.REJECTP_REASON, SUM(S.REJECTCOUNTBYREASON ) REJECTCOUNTBYREASON
        FROM SAF_REJECTREASON_SUMMARY S
        WHERE S.MONTH = ''' || SECOND_DATE || '''
          AND ISFREELANCE = 1
        GROUP BY S.MONTH,S.DISTRIBUTORUID,S.REJECTP_REASON
      )
      PIVOT (SUM(REJECTCOUNTBYREASON) FOR REJECTP_REASON IN (' || PIVOT_CLAUSE2 || '))';
     -- DBMS_OUTPUT.PUT_LINE(SQL_STMTCURRENT);
    EXECUTE IMMEDIATE SQL_STMTCURRENT;
    
    SQL_STMTCURRENT := '
        CREATE GLOBAL TEMPORARY TABLE CURRENT_REJECT_SAF_NORMAL   
        ON COMMIT PRESERVE ROWS
        AS
          SELECT * FROM (
        SELECT 0,MONTH, S.DISTRIBUTORUID,S.REJECTP_REASON, SUM(S.REJECTCOUNTBYREASON ) REJECTCOUNTBYREASON
        FROM SAF_REJECTREASON_SUMMARY S
        WHERE S.MONTH = ''' || SECOND_DATE || '''
          AND ISFREELANCE = 0
        GROUP BY  S.MONTH,S.DISTRIBUTORUID,S.REJECTP_REASON
      )
      PIVOT (SUM(REJECTCOUNTBYREASON) FOR REJECTP_REASON IN (' || PIVOT_CLAUSE2 || '))';
     -- DBMS_OUTPUT.PUT_LINE(SQL_STMTCURRENT);
    EXECUTE IMMEDIATE SQL_STMTCURRENT;
  
    END;
---------------------------------------------------------------------------------------------------
    IF (P_IsFreelanceAgent = 1)
    THEN
      OPEN P_CURSOR FOR   
      with HEADERSADDETAIL AS 
       (
          SELECT SSE.FirstName ||' '|| SSE.LastName AS SSM
          ,AE.FirstName ||' '|| AE.LastName AS ASM
          ,SE2.FirstName ||' '|| SE2.LastName AS FSC
          ,A.Description AS OperationalDistrict
          ,KK.ActivateDistributorUID
          ,KK.SIMActivation  
          ,KK.SAF_RECIEVED AS SAF_RECIEVED 
          ,KK.SAF_RECIEVED_PERCENTAG AS SAF_RECIEVED_PERCENTAGE 
          ,KK.AccepetedCount
          ,KK.Accepeted_PERCENTAG
          ,KK.SAF_Rejected     
          ,KK.SAF_REJECT_PCT
          ,CASE WHEN KK.SAF_REJECT_PCT >= P_SAFTHRESHHOLD_TOT THEN 'Above' ELSE 'Below' END AS STATUS_TOT_REJECT
          ,KK.To_be_Collected
          ,KK.To_be_Collected_PCT
          ,CASE WHEN KK.To_be_Collected_PCT >= P_SAF_REJECT_THRESHHOLD THEN 'Above' ELSE 'Below' END AS STATUS_TOT_PEND
        FROM
        (
             SELECT S.ActivateDistributorUID
            ,COUNT(S.PUID) AS SIMActivation
            ,(SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) + COUNT(KK.SUBSCIBER_ID)) AS SAF_RECIEVED
            ,CAST((SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) + COUNT(KK.SUBSCIBER_ID)) / (CAST(COUNT(S.PUID) AS DECIMAL(18,2))) * 100 AS DECIMAL(18,2)) AS SAF_RECIEVED_PERCENTAG
            ,SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) AS AccepetedCount
            ,CASE WHEN SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) + COUNT(KK.SUBSCIBER_ID) = 0 
             THEN 0
              ELSE
                CAST((
                    SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) / 
                    (CAST(COUNT(S.PUID) AS DECIMAL(18,2))) ) * 100  AS DECIMAL(18,2)
                ) END AS Accepeted_PERCENTAG
              ,COUNT(KK.SUBSCIBER_ID) AS SAF_Rejected     
            ,CAST(COUNT(KK.SUBSCIBER_ID) / (CAST(COUNT(S.PUID) AS DECIMAL(18,2)))  * 100  AS DECIMAL(18,2))  AS SAF_REJECT_PCT
            ,(COUNT(S.PUID) - SUM(CASE WHEN S.SAFDATE IS NOT NULL THEN 1 ELSE 0 END)) - COUNT(KK.SUBSCIBER_ID)     AS To_be_Collected
           , CAST((((COUNT(S.PUID) - SUM(CASE WHEN S.SAFDATE IS NOT NULL THEN 1 ELSE 0 END)) - COUNT(KK.SUBSCIBER_ID))/ COUNT(S.PUID)) * 100  AS DECIMAL(18,2))  AS To_be_Collected_PCT
          FROM SIM S
            LEFT JOIN Outlet O ON S.ActiveOutletUID = O.PUID
            LEFT OUTER JOIN
              (
                SELECT DISTINCT SS.SUBSCIBER_ID,SS.SaFDate--,IsReject = 1
                FROM SAF_Status SS
                WHERE SS.IsReject  = 1
                AND SS.IsCurrent = 1
                AND TRUNC(SS.SAFDATE) >= P_StartDate1  - 60
              )KK ON S.DN = KK.SUBSCIBER_ID AND S.SAFDate IS NULL AND KK.SAFDATE > (S.ACTIVATIONDATE - 60) -- -- SAF status date > activation date - 60 days --AND S.IsSAFCollected = 1 
          inner join CURRENT_REJECT_SAF CUR ON  S.ActivateDistributorUID = CUR.DISTRIBUTORUID
          WHERE (P_DistributorUID=P_DistributorUID OR S.ActivateDistributorUID =P_DistributorUID)
            AND (IsReportingUserLevel= 0 OR S.ActivateDistributorUID IN (SELECT PUID FROM DistributorUIDs_SAFStatusRpt))
            AND TRUNC(S.ActivationDate) >=  P_StartDate1  AND TRUNC(S.ActivationDate) <=  P_EndDate1 
            AND NVL(O.IsFreeLanceAgent,0) = 1
            --AND S.EXPIRYDATE IS NULL  -- because if activation is happend recently then sim probabaly in active status
          GROUP BY S.ActivateDistributorUID
        )KK 
        INNER JOIN Distributor D ON KK.ActivateDistributorUID = D.PUID
        INNER JOIN Area A ON D.BusinessAreaUID = A.PUID
        INNER JOIN
        (
          SELECT DISTINCT AG.DistributorUID,SE.EmployeeUID
          FROM Agent AG
            INNER JOIN Agent SE ON AG.ParentUID = SE.PUID
          WHERE AG.ExpiryDate IS NULL
           AND AG.mpt_DesignationEnum=1 ----7/3/2017 mismatch with MIS just
            AND NVL(AG.IsPromoSub,0) = 1
        )SE ON D.PUID = SE.DistributorUID
        INNER JOIN Employee SE2 ON SE.EmployeeUID = SE2.PUID
        INNER JOIN Employee AE ON SE2.ParentUID = AE.PUID
        INNER JOIN Employee SM ON AE.ParentUID = SM.PUID
        INNER JOIN Employee SSE ON SM.ParentUID = SSE.PUID
      WHERE  SM.ExpiryDate IS NULL
        AND SSE.ExpiryDate IS NULL
        AND NVL(D.mpt_TypeEnum,0) <> 1
        AND D.ExpiryDate IS NULL
        AND (P_ChanelUID1 IS NULL OR D.mpt_ChannelUID = P_ChanelUID1)
      ORDER BY 3
      ),
      PreRejectSAF AS (       
      SELECT KK.*,CUR.*
        FROM
        (
             SELECT S.ActivateDistributorUID 
            ,(SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) + COUNT(KK.SUBSCIBER_ID)) AS SAF_RECIEVED 
            ,SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) AS AccepetedCount 
            ,COUNT(KK.SUBSCIBER_ID) AS SAF_Rejected      
              FROM SIM S
              LEFT JOIN Outlet O ON S.ActiveOutletUID = O.PUID
              LEFT OUTER JOIN
                (
                  SELECT DISTINCT SS.SUBSCIBER_ID,SS.SaFDate--,IsReject = 1
                  FROM SAF_Status SS
                  WHERE SS.IsReject  = 1
                  AND SS.IsCurrent = 1
                  AND TRUNC(SS.SAFDATE) >= TRUNC(ADD_MONTHS(P_StartDate,-1),'MONTH')  - 60
                )KK ON S.DN = KK.SUBSCIBER_ID AND S.SAFDate IS NULL AND KK.SAFDATE > (S.ACTIVATIONDATE - 60) -- -- SAF status date > activation date - 60 days --AND S.IsSAFCollected = 1 
             WHERE (P_DistributorUID=P_DistributorUID OR S.ActivateDistributorUID =P_DistributorUID)
              AND (IsReportingUserLevel= 0 OR S.ActivateDistributorUID IN (SELECT PUID FROM DistributorUIDs_SAFStatusRpt))
              AND TRUNC(S.ActivationDate) >= TRUNC(ADD_MONTHS(P_StartDate,-1),'MONTH') AND TRUNC(S.ActivationDate) <= TRUNC(P_EndDate,'DDD') 
              AND NVL(O.IsFreeLanceAgent,0) = 1
              --AND S.EXPIRYDATE IS NULL  -- because if activation is happend recently then sim probabaly in active status
            GROUP BY S.ActivateDistributorUID
          )KK 
          inner join PREV_REJECT_SAF CUR ON  KK.ActivateDistributorUID = CUR.DISTRIBUTORUID
      )     
      select HD.SSM
        ,HD.ASM
        ,HD.FSC
        ,HD.OperationalDistrict
        ,HD.ActivateDistributorUID
        ,HD.SIMActivation  
        ,HD.SAF_RECIEVED 
        ,HD.SAF_RECIEVED_PERCENTAGE 
        ,HD.AccepetedCount
        ,HD.Accepeted_PERCENTAG
        ,HD.SAF_Rejected     
        ,PRV.*   
        ,HD.SAF_REJECT_PCT
        ,HD.STATUS_TOT_REJECT
        ,HD.To_be_Collected
        ,HD.To_be_Collected_PCT
        ,HD.STATUS_TOT_PEND
        ,CUR.*
      from HEADERSADDETAIL HD
      LEFT JOIN CURRENT_REJECT_SAF PRV ON HD.ActivateDistributorUID = PRV.DistributorUID
      LEFT JOIN PreRejectSAF CUR ON HD.ActivateDistributorUID = CUR.ActivateDistributorUID;  
      
    ELSE
      OPEN P_CURSOR FOR
      with HEADERSADDETAIL AS 
     (
        SELECT SSE.FirstName || ' ' || SSE.LastName AS SSM
        ,AE.FirstName || ' ' || AE.LastName  AS ASM
        ,FE.FirstName || ' ' || FE.LastName  AS FSC
        ,A.Description AS OperationalDistrict
        ,KK.ActivateDistributorUID
        ,KK.SIMActivation  
        ,KK.SAF_RECIEVED AS SAF_RECIEVED 
        ,KK.SAF_RECIEVED_PERCENTAG AS SAF_RECIEVED_PERCENTAGE 
        ,KK.AccepetedCount
        ,KK.Accepeted_PERCENTAG
        ,KK.SAF_Rejected     
        ,KK.SAF_REJECT_PCT
        ,CASE WHEN KK.SAF_REJECT_PCT >= P_SAFTHRESHHOLD_TOT THEN 'Above' ELSE 'Below' END AS STATUS_TOT_REJECT
        ,KK.To_be_Collected
        ,KK.To_be_Collected_PCT
        ,CASE WHEN KK.To_be_Collected_PCT >= P_SAF_REJECT_THRESHHOLD THEN 'Above' ELSE 'Below' END AS STATUS_TOT_PEND
      FROM
      (
           SELECT S.ActivateDistributorUID
          ,COUNT(S.PUID) AS SIMActivation
          ,(SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) + COUNT(KK.SUBSCIBER_ID)) AS SAF_RECIEVED
          ,CAST((SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) + COUNT(KK.SUBSCIBER_ID)) / (CAST(COUNT(S.PUID) AS DECIMAL(18,2))) * 100 AS DECIMAL(18,2)) AS SAF_RECIEVED_PERCENTAG
          ,SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) AS AccepetedCount
          ,CASE WHEN SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) + COUNT(KK.SUBSCIBER_ID) = 0 
           THEN 0
            ELSE
              CAST((
                  SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) / 
                  (CAST(COUNT(S.PUID) AS DECIMAL(18,2))) ) * 100  AS DECIMAL(18,2)
              ) END AS Accepeted_PERCENTAG
            ,COUNT(KK.SUBSCIBER_ID) AS SAF_Rejected     
          ,CAST(COUNT(KK.SUBSCIBER_ID) / (CAST(COUNT(S.PUID) AS DECIMAL(18,2)))  * 100  AS DECIMAL(18,2))  AS SAF_REJECT_PCT
          ,(COUNT(S.PUID) - SUM(CASE WHEN S.SAFDATE IS NOT NULL THEN 1 ELSE 0 END)) - COUNT(KK.SUBSCIBER_ID)     AS To_be_Collected
         , CAST((((COUNT(S.PUID) - SUM(CASE WHEN S.SAFDATE IS NOT NULL THEN 1 ELSE 0 END)) - COUNT(KK.SUBSCIBER_ID))/ COUNT(S.PUID)) * 100  AS DECIMAL(18,2))  AS To_be_Collected_PCT
        FROM SIM S
          LEFT JOIN Outlet O ON S.ActiveOutletUID = O.PUID
          LEFT OUTER JOIN
            (
              SELECT DISTINCT SS.SUBSCIBER_ID,SS.SaFDate--,IsReject = 1
              FROM SAF_Status SS
              WHERE SS.IsReject  = 1
              AND SS.IsCurrent = 1
              AND TRUNC(SS.SAFDATE) >= P_StartDate1 - 60
            )KK ON S.DN = KK.SUBSCIBER_ID AND S.SAFDate IS NULL AND KK.SAFDATE > (S.ACTIVATIONDATE - 60) -- -- SAF status date > activation date - 60 days --AND S.IsSAFCollected = 1 
        inner join CURRENT_REJECT_SAF_NORMAL CUR ON  S.ActivateDistributorUID = CUR.DISTRIBUTORUID
        WHERE (1=1 OR S.ActivateDistributorUID = 1)
          AND (0= 0 OR S.ActivateDistributorUID IN (SELECT PUID FROM DistributorUIDs_SAFStatusRpt))
          AND TRUNC(S.ActivationDate) >= P_StartDate1 AND TRUNC(S.ActivationDate) <= P_EndDate1
          AND NVL(O.IsFreeLanceAgent,0) <> 1
          --AND S.EXPIRYDATE IS NULL  -- because if activation is happend recently then sim probabaly in active status
        GROUP BY S.ActivateDistributorUID
      )KK 
         INNER JOIN Distributor D ON KK.ActivateDistributorUID = D.PUID
          INNER JOIN Area A ON D.BusinessAreaUID = A.PUID
          INNER JOIN Employee DE ON D.emp_OwnerUID = DE.PUID
          INNER JOIN Employee FE ON DE.ParentUID = FE.PUID
          INNER JOIN Employee AE ON FE.ParentUID = AE.PUID
          INNER JOIN Employee SE ON AE.ParentUID = SE.PUID
          INNER JOIN Employee SSE ON SE.ParentUID = SSE.PUID
        WHERE DE.ExpiryDate IS NULL
          AND FE.ExpiryDate IS NULL
          AND AE.ExpiryDate IS NULL
          AND SE.ExpiryDate IS NULL
          AND SSE.ExpiryDate IS NULL
          AND NVL(D.mpt_TypeEnum,0) <> 1
          AND D.ExpiryDate IS NULL
        --  AND (P_ChanelUID1 IS NULL OR D.mpt_ChannelUID = P_ChanelUID1)
        ORDER BY 3
      ),
      PreRejectSAF AS (       
      SELECT KK.*,CUR.*
        FROM
        (
             SELECT S.ActivateDistributorUID 
            ,(SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) + COUNT(KK.SUBSCIBER_ID)) AS SAF_RECIEVED 
            ,SUM(CASE WHEN S.SAFDate IS NOT NULL THEN 1 ELSE 0 END) AS AccepetedCount 
            ,COUNT(KK.SUBSCIBER_ID) AS SAF_Rejected      
              FROM SIM S
              LEFT JOIN Outlet O ON S.ActiveOutletUID = O.PUID
              LEFT OUTER JOIN
                (
                  SELECT DISTINCT SS.SUBSCIBER_ID,SS.SaFDate--,IsReject = 1
                  FROM SAF_Status SS
                  WHERE SS.IsReject  = 1
                  AND SS.IsCurrent = 1
                  AND TRUNC(SS.SAFDATE) >= P_PreviousStartDate - 60
                )KK ON S.DN = KK.SUBSCIBER_ID AND S.SAFDate IS NULL AND KK.SAFDATE > (S.ACTIVATIONDATE - 60) -- -- SAF status date > activation date - 60 days --AND S.IsSAFCollected = 1 
             WHERE (1=1 OR S.ActivateDistributorUID = 1)
              AND (0= 0 OR S.ActivateDistributorUID IN (SELECT PUID FROM DistributorUIDs_SAFStatusRpt))
              AND TRUNC(S.ActivationDate) >= P_PreviousStartDate AND TRUNC(S.ActivationDate) <= P_PreviousEndDate 
              AND NVL(O.IsFreeLanceAgent,0) <> 1
              --AND S.EXPIRYDATE IS NULL  -- because if activation is happend recently then sim probabaly in active status
            GROUP BY S.ActivateDistributorUID
          )KK 
          inner join PREV_REJECT_SAF_NORMAL CUR ON  KK.ActivateDistributorUID = CUR.DISTRIBUTORUID
      )
      select HD.SSM
        ,HD.ASM
        ,HD.FSC
        ,HD.OperationalDistrict
        ,HD.ActivateDistributorUID
        ,HD.SIMActivation  
        ,HD.SAF_RECIEVED 
        ,HD.SAF_RECIEVED_PERCENTAGE 
        ,HD.AccepetedCount
        ,HD.Accepeted_PERCENTAG
        ,HD.SAF_Rejected     
        ,PRV.*   
        ,HD.SAF_REJECT_PCT
        ,HD.STATUS_TOT_REJECT
        ,HD.To_be_Collected
        ,HD.To_be_Collected_PCT
        ,HD.STATUS_TOT_PEND
        ,CUR.*
      from HEADERSADDETAIL HD
      LEFT JOIN CURRENT_REJECT_SAF_NORMAL PRV ON HD.ActivateDistributorUID = PRV.DistributorUID
      LEFT JOIN PreRejectSAF CUR ON HD.ActivateDistributorUID = CUR.ActivateDistributorUID;

    END IF;

    COMMIT;
END;