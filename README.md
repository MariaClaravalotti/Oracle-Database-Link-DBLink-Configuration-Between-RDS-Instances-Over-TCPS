# DBLink RDS Oracle via TCPS Oracle-Database (Port 2484)

This document describes exactly the steps I executed to create a secure DBLink between two AWS RDS Oracle databases using TCPS (port 2484), following the same structure used in my Git repository.

---

## Architecture

Source: RDS Oracle A  
Target: RDS Oracle B  
Protocol: TCPS  
Port: 2484  
Security: Oracle Wallet (SSL)  
Local environment: Windows  

---

## Step 1 – Validate RDS prerequisites

1. Confirm that TCPS is enabled on both RDS instances and that port 2484 is allowed in the Security Group.
2. Confirm network connectivity between the RDS instances (Security Group to Security Group or allowed IP).
3. Ensure a valid database user and password exist on the target database.

---

## Step 2 – Download the wallet from the target RDS

From the AWS Console:

1. Go to RDS → Databases → target database
2. Open Configuration
3. Download the DB Instance Wallet
4. Extract the ZIP file locally on Windows

Example local path:

C:\oracle\wallet_target

---

## Step 3 – Create sqlnet.ora (local/client)

File path:

C:\oracle\wallet_target\sqlnet.ora

Content:

WALLET_LOCATION =
 (SOURCE =
   (METHOD = FILE)
   (METHOD_DATA =
     (DIRECTORY = C:\oracle\wallet_target)
   )
 )

SSL_SERVER_DN_MATCH = YES

---

## Step 4 – Create tnsnames.ora

File path:

C:\oracle\wallet_target\tnsnames.ora

Example content:

DB_TARGET_TCPS =
 (DESCRIPTION =
   (ADDRESS = (PROTOCOL = TCPS)(HOST = target-rds-endpoint)(PORT = 2484))
   (CONNECT_DATA =
     (SERVICE_NAME = ORCL)
   )
 )

---

## Step 5 – Test the connection using SQL*Plus (local)

Set the TNS_ADMIN variable:

set TNS_ADMIN=C:\oracle\wallet_target

Test the connection:

sqlplus target_user@DB_TARGET_TCPS or SQL DEVELOPER -> SELECT * FROM dual@NOME_DBLINK;


If the connection succeeds, the wallet and TCPS configuration are correct.

---

## Step 6 – Upload the wallet to the source RDS

Files to include in the ZIP:
- cwallet.sso
- ewallet.p12
- sqlnet.ora
- tnsnames.ora

ZIP file name:

wallet_tcps.zip

Upload the wallet using the AWS RDS utility package:

exec rdsadmin.rdsadmin_util.upload_wallet(
  p_wallet    => 'WALLET_TCPS',
  p_directory => 'DATA_PUMP_DIR'
);

---

## Step 7 – Configure sqlnet on the source RDS

Configure the wallet location on the source RDS:

exec rdsadmin.rdsadmin_util.set_configuration(
  name  => 'WALLET_LOCATION',
  value => '/rdsdbdata/config/wallet'
);

---

## Step 8 – Create the DBLink

Connected to the source RDS:

CREATE DATABASE LINK DBLINK_TCPS_TARGET
CONNECT TO target_user IDENTIFIED BY "password"
USING 'DB_TARGET_TCPS';

---

## Step 9 – Test the DBLink

SELECT * FROM dual@DBLINK_TCPS_TARGET;

If it returns X, the TCPS DBLink is working correctly.

---

## Important Notes

- Port 2484 is mandatory for TCPS
- The wallet must match the target RDS wallet
- SSL_SERVER_DN_MATCH = YES is required
- Always test the TCPS connection locally before creating the DBLink

---

## Status

DBLink successfully created  
Encrypted communication using TCPS  
Validated in production environment  

Author: Maria Clara


<img width="767" height="589" alt="image" src="https://github.com/user-attachments/assets/88c5b9de-433f-4008-82ee-6503c94be52c" />
