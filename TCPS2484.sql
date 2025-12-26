-----Create or use a custom Option Group 

aws rds add-option-to-option-group --option-group-name YourOptionGroup \
  --options 'OptionName=SSL,Port=2484,VpcSecurityGroupMemberships="sg
<YourSGID>",OptionSettings=[{Name=SQLNET.SSL_VERSION,Value=1.2}]'


----Create a wallet on a local machine

orapki wallet create -wallet /tmp/rdswallet -pwd Welcome1 -auto_login  
orapki wallet add -wallet /tmp/rdswallet -pwd Welcome1 -trusted_cert -cert rds-ca
cert.pem

----Create an RDS directory for the wallet

EXEC rdsadmin.rdsadmin_util.create_directory(p_directory_name => 'REMOTE_WALLET');


-----This creates a directory accessible via Oracle named REMOTE_WALLET

SELECT directory_path FROM dba_directories WHERE directory_name = 'REMOTE_WALLET';


--- PL/SQL script on the RDS to write the file.
DECLARE 
  f UTL_FILE.file_type; 
  base64_blob VARCHAR2(32767) := '<Base64 string here>';
BEGIN 
  f := UTL_FILE.fopen('REMOTE_WALLET', 'cwallet.sso', 'wb', 32767);
  UTL_FILE.put_raw(f, UTL_ENCODE.base64_decode(UTL_RAW.cast_to_raw(base64_blob))); 
  UTL_FILE.fclose(f);
END;
/ 

----Verify the files on RDS
SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir('REMOTE_WALLET'));

----Create the Database Link Using TCPS and the Wallet-------

CREATE DATABASE LINK TargetDB_SSL CONNECT TO target_user IDENTIFIED BY password
 USING '(DESCRIPTION=
           (ADDRESS=(PROTOCOL=TCPS)(HOST=<target-endpoint>)(PORT=2484))
           (CONNECT_DATA=(SERVICE_NAME=<service-name>))
           (SECURITY=(MY_WALLET_DIRECTORY=<wallet_path>)
                     (SSL_SERVER_CERT_DN="<Target_Cert_DN>")))';

----Verify Connection and Certificate Validation

SELECT sid, network_service_banner 
FROM v$session_connect_info 
WHERE sid = (SELECT sid FROM v$session 
WHERE audsid = USERENV('SESSIONID'))