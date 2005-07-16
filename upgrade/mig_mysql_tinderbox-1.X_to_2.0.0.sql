
SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE users
  ADD User_Password varchar(41) NOT NULL,
  ADD User_Www_Enabled tinyint(1) NOT NULL default '0';

DROP TABLE IF EXISTS user_permissions;
CREATE TABLE IF NOT EXISTS user_permissions (
  User_Id int(11) NOT NULL,
  Host_Id int(11) NOT NULL,
  User_Permission_Object_Type enum('builds','users') NOT NULL,
  User_Permission_Object_Id int(11) NOT NULL default '0',
  User_Permission int(11) NOT NULL default '0',
  PRIMARY KEY  (User_Id,User_Permission_Object_Type,User_Permission_Object_Id,User_Permission,Host_Id),
  INDEX (User_Id),
  FOREIGN KEY (User_Id)
    REFERENCES users(User_Id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) TYPE=INNODB;


ALTER TABLE build_ports
  CHANGE Last_Status Last_Status enum('UNKNOWN','SUCCESS','FAIL','BROKEN', 'LEFTOVERS') DEFAULT 'UNKNOWN';

DROP TABLE IF EXISTS hosts;
CREATE TABLE hosts (
  Host_Id int NOT NULL auto_increment,
  Host_Name varchar(255) NOT NULL,
  PRIMARY KEY (Host_Id),
  KEY Host_Name (Host_Name)
) TYPE=INNODB;

DROP TABLE IF EXISTS build_ports_queue;
CREATE TABLE build_ports_queue (
  Build_Ports_Queue_Id int NOT NULL auto_increment,
  Build_Id int NOT NULL,
  User_Id int NOT NULL,
  Port_Directory varchar(255) NOT NULL,
  Priority int NOT NULL default '10',
  Host_Id int NOT NULL,
  PRIMARY KEY (Build_Ports_Queue_Id),
  UNIQUE KEY BId_PDirectory_HId (Build_Id,Port_Directory,Host_Id),
  KEY Host_Id (Host_Id),
  KEY User_Id (User_Id),
  FOREIGN KEY (Build_Id)
    REFERENCES builds (Build_Id)
    ON UPDATE CASCADE,
  FOREIGN KEY (Host_Id)
    REFERENCES hosts (Host_Id)
    ON UPDATE CASCADE
) TYPE=INNODB;

SET FOREIGN_KEY_CHECKS=1;
