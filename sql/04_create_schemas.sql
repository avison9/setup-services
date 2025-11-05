---create schema file
\c :"tenant"-analytics
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS processed;
CREATE SCHEMA IF NOT EXISTS reporting;

ALTER ROLE :"tenant"-:"suffix" SET search_path TO staging, processed, reporting, public;