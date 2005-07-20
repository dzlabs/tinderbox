SET FOREIGN_KEY_CHECKS=0;

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

DROP TABLE IF EXISTS hosts;
CREATE TABLE hosts (
  Host_Id int NOT NULL auto_increment,
  Host_Name varchar(255) NOT NULL,
  PRIMARY KEY (Host_Id),
  KEY Host_Name (Host_Name)
) TYPE=INNODB;

DROP TABLE IF EXISTS config;
CREATE TABLE config (
  Config_Option_Name varchar(255) NOT NULL,
  Config_Option_Value text,
  Host_Id int NOT NULL DEFAULT -1,
  PRIMARY KEY (Config_Option_Name, Host_Id),
  INDEX (Host_Id),
  FOREIGN KEY (Host_Id)
    REFERENCES hosts(Host_Id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) TYPE=INNODB;

DROP TABLE IF EXISTS build_ports_queue;
CREATE TABLE build_ports_queue (
  Build_Ports_Queue_Id int(11) NOT NULL auto_increment,
  Enqueue_Date datetime,
  Completion_Date datetime,
  Build_Id int NOT NULL,
  User_Id int NOT NULL,
  Port_Directory varchar(255) NOT NULL,
  Priority int NOT NULL default '10',
  Host_Id int NOT NULL,
  Email_On_Completion tinyint(1) NOT NULL,
  Status enum('ENQUEUED','PROCESSING','SUCCESS','FAIL') NOT NULL default 'ENQUEUED',
  PRIMARY KEY (Build_Ports_Queue_Id),
  KEY Host_Id (Host_Id),
  KEY User_Id (User_Id),
  FOREIGN KEY (Build_Id)
    REFERENCES builds (Build_Id)
    ON UPDATE CASCADE,
  FOREIGN KEY (Host_Id)
    REFERENCES hosts (Host_Id)
    ON UPDATE CASCADE
) TYPE=INNODB;

ALTER TABLE users
  ADD User_Password varchar(41) NOT NULL,
  ADD User_Www_Enabled tinyint(1) NOT NULL default '0';

ALTER TABLE build_ports
  CHANGE Last_Status Last_Status enum('UNKNOWN','SUCCESS','FAIL','BROKEN', 'LEFTOVERS') DEFAULT 'UNKNOWN';

ALTER TABLE jails
  ADD Jail_Src_Mount text;

ALTER TABLE ports_trees
  ADD Ports_Tree_Ports_Mount text;

INSERT INTO hosts VALUES (-1, '__ALL__') ON DUPLICATE KEY UPDATE Host_Name=VALUES(Host_Name);

INSERT INTO config VALUES ('__DSVERSION__', '2.0.0', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);
INSERT INTO config VALUES ('CCACHE_ENABLED', '0', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);
INSERT INTO config VALUES ('CCACHE_DIR', '', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);
INSERT INTO config VALUES ('CCACHE_NOLINK', '1', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);
INSERT INTO config VALUES ('CCACHE_MAX_SIZE', '1G', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);
INSERT INTO config VALUES ('CCACHE_JAIL', '0', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);
INSERT INTO config VALUES ('CCACHE_LOGFILE', '', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);
INSERT INTO config VALUES ('DISTFILE_CACHE', '', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);
INSERT INTO config VALUES ('TINDERD_SLEEPTIME', '120', -1) ON DUPLICATE KEY UPDATE Config_Option_Value=VALUES(Config_Option_Value);

SET FOREIGN_KEY_CHECKS=1;
