Cloudfile
=========
This is a small project that aims to make it easy to get/put files to some arbitrary location without trying to store the file with the application.

Usage
=====
The client folder contains the client cfc, a testing page, and a sample file that can be uploaded.

Setting this up on your own?
============================
I have this setup to use oracle via hibernate, but sql server should work just as well.  ColdFusion 9 should work fine, but I did all my development with 9.0.1.

- create tables from sql scripts
- setup dsn in coldfusion
- set config.ini to reflect your current server setup (i.e. if you are using it on localhost or somewhere else)