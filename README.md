# Laboratorio de Real Time y Near Real Time

## Version 0.0.1

## Features
- Estructura de Directorios del Proyecto
- Archivo ps1 con las instrucciones para crear la M.V. en VirtualBox en Windows

## Description
Este Laboratorio tiene como propósito hacer las pruebas de procesos en Real Time y Near Real Time con los siguientes componentes técnicos:
- Sistema Gestor de Base de Datos PostgreSQL
- Apache Zookeeper y Apache Kafka
- Debezium que se conecta a través de Kafka a PostgreSQL y lleva el traciego del Change Data Capture de 3 tablas: Factura, Cliente y TipoCambioDolar
- Mirror Maker 2 (mm2) que a través de un conector con protocolo Kafka envia los datos a un Azure Event Hub Namespace
- Azure Event Hub Namespace
- Azure Databricks como consumidor de datos

