-- MySQL dump 10.13  Distrib 5.7.24, for osx10.14 (x86_64)
--
-- Host: localhost    Database: proj
-- ------------------------------------------------------
-- Server version	5.7.24

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `proj`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `proj` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `proj`;

--
-- Table structure for table `container`
--

DROP TABLE IF EXISTS `container`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `container` (
  `containerid` varchar(5) NOT NULL,
  `dispid` varchar(5) NOT NULL,
  `contents` varchar(16) DEFAULT NULL,
  `weight` decimal(7,2) NOT NULL,
  `insuredvalue` decimal(10,2) NOT NULL,
  PRIMARY KEY (`containerid`,`dispid`),
  KEY `dispid` (`dispid`),
  CONSTRAINT `container_ibfk_1` FOREIGN KEY (`dispid`) REFERENCES `dispatch` (`dispid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container`
--

LOCK TABLES `container` WRITE;
/*!40000 ALTER TABLE `container` DISABLE KEYS */;
INSERT INTO `container` VALUES ('CT1','DP1',NULL,0.00,0.00),('CT1','DP2','Furnature',500.00,50.00),('CT1','DP3','Cash',500.00,99999.00),('CT2','DP1',NULL,0.00,0.00),('CT2','DP2','Top Soil',4000.00,0.00);
/*!40000 ALTER TABLE `container` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer` (
  `custid` varchar(4) NOT NULL,
  `custfname` varchar(16) NOT NULL,
  `custlname` varchar(16) NOT NULL,
  `referrercustid` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`custid`),
  KEY `referrercustid` (`referrercustid`),
  CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`referrercustid`) REFERENCES `customer` (`custid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES ('C1','Frank','Wright',NULL),('C2','Ralph','Williams','C1'),('C3','Joe','Smith',NULL),('C4','Peter','Lee',NULL),('C5','Jacob','Rhoda',NULL),('C6','Johhny','Appleseed','C5');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispatch`
--

DROP TABLE IF EXISTS `dispatch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dispatch` (
  `dispid` varchar(5) NOT NULL,
  `dispdate` date NOT NULL,
  `orderdate` date NOT NULL,
  `price` decimal(5,2) NOT NULL,
  `routeid` varchar(3) DEFAULT NULL,
  `custid` varchar(4) NOT NULL,
  `truckid` varchar(3) NOT NULL,
  `driverid` varchar(3) DEFAULT NULL,
  `streetAddress` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`dispid`),
  KEY `routeid` (`routeid`),
  KEY `truckid` (`truckid`),
  KEY `custid` (`custid`),
  KEY `driverid` (`driverid`),
  CONSTRAINT `dispatch_ibfk_1` FOREIGN KEY (`routeid`) REFERENCES `route` (`routeid`),
  CONSTRAINT `dispatch_ibfk_3` FOREIGN KEY (`truckid`) REFERENCES `truck` (`truckid`),
  CONSTRAINT `dispatch_ibfk_4` FOREIGN KEY (`custid`) REFERENCES `customer` (`custid`),
  CONSTRAINT `dispatch_ibfk_5` FOREIGN KEY (`driverid`) REFERENCES `driver` (`driverid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispatch`
--

LOCK TABLES `dispatch` WRITE;
/*!40000 ALTER TABLE `dispatch` DISABLE KEYS */;
INSERT INTO `dispatch` VALUES ('DP1','2018-12-13','2018-10-09',200.00,'RT1','C1','T1','D2','430 N President Street','Wheaton','IL'),('DP2','2018-12-14','2018-10-08',800.00,'RT1','C2','T2','D1','430 N President Street','Wheaton','IL'),('DP3','2018-12-14','2018-10-07',500.00,'RT3','C3','T1','D2','501 College Avenue','Wheaton','IL'),('DP4','2018-12-14','2018-10-30',50.00,'RT1','C4','T1',NULL,'430 N President Street','Wheaton','IL'),('DP5','2018-12-20','2018-12-12',200.00,NULL,'C1','T1',NULL,'501 College Avenue','Wheaton','IL'),('DP6','2018-12-20','2018-12-12',500.00,NULL,'C3','T3',NULL,'418 N President Street','Wheaton','IL'),('DP7','2018-12-28','2018-12-12',100.00,NULL,'C5','T3','D3','430 N President Street','Wheaton','IL');
/*!40000 ALTER TABLE `dispatch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `driver`
--

DROP TABLE IF EXISTS `driver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `driver` (
  `driverid` varchar(3) NOT NULL,
  `driverlicenseno` char(12) NOT NULL,
  `driverfname` varchar(16) NOT NULL,
  `driverlname` varchar(16) NOT NULL,
  `callsign` char(5) NOT NULL,
  `dateofbirth` date NOT NULL,
  `radioid` varchar(3) NOT NULL,
  `drivingtruckid` varchar(3) DEFAULT NULL,
  PRIMARY KEY (`driverid`),
  UNIQUE KEY `driverlicenseno` (`driverlicenseno`),
  UNIQUE KEY `callsign` (`callsign`),
  KEY `drivingtruckid` (`drivingtruckid`),
  KEY `radioid` (`radioid`),
  CONSTRAINT `driver_ibfk_2` FOREIGN KEY (`drivingtruckid`) REFERENCES `truck` (`truckid`),
  CONSTRAINT `driver_ibfk_3` FOREIGN KEY (`radioid`) REFERENCES `radio` (`radioid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `driver`
--

LOCK TABLES `driver` WRITE;
/*!40000 ALTER TABLE `driver` DISABLE KEYS */;
INSERT INTO `driver` VALUES ('D1','5555-55-0001','Bob','Smith','W6EEN','1979-01-01','RD3','T2'),('D2','5555-55-0002','Frank','Brown','M4QQP','1965-02-15','R2','T1'),('D3','5555-55-0003','Brad','Leap','A113B','1988-02-29','R1','T3'),('D4','5555-55-0004','Dave','Shoop','1337B','1990-05-02','R4',NULL);
/*!40000 ALTER TABLE `driver` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fluent`
--

DROP TABLE IF EXISTS `fluent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fluent` (
  `id` varbinary(16) NOT NULL,
  `name` varchar(255) NOT NULL,
  `batch` bigint(20) NOT NULL,
  `createdAt` datetime(6) DEFAULT NULL,
  `updatedAt` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fluent`
--

LOCK TABLES `fluent` WRITE;
/*!40000 ALTER TABLE `fluent` DISABLE KEYS */;
INSERT INTO `fluent` VALUES (_binary 'I—MtOKS–\æ}\'y®\ë','CacheEntry<MySQL.MySQLDatabase>',1,'2018-12-08 16:57:14.904623','2018-12-08 16:57:14.904623');
/*!40000 ALTER TABLE `fluent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fluentcache`
--

DROP TABLE IF EXISTS `fluentcache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fluentcache` (
  `key` varchar(255) NOT NULL,
  `data` json NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fluentcache`
--

LOCK TABLES `fluentcache` WRITE;
/*!40000 ALTER TABLE `fluentcache` DISABLE KEYS */;
INSERT INTO `fluentcache` VALUES ('EmEX7iwJS7D3e5Dh95D5ZQ==','[123, 34, 100, 97, 116, 97, 34, 58, 123, 125, 125]'),('HWLRxbYL+ulsp1EpBpbacQ==','[123, 34, 100, 97, 116, 97, 34, 58, 123, 34, 95, 85, 115, 101, 114, 83, 101, 115, 115, 105, 111, 110, 34, 58, 34, 49, 34, 125, 125]'),('RDUXeNgM1xPpTqGI17qQWw==','[123, 34, 100, 97, 116, 97, 34, 58, 123, 125, 125]');
/*!40000 ALTER TABLE `fluentcache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `future_dispatch`
--

DROP TABLE IF EXISTS `future_dispatch`;
/*!50001 DROP VIEW IF EXISTS `future_dispatch`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `future_dispatch` AS SELECT 
 1 AS `dispid`,
 1 AS `dispdate`,
 1 AS `orderdate`,
 1 AS `price`,
 1 AS `routeid`,
 1 AS `custid`,
 1 AS `truckid`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `radio`
--

DROP TABLE IF EXISTS `radio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `radio` (
  `radioid` varchar(3) NOT NULL,
  PRIMARY KEY (`radioid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `radio`
--

LOCK TABLES `radio` WRITE;
/*!40000 ALTER TABLE `radio` DISABLE KEYS */;
INSERT INTO `radio` VALUES ('R1'),('R2'),('R4'),('RD3');
/*!40000 ALTER TABLE `radio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `region`
--

DROP TABLE IF EXISTS `region`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `region` (
  `regionid` varchar(3) NOT NULL,
  `regionname` varchar(12) NOT NULL,
  PRIMARY KEY (`regionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `region`
--

LOCK TABLES `region` WRITE;
/*!40000 ALTER TABLE `region` DISABLE KEYS */;
INSERT INTO `region` VALUES ('GE','Glen Ellyn'),('WCH','West Chicago'),('WTN','Wheaton');
/*!40000 ALTER TABLE `region` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `route`
--

DROP TABLE IF EXISTS `route`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `route` (
  `routeid` varchar(3) NOT NULL,
  `routename` varchar(12) NOT NULL,
  PRIMARY KEY (`routeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route`
--

LOCK TABLES `route` WRITE;
/*!40000 ALTER TABLE `route` DISABLE KEYS */;
INSERT INTO `route` VALUES ('RT1','A'),('RT2','B'),('RT3','C');
/*!40000 ALTER TABLE `route` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routepoint`
--

DROP TABLE IF EXISTS `routepoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `routepoint` (
  `routeid` varchar(3) NOT NULL,
  `stopid` char(6) NOT NULL,
  `order` int(11) NOT NULL,
  PRIMARY KEY (`routeid`,`stopid`),
  KEY `stopid` (`stopid`),
  CONSTRAINT `routepoint_ibfk_1` FOREIGN KEY (`routeid`) REFERENCES `route` (`routeid`),
  CONSTRAINT `routepoint_ibfk_2` FOREIGN KEY (`stopid`) REFERENCES `waypoint` (`stopid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routepoint`
--

LOCK TABLES `routepoint` WRITE;
/*!40000 ALTER TABLE `routepoint` DISABLE KEYS */;
INSERT INTO `routepoint` VALUES ('RT1','RP001',1),('RT1','RP002',2),('RT1','RP003',3),('RT1','RP004',4),('RT1','RP005',5),('RT1','RP006',6),('RT1','RP007',7),('RT2','RP001',1),('RT2','RP002',2),('RT2','RP003',3),('RT2','RP004',4),('RT2','RP005',5),('RT2','RP006',6),('RT2','RP007',7),('RT3','RP004',1),('RT3','RP005',2),('RT3','RP006',3),('RT3','RP007',4);
/*!40000 ALTER TABLE `routepoint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `truck`
--

DROP TABLE IF EXISTS `truck`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `truck` (
  `truckid` varchar(3) NOT NULL,
  `truckmodel` varchar(12) NOT NULL,
  `misinceoilchange` int(11) NOT NULL,
  `ownerdriverid` varchar(3) NOT NULL,
  PRIMARY KEY (`truckid`),
  KEY `ownerdriverid` (`ownerdriverid`),
  CONSTRAINT `truck_ibfk_1` FOREIGN KEY (`ownerdriverid`) REFERENCES `driver` (`driverid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `truck`
--

LOCK TABLES `truck` WRITE;
/*!40000 ALTER TABLE `truck` DISABLE KEYS */;
INSERT INTO `truck` VALUES ('T1','Tundra',0,'D1'),('T2','Sierra',1200,'D1'),('T3','F150',500,'D1'),('T4','RAM',0,'D4');
/*!40000 ALTER TABLE `truck` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `truckregion`
--

DROP TABLE IF EXISTS `truckregion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `truckregion` (
  `regionid` varchar(3) NOT NULL,
  `truckid` varchar(3) NOT NULL,
  PRIMARY KEY (`regionid`,`truckid`),
  KEY `truckid` (`truckid`),
  CONSTRAINT `truckregion_ibfk_2` FOREIGN KEY (`truckid`) REFERENCES `truck` (`truckid`),
  CONSTRAINT `truckregion_ibfk_3` FOREIGN KEY (`regionid`) REFERENCES `region` (`regionid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `truckregion`
--

LOCK TABLES `truckregion` WRITE;
/*!40000 ALTER TABLE `truckregion` DISABLE KEYS */;
INSERT INTO `truckregion` VALUES ('GE','T1'),('WCH','T1'),('WTN','T1'),('GE','T2'),('WCH','T2'),('WTN','T2'),('GE','T3'),('WCH','T3'),('WTN','T3'),('GE','T4'),('WCH','T4'),('WTN','T4');
/*!40000 ALTER TABLE `truckregion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `userID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `passwordHash` varchar(60) NOT NULL,
  `driverID` varchar(3) DEFAULT NULL,
  `type` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`userID`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','','$2b$10$awR5Ei1u52fbBlmLcH32jO3ij2mTQTOCYFf/5j4dx/jgAoeId9vLm',NULL,1),(2,'test','','$2b$10$awR5Ei1u52fbBlmLcH32jO3ij2mTQTOCYFf/5j4dx/jgAoeId9vLm','D1',0);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waypoint`
--

DROP TABLE IF EXISTS `waypoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `waypoint` (
  `stopid` char(6) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  PRIMARY KEY (`stopid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waypoint`
--

LOCK TABLES `waypoint` WRITE;
/*!40000 ALTER TABLE `waypoint` DISABLE KEYS */;
INSERT INTO `waypoint` VALUES ('RP001',41.87010040,-88.09228790),('RP002',41.87000390,-88.09697740),('RP003',41.87023280,-88.09708340),('RP004',41.87042090,-88.09759490),('RP005',41.87089630,-88.09759760),('RP006',41.87086800,-88.09923360),('RP007',41.87235180,-88.09925070);
/*!40000 ALTER TABLE `waypoint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Current Database: `proj`
--

USE `proj`;

--
-- Final view structure for view `future_dispatch`
--

/*!50001 DROP VIEW IF EXISTS `future_dispatch`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `future_dispatch` AS select 1 AS `dispid`,1 AS `dispdate`,1 AS `orderdate`,1 AS `price`,1 AS `routeid`,1 AS `custid`,1 AS `truckid` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-12-12  0:05:03
