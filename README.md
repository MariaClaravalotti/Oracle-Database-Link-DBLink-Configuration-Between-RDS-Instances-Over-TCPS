# Oracle-Database-Link-DBLink-Configuration-Between-RDS-Instances-Over-TCPS
This project documents the secure configuration of Oracle DBLinks between Amazon RDS instances using TCPS, enabling encrypted cross-database communication.


## Problem

Standard DBLink configurations may transmit data without encryption, violating security and compliance requirements.

## 🏗 Architecture

Amazon RDS for Oracle (Source and Target)

TCPS (Port 2484)

Oracle Wallet

SSL Certificates

## ⚙️ How It Works (Step-by-Step)

Download AWS RDS root certificates.

Create and configure Oracle Wallet.

Import certificates into the Wallet.

Configure sqlnet.ora and tnsnames.ora.

Create DBLink using TCPS connection string.

Validate encrypted communication.

## 🚀 Key Features

Encrypted database-to-database traffic

Secure credential handling

Compliance-ready configuration

## 🛠 Technologies

Amazon RDS Oracle

Oracle Wallet

TCPS / SSL

SQL*Plus

## 📈 Results

Secure data exchange between RDS instances

Successful DBLink connectivity over TCPS

Compliance with security standards

## 📚 Lessons Learned

TCPS is mandatory in regulated environments

Wallet management is critical

DBLink security requires careful configuration

<img width="767" height="589" alt="image" src="https://github.com/user-attachments/assets/88c5b9de-433f-4008-82ee-6503c94be52c" />
