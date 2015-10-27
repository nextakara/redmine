create database db_redmine default character set utf8;
grant all on db_redmine.* to user_redmine@localhost identified by 'password';
flush privileges;
