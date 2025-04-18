CREATE DATABASE  IF NOT EXISTS `port` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `port`;
-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: port
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `berth_assignments`
--

DROP TABLE IF EXISTS `berth_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `berth_assignments` (
  `assignment_id` int NOT NULL AUTO_INCREMENT,
  `berth_id` int NOT NULL,
  `ship_id` int NOT NULL,
  `schedule_id` int NOT NULL,
  `arrival_time` datetime NOT NULL,
  `departure_time` datetime NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`assignment_id`),
  KEY `fk_berth` (`berth_id`),
  KEY `fk_ship` (`ship_id`),
  KEY `fk_schedule` (`schedule_id`),
  CONSTRAINT `fk_berth` FOREIGN KEY (`berth_id`) REFERENCES `berths` (`berth_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`schedule_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ship` FOREIGN KEY (`ship_id`) REFERENCES `ships` (`ship_id`) ON DELETE CASCADE,
  CONSTRAINT `valid_assignment_times` CHECK ((`arrival_time` < `departure_time`))
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `berth_assignments`
--

LOCK TABLES `berth_assignments` WRITE;
/*!40000 ALTER TABLE `berth_assignments` DISABLE KEYS */;
INSERT INTO `berth_assignments` VALUES (39,77,53,97,'2025-03-18 16:00:00','2025-03-19 08:30:00','active','2025-04-17 22:48:40','2025-04-17 22:48:40'),(40,81,53,97,'2025-03-29 14:30:00','2025-03-30 10:00:00','active','2025-04-17 22:48:40','2025-04-17 22:48:40'),(41,77,57,102,'2025-04-06 16:00:00','2025-04-07 07:30:00','active','2025-04-17 22:48:40','2025-04-17 22:48:40'),(42,85,57,102,'2025-04-29 15:30:00','2025-04-30 09:00:00','active','2025-04-17 22:48:40','2025-04-17 22:48:40'),(43,83,56,103,'2025-04-08 16:00:00','2025-04-09 08:30:00','active','2025-04-17 22:48:40','2025-04-17 22:48:40'),(49,97,52,121,'2025-04-19 06:00:00','2025-04-19 13:00:00','active','2025-04-18 04:14:30','2025-04-18 04:14:30'),(50,98,52,121,'2025-04-23 11:00:00','2025-04-24 00:00:00','active','2025-04-18 04:14:30','2025-04-18 04:14:30'),(51,99,67,122,'2025-04-19 06:00:00','2025-04-19 13:00:00','active','2025-04-18 04:29:13','2025-04-18 04:29:13'),(52,100,67,122,'2025-04-23 11:00:00','2025-04-24 00:00:00','active','2025-04-18 04:29:13','2025-04-18 04:29:13'),(53,99,67,123,'2025-04-21 06:00:00','2025-04-21 13:00:00','active','2025-04-18 04:32:29','2025-04-18 04:32:29'),(54,100,67,123,'2025-04-25 11:00:00','2025-04-26 00:00:00','active','2025-04-18 04:32:29','2025-04-18 04:32:29');
/*!40000 ALTER TABLE `berth_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `berths`
--

DROP TABLE IF EXISTS `berths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `berths` (
  `berth_id` int NOT NULL AUTO_INCREMENT,
  `berth_number` varchar(20) NOT NULL,
  `port_id` int NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'container',
  `length` decimal(10,2) NOT NULL,
  `width` decimal(10,2) NOT NULL,
  `depth` decimal(10,2) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`berth_id`),
  KEY `port_id` (`port_id`),
  CONSTRAINT `berths_ibfk_1` FOREIGN KEY (`port_id`) REFERENCES `ports` (`port_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `berths`
--

LOCK TABLES `berths` WRITE;
/*!40000 ALTER TABLE `berths` DISABLE KEYS */;
INSERT INTO `berths` VALUES (77,'VAN-B001',87,'container',340.00,45.00,15.00,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(78,'VAN-B002',87,'bulk',300.00,42.00,14.50,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(81,'TOK-B001',89,'container',360.00,48.00,16.00,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(82,'TOK-B002',89,'tanker',330.00,52.00,17.00,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(83,'RIO-B001',90,'container',320.00,44.00,15.20,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(84,'RIO-B002',90,'bulk',270.00,38.00,13.50,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(85,'MAR-B001',91,'container',330.00,45.00,15.00,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(87,'MEL-B001',93,'container',340.00,46.00,15.50,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(88,'BUS-B001',94,'container',350.00,47.00,16.00,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(90,'SHA-B001',96,'container',380.00,50.00,16.50,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(91,'SIN-B001',97,'container',370.00,49.00,16.20,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(92,'ROT-B001',98,'container',360.00,48.00,16.00,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(93,'DUB-B001',99,'container',350.00,47.00,15.80,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(94,'NYC-B001',100,'container',340.00,46.00,15.50,'active','2025-04-17 22:48:38','2025-04-17 22:48:38'),(97,'B05',92,'multipurpose',100.00,100.00,100.00,'reserved','2025-04-18 04:13:39','2025-04-18 04:14:30'),(98,'B05',95,'multipurpose',100.00,100.00,100.00,'reserved','2025-04-18 04:13:56','2025-04-18 04:14:30'),(99,'asd',92,'multipurpose',10000.00,1000.00,1000.00,'active','2025-04-18 04:24:08','2025-04-18 04:24:08'),(100,'B06',95,'multipurpose',100.00,100.00,100.00,'active','2025-04-18 04:28:47','2025-04-18 04:28:47');
/*!40000 ALTER TABLE `berths` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cargo`
--

DROP TABLE IF EXISTS `cargo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cargo` (
  `cargo_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `description` varchar(255) NOT NULL,
  `cargo_type` varchar(50) NOT NULL,
  `weight` decimal(10,2) NOT NULL,
  `dimensions` varchar(100) DEFAULT NULL,
  `special_instructions` text,
  `status` varchar(50) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cargo_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `cargo_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cargo`
--

LOCK TABLES `cargo` WRITE;
/*!40000 ALTER TABLE `cargo` DISABLE KEYS */;
INSERT INTO `cargo` VALUES (103,42,'Computer Equipment','container',5000.00,'20x8x8.5','Handle with care. Keep dry.','booked','2025-04-17 22:48:38','2025-04-17 22:48:40'),(104,42,'Automotive Parts','container',12000.50,'40x8x8.5','Heavy equipment inside.','in_transit','2025-04-17 22:48:38','2025-04-17 22:48:41'),(105,42,'Frozen Foods','container',8000.75,'40x8x8.5','Maintain temperature between -18Â°C to -20Â°C','booked','2025-04-17 22:48:38','2025-04-17 22:50:12'),(106,42,'Crude Oil','liquid',25000.00,'40Ã—8Ã—8.5','Flammable liquid.','pending','2025-04-17 22:48:38','2025-04-17 22:48:41'),(107,42,'Luxury Yacht','vehicle',18000.00,'60Ã—15Ã—20','High-value item. Special insurance.','booked','2025-04-17 22:48:38','2025-04-17 22:48:41'),(108,43,'Designer Furniture','container',3500.00,'20Ã—8Ã—8.5','Fragile items inside.','booked','2025-04-17 22:48:38','2025-04-17 23:08:40'),(109,43,'Medical Supplies','container',2800.00,'20Ã—8Ã—8.5','Priority shipment. Temperature controlled.','booked','2025-04-17 22:48:38','2025-04-17 22:49:29'),(110,43,'Farm Equipment','bulk',15000.00,'30Ã—10Ã—5','Heavy machinery.','pending','2025-04-17 22:48:38','2025-04-17 22:48:41'),(111,43,'Luxury Cars','vehicle',5200.00,'40Ã—8Ã—8.5','Premium vehicles, special handling required.','booked','2025-04-17 22:48:38','2025-04-17 22:48:40'),(112,43,'Pharmaceuticals','container',1800.00,'20Ã—8Ã—8.5','Temperature sensitive. Keep between 2-8Â°C.','in_transit','2025-04-17 22:48:38','2025-04-17 22:48:41'),(113,44,'Solar Panels','container',7500.00,'40Ã—8Ã—8.5','Fragile glass components. Secure stacking.','booked','2025-04-17 22:48:38','2025-04-17 22:48:40'),(114,44,'Industrial Machinery','bulk',22000.00,'40Ã—10Ã—9','Heavy items. Use appropriate lifting equipment.','booked','2025-04-17 22:48:38','2025-04-17 23:08:10'),(115,44,'Packaged Food Products','container',4200.00,'20Ã—8Ã—8.5','Keep away from moisture and heat.','booked','2025-04-17 22:48:38','2025-04-17 22:50:06'),(116,44,'Textiles and Fabrics','container',3100.00,'20Ã—8Ã—8.5','Protect from water damage.','in_transit','2025-04-17 22:48:38','2025-04-17 22:48:41'),(117,44,'Construction Materials','bulk',17500.00,'40Ã—8Ã—8.5','Various building supplies, non-hazardous.','pending','2025-04-17 22:48:38','2025-04-17 22:48:41'),(118,45,'Organic Produce','container',4000.00,'20Ã—8Ã—8.5','Perishable goods. Temperature monitoring required.','booked','2025-04-17 22:48:38','2025-04-17 22:50:07'),(119,45,'Wind Turbine Components','bulk',31000.00,'60Ã—15Ã—10','Oversized cargo. Special handling protocol.','pending','2025-04-17 22:48:38','2025-04-17 22:48:41'),(120,45,'Mineral Ores','bulk',28000.00,'40Ã—8Ã—8.5','Heavy bulk material.','in_transit','2025-04-17 22:48:38','2025-04-17 22:48:41'),(121,45,'Artwork and Sculptures','container',1200.00,'20Ã—8Ã—8.5','Extremely fragile. Expert handling only.','booked','2025-04-17 22:48:38','2025-04-17 22:48:40'),(122,45,'Chemicals (Non-hazardous)','liquid',18000.00,'40Ã—8Ã—8.5','Keep away from food products.','in_transit','2025-04-17 22:48:38','2025-04-17 22:48:41'),(123,46,'Electronic Components','container',2500.00,'20Ã—8Ã—8.5','Sensitive electronics. Avoid electromagnetic fields.','booked','2025-04-17 22:48:38','2025-04-17 22:50:08'),(124,46,'Automotive Vehicles','vehicle',12000.00,'40Ã—10Ã—8','5 standard sedans secured on rack.','in_transit','2025-04-17 22:48:38','2025-04-17 22:48:41'),(125,46,'Lumber and Timber','bulk',19000.00,'40Ã—8Ã—8.5','Treated wood products. Keep dry.','pending','2025-04-17 22:48:38','2025-04-17 22:48:41'),(126,46,'Processed Metals','container',26000.00,'40Ã—8Ã—8.5','Heavy steel components.','in_transit','2025-04-17 22:48:38','2025-04-17 22:48:41'),(127,46,'Wine Shipment','container',8500.00,'20Ã—8Ã—8.5','Fragile glass bottles. Temperature controlled.','booked','2025-04-17 22:48:38','2025-04-17 22:48:40'),(131,53,'Electronics','container',3433.00,'','','pending','2025-04-18 02:50:51','2025-04-18 02:50:51'),(132,2,'Electronics','bulk',200.00,'2.5*3.4*7','','booked','2025-04-18 03:04:10','2025-04-18 03:12:44');
/*!40000 ALTER TABLE `cargo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cargo_bookings`
--

DROP TABLE IF EXISTS `cargo_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cargo_bookings` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `cargo_id` int NOT NULL,
  `schedule_id` int NOT NULL,
  `user_id` int NOT NULL,
  `booking_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `booking_status` enum('pending','confirmed','cancelled','completed') NOT NULL DEFAULT 'pending',
  `payment_status` enum('unpaid','paid','refunded') NOT NULL DEFAULT 'unpaid',
  `price` decimal(12,2) NOT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`booking_id`),
  KEY `idx_cargo_bookings_user` (`user_id`),
  KEY `idx_cargo_bookings_cargo` (`cargo_id`),
  KEY `idx_cargo_bookings_schedule` (`schedule_id`),
  KEY `idx_cargo_bookings_status` (`booking_status`),
  CONSTRAINT `cargo_bookings_ibfk_1` FOREIGN KEY (`cargo_id`) REFERENCES `cargo` (`cargo_id`) ON DELETE CASCADE,
  CONSTRAINT `cargo_bookings_ibfk_2` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`schedule_id`) ON DELETE CASCADE,
  CONSTRAINT `cargo_bookings_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cargo_bookings`
--

LOCK TABLES `cargo_bookings` WRITE;
/*!40000 ALTER TABLE `cargo_bookings` DISABLE KEYS */;
INSERT INTO `cargo_bookings` VALUES (79,105,96,42,'2025-03-02 05:00:00','completed','paid',20000.00,'Shipment delivered successfully','2025-04-17 22:48:40','2025-04-17 22:48:40'),(80,109,97,43,'2025-03-04 05:00:00','completed','paid',8960.00,'Shipment arrived on time','2025-04-17 22:48:40','2025-04-17 22:48:40'),(81,115,98,44,'2025-03-07 05:00:00','completed','paid',11550.00,'Shipment completed as scheduled','2025-04-17 22:48:40','2025-04-17 22:48:40'),(82,118,99,45,'2025-03-05 05:00:00','completed','paid',11200.00,'Delivery confirmed by receiver','2025-04-17 22:48:40','2025-04-17 22:48:40'),(83,123,100,46,'2025-02-27 05:00:00','completed','paid',7875.00,'Shipment arrived in excellent condition','2025-04-17 22:48:40','2025-04-17 22:48:40'),(84,108,101,43,'2025-02-25 05:00:00','cancelled','refunded',9975.00,'Cancelled due to schedule changes','2025-04-17 22:48:40','2025-04-17 22:48:40'),(85,104,102,42,'2025-04-02 04:00:00','confirmed','paid',37200.00,'Currently in transit','2025-04-17 22:48:40','2025-04-17 22:48:40'),(86,112,103,43,'2025-04-05 04:00:00','confirmed','paid',4500.00,'Currently in transit','2025-04-17 22:48:40','2025-04-17 22:48:40'),(87,116,104,44,'2025-04-09 04:00:00','confirmed','paid',6820.00,'Currently in transit','2025-04-17 22:48:40','2025-04-17 22:48:40'),(88,122,105,45,'2025-04-07 04:00:00','confirmed','paid',52200.00,'Currently in transit','2025-04-17 22:48:40','2025-04-17 22:48:40'),(89,126,106,46,'2025-04-10 04:00:00','confirmed','paid',67600.00,'Currently in transit','2025-04-17 22:48:40','2025-04-17 22:48:40'),(90,103,107,42,'2025-04-14 04:00:00','confirmed','paid',12500.00,'Scheduled for upcoming voyage','2025-04-17 22:48:40','2025-04-17 22:48:40'),(91,111,108,43,'2025-04-15 04:00:00','confirmed','paid',14820.00,'Scheduled for upcoming voyage','2025-04-17 22:48:40','2025-04-17 22:48:40'),(92,113,109,44,'2025-04-13 04:00:00','confirmed','paid',26250.00,'Scheduled for upcoming voyage','2025-04-17 22:48:40','2025-04-17 22:48:40'),(93,121,110,45,'2025-04-12 04:00:00','confirmed','paid',2520.00,'Premium handling for artwork','2025-04-17 22:48:40','2025-04-17 22:48:40'),(94,127,111,46,'2025-04-14 04:00:00','confirmed','paid',25075.00,'Temperature-controlled shipping','2025-04-17 22:48:40','2025-04-17 22:48:40'),(95,106,112,42,'2025-04-17 04:00:00','pending','unpaid',80000.00,'Awaiting payment confirmation','2025-04-17 22:48:40','2025-04-17 22:48:40'),(96,110,113,43,'2025-04-16 04:00:00','pending','unpaid',41250.00,'Awaiting documentation','2025-04-17 22:48:40','2025-04-17 22:48:40'),(97,117,114,44,'2025-04-17 04:00:00','pending','unpaid',49000.00,'Quote provided, awaiting confirmation','2025-04-17 22:48:40','2025-04-17 22:48:40'),(98,119,115,45,'2025-04-16 04:00:00','pending','unpaid',97650.00,'Special handling requirements under review','2025-04-17 22:48:40','2025-04-17 22:48:40'),(99,125,116,46,'2025-04-17 04:00:00','pending','unpaid',62700.00,'Awaiting insurance documentation','2025-04-17 22:48:40','2025-04-17 22:48:40'),(100,103,117,42,'2025-02-01 05:00:00','completed','paid',12500.00,'Historical shipment 1','2025-04-17 22:49:29','2025-04-17 22:49:29'),(101,109,118,43,'2025-02-03 05:00:00','completed','paid',8960.00,'Historical shipment 2','2025-04-17 22:49:29','2025-04-17 22:49:29'),(102,115,119,44,'2025-01-02 05:00:00','completed','paid',11550.00,'Historical shipment 3','2025-04-17 22:50:06','2025-04-17 22:50:06'),(103,118,120,45,'2024-12-31 05:00:00','completed','paid',11200.00,'Historical shipment 4','2025-04-17 22:50:07','2025-04-17 22:50:07'),(104,132,107,2,'2025-04-18 03:10:48','cancelled','refunded',0.00,'','2025-04-18 03:10:48','2025-04-18 03:11:00'),(105,132,112,2,'2025-04-18 03:12:44','confirmed','paid',640.00,'','2025-04-18 03:12:44','2025-04-18 03:12:44');
/*!40000 ALTER TABLE `cargo_bookings` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_booking_insert` AFTER INSERT ON `cargo_bookings` FOR EACH ROW BEGIN
    -- Update cargo status to 'booked'
    UPDATE cargo 
    SET status = 'booked'
    WHERE cargo_id = NEW.cargo_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_booking_update` AFTER UPDATE ON `cargo_bookings` FOR EACH ROW BEGIN
    IF NEW.booking_status = 'cancelled' AND OLD.booking_status != 'cancelled' THEN
        -- Update cargo status back to 'pending'
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = NEW.cargo_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `connected_booking_segments`
--

DROP TABLE IF EXISTS `connected_booking_segments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `connected_booking_segments` (
  `segment_id` int NOT NULL AUTO_INCREMENT,
  `connected_booking_id` int NOT NULL,
  `schedule_id` int NOT NULL,
  `segment_order` int NOT NULL,
  `segment_price` decimal(12,2) NOT NULL,
  PRIMARY KEY (`segment_id`),
  KEY `idx_segment_booking` (`connected_booking_id`),
  KEY `idx_segment_schedule` (`schedule_id`),
  KEY `idx_segment_order` (`segment_order`),
  CONSTRAINT `connected_booking_segments_ibfk_1` FOREIGN KEY (`connected_booking_id`) REFERENCES `connected_bookings` (`connected_booking_id`),
  CONSTRAINT `connected_booking_segments_ibfk_2` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`schedule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connected_booking_segments`
--

LOCK TABLES `connected_booking_segments` WRITE;
/*!40000 ALTER TABLE `connected_booking_segments` DISABLE KEYS */;
INSERT INTO `connected_booking_segments` VALUES (44,33,96,1,30000.00),(45,33,98,2,20400.00),(46,34,97,1,70400.00),(47,35,104,1,61600.00),(48,36,106,1,31200.00),(49,37,107,1,8750.00),(50,37,111,2,29750.00),(51,38,108,1,51300.00),(52,39,114,1,61600.00),(53,40,115,1,97650.00),(54,41,98,1,52250.00),(55,42,117,1,6250.00),(56,43,119,1,22000.00);
/*!40000 ALTER TABLE `connected_booking_segments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connected_bookings`
--

DROP TABLE IF EXISTS `connected_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `connected_bookings` (
  `connected_booking_id` int NOT NULL AUTO_INCREMENT,
  `cargo_id` int NOT NULL,
  `user_id` int NOT NULL,
  `origin_port_id` int NOT NULL,
  `destination_port_id` int NOT NULL,
  `booking_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `booking_status` enum('pending','confirmed','cancelled','completed') NOT NULL DEFAULT 'pending',
  `payment_status` enum('unpaid','paid','refunded') NOT NULL DEFAULT 'unpaid',
  `total_price` decimal(12,2) NOT NULL,
  `notes` text,
  PRIMARY KEY (`connected_booking_id`),
  KEY `origin_port_id` (`origin_port_id`),
  KEY `destination_port_id` (`destination_port_id`),
  KEY `idx_connected_bookings_user` (`user_id`),
  KEY `idx_connected_bookings_cargo` (`cargo_id`),
  KEY `idx_connected_bookings_status` (`booking_status`),
  CONSTRAINT `connected_bookings_ibfk_1` FOREIGN KEY (`cargo_id`) REFERENCES `cargo` (`cargo_id`),
  CONSTRAINT `connected_bookings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `connected_bookings_ibfk_3` FOREIGN KEY (`origin_port_id`) REFERENCES `ports` (`port_id`),
  CONSTRAINT `connected_bookings_ibfk_4` FOREIGN KEY (`destination_port_id`) REFERENCES `ports` (`port_id`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connected_bookings`
--

LOCK TABLES `connected_bookings` WRITE;
/*!40000 ALTER TABLE `connected_bookings` DISABLE KEYS */;
INSERT INTO `connected_bookings` VALUES (33,107,42,86,92,'2025-02-25 05:00:00','completed','paid',50400.00,'Multi-segment shipment completed successfully'),(34,114,44,87,89,'2025-03-02 05:00:00','completed','paid',70400.00,'Heavy machinery successfully delivered'),(35,120,45,98,95,'2025-04-07 04:00:00','confirmed','paid',61600.00,'Multi-segment shipment currently in transit'),(36,124,46,97,94,'2025-04-09 04:00:00','confirmed','paid',31200.00,'Vehicles in transit to final destination'),(37,108,43,86,99,'2025-04-13 04:00:00','confirmed','paid',38500.00,'Multi-segment shipment scheduled'),(38,107,42,88,92,'2025-04-14 04:00:00','confirmed','paid',51300.00,'Special arrangements for luxury yacht transport'),(39,114,44,96,97,'2025-04-17 04:00:00','pending','unpaid',61600.00,'Multi-segment shipment pending confirmation'),(40,119,45,86,99,'2025-04-16 04:00:00','pending','unpaid',97650.00,'Specialized transport for oversized wind turbine components'),(41,125,46,89,90,'2025-03-05 05:00:00','cancelled','refunded',52250.00,'Cancelled due to client request'),(42,123,46,86,88,'2025-01-28 05:00:00','completed','paid',6250.00,'Historical connected shipment 1'),(43,105,42,89,90,'2025-01-02 05:00:00','completed','paid',22000.00,'Historical connected shipment 2');
/*!40000 ALTER TABLE `connected_bookings` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_connected_booking_insert` AFTER INSERT ON `connected_bookings` FOR EACH ROW BEGIN
    -- Update cargo status to 'booked'
    UPDATE cargo 
    SET status = 'booked'
    WHERE cargo_id = NEW.cargo_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_connected_booking_update` AFTER UPDATE ON `connected_bookings` FOR EACH ROW BEGIN
    IF NEW.booking_status = 'cancelled' AND OLD.booking_status != 'cancelled' THEN
        -- Update cargo status back to 'pending'
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = NEW.cargo_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2025-04-17 19:20:22.977166'),(2,'auth','0001_initial','2025-04-17 19:20:23.323739'),(3,'admin','0001_initial','2025-04-17 19:20:23.403089'),(4,'admin','0002_logentry_remove_auto_add','2025-04-17 19:20:23.407700'),(5,'admin','0003_logentry_add_action_flag_choices','2025-04-17 19:20:23.411792'),(6,'contenttypes','0002_remove_content_type_name','2025-04-17 19:20:23.495358'),(7,'auth','0002_alter_permission_name_max_length','2025-04-17 19:20:23.532007'),(8,'auth','0003_alter_user_email_max_length','2025-04-17 19:20:23.545231'),(9,'auth','0004_alter_user_username_opts','2025-04-17 19:20:23.549277'),(10,'auth','0005_alter_user_last_login_null','2025-04-17 19:20:23.584556'),(11,'auth','0006_require_contenttypes_0002','2025-04-17 19:20:23.585887'),(12,'auth','0007_alter_validators_add_error_messages','2025-04-17 19:20:23.589909'),(13,'auth','0008_alter_user_username_max_length','2025-04-17 19:20:23.631433'),(14,'auth','0009_alter_user_last_name_max_length','2025-04-17 19:20:23.674045'),(15,'auth','0010_alter_group_name_max_length','2025-04-17 19:20:23.686450'),(16,'auth','0011_update_proxy_permissions','2025-04-17 19:20:23.691555'),(17,'auth','0012_alter_user_first_name_max_length','2025-04-17 19:20:23.728996'),(18,'sessions','0001_initial','2025-04-17 19:20:23.762672');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('21yz6ptrfgxnkzeuzytithc6q7c7ahgv','.eJyrViotTi2Kz0xRsjLSUUosS8zMSUzKSY0vys9JLVayilZKTMnNzFPSUUouLS7Jz00tAjKLMzIL8svzgOxYICc1JzW5JDUFrEPJCqq-FgBZbh7q:1u5dG1:Pgxjc9mkLKEmW115ot13AZVtzeuJej9uS_AX1YEMwj4','2025-05-02 04:23:17.641267'),('6r43k6mmzcxfrgdo0hym3alxltdn2voo','.eJyrViotTi2Kz0xRsjLSUUosS8zMSUzKSY0vys9JLVayilZKTMnNzFPSUUouLS7Jz00tAjKLMzIL8svzgOxYICc1JzW5JDUFrEPJCkmyFgDbfSDA:1u5dES:epAntcbg-i8yUyZfrI9jOodZ6Ki-BQopFewYtwFuHjw','2025-05-02 04:21:40.148906');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ports`
--

DROP TABLE IF EXISTS `ports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ports` (
  `port_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `country` varchar(100) NOT NULL,
  `location` point NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`port_id`),
  SPATIAL KEY `location` (`location`)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ports`
--

LOCK TABLES `ports` WRITE;
/*!40000 ALTER TABLE `ports` DISABLE KEYS */;
INSERT INTO `ports` VALUES (86,'Port of Hamburg','Germany',_binary '\0\0\0\0\0\0\0?\Æü#@­i\ÞqŠ\ÆJ@','active','2025-04-17 22:48:37'),(87,'Port of Vancouver','Canada',_binary '\0\0\0\0\0\0\0Zd;\ßO\Å^À#J{ƒ/¤H@','active','2025-04-17 22:48:37'),(88,'Port of Mumbai','India',_binary '\0\0\0\0\0\0\0À\ìž<,8R@UÁ¨¤Nð2@','active','2025-04-17 22:48:37'),(89,'Port of Tokyo','Japan',_binary '\0\0\0\0\0\0\0•\Ô	h\"va@\ÇK7‰A\ØA@','active','2025-04-17 22:48:37'),(90,'Port of Rio de Janeiro','Brazil',_binary '\0\0\0\0\0\0\0<½R–!–EÀGx$\è6À','active','2025-04-17 22:48:37'),(91,'Port of Marseille','France',_binary '\0\0\0\0\0\0\0B>\èÙ¬z@Ë¡E¶ó¥E@','active','2025-04-17 22:48:37'),(92,'Port of Alexandria','Egypt',_binary '\0\0\0\0\0\0\0\Ð\ÕV\ì/\ë=@ú\í\ëÀ93?@','active','2025-04-17 22:48:37'),(93,'Port of Melbourne','Australia',_binary '\0\0\0\0\0\0\0\âX·\Ñb@Gx$\èBÀ','active','2025-04-17 22:48:37'),(94,'Port of Busan','South Korea',_binary '\0\0\0\0\0\0\0|ò°Pk\"`@I.ÿ!ý–A@','active','2025-04-17 22:48:37'),(95,'Port of Barcelona','Spain',_binary '\0\0\0\0\0\0\0E\ØðôJY@E\ØðôJ±D@','active','2025-04-17 22:48:37'),(96,'Port of Shanghai','China',_binary '\0\0\0\0\0\0\0\Ì\î\É\ÃBy^@§\èH.\ß>@','active','2025-04-17 22:48:37'),(97,'Port of Singapore','Singapore',_binary '\0\0\0\0\0\0\0±PkšwôY@\Ì]K\È=ô?','active','2025-04-17 22:48:37'),(98,'Port of Rotterdam','Netherlands',_binary '\0\0\0\0\0\0\0\É\å?¤Ÿ@6<½RöI@','active','2025-04-17 22:48:37'),(99,'Port of Dubai','UAE',_binary '\0\0\0\0\0\0\0\ß\à“©¢K@†8\Ö\Åm49@','active','2025-04-17 22:48:37'),(100,'Port of New York','USA',_binary '\0\0\0\0\0\0\0ªñ\ÒMb€RÀ^K\È=[D@','active','2025-04-17 22:48:37'),(101,'Port of Reykjavik','Iceland',_binary '\0\0\0\0\0\0\0¨5\Í;Nñ5Àþe÷\äa	P@','inactive','2025-04-17 22:48:37'),(102,'Port of Havana','Cuba',_binary '\0\0\0\0\0\0\0¬­\Ø_v—TÀ[Ó¼\ã7@','inactive','2025-04-17 22:48:37'),(103,'Port of Murmansk','Russia',_binary '\0\0\0\0\0\0\0&S£’Š@@\ÓMbX=Q@','inactive','2025-04-17 22:48:37'),(104,'Port of Ushuaia','Argentina',_binary '\0\0\0\0\0\0\0\Ïf\Õ\çjQÀ\ÊTÁ¨¤fKÀ','inactive','2025-04-17 22:48:37'),(105,'Port of Churchill','Canada',_binary '\0\0\0\0\0\0\0jMóŠWÀŠc\îZbM@','inactive','2025-04-17 22:48:37');
/*!40000 ALTER TABLE `ports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'admin'),(4,'customer'),(5,'shipowner');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `routes` (
  `route_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `origin_port_id` int NOT NULL,
  `destination_port_id` int NOT NULL,
  `distance` decimal(10,2) NOT NULL COMMENT 'Distance in nautical miles',
  `duration` decimal(6,2) NOT NULL COMMENT 'Duration in days',
  `status` enum('active','inactive','seasonal','deleted') NOT NULL DEFAULT 'active',
  `owner_id` int NOT NULL,
  `ship_id` int DEFAULT NULL,
  `cost_per_kg` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`route_id`),
  KEY `origin_port_id` (`origin_port_id`),
  KEY `destination_port_id` (`destination_port_id`),
  KEY `owner_id` (`owner_id`),
  KEY `ship_id` (`ship_id`),
  CONSTRAINT `routes_ibfk_1` FOREIGN KEY (`origin_port_id`) REFERENCES `ports` (`port_id`),
  CONSTRAINT `routes_ibfk_2` FOREIGN KEY (`destination_port_id`) REFERENCES `ports` (`port_id`),
  CONSTRAINT `routes_ibfk_3` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `routes_ibfk_4` FOREIGN KEY (`ship_id`) REFERENCES `ships` (`ship_id`),
  CONSTRAINT `different_ports` CHECK ((`origin_port_id` <> `destination_port_id`)),
  CONSTRAINT `non_negative_cost` CHECK ((`cost_per_kg` >= 0)),
  CONSTRAINT `positive_distance` CHECK ((`distance` > 0)),
  CONSTRAINT `positive_duration` CHECK ((`duration` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES (52,'Hamburg-Mumbai Express',86,88,3533.71,7.36,'active',47,52,0.00,'2025-04-17 22:48:39','2025-04-18 02:59:29'),(53,'Vancouver-Tokyo Direct',87,89,7500.00,10.00,'active',47,53,3.20,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(54,'Mumbai-Alexandria Route',88,92,4800.00,8.00,'active',47,54,2.85,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(55,'Tokyo-Rio Connection',89,90,18200.00,25.00,'active',48,55,2.75,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(56,'Rio-Hamburg Trade Route',90,86,10500.00,16.00,'active',48,56,2.60,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(57,'Vancouver-Marseille Trade Route',87,91,15800.00,22.00,'active',48,57,3.10,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(58,'Shanghai-Singapore Express',96,97,4100.00,6.00,'active',49,58,2.80,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(59,'Rotterdam-Barcelona Link',98,95,2200.00,4.00,'active',49,59,2.20,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(60,'Alexandria-Melbourne Route',92,93,14200.00,20.00,'active',49,60,3.50,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(61,'Hamburg-Dubai Connection',86,99,11900.00,18.00,'active',50,61,3.15,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(62,'Dubai-Tokyo Express',99,89,8300.00,12.00,'active',50,62,2.90,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(63,'Marseille-Alexandria Link',91,92,2800.00,5.00,'active',50,63,2.10,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(64,'Singapore-Busan Express',97,94,4800.00,7.00,'active',51,64,2.60,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(65,'New York-Barcelona Route',100,95,6800.00,10.00,'active',51,65,2.95,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(66,'Mumbai-Melbourne Connection',88,93,10200.00,15.00,'active',51,66,3.30,'2025-04-17 22:48:39','2025-04-17 22:48:39'),(67,'Chandan',92,95,1467.10,4.10,'active',47,NULL,10.00,'2025-04-18 03:54:44','2025-04-18 03:54:44'),(68,'Chandan',92,95,1467.10,4.10,'active',2,NULL,10.00,'2025-04-18 04:22:17','2025-04-18 04:22:17');
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedules` (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `ship_id` int NOT NULL,
  `route_id` int NOT NULL,
  `departure_date` datetime NOT NULL,
  `arrival_date` datetime NOT NULL,
  `actual_departure` datetime DEFAULT NULL,
  `actual_arrival` datetime DEFAULT NULL,
  `status` enum('scheduled','in_progress','completed','cancelled','delayed') NOT NULL,
  `max_cargo` decimal(12,2) DEFAULT '0.00',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`schedule_id`),
  KEY `ship_id` (`ship_id`),
  KEY `route_id` (`route_id`),
  CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`ship_id`) REFERENCES `ships` (`ship_id`) ON DELETE CASCADE,
  CONSTRAINT `schedules_ibfk_2` FOREIGN KEY (`route_id`) REFERENCES `routes` (`route_id`) ON DELETE CASCADE,
  CONSTRAINT `valid_dates` CHECK ((`arrival_date` > `departure_date`))
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedules`
--

LOCK TABLES `schedules` WRITE;
/*!40000 ALTER TABLE `schedules` DISABLE KEYS */;
INSERT INTO `schedules` VALUES (96,52,52,'2025-03-12 08:00:00','2025-03-24 16:00:00','2025-03-12 08:30:00','2025-03-24 15:45:00','completed',80000.00,'Voyage completed successfully','2025-04-17 22:48:39','2025-04-17 22:48:39'),(97,53,53,'2025-03-19 09:00:00','2025-03-29 14:00:00','2025-03-19 09:15:00','2025-03-29 15:30:00','completed',60000.00,'Delay due to weather conditions','2025-04-17 22:48:39','2025-04-17 22:48:39'),(98,55,55,'2025-03-22 07:00:00','2025-04-16 15:00:00','2025-03-22 07:30:00','2025-04-16 16:15:00','completed',100000.00,'Smooth sailing','2025-04-17 22:48:39','2025-04-17 22:48:39'),(99,58,58,'2025-03-25 08:30:00','2025-03-31 16:30:00','2025-03-25 09:00:00','2025-03-31 17:00:00','completed',80000.00,'Completed with minor delays','2025-04-17 22:48:39','2025-04-17 22:48:39'),(100,61,61,'2025-03-29 10:00:00','2025-04-16 18:00:00','2025-03-29 10:30:00','2025-04-16 18:30:00','completed',85000.00,'Voyage completed as scheduled','2025-04-17 22:48:39','2025-04-17 22:48:39'),(101,54,54,'2025-04-01 10:00:00','2025-04-09 17:00:00','2025-04-01 10:45:00',NULL,'cancelled',90000.00,'Cancelled due to technical issues','2025-04-17 22:48:39','2025-04-17 22:48:39'),(102,57,57,'2025-04-07 08:00:00','2025-04-29 16:00:00','2025-04-07 08:15:00',NULL,'in_progress',42000.00,'Currently in transit','2025-04-17 22:48:39','2025-04-17 22:48:39'),(103,56,56,'2025-04-09 09:00:00','2025-04-25 17:00:00','2025-04-09 09:30:00',NULL,'in_progress',70000.00,'Currently in transit','2025-04-17 22:48:39','2025-04-17 22:48:39'),(104,59,59,'2025-04-15 10:00:00','2025-04-19 14:00:00','2025-04-15 10:15:00',NULL,'in_progress',65000.00,'Currently in transit','2025-04-17 22:48:39','2025-04-17 22:48:39'),(105,62,62,'2025-04-11 07:00:00','2025-04-23 15:00:00','2025-04-11 07:30:00',NULL,'in_progress',85000.00,'Currently in transit','2025-04-17 22:48:39','2025-04-17 22:48:39'),(106,64,64,'2025-04-13 08:30:00','2025-04-20 16:30:00','2025-04-13 09:00:00',NULL,'in_progress',75000.00,'Currently in transit','2025-04-17 22:48:39','2025-04-17 22:48:39'),(107,52,52,'2025-04-22 08:00:00','2025-05-04 16:00:00',NULL,NULL,'scheduled',80000.00,'Regular cargo service','2025-04-17 22:48:39','2025-04-18 03:11:00'),(108,54,54,'2025-04-25 09:00:00','2025-05-03 17:00:00',NULL,NULL,'scheduled',90000.00,'Express service','2025-04-17 22:48:39','2025-04-17 22:48:39'),(109,60,60,'2025-04-27 10:00:00','2025-05-17 18:00:00',NULL,NULL,'scheduled',60000.00,'Long-distance route','2025-04-17 22:48:39','2025-04-17 22:48:39'),(110,63,63,'2025-04-29 07:00:00','2025-05-04 15:00:00',NULL,NULL,'scheduled',65000.00,'Mediterranean service','2025-04-17 22:48:39','2025-04-17 22:48:39'),(111,65,65,'2025-05-02 08:30:00','2025-05-12 16:30:00',NULL,NULL,'scheduled',70000.00,'Transatlantic crossing','2025-04-17 22:48:39','2025-04-17 22:48:39'),(112,53,53,'2025-05-17 08:00:00','2025-05-27 16:00:00',NULL,NULL,'scheduled',59800.00,'Next month service','2025-04-17 22:48:39','2025-04-18 03:12:44'),(113,55,55,'2025-05-20 09:00:00','2025-06-14 17:00:00',NULL,NULL,'scheduled',100000.00,'Long-distance transoceanic route','2025-04-17 22:48:39','2025-04-17 22:48:39'),(114,58,58,'2025-05-22 10:00:00','2025-05-28 18:00:00',NULL,NULL,'scheduled',80000.00,'Asian trade route','2025-04-17 22:48:39','2025-04-17 22:48:39'),(115,61,61,'2025-05-25 07:00:00','2025-06-12 15:00:00',NULL,NULL,'scheduled',85000.00,'Europe-Middle East trade','2025-04-17 22:48:39','2025-04-17 22:48:39'),(116,66,66,'2025-05-27 08:30:00','2025-06-11 16:30:00',NULL,NULL,'scheduled',90000.00,'Indian Ocean crossing','2025-04-17 22:48:39','2025-04-17 22:48:39'),(117,52,52,'2025-02-11 08:00:00','2025-02-23 16:00:00','2025-02-11 08:30:00','2025-02-23 15:45:00','completed',80000.00,'Historical voyage 1','2025-04-17 22:48:41','2025-04-17 22:48:41'),(118,53,53,'2025-02-18 09:00:00','2025-02-28 14:00:00','2025-02-18 09:15:00','2025-02-28 15:30:00','completed',60000.00,'Historical voyage 2','2025-04-17 22:48:41','2025-04-17 22:48:41'),(119,55,55,'2025-01-12 07:00:00','2025-02-06 15:00:00','2025-01-12 07:30:00','2025-02-06 16:15:00','completed',100000.00,'Historical voyage 3','2025-04-17 22:48:41','2025-04-17 22:48:41'),(120,58,58,'2025-01-20 08:30:00','2025-01-26 16:30:00','2025-01-20 09:00:00','2025-01-26 17:00:00','completed',80000.00,'Historical voyage 4','2025-04-17 22:48:41','2025-04-17 22:48:41'),(121,52,67,'2025-04-19 12:00:00','2025-04-23 12:00:00',NULL,NULL,'scheduled',1000.00,'CHandan','2025-04-18 04:14:30','2025-04-18 04:14:30'),(122,67,68,'2025-04-19 12:00:00','2025-04-23 12:00:00',NULL,NULL,'scheduled',2100000.00,'','2025-04-18 04:29:13','2025-04-18 04:29:13'),(123,67,68,'2025-04-21 12:00:00','2025-04-25 12:00:00',NULL,NULL,'completed',5000000.00,'','2025-04-18 04:32:29','2025-04-18 04:41:50');
/*!40000 ALTER TABLE `schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ships`
--

DROP TABLE IF EXISTS `ships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ships` (
  `ship_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `ship_type` enum('container','bulk','tanker','roro') NOT NULL,
  `capacity` decimal(12,2) NOT NULL,
  `current_port_id` int DEFAULT NULL,
  `imo_number` varchar(20) NOT NULL,
  `flag` varchar(50) NOT NULL,
  `year_built` int NOT NULL,
  `status` enum('active','maintenance','docked','in_transit','deleted') NOT NULL,
  `owner_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ship_id`),
  UNIQUE KEY `imo_number` (`imo_number`),
  KEY `current_port_id` (`current_port_id`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `ships_ibfk_1` FOREIGN KEY (`current_port_id`) REFERENCES `ports` (`port_id`),
  CONSTRAINT `ships_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ships`
--

LOCK TABLES `ships` WRITE;
/*!40000 ALTER TABLE `ships` DISABLE KEYS */;
INSERT INTO `ships` VALUES (52,'Atlantic Explorer','container',85000.00,86,'IMO9395001','Panama',2015,'active',47,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(53,'Pacific Voyager','bulk',65000.00,87,'IMO9412002','Marshall Islands',2017,'active',47,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(54,'North Sea Carrier','container',92000.00,88,'IMO9321003','Liberia',2014,'active',47,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(55,'Mediterranean Queen','tanker',105000.00,89,'IMO9517004','Greece',2018,'active',48,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(56,'Asian Star','container',78000.00,90,'IMO9632005','Singapore',2016,'active',48,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(57,'Caribbean Princess','container',45000.00,87,'IMO9745006','United States',2019,'active',48,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(58,'Oceanic Voyager','container',88000.00,96,'IMO9823007','Hong Kong',2017,'active',49,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(59,'Baltic Transporter','bulk',72000.00,98,'IMO9456008','Denmark',2016,'active',49,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(60,'Aegean Express','container',65000.00,92,'IMO9789009','Malta',2018,'active',49,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(61,'Nordic Adventurer','container',90000.00,86,'IMO9567010','Norway',2019,'active',50,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(62,'Caspian Trader','tanker',95000.00,99,'IMO9654011','Cyprus',2015,'active',50,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(63,'Adriatic Eagle','bulk',68000.00,91,'IMO9432012','Italy',2017,'active',50,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(64,'Pacific Guardian','container',82000.00,97,'IMO9876013','Malaysia',2018,'active',51,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(65,'Atlantic Champion','bulk',75000.00,100,'IMO9765014','Bahamas',2016,'active',51,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(66,'Indian Ocean Navigator','tanker',98000.00,88,'IMO9543015','India',2017,'active',51,'2025-04-17 22:48:38','2025-04-17 22:48:38'),(67,'Chandan','container',10000.00,NULL,'BVlasda','Indai',2013,'active',2,'2025-04-18 04:21:58','2025-04-18 04:21:58');
/*!40000 ALTER TABLE `ships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,1),(2,1),(3,1),(42,1),(53,1),(1,4),(2,4),(42,4),(43,4),(45,4),(52,4),(53,4),(1,5),(2,5),(47,5),(48,5),(49,5),(50,5),(51,5),(53,5);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'harsh','Harsh','Raj','+19876543210','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','harsh777111raj@gmail.com','2025-04-17 19:19:37'),(2,'chandan','Chandan','Keelara','+19876543210','pbkdf2_sha256$870000$ptkFMQLnKiCyNdqvXClnqw$jNVHTYUNSN/ZYkn3sADAlxHbritD153Vc+pkNtHCnlA=','chandan.keelara@gmail.com','2025-04-17 19:19:37'),(3,'johndoe','John','Doe','+12345678901','$2y$10$JKfHS9jYpfLNIx.G5hZTNO1UbFT9ZVrJvzJ4Ly6o4BWvdmZl5xM3K','john.doe@example.com','2025-04-17 19:19:37'),(4,'janedoe','Jane','Doe','+12345678902','$2y$10$bXIQxIBbDR4hPWLIzl7i/evWPl2HBceztg5Afr/VSzCsKxURZj0ji','jane.doe@example.com','2025-04-17 19:19:37'),(42,'tomsmith','Tom','Smith','+11234567890','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','customer1@example.com','2025-04-17 22:48:37'),(43,'sarahlee','Sarah','Lee','+11234567891','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','customer2@example.com','2025-04-17 22:48:37'),(44,'davidwang','David','Wang','+11234567892','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','customer3@example.com','2025-04-17 22:48:37'),(45,'emilyjones','Emily','Jones','+11234567893','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','customer4@example.com','2025-04-17 22:48:37'),(46,'rajpatel','Raj','Patel','+11234567894','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','customer5@example.com','2025-04-17 22:48:37'),(47,'jamesship','James','Carter','+11234567895','pbkdf2_sha256$870000$qZr3z42XELxKlSxU0xpoux$eBlzO6W5lC4UXPJwxUAH8rEqQKNsVHzLkIIpYbelTqU=','shipowner1@shipping.com','2025-04-17 22:48:37'),(48,'marinafleet','Marina','Rodriguez','+11234567896','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','shipowner2@fleetmanagement.com','2025-04-17 22:48:37'),(49,'robertships','Robert','Chen','+11234567897','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','shipowner3@oceanfleet.com','2025-04-17 22:48:37'),(50,'sofiamarine','Sofia','Kowalski','+11234567898','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','shipowner4@marinecorp.com','2025-04-17 22:48:37'),(51,'liamvessel','Liam','Garcia','+11234567899','$2y$10$GfVYzRpHzL6bUx5YJ8HaY.3uPK4oHYQ3L8MlXvvQJN9Kcx6KKq4eO','shipowner5@vesselops.com','2025-04-17 22:48:37'),(52,'dddd','xyz','abv','22222','pbkdf2_sha256$870000$Usw0oRtJLZB6joiSBB852j$zYBu+3QeRkEX/REavELDQX4v1RMQnTHDlrBrctuh8+8=','test@gmail.com','2025-04-18 02:36:55'),(53,'sss','sss','sss','2222','pbkdf2_sha256$870000$9Hsn7gFjhpTuBJF3jUhhUp$vLV3nEkrR453HCBpU1e5lCfGReNvV3mM0H7HeW7ap0M=','test2@gmail.com','2025-04-18 02:41:30');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'port'
--

--
-- Dumping routines for database 'port'
--
/*!50003 DROP FUNCTION IF EXISTS `get_full_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `get_full_name`(uid INT) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE full_name VARCHAR(100);
    SELECT CONCAT(first_name, ' ', last_name) INTO full_name FROM users WHERE user_id = uid;
    RETURN full_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_username` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `get_username`(p_user_id INT) RETURNS varchar(255) CHARSET utf8mb4
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE username VARCHAR(255);
    
    SELECT u.username INTO username
    FROM users u
    WHERE u.user_id = p_user_id;
    
    RETURN username;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_customer_cargo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_customer_cargo`(
    IN p_user_id INT,
    IN p_description VARCHAR(255),
    IN p_cargo_type VARCHAR(50),
    IN p_weight DECIMAL(10,2),
    IN p_dimensions VARCHAR(100),
    IN p_special_instructions TEXT
)
BEGIN
    INSERT INTO cargo (
        user_id, 
        description, 
        cargo_type, 
        weight, 
        dimensions, 
        special_instructions, 
        status
    ) VALUES (
        p_user_id, 
        p_description, 
        p_cargo_type, 
        p_weight, 
        p_dimensions, 
        p_special_instructions, 
        'pending'
    );
    
    -- Return the ID of the newly created cargo
    SELECT LAST_INSERT_ID() AS cargo_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_new_berth` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_new_berth`(
    IN p_port_id INT,
    IN p_berth_number VARCHAR(20),
    IN p_type VARCHAR(50),
    IN p_length DECIMAL(10, 2),
    IN p_width DECIMAL(10, 2),
    IN p_depth DECIMAL(10, 2),
    IN p_status VARCHAR(20),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE port_exists INT;
    DECLARE berth_exists INT;
    DECLARE port_name VARCHAR(100);
    
    -- Check if the port exists and get its name
    SELECT COUNT(*) INTO port_exists
    FROM ports 
    WHERE port_id = p_port_id
    AND status = 'active';
    
    -- Get port name separately
    SELECT name INTO port_name
    FROM ports
    WHERE port_id = p_port_id;
    
    IF port_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = 'The selected port does not exist or is inactive.';
    ELSE
        -- Check if the berth number already exists for this port
        SELECT COUNT(*) INTO berth_exists
        FROM berths
        WHERE port_id = p_port_id AND berth_number = p_berth_number;
        
        IF berth_exists > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Berth number "', p_berth_number, '" already exists for port "', port_name, '".');
        ELSEIF p_length <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth length must be greater than zero.';
        ELSEIF p_width <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth width must be greater than zero.';
        ELSEIF p_depth <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth depth must be greater than zero.';
        ELSE
            -- Insert the new berth
            INSERT INTO berths (
                port_id, berth_number, type, length, width, depth, status
            ) VALUES (
                p_port_id, p_berth_number, p_type, p_length, p_width, p_depth, p_status
            );
            
            SET p_success = TRUE;
            SET p_message = CONCAT('Berth "', p_berth_number, '" has been added successfully to port "', port_name, '".');
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_new_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_new_user`(IN uname VARCHAR(50), IN email VARCHAR(100))
BEGIN
    INSERT INTO users (username, email, password) VALUES (uname, email, 'default123');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_route` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_route`(
    IN p_name VARCHAR(100),
    IN p_origin_port_id INT,
    IN p_destination_port_id INT,
    IN p_distance DECIMAL(10, 2),
    IN p_duration DECIMAL(6, 2),
    IN p_status VARCHAR(20),
    IN p_cost_per_kg DECIMAL(10, 2),
    IN p_owner_id INT,
    OUT p_route_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE valid_ports INT;
    DECLARE route_exists INT;
    
    -- Check if both ports exist and are active
    SELECT COUNT(*) INTO valid_ports 
    FROM ports p1, ports p2
    WHERE p1.port_id = p_origin_port_id 
      AND p2.port_id = p_destination_port_id
      AND p1.status = 'active'
      AND p2.status = 'active';
    
    -- Check if this route already exists for this owner
    SELECT COUNT(*) INTO route_exists
    FROM routes
    WHERE owner_id = p_owner_id
      AND origin_port_id = p_origin_port_id
      AND destination_port_id = p_destination_port_id
      AND status != 'deleted';
      
    -- Begin validation checks
    IF p_origin_port_id = p_destination_port_id THEN
        SET p_success = FALSE;
        SET p_message = 'Origin and destination ports cannot be the same.';
    ELSEIF valid_ports < 1 THEN
        SET p_success = FALSE;
        SET p_message = 'One or both ports do not exist or are not active.';
    ELSEIF p_distance <= 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Distance must be greater than zero.';
    ELSEIF p_duration <= 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Duration must be greater than zero.';
    ELSEIF route_exists > 0 THEN
        SET p_success = FALSE;
        SET p_message = 'A route between these ports already exists. Please edit the existing route instead.';
    ELSEIF p_cost_per_kg <= 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Cost per kg cannot be negative or zero. You might loose a lot of money.';
    ELSE
        -- All validations passed, insert the route
        INSERT INTO routes (
            name, 
            origin_port_id, 
            destination_port_id, 
            distance, 
            duration, 
            status, 
            owner_id, 
            cost_per_kg
        ) VALUES (
            p_name,
            p_origin_port_id,
            p_destination_port_id,
            p_distance,
            p_duration,
            p_status,
            p_owner_id,
            p_cost_per_kg
        );
        
        SET p_route_id = LAST_INSERT_ID();
        SET p_success = TRUE;
        SET p_message = CONCAT('Route "', p_name, '" created successfully!');
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cancel_booking_connected` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_booking_connected`(
    IN p_booking_id INT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_cargo_id INT;
    DECLARE v_cargo_weight DECIMAL(10, 2);
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_schedule_id INT;
    
    -- Cursor for schedule IDs
    DECLARE schedule_cursor CURSOR FOR
        SELECT schedule_id
        FROM connected_booking_segments
        WHERE connected_booking_id = p_booking_id;
    
    -- Handler for when cursor reaches end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Handler for SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'An error occurred while cancelling the booking';
    END;
    
    START TRANSACTION;
    
    -- Get booking details
    SELECT cargo_id INTO v_cargo_id
    FROM connected_bookings 
    WHERE connected_booking_id = p_booking_id AND user_id = p_user_id
    LIMIT 1;
    
    IF v_cargo_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Booking not found or does not belong to you';
        ROLLBACK;
    ELSE
        -- Get cargo weight
        SELECT weight INTO v_cargo_weight
        FROM cargo
        WHERE cargo_id = v_cargo_id
        LIMIT 1;
        
        -- Update booking status
        UPDATE connected_bookings 
        SET booking_status = 'cancelled', payment_status = 'refunded'
        WHERE connected_booking_id = p_booking_id AND user_id = p_user_id;
        
        -- Update cargo status
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = v_cargo_id;
        
        -- Restore schedule capacity for all segments
        OPEN schedule_cursor;
        
        read_loop: LOOP
            FETCH schedule_cursor INTO v_schedule_id;
            IF done THEN
                LEAVE read_loop;
            END IF;
            
            UPDATE schedules
            SET max_cargo = max_cargo + v_cargo_weight
            WHERE schedule_id = v_schedule_id;
        END LOOP;
        
        CLOSE schedule_cursor;
        
        SET p_success = TRUE;
        SET p_message = 'Connected booking cancelled successfully. Your payment will be refunded.';
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cancel_booking_direct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_booking_direct`(
    IN p_booking_id INT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_cargo_id INT;
    DECLARE v_schedule_id INT;
    DECLARE v_cargo_weight DECIMAL(10, 2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'An error occurred while cancelling the booking';
    END;
    
    START TRANSACTION;
    
    -- Get booking details
    SELECT cargo_id, schedule_id INTO v_cargo_id, v_schedule_id
    FROM cargo_bookings 
    WHERE booking_id = p_booking_id AND user_id = p_user_id
    LIMIT 1;
    
    IF v_cargo_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Booking not found or does not belong to you';
        ROLLBACK;
    ELSE
        -- Get cargo weight
        SELECT weight INTO v_cargo_weight
        FROM cargo
        WHERE cargo_id = v_cargo_id
        LIMIT 1;
        
        -- Update booking status
        UPDATE cargo_bookings 
        SET booking_status = 'cancelled', payment_status = 'refunded'
        WHERE booking_id = p_booking_id AND user_id = p_user_id;
        
        -- Update cargo status
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = v_cargo_id;
        
        -- Restore schedule capacity
        UPDATE schedules
        SET max_cargo = max_cargo + v_cargo_weight
        WHERE schedule_id = v_schedule_id;
        
        SET p_success = TRUE;
        SET p_message = 'Booking cancelled successfully. Your payment will be refunded.';
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cancel_connected_booking` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_connected_booking`(
    IN p_booking_id INT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE cargo_id INT;
    DECLARE cargo_weight DECIMAL(10, 2);
    
    START TRANSACTION;
    
    -- Get cargo ID for this booking
    SELECT cb.cargo_id 
    INTO cargo_id
    FROM connected_bookings cb
    WHERE cb.connected_booking_id = p_booking_id AND cb.user_id = p_user_id
    FOR UPDATE;
    
    IF cargo_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Booking not found or does not belong to you';
        ROLLBACK;
    ELSE
        -- Get cargo weight to restore schedule capacity
        SELECT weight INTO cargo_weight 
        FROM cargo WHERE cargo_id = cargo_id;
        
        -- Update connected booking status
        UPDATE connected_bookings 
        SET booking_status = 'cancelled', payment_status = 'refunded'
        WHERE connected_booking_id = p_booking_id AND user_id = p_user_id;
        
        -- Update cargo status back to pending
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = cargo_id;
        
        -- Restore schedule capacity for all segments
        UPDATE schedules s
        JOIN connected_booking_segments cbs ON s.schedule_id = cbs.schedule_id
        SET s.max_cargo = s.max_cargo + cargo_weight
        WHERE cbs.connected_booking_id = p_booking_id;
        
        SET p_success = TRUE;
        SET p_message = 'Connected booking cancelled successfully. Your payment will be refunded.';
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cancel_direct_booking` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_direct_booking`(
    IN p_booking_id INT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE cargo_id INT;
    DECLARE schedule_id INT;
    DECLARE cargo_weight DECIMAL(10, 2);
    
    START TRANSACTION;
    
    -- Get cargo ID and schedule ID for this booking
    SELECT cb.cargo_id, cb.schedule_id 
    INTO cargo_id, schedule_id
    FROM cargo_bookings cb
    WHERE cb.booking_id = p_booking_id AND cb.user_id = p_user_id
    FOR UPDATE;
    
    IF cargo_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Booking not found or does not belong to you';
        ROLLBACK;
    ELSE
        -- Get cargo weight to restore schedule capacity
        SELECT weight INTO cargo_weight 
        FROM cargo WHERE cargo_id = cargo_id;
        
        -- Update booking status
        UPDATE cargo_bookings 
        SET booking_status = 'cancelled', payment_status = 'refunded'
        WHERE booking_id = p_booking_id AND user_id = p_user_id;
        
        -- Update cargo status back to pending
        UPDATE cargo 
        SET status = 'pending'
        WHERE cargo_id = cargo_id;
        
        -- Restore schedule capacity
        UPDATE schedules
        SET max_cargo = max_cargo + cargo_weight
        WHERE schedule_id = schedule_id;
        
        SET p_success = TRUE;
        SET p_message = 'Booking cancelled successfully. Your payment will be refunded.';
        COMMIT;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_berth_availability` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `check_berth_availability`(
    IN p_berth_id INT,
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    OUT p_is_available BOOLEAN,
    OUT p_conflict_details VARCHAR(255)
)
BEGIN
    DECLARE conflict_count INT;
    DECLARE berth_status VARCHAR(20);
    DECLARE conflict_start DATETIME;
    DECLARE conflict_end DATETIME;
    DECLARE conflict_ship VARCHAR(100);
    
    -- First, check if the berth exists and is active
    SELECT status INTO berth_status
    FROM berths
    WHERE berth_id = p_berth_id;
    
    IF berth_status IS NULL THEN
        SET p_is_available = FALSE;
        SET p_conflict_details = 'Berth does not exist';
    ELSEIF berth_status != 'active' THEN
        SET p_is_available = FALSE;
        SET p_conflict_details = CONCAT('Berth is not active (current status: ', berth_status, ')');
    ELSE
        -- Check for overlapping berth assignments
        SELECT COUNT(*), 
               MIN(ba.arrival_time),
               MIN(ba.departure_time),
               (SELECT name FROM ships WHERE ship_id = MIN(ba.ship_id))
        INTO conflict_count, conflict_start, conflict_end, conflict_ship
        FROM berth_assignments ba
        WHERE ba.berth_id = p_berth_id
          AND ba.status = 'active'
          AND (
              -- New booking starts during existing booking
              (p_start_time BETWEEN ba.arrival_time AND ba.departure_time)
              -- New booking ends during existing booking
              OR (p_end_time BETWEEN ba.arrival_time AND ba.departure_time)
              -- New booking completely contains existing booking
              OR (p_start_time <= ba.arrival_time AND p_end_time >= ba.departure_time)
          );
        
        IF conflict_count > 0 THEN
            SET p_is_available = FALSE;
            SET p_conflict_details = CONCAT(
                'Berth already booked by ', 
                conflict_ship, 
                ' from ', 
                DATE_FORMAT(conflict_start, '%Y-%m-%d %H:%i'),
                ' to ',
                DATE_FORMAT(conflict_end, '%Y-%m-%d %H:%i')
            );
        ELSE
            SET p_is_available = TRUE;
            SET p_conflict_details = 'Berth is available for the requested time period';
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_booking_segment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_booking_segment`(
    IN p_connected_booking_id INT,
    IN p_schedule_id INT,
    IN p_segment_order INT,
    IN p_cargo_weight DECIMAL(10,2)
)
BEGIN
    DECLARE segment_price DECIMAL(12,2);
    
    -- Calculate segment price
    SELECT 
        r.cost_per_kg * p_cargo_weight INTO segment_price
    FROM 
        schedules s
    JOIN 
        routes r ON s.route_id = r.route_id
    WHERE 
        s.schedule_id = p_schedule_id;
    
    -- Insert segment
    INSERT INTO connected_booking_segments (
        connected_booking_id, schedule_id, segment_order, segment_price
    ) VALUES (
        p_connected_booking_id, p_schedule_id, p_segment_order, segment_price
    );
    
    -- Update schedule available capacity
    UPDATE schedules
    SET max_cargo = max_cargo - p_cargo_weight
    WHERE schedule_id = p_schedule_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_connected_booking` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_connected_booking`(
    IN p_cargo_id INT,
    IN p_user_id INT,
    IN p_schedule_ids VARCHAR(255),
    IN p_notes TEXT,
    OUT p_booking_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE origin_port_id INT;
    DECLARE destination_port_id INT;
    DECLARE total_price DECIMAL(12, 2);
    DECLARE cargo_weight DECIMAL(10, 2);
    DECLARE first_schedule_id INT;
    DECLARE last_schedule_id INT;
    DECLARE done INT DEFAULT 0;
    DECLARE segment_count INT DEFAULT 0;
    DECLARE current_schedule_id INT;
    DECLARE segment_price DECIMAL(12, 2);
    
    -- Create a temporary table to store schedule IDs
    DROP TEMPORARY TABLE IF EXISTS temp_schedule_ids;
    CREATE TEMPORARY TABLE temp_schedule_ids (
        id INT AUTO_INCREMENT PRIMARY KEY,
        schedule_id INT NOT NULL
    );
    
    -- Insert schedule IDs into temporary table
    SET @sql = CONCAT("INSERT INTO temp_schedule_ids (schedule_id) VALUES ('", 
                REPLACE(p_schedule_ids, ",", "'),('"), "')");
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Get first and last schedule IDs
    SELECT schedule_id INTO first_schedule_id FROM temp_schedule_ids ORDER BY id LIMIT 1;
    SELECT schedule_id INTO last_schedule_id FROM temp_schedule_ids ORDER BY id DESC LIMIT 1;
    
    -- Get total count of segments
    SELECT COUNT(*) INTO segment_count FROM temp_schedule_ids;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get origin and destination port IDs
    SELECT 
        r1.origin_port_id, r2.destination_port_id 
    INTO 
        origin_port_id, destination_port_id
    FROM 
        schedules s1
    JOIN 
        routes r1 ON s1.route_id = r1.route_id
    JOIN 
        schedules s2
    JOIN 
        routes r2 ON s2.route_id = r2.route_id
    WHERE 
        s1.schedule_id = first_schedule_id
        AND s2.schedule_id = last_schedule_id;
    
    -- Get cargo weight
    SELECT weight INTO cargo_weight FROM cargo WHERE cargo_id = p_cargo_id;
    
    -- Calculate total price by summing segment prices
    SELECT 
        SUM(r.cost_per_kg * cargo_weight) INTO total_price
    FROM 
        temp_schedule_ids t
    JOIN 
        schedules s ON t.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id;
    
    IF origin_port_id IS NULL OR destination_port_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Could not determine route endpoints';
        ROLLBACK;
    ELSEIF total_price IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Could not calculate booking price';
        ROLLBACK;
    ELSE
        -- Create the connected booking
        INSERT INTO connected_bookings (
            cargo_id, user_id, origin_port_id, destination_port_id,
            booking_date, booking_status, payment_status, 
            total_price, notes
        ) VALUES (
            p_cargo_id, p_user_id, origin_port_id, destination_port_id,
            NOW(), 'confirmed', 'paid', 
            total_price, p_notes
        );
        
        SET p_booking_id = LAST_INSERT_ID();
        
        -- Add each segment to the connected_booking_segments table
        -- Use cursor to iterate through temp_schedule_ids
        BEGIN
            DECLARE cur CURSOR FOR 
                SELECT schedule_id FROM temp_schedule_ids ORDER BY id;
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
            
            OPEN cur;
            
            SET @segment_order = 0;
            read_loop: LOOP
                FETCH cur INTO current_schedule_id;
                IF done THEN
                    LEAVE read_loop;
                END IF;
                
                SET @segment_order = @segment_order + 1;
                
                -- Calculate segment price
                SELECT 
                    r.cost_per_kg * cargo_weight INTO segment_price
                FROM 
                    schedules s
                JOIN 
                    routes r ON s.route_id = r.route_id
                WHERE 
                    s.schedule_id = current_schedule_id;
                
                -- Insert segment
                INSERT INTO connected_booking_segments (
                    connected_booking_id, schedule_id, segment_order, segment_price
                ) VALUES (
                    p_booking_id, current_schedule_id, @segment_order, segment_price
                );
                
                -- Update schedule available capacity
                UPDATE schedules
                SET max_cargo = max_cargo - cargo_weight
                WHERE schedule_id = current_schedule_id;
            END LOOP;
            
            CLOSE cur;
        END;
        
        -- Update cargo status (trigger handles this but keeping for clarity)
        UPDATE cargo 
        SET status = 'booked'
        WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
        
        SET p_success = TRUE;
        SET p_message = CONCAT('Connected route booked successfully! Booking ID: ', p_booking_id);
        COMMIT;
    END IF;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS temp_schedule_ids;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_direct_booking` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_direct_booking`(
    IN p_cargo_id INT,
    IN p_schedule_id INT,
    IN p_user_id INT,
    IN p_notes TEXT,
    OUT p_booking_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE cargo_weight DECIMAL(10, 2);
    DECLARE total_price DECIMAL(12, 2);
    DECLARE cargo_status VARCHAR(50);
    
    -- Transaction to ensure all operations complete or none do
    START TRANSACTION;
    
    -- Check if cargo is already booked
    SELECT status INTO cargo_status
    FROM cargo 
    WHERE cargo_id = p_cargo_id;
    
    IF cargo_status = 'booked' THEN
        SET p_success = FALSE;
        SET p_message = 'Cargo is already booked';
        ROLLBACK;
    ELSE
        -- Calculate booking price
        SELECT
            r.cost_per_kg * c.weight,
            c.weight INTO total_price, cargo_weight
        FROM
            schedules s
        JOIN
            routes r ON s.route_id = r.route_id
        JOIN
            cargo c ON c.cargo_id = p_cargo_id
        WHERE
            s.schedule_id = p_schedule_id;
            
        IF total_price IS NULL THEN
            SET p_success = FALSE;
            SET p_message = 'Could not calculate booking price';
            ROLLBACK;
        ELSE
            -- Create the booking
            INSERT INTO cargo_bookings (
                cargo_id, schedule_id, user_id, 
                booking_date, booking_status, payment_status,
                price, notes
            ) VALUES (
                p_cargo_id, p_schedule_id, p_user_id, 
                NOW(), 'confirmed', 'paid',
                total_price, p_notes
            );
                
            SET p_booking_id = LAST_INSERT_ID();
                
            -- Update cargo status (trigger handles this but keeping for clarity)
            UPDATE cargo 
            SET status = 'booked'
            WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
                
            -- Update schedule available capacity
            UPDATE schedules
            SET max_cargo = max_cargo - cargo_weight
            WHERE schedule_id = p_schedule_id;
                
            SET p_success = TRUE;
            SET p_message = CONCAT('Cargo booked successfully! Booking ID: ', p_booking_id);
            COMMIT;
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_schedule_with_berths` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_schedule_with_berths`(
    IN p_ship_id INT,
    IN p_route_id INT,
    IN p_max_cargo DECIMAL(12, 2),
    IN p_status VARCHAR(20),
    IN p_notes TEXT,
    IN p_departure_date DATETIME,
    IN p_arrival_date DATETIME,
    IN p_origin_berth_id INT,
    IN p_origin_berth_start DATETIME,
    IN p_origin_berth_end DATETIME,
    IN p_destination_berth_id INT,
    IN p_destination_berth_start DATETIME,
    IN p_destination_berth_end DATETIME,
    OUT p_schedule_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_ship_name VARCHAR(100);
    DECLARE v_origin_port_id INT;
    DECLARE v_destination_port_id INT;
    DECLARE v_origin_available BOOLEAN DEFAULT TRUE;
    DECLARE v_destination_available BOOLEAN DEFAULT TRUE;
    DECLARE v_origin_conflict VARCHAR(255);
    DECLARE v_destination_conflict VARCHAR(255);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get ship name for messages
    SELECT name INTO v_ship_name 
    FROM ships 
    WHERE ship_id = p_ship_id;
    
    -- Get origin and destination port ids from route
    SELECT origin_port_id, destination_port_id 
    INTO v_origin_port_id, v_destination_port_id
    FROM routes
    WHERE route_id = p_route_id;
    
    -- Validate inputs
    IF v_ship_name IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Ship not found';
        ROLLBACK;
    ELSEIF p_departure_date IS NULL OR p_arrival_date IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Departure and arrival dates are required';
        ROLLBACK;
    ELSEIF p_departure_date >= p_arrival_date THEN
        SET p_success = FALSE;
        SET p_message = 'Departure date must be before arrival date';
        ROLLBACK;
    ELSEIF v_origin_port_id IS NULL OR v_destination_port_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Invalid route selected';
        ROLLBACK;
    ELSE
        -- Check berth availability if berths are provided
        IF p_origin_berth_id IS NOT NULL AND p_origin_berth_start IS NOT NULL AND p_origin_berth_end IS NOT NULL THEN
            -- Verify berth is in the origin port
            SELECT COUNT(*) = 1 INTO v_origin_available
            FROM berths b
            WHERE b.berth_id = p_origin_berth_id 
            AND b.port_id = v_origin_port_id
            AND b.status = 'active';
            
            IF NOT v_origin_available THEN
                SET v_origin_conflict = 'Selected origin berth is not available in the origin port';
            ELSE
                -- Check for booking conflicts
                SELECT NOT EXISTS (
                    SELECT 1
                    FROM berth_assignments ba
                    WHERE ba.berth_id = p_origin_berth_id
                      AND ba.status = 'active'
                      AND (
                          (p_origin_berth_start BETWEEN ba.arrival_time AND ba.departure_time)
                          OR (p_origin_berth_end BETWEEN ba.arrival_time AND ba.departure_time)
                          OR (p_origin_berth_start <= ba.arrival_time AND p_origin_berth_end >= ba.departure_time)
                      )
                ) INTO v_origin_available;
                
                IF NOT v_origin_available THEN
                    SET v_origin_conflict = 'Origin berth has conflicting bookings for the selected time period';
                END IF;
            END IF;
        END IF;
        
        IF p_destination_berth_id IS NOT NULL AND p_destination_berth_start IS NOT NULL AND p_destination_berth_end IS NOT NULL THEN
            -- Verify berth is in the destination port
            SELECT COUNT(*) = 1 INTO v_destination_available
            FROM berths b
            WHERE b.berth_id = p_destination_berth_id 
            AND b.port_id = v_destination_port_id
            AND b.status = 'active';
            
            IF NOT v_destination_available THEN
                SET v_destination_conflict = 'Selected destination berth is not available in the destination port';
            ELSE
                -- Check for booking conflicts
                SELECT NOT EXISTS (
                    SELECT 1
                    FROM berth_assignments ba
                    WHERE ba.berth_id = p_destination_berth_id
                      AND ba.status = 'active'
                      AND (
                          (p_destination_berth_start BETWEEN ba.arrival_time AND ba.departure_time)
                          OR (p_destination_berth_end BETWEEN ba.arrival_time AND ba.departure_time)
                          OR (p_destination_berth_start <= ba.arrival_time AND p_destination_berth_end >= ba.departure_time)
                      )
                ) INTO v_destination_available;
                
                IF NOT v_destination_available THEN
                    SET v_destination_conflict = 'Destination berth has conflicting bookings for the selected time period';
                END IF;
            END IF;
        END IF;
        
        -- If berths aren't available, return error message
        IF (p_origin_berth_id IS NOT NULL AND NOT v_origin_available) THEN
            SET p_success = FALSE;
            SET p_message = v_origin_conflict;
            ROLLBACK;
        ELSEIF (p_destination_berth_id IS NOT NULL AND NOT v_destination_available) THEN
            SET p_success = FALSE;
            SET p_message = v_destination_conflict;
            ROLLBACK;
        ELSE
            -- Create the schedule
            INSERT INTO schedules (
                ship_id, 
                route_id, 
                departure_date, 
                arrival_date, 
                status, 
                max_cargo, 
                notes,
                created_at,
                updated_at
            ) VALUES (
                p_ship_id,
                p_route_id,
                p_departure_date,
                p_arrival_date,
                p_status,
                p_max_cargo,
                p_notes,
                NOW(),
                NOW()
            );
            
            -- Get the new schedule ID
            SET p_schedule_id = LAST_INSERT_ID();
            
            -- Create berth assignments if provided
            IF p_origin_berth_id IS NOT NULL AND p_origin_berth_start IS NOT NULL AND p_origin_berth_end IS NOT NULL THEN
                INSERT INTO berth_assignments (
                    berth_id,
                    ship_id,
                    schedule_id,
                    arrival_time,
                    departure_time,
                    status,
                    created_at,
                    updated_at
                ) VALUES (
                    p_origin_berth_id,
                    p_ship_id,
                    p_schedule_id,
                    p_origin_berth_start,
                    p_origin_berth_end,
                    'active',
                    NOW(),
                    NOW()
                );
                
            
            END IF;
            
            IF p_destination_berth_id IS NOT NULL AND p_destination_berth_start IS NOT NULL AND p_destination_berth_end IS NOT NULL THEN
                INSERT INTO berth_assignments (
                    berth_id,
                    ship_id,
                    schedule_id,
                    arrival_time,
                    departure_time,
                    status,
                    created_at,
                    updated_at
                ) VALUES (
                    p_destination_berth_id,
                    p_ship_id,
                    p_schedule_id,
                    p_destination_berth_start,
                    p_destination_berth_end,
                    'active',
                    NOW(),
                    NOW()
                );

            END IF;
            
            SET p_success = TRUE;
            SET p_message = CONCAT('Schedule created successfully for ship "', v_ship_name, '"');
            COMMIT;
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_berth` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_berth`(
    IN p_berth_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE berth_exists INT DEFAULT 0;
    DECLARE berth_number VARCHAR(20) DEFAULT NULL;
    DECLARE berth_status VARCHAR(20) DEFAULT NULL;
    DECLARE assignment_count INT DEFAULT 0;
    DECLARE port_name VARCHAR(100) DEFAULT NULL;
    DECLARE port_id_val INT DEFAULT NULL;
    
    -- Initialize output parameters
    SET p_success = FALSE;
    SET p_message = 'An error occurred during the deletion process.';
    
    -- Check if berth exists
    SELECT COUNT(*) INTO berth_exists
    FROM berths
    WHERE berth_id = p_berth_id;
    
    IF berth_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = CONCAT('The berth with ID ', p_berth_id, ' does not exist.');
    ELSE
        -- Get berth number and status separately to avoid issues
        SELECT berth_number INTO berth_number 
        FROM berths 
        WHERE berth_id = p_berth_id;
        
        SELECT status INTO berth_status 
        FROM berths 
        WHERE berth_id = p_berth_id;
        
        SELECT port_id INTO port_id_val 
        FROM berths 
        WHERE berth_id = p_berth_id;
        
        -- Get port name
        IF port_id_val IS NOT NULL THEN
            SELECT name INTO port_name 
            FROM ports 
            WHERE port_id = port_id_val;
        END IF;
        
        -- Use default values if any data is missing
        IF berth_number IS NULL THEN
            SET berth_number = CONCAT('ID:', p_berth_id);
        END IF;
        
        IF port_name IS NULL THEN
            SET port_name = 'Unknown Port';
        END IF;
        
        -- Check for assignments
        SELECT COUNT(*) INTO assignment_count
        FROM berth_assignments
        WHERE berth_id = p_berth_id AND status = 'active';
        
        -- Perform validation
        IF berth_status = 'occupied' THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete berth "', berth_number, '" because it is currently occupied.');
        ELSEIF assignment_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete berth "', berth_number, '" because it has ', assignment_count, ' active assignments.');
        ELSE
            -- Safe to delete
            START TRANSACTION;
            
            DELETE FROM berths WHERE berth_id = p_berth_id;
            
            IF ROW_COUNT() > 0 THEN
                SET p_success = TRUE;
                SET p_message = CONCAT('Berth "', berth_number, '" has been deleted successfully from port "', port_name, '".');
                COMMIT;
            ELSE
                SET p_success = FALSE;
                SET p_message = CONCAT('Failed to delete berth "', berth_number, '". No rows affected.');
                ROLLBACK;
            END IF;
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_customer_cargo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_customer_cargo`(
    IN p_cargo_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE cargo_exists INT;
    DECLARE delete_allowed INT;
    
    -- Check if cargo exists and belongs to the user
    SELECT COUNT(*) INTO cargo_exists
    FROM cargo
    WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
    
    -- Check if cargo is in a state that allows deletion (only pending)
    SELECT COUNT(*) INTO delete_allowed
    FROM cargo
    WHERE cargo_id = p_cargo_id 
      AND user_id = p_user_id
      AND status = 'pending';
    
    -- Only delete if cargo exists, belongs to the user, and is in a deletable state
    IF cargo_exists > 0 AND delete_allowed > 0 THEN
        DELETE FROM cargo 
        WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
        
        -- Return success code
        SELECT 1 AS status;
    ELSE
        -- Return failure code
        SELECT 0 AS status;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_port` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_port`(
    IN p_port_id INT,
    OUT p_status BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE berth_count INT DEFAULT 0;
    DECLARE route_count INT DEFAULT 0;
    DECLARE port_name VARCHAR(100);
    
    -- Get port name for message
    SELECT name INTO port_name FROM ports WHERE port_id = p_port_id;
    
    IF port_name IS NULL THEN
        SET p_status = FALSE;
        SET p_message = 'Port not found.';
    ELSE
        -- Check if port has berths
        SELECT COUNT(*) INTO berth_count FROM berths WHERE port_id = p_port_id;
        
        -- Check if port is used in routes (as origin or destination)
        SELECT COUNT(*) INTO route_count 
        FROM routes 
        WHERE origin_port_id = p_port_id OR destination_port_id = p_port_id;
        
        -- Only delete if no dependencies exist
        IF berth_count > 0 THEN
            SET p_status = FALSE;
            SET p_message = CONCAT('Cannot delete port "', port_name, '". It has ', berth_count, ' berth(s) associated with it. Please delete them first.');
        ELSEIF route_count > 0 THEN
            SET p_status = FALSE;
            SET p_message = CONCAT('Cannot delete port "', port_name, '". It is used in ', route_count, ' route(s). Please delete them first.');
        ELSE
            -- Safe to delete
            DELETE FROM ports WHERE port_id = p_port_id;
            SET p_status = TRUE;
            SET p_message = CONCAT('Port "', port_name, '" deleted successfully!');
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_schedule_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_schedule_proc`(
    IN p_schedule_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_ship_id INT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_origin_berth_id INT;
    DECLARE v_destination_berth_id INT;
    
    -- Get schedule details
    SELECT ship_id, status
    INTO v_ship_id, v_status
    FROM schedules
    WHERE schedule_id = p_schedule_id;
    
    IF v_ship_id IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Schedule not found';
    ELSE
        -- Start transaction
        START TRANSACTION;
        
        -- Get berth IDs from assignments
        SELECT 
            (SELECT berth_id FROM berth_assignments 
             WHERE schedule_id = p_schedule_id AND berth_id IN (
                 SELECT b.berth_id FROM berths b
                 JOIN ports p ON b.port_id = p.port_id
                 JOIN routes r ON p.port_id = r.origin_port_id
                 WHERE r.route_id = (SELECT route_id FROM schedules WHERE schedule_id = p_schedule_id)
             ) LIMIT 1) AS origin_berth_id,
            (SELECT berth_id FROM berth_assignments 
             WHERE schedule_id = p_schedule_id AND berth_id IN (
                 SELECT b.berth_id FROM berths b
                 JOIN ports p ON b.port_id = p.port_id
                 JOIN routes r ON p.port_id = r.destination_port_id
                 WHERE r.route_id = (SELECT route_id FROM schedules WHERE schedule_id = p_schedule_id)
             ) LIMIT 1) AS destination_berth_id
        INTO v_origin_berth_id, v_destination_berth_id;

        -- If schedule is not completed, free up berths
        IF v_status != 'completed' THEN
            IF v_origin_berth_id IS NOT NULL THEN
                UPDATE berths 
                SET status = 'active'
                WHERE berth_id = v_origin_berth_id AND status IN ('reserved', 'occupied');
            END IF;
            
            IF v_destination_berth_id IS NOT NULL THEN
                UPDATE berths 
                SET status = 'active'
                WHERE berth_id = v_destination_berth_id AND status IN ('reserved', 'occupied');
            END IF;
        END IF;
        
        -- Delete berth assignments first
        DELETE FROM berth_assignments WHERE schedule_id = p_schedule_id;
        
        -- Delete the schedule
        DELETE FROM schedules WHERE schedule_id = p_schedule_id;
        
        COMMIT;
        
        SET p_success = TRUE;
        SET p_message = 'Schedule deleted successfully';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_user`(
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE username VARCHAR(50);
    DECLARE cargo_count INT DEFAULT 0;
    DECLARE bookings_count INT DEFAULT 0;
    DECLARE ships_count INT DEFAULT 0;
    DECLARE routes_count INT DEFAULT 0;
    
    -- Get username for message
    SELECT username INTO username FROM users WHERE user_id = p_user_id;
    IF username IS NULL THEN
        select user_id into username from users where user_id = p_user_id;
    END IF;
    
    IF username IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'User not found.';
    ELSE
        -- Check if user has any cargo
        SELECT COUNT(*) INTO cargo_count FROM cargo WHERE user_id = p_user_id;
        
        -- Check if user has any bookings (direct or connected)
        SELECT 
            (SELECT COUNT(*) FROM cargo_bookings WHERE user_id = p_user_id) +
            (SELECT COUNT(*) FROM connected_bookings WHERE user_id = p_user_id)
        INTO bookings_count;
        
        -- Check if user owns any ships
        SELECT COUNT(*) INTO ships_count FROM ships WHERE owner_id = p_user_id;
        
        -- Check if user owns any routes
        SELECT COUNT(*) INTO routes_count FROM routes WHERE owner_id = p_user_id;
        
        -- Only delete if no dependencies exist
        IF cargo_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete user "', username, '". User has ', cargo_count, ' cargo items. Please delete them first.');
        ELSEIF bookings_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete user "', username, '". User has ', bookings_count, ' bookings. Please delete them first.');
        ELSEIF ships_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete user "', username, '". User owns ', ships_count, ' ships. Please reassign or delete them first.');
        ELSEIF routes_count > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Cannot delete user "', username, '". User owns ', routes_count, ' routes. Please reassign or delete them first.');
        ELSE
            -- Safe to delete
            DELETE FROM user_roles WHERE user_id = p_user_id;
            DELETE FROM users WHERE user_id = p_user_id;
            
            SET p_success = TRUE;
            SET p_message = CONCAT('User "', username, '" deleted successfully!');
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `edit_berth` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_berth`(
    IN p_berth_id INT,
    IN p_port_id INT,
    IN p_berth_number VARCHAR(20),
    IN p_type VARCHAR(50),
    IN p_length DECIMAL(10, 2),
    IN p_width DECIMAL(10, 2),
    IN p_depth DECIMAL(10, 2),
    IN p_status VARCHAR(20),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE berth_exists INT;
    DECLARE existing_berth_number VARCHAR(20);
    DECLARE port_name VARCHAR(100);
    DECLARE duplicate_exists INT;
    
    -- Check if the berth exists and get its number
    SELECT COUNT(*) INTO berth_exists
    FROM berths
    WHERE berth_id = p_berth_id;
    
    -- Get berth number separately
    SELECT berth_number INTO existing_berth_number
    FROM berths
    WHERE berth_id = p_berth_id;
    
    IF berth_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = 'The selected berth does not exist.';
    ELSE
        -- Get port name for message
        SELECT name INTO port_name
        FROM ports
        WHERE port_id = p_port_id;
        
        -- Check for duplicate berth number
        SELECT COUNT(*) INTO duplicate_exists
        FROM berths
        WHERE port_id = p_port_id 
        AND berth_number = p_berth_number 
        AND berth_id != p_berth_id;
        
        IF duplicate_exists > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Berth number "', p_berth_number, '" is already in use by another berth at port "', port_name, '".');
        ELSEIF p_length <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth length must be greater than zero.';
        ELSEIF p_width <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth width must be greater than zero.';
        ELSEIF p_depth <= 0 THEN
            SET p_success = FALSE;
            SET p_message = 'Berth depth must be greater than zero.';
        ELSE
            -- Update the berth
            UPDATE berths
            SET berth_number = p_berth_number,
                type = p_type,
                length = p_length,
                width = p_width,
                depth = p_depth,
                status = p_status
            WHERE berth_id = p_berth_id;
            
            SET p_success = TRUE;
            SET p_message = CONCAT('Berth "', p_berth_number, '" has been updated successfully.');
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `edit_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_user`(
    IN p_user_id INT,
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_roles VARCHAR(255),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE existing_username VARCHAR(50);
    DECLARE email_exists INT DEFAULT 0;
    DECLARE role_id_val INT;
    DECLARE role_name_val VARCHAR(50);
    DECLARE role_exists BOOLEAN;
    DECLARE done INT DEFAULT FALSE;
    DECLARE roles_cursor CURSOR FOR SELECT value FROM roles_temp;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Create temporary table for roles
    DROP TEMPORARY TABLE IF EXISTS roles_temp;
    CREATE TEMPORARY TABLE roles_temp (
        id INT AUTO_INCREMENT PRIMARY KEY,
        value VARCHAR(50)
    );
    
    -- Parse the roles string into the temporary table
    SET @sql = CONCAT("INSERT INTO roles_temp (value) VALUES ('", REPLACE(p_roles, ",", "'),('"), "')");
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Check if user exists
    SELECT username INTO existing_username FROM users WHERE user_id = p_user_id;
    
    IF existing_username IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'User not found.';
    ELSE
        -- Check if email is already in use by another user
        SELECT COUNT(*) INTO email_exists 
        FROM users 
        WHERE email = p_email AND user_id != p_user_id;
        
        IF email_exists > 0 THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Email "', p_email, '" is already in use by another user.');
        ELSE
            START TRANSACTION;
            
            -- Update user information
            IF p_password IS NOT NULL AND p_password != '' THEN
                UPDATE users 
                SET username = p_username, 
                    email = p_email, 
                    password = p_password 
                WHERE user_id = p_user_id;
            ELSE
                UPDATE users 
                SET username = p_username, 
                    email = p_email 
                WHERE user_id = p_user_id;
            END IF;
            
            -- Delete existing roles
            DELETE FROM user_roles WHERE user_id = p_user_id;
            
            -- Check if all roles exist and add them
            OPEN roles_cursor;
            
            roles_loop: LOOP
                FETCH roles_cursor INTO role_name_val;
                IF done THEN
                    LEAVE roles_loop;
                END IF;
                
                -- Check if role exists
                SELECT role_id INTO role_id_val 
                FROM roles 
                WHERE role_name = role_name_val;
                
                IF role_id_val IS NULL THEN
                    SET p_success = FALSE;
                    SET p_message = CONCAT('Role "', role_name_val, '" does not exist.');
                    ROLLBACK;
                    CLOSE roles_cursor;
                    LEAVE roles_loop;
                ELSE
                    -- Add role to user
                    INSERT INTO user_roles (user_id, role_id)
                    VALUES (p_user_id, role_id_val);
                END IF;
            END LOOP;
            
            CLOSE roles_cursor;
            
            IF p_success IS NULL THEN
                SET p_success = TRUE;
                SET p_message = CONCAT('User "', p_username, '" updated successfully!');
                COMMIT;
            END IF;
        END IF;
    END IF;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS roles_temp;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `filter_users_advanced` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `filter_users_advanced`(
    IN username_filter VARCHAR(100),
    IN email_filter VARCHAR(100),
    IN role_filter VARCHAR(50)
)
BEGIN
    SELECT 
        u.user_id, 
        u.username, 
        u.email, 
        GROUP_CONCAT(r.role_name SEPARATOR ', ') as role_name
    FROM 
        users u
    JOIN 
        user_roles ur ON u.user_id = ur.user_id
    JOIN 
        roles r ON ur.role_id = r.role_id
    WHERE 
        (username_filter IS NULL OR u.username LIKE CONCAT('%', username_filter, '%')) AND
        (email_filter IS NULL OR u.email LIKE CONCAT('%', email_filter, '%')) AND
        (role_filter IS NULL OR r.role_name = role_filter)
    GROUP BY 
        u.user_id, u.username, u.email
    ORDER BY 
        u.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_all_routes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_all_routes`(
    IN p_origin_port_id INT,
    IN p_destination_port_id INT,
    IN p_earliest_date VARCHAR(50),
    IN p_latest_date VARCHAR(50),
    IN p_cargo_id INT,
    IN p_max_connections INT
)
BEGIN
    DECLARE cargo_weight DECIMAL(10,2);
    DECLARE cargo_type VARCHAR(50);
    
    -- Get cargo details
    SELECT weight, cargo_type INTO cargo_weight, cargo_type
    FROM cargo
    WHERE cargo_id = p_cargo_id;
    
    -- Use Common Table Expressions (CTE) to organize the query
    WITH 
    -- CTE for direct routes
    direct_routes AS (
        SELECT 
            'direct' AS route_type,
            CAST(s.schedule_id AS CHAR) AS schedule_ids,
            1 AS total_segments,
            op.name AS origin_port,
            dp.name AS destination_port,
            s.departure_date,
            s.arrival_date,
            TIMESTAMPDIFF(DAY, s.departure_date, s.arrival_date) AS duration,
            r.distance,
            cargo_weight AS cargo_weight,
            (cargo_weight * r.cost_per_kg) AS total_cost,
            p_cargo_id AS cargo_id,
            ships.name AS ship_name,
            ships.ship_type,
            r.name AS route_name,
            r.route_id,
            s.schedule_id,
            r.cost_per_kg,
            s.max_cargo
        FROM 
            schedules s
        JOIN 
            routes r ON s.route_id = r.route_id
        JOIN 
            ships ON s.ship_id = ships.ship_id
        JOIN 
            ports op ON r.origin_port_id = op.port_id
        JOIN 
            ports dp ON r.destination_port_id = dp.port_id
        WHERE 
            r.origin_port_id = p_origin_port_id
            AND r.destination_port_id = p_destination_port_id
            AND DATE(s.departure_date) >= DATE(p_earliest_date)
            AND DATE(s.arrival_date) <= DATE(p_latest_date)
            AND s.status IN ('scheduled', 'in_progress')
            AND s.max_cargo >= cargo_weight
    ),
    -- CTE for first segment schedules
    first_segments AS (
        SELECT 
            s.schedule_id,
            s.route_id,
            r.origin_port_id,
            r.destination_port_id,
            s.departure_date,
            s.arrival_date,
            r.cost_per_kg,
            r.distance,
            s.max_cargo,
            r.name AS route_name,
            ships.name AS ship_name,
            ships.ship_type,
            op.name AS origin_port,
            dp.name AS destination_port
        FROM 
            schedules s
        JOIN 
            routes r ON s.route_id = r.route_id
        JOIN 
            ships ON s.ship_id = ships.ship_id
        JOIN 
            ports op ON r.origin_port_id = op.port_id
        JOIN 
            ports dp ON r.destination_port_id = dp.port_id
        WHERE 
            r.origin_port_id = p_origin_port_id
            AND DATE(s.departure_date) >= DATE(p_earliest_date)
            AND DATE(s.arrival_date) <= DATE(p_latest_date)
            AND s.status IN ('scheduled', 'in_progress')
            AND s.max_cargo >= cargo_weight
    ),
    -- CTE for second segment schedules
    second_segments AS (
        SELECT 
            s.schedule_id,
            s.route_id,
            r.origin_port_id,
            r.destination_port_id,
            s.departure_date,
            s.arrival_date,
            r.cost_per_kg,
            r.distance,
            s.max_cargo,
            r.name AS route_name,
            ships.name AS ship_name, 
            ships.ship_type,
            op.name AS origin_port,
            dp.name AS destination_port
        FROM 
            schedules s
        JOIN 
            routes r ON s.route_id = r.route_id
        JOIN 
            ships ON s.ship_id = ships.ship_id
        JOIN 
            ports op ON r.origin_port_id = op.port_id
        JOIN 
            ports dp ON r.destination_port_id = dp.port_id
        WHERE 
            r.destination_port_id = p_destination_port_id
            AND DATE(s.departure_date) >= DATE(p_earliest_date)
            AND DATE(s.arrival_date) <= DATE(p_latest_date)
            AND s.status IN ('scheduled', 'in_progress')
            AND s.max_cargo >= cargo_weight
    ),
    -- CTE for connected routes
    connected_routes AS (
        SELECT 
            'connected' AS route_type,
            CONCAT(s1.schedule_id, ',', s2.schedule_id) AS schedule_ids,
            2 AS total_segments,
            s1.origin_port AS origin_port,
            s2.destination_port AS destination_port,
            s1.departure_date,
            s2.arrival_date,
            TIMESTAMPDIFF(DAY, s1.departure_date, s2.arrival_date) AS duration,
            (s1.distance + s2.distance) AS distance,
            cargo_weight AS cargo_weight,
            (cargo_weight * (s1.cost_per_kg + s2.cost_per_kg)) AS total_cost,
            p_cargo_id AS cargo_id,
            CONCAT(s1.ship_name, ' / ', s2.ship_name) AS ship_name,
            CONCAT(s1.ship_type, ' / ', s2.ship_type) AS ship_type,
            CONCAT(s1.route_name, ' + ', s2.route_name) AS route_name,
            NULL AS route_id, -- No single route ID for connected routes
            NULL AS schedule_id, -- No single schedule ID for connected routes
            (s1.cost_per_kg + s2.cost_per_kg) AS cost_per_kg,
            LEAST(s1.max_cargo, s2.max_cargo) AS max_cargo
        FROM 
            first_segments s1
        JOIN 
            second_segments s2 ON s1.destination_port_id = s2.origin_port_id
            AND s2.departure_date >= s1.arrival_date
        WHERE
            s1.origin_port_id = p_origin_port_id
            AND s2.destination_port_id = p_destination_port_id
    )
    
    -- Select direct routes
    SELECT * FROM direct_routes
    
    -- Add connected routes if requested
    UNION ALL
    SELECT * FROM connected_routes WHERE p_max_connections > 0
    
    -- Order the combined results
    ORDER BY departure_date, total_cost, total_segments;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_active_ports` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_active_ports`()
BEGIN
    SELECT port_id, name, country, ST_Y(location) as lat, ST_X(location) as lng
    FROM ports 
    WHERE status = 'active'
    ORDER BY name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_admin_booking_trends` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_admin_booking_trends`(
    IN p_days_back INT
)
BEGIN
    -- Calculate start date
    SET @start_date = DATE_SUB(CURDATE(), INTERVAL p_days_back DAY);
    
    -- Get daily booking data (direct and connected)
    SELECT 
        DATE(booking_date) as booking_day,
        COUNT(*) as booking_count,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_day
    
    UNION ALL
    
    SELECT 
        DATE(booking_date) as booking_day,
        COUNT(*) as booking_count,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_day
    
    ORDER BY booking_day;
    
    -- Get weekly booking data
    SELECT 
        YEARWEEK(booking_date) as booking_week,
        COUNT(*) as booking_count,
        COALESCE(SUM(price), 0) as revenue,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_week
    
    UNION ALL
    
    SELECT 
        YEARWEEK(booking_date) as booking_week,
        COUNT(*) as booking_count,
        COALESCE(SUM(total_price), 0) as revenue,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_week
    
    ORDER BY booking_week;
    
    -- Get monthly booking data
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m') as booking_month,
        COUNT(*) as booking_count,
        COALESCE(SUM(price), 0) as revenue,
        'direct' as booking_type
    FROM cargo_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_month
    
    UNION ALL
    
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m') as booking_month,
        COUNT(*) as booking_count,
        COALESCE(SUM(total_price), 0) as revenue,
        'connected' as booking_type
    FROM connected_bookings
    WHERE booking_date >= @start_date
    GROUP BY booking_month
    
    ORDER BY booking_month;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_admin_cargo_stats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_admin_cargo_stats`()
BEGIN
    -- Get cargo by type
    SELECT 
        cargo_type,
        COUNT(*) as cargo_count,
        COALESCE(AVG(weight), 0) as avg_weight
    FROM cargo
    GROUP BY cargo_type
    ORDER BY cargo_count DESC;
    
    -- Get cargo by status
    SELECT 
        status,
        COUNT(*) as cargo_count
    FROM cargo
    GROUP BY status
    ORDER BY cargo_count DESC;
    
    -- Get cargo booking conversion rates
    SELECT 
        'overall' as metric,
        COUNT(DISTINCT c.cargo_id) as total_cargo,
        (
            SELECT COUNT(DISTINCT cargo_id) FROM 
            (
                SELECT cargo_id FROM cargo_bookings
                where booking_status in ('completed', 'confirmed')
                UNION
                SELECT cargo_id FROM connected_bookings
                where booking_status in ("completed", "confirmed")
            ) as booked
        ) as booked_cargo,
        (
            (
                SELECT COUNT(DISTINCT cargo_id) FROM 
                (
                    SELECT cargo_id FROM cargo_bookings
                    where booking_status in ('completed', 'confirmed')
                    UNION
                    SELECT cargo_id FROM connected_bookings
                    where booking_status in ("completed", "confirmed")
                ) as booked
            ) / COUNT(DISTINCT c.cargo_id) * 100
        ) as conversion_rate
    FROM cargo c;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_admin_dashboard_stats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_admin_dashboard_stats`()
BEGIN
    -- Get total users count by role
    SELECT 
        r.role_name,
        COUNT(DISTINCT ur.user_id) as user_count
    FROM roles r
    LEFT JOIN user_roles ur ON r.role_id = ur.role_id
    GROUP BY r.role_name
    ORDER BY user_count DESC;
    
    -- Get total cargo count by status
    SELECT 
        status,
        COUNT(*) as cargo_count
    FROM cargo
    GROUP BY status
    ORDER BY cargo_count DESC;
    
    -- Get total ships by type and status
    SELECT 
        ship_type,
        status,
        COUNT(*) as ship_count
    FROM ships
    WHERE status != 'deleted'
    GROUP BY ship_type, status
    ORDER BY ship_type, status;
    
    -- Get booking statistics (both direct and connected)
    SELECT 
        'direct' as booking_type,
        booking_status,
        COUNT(*) as booking_count,
        COALESCE(SUM(price), 0) as total_revenue
    FROM cargo_bookings
    GROUP BY booking_status
    
    UNION ALL
    
    SELECT 
        'connected' as booking_type,
        booking_status,
        COUNT(*) as booking_count,
        COALESCE(SUM(total_price), 0) as total_revenue
    FROM connected_bookings
    GROUP BY booking_status
    ORDER BY booking_type, booking_status;
    
    -- Get ports by status
    SELECT 
        status,
        COUNT(*) as port_count
    FROM ports
    GROUP BY status
    ORDER BY port_count DESC;
    
    -- Get total system revenue - make this match the sum in the booking stats
    SELECT 
        (
            SELECT COALESCE(SUM(price), 0) 
            FROM cargo_bookings 
            WHERE booking_status != 'cancelled' AND payment_status = 'paid'
        )
        +
        (
            SELECT COALESCE(SUM(total_price), 0) 
            FROM connected_bookings 
            WHERE booking_status != 'cancelled' AND payment_status = 'paid'
        ) AS total_system_revenue;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_admin_recent_activities` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_admin_recent_activities`(
    IN p_limit INT
)
BEGIN
    -- Get recent user registrations
    SELECT 
        'user_registration' as activity_type,
        user_id,
        username,
        email,
        created_at as activity_time
    FROM users
    ORDER BY created_at DESC
    LIMIT p_limit;
    
    -- Get recent direct bookings - with safer price handling
    SELECT 
        'direct_booking' as activity_type,
        cb.booking_id as id,
        u.username,
        c.description as cargo_description,
        COALESCE(cb.price, 0) as amount,
        cb.booking_status as status,
        cb.booking_date as activity_time
    FROM cargo_bookings cb
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    ORDER BY cb.booking_date DESC
    LIMIT p_limit;
    
    -- Get recent connected bookings - with safer price handling
    SELECT 
        'connected_booking' as activity_type,
        cb.connected_booking_id as id,
        u.username,
        c.description as cargo_description,
        COALESCE(cb.total_price, 0) as amount,
        cb.booking_status as status,
        cb.booking_date as activity_time
    FROM connected_bookings cb
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    ORDER BY cb.booking_date DESC
    LIMIT p_limit;
    
    -- Get recent schedule creations
    SELECT 
        'schedule_creation' as activity_type,
        s.schedule_id as id,
        sh.name as ship_name,
        r.name as route_name,
        s.departure_date,
        s.arrival_date,
        s.created_at as activity_time
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    ORDER BY s.created_at DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_admin_top_routes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_admin_top_routes`(
    IN p_limit INT
)
BEGIN
    -- Create temporary tables to store direct and connected booking data
    DROP TEMPORARY TABLE IF EXISTS temp_direct_route_revenue;
    CREATE TEMPORARY TABLE temp_direct_route_revenue (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100),
        booking_count INT,
        revenue DECIMAL(12,2)
    );
    
    DROP TEMPORARY TABLE IF EXISTS temp_connected_route_revenue;
    CREATE TEMPORARY TABLE temp_connected_route_revenue (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100),
        booking_count INT,
        revenue DECIMAL(12,2)
    );
    
    DROP TEMPORARY TABLE IF EXISTS temp_all_routes;
    CREATE TEMPORARY TABLE temp_all_routes (
        route_id INT,
        route_name VARCHAR(100),
        origin_port VARCHAR(100),
        destination_port VARCHAR(100)
    );
    
    -- Get top routes by direct booking revenue - with COALESCE to handle NULL values
    INSERT INTO temp_direct_route_revenue
    SELECT 
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        COUNT(cb.booking_id) AS booking_count,
        COALESCE(SUM(cb.price), 0) AS revenue
    FROM routes r
    JOIN ports op ON r.origin_port_id = op.port_id
    JOIN ports dp ON r.destination_port_id = dp.port_id
    JOIN schedules s ON r.route_id = s.route_id
    JOIN cargo_bookings cb ON s.schedule_id = cb.schedule_id
    WHERE cb.booking_status != 'cancelled'
    GROUP BY r.route_id, r.name, op.name, dp.name;
    
    -- Get top routes by connected booking revenue - with COALESCE to handle NULL values
    INSERT INTO temp_connected_route_revenue
    SELECT 
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        COUNT(DISTINCT cbs.connected_booking_id) AS booking_count,
        COALESCE(SUM(cbs.segment_price), 0) AS revenue
    FROM routes r
    JOIN ports op ON r.origin_port_id = op.port_id
    JOIN ports dp ON r.destination_port_id = dp.port_id
    JOIN schedules s ON r.route_id = s.route_id
    JOIN connected_booking_segments cbs ON s.schedule_id = cbs.schedule_id
    JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
    WHERE cb.booking_status != 'cancelled'
    GROUP BY r.route_id, r.name, op.name, dp.name;
    
    -- Get all routes that have either direct or connected bookings
    INSERT INTO temp_all_routes
    SELECT DISTINCT route_id, route_name, origin_port, destination_port 
    FROM temp_direct_route_revenue
    
    UNION
    
    SELECT DISTINCT route_id, route_name, origin_port, destination_port 
    FROM temp_connected_route_revenue;
    
    -- Select the top routes with combined revenue, safely handling NULL values
    SELECT 
        r.route_id,
        r.route_name,
        r.origin_port,
        r.destination_port,
        COALESCE(d.booking_count, 0) + COALESCE(c.booking_count, 0) AS total_bookings,
        COALESCE(d.revenue, 0) + COALESCE(c.revenue, 0) AS total_revenue
    FROM temp_all_routes r
    LEFT JOIN temp_direct_route_revenue d ON r.route_id = d.route_id
    LEFT JOIN temp_connected_route_revenue c ON r.route_id = c.route_id
    ORDER BY total_revenue DESC
    LIMIT p_limit;
    
    -- Clean up temporary tables
    DROP TEMPORARY TABLE IF EXISTS temp_direct_route_revenue;
    DROP TEMPORARY TABLE IF EXISTS temp_connected_route_revenue;
    DROP TEMPORARY TABLE IF EXISTS temp_all_routes;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_all_berth_assignments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_berth_assignments`()
BEGIN
    SELECT 
        ba.assignment_id,
        ba.berth_id,
        b.berth_number,
        p.name AS port_name,
        p.country AS port_country,
        ba.arrival_time,
        ba.departure_time,
        ba.status,
        s.ship_id,
        s.name AS ship_name,
        s.owner_id,
        sc.schedule_id,
        r.name AS route_name
    FROM berth_assignments ba
    JOIN berths b ON ba.berth_id = b.berth_id
    JOIN ports p ON b.port_id = p.port_id
    JOIN ships s ON ba.ship_id = s.ship_id
    JOIN schedules sc ON ba.schedule_id = sc.schedule_id
    JOIN routes r ON sc.route_id = r.route_id
    ORDER BY ba.arrival_time DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_available_berths` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_available_berths`(
    IN p_port_id INT,
    IN p_start_time DATETIME,
    IN p_end_time DATETIME
)
BEGIN
    -- Get all berths from the specified port that are:
    -- 1. Marked as active
    -- 2. Not already booked during the requested time period
    SELECT 
        b.berth_id,
        b.berth_number,
        b.type,
        b.length,
        b.width,
        b.depth,
        b.status
    FROM 
        berths b
    WHERE 
        b.port_id = p_port_id
        AND b.status = 'active'
        AND NOT EXISTS (
            -- Check for overlapping berth assignments
            SELECT 1
            FROM berth_assignments ba
            WHERE ba.berth_id = b.berth_id
              AND ba.status = 'active'
              AND (
                  -- New booking starts during existing booking
                  (p_start_time BETWEEN ba.arrival_time AND ba.departure_time)
                  -- New booking ends during existing booking
                  OR (p_end_time BETWEEN ba.arrival_time AND ba.departure_time)
                  -- New booking completely contains existing booking
                  OR (p_start_time <= ba.arrival_time AND p_end_time >= ba.departure_time)
              )
        )
    ORDER BY 
        b.berth_number;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_booking_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_booking_details`(IN p_booking_id INT, IN p_user_id INT)
BEGIN
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        c.cargo_type,
        c.weight AS cargo_weight,
        c.dimensions AS cargo_dimensions,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        b.notes,
        ships.name AS ship_name,
        ships.ship_type
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.booking_id = p_booking_id AND b.user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_booking_price_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_booking_price_info`(
    IN p_cargo_id INT,
    IN p_schedule_id INT
)
BEGIN
    SELECT 
        r.cost_per_kg,
        c.weight,
        r.cost_per_kg * c.weight AS total_price
    FROM 
        schedules s
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        cargo c ON c.cargo_id = p_cargo_id
    WHERE 
        s.schedule_id = p_schedule_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_booking_status_counts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_booking_status_counts`(
    IN p_user_id INT
)
BEGIN
    SELECT 
        'direct' as type,
        booking_status,
        COUNT(*) as count
    FROM 
        cargo_bookings
    WHERE 
        user_id = p_user_id
    GROUP BY 
        booking_status
    
    UNION ALL
    
    SELECT 
        'connected' as type,
        booking_status,
        COUNT(*) as count
    FROM 
        connected_bookings
    WHERE 
        user_id = p_user_id
    GROUP BY 
        booking_status;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_cargo_by_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_cargo_by_type`(
    IN p_user_id INT
)
BEGIN
    SELECT 
        cargo_type, 
        COUNT(*) as count
    FROM 
        cargo
    WHERE 
        user_id = p_user_id
    GROUP BY 
        cargo_type
    ORDER BY 
        count DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_cargo_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_cargo_details`(IN p_cargo_id INT, IN p_user_id INT)
BEGIN
    SELECT 
        cargo_id, description, cargo_type, weight, dimensions
    FROM 
        cargo
    WHERE 
        cargo_id = p_cargo_id AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_cargo_details_api` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_cargo_details_api`(
    IN p_cargo_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT cargo_id, description, cargo_type, weight, dimensions
    FROM cargo
    WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_connected_booking_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_connected_booking_by_id`(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    -- Get connected booking details
    SELECT 
        cb.connected_booking_id,
        cb.cargo_id,
        c.description AS cargo_description,
        c.cargo_type,
        c.weight AS cargo_weight,
        c.dimensions AS cargo_dimensions,
        op.name AS origin_port,
        dp.name AS destination_port,
        cb.booking_status,
        cb.payment_status,
        cb.total_price,
        cb.booking_date,
        cb.notes,
        'connected' AS booking_type
    FROM 
        connected_bookings cb
    JOIN 
        cargo c ON cb.cargo_id = c.cargo_id
    JOIN 
        ports op ON cb.origin_port_id = op.port_id
    JOIN 
        ports dp ON cb.destination_port_id = dp.port_id
    WHERE 
        cb.connected_booking_id = p_booking_id AND cb.user_id = p_user_id;
    
    -- Get segment details for this connected booking
    SELECT 
        cbs.segment_id,
        cbs.segment_order,
        cbs.schedule_id,
        cbs.segment_price,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        op.port_id AS origin_port_id,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        dp.name AS destination_port,
        dp.port_id AS destination_port_id,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        r.distance,
        ships.name AS ship_name,
        ships.ship_type,
        TIMESTAMPDIFF(HOUR, 
            s.arrival_date, 
            LEAD(s.departure_date) OVER (ORDER BY cbs.segment_order)
        ) / 24 AS connection_time
    FROM 
        connected_booking_segments cbs
    JOIN 
        schedules s ON cbs.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        cbs.connected_booking_id = p_booking_id
    ORDER BY 
        cbs.segment_order;
    
    -- Get username
    SELECT username FROM users WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_connected_booking_dates` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_connected_booking_dates`(IN p_booking_id INT)
BEGIN
    SELECT 
        MIN(s.departure_date) AS first_departure,
        MAX(s.arrival_date) AS last_arrival
    FROM 
        connected_booking_segments cbs
    JOIN 
        schedules s ON cbs.schedule_id = s.schedule_id
    WHERE 
        cbs.connected_booking_id = p_booking_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_connected_booking_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_connected_booking_details`(
    IN p_schedule_ids VARCHAR(255),
    IN p_cargo_id INT,
    IN p_user_id INT
)
BEGIN
    -- Create a temporary table to store schedule IDs
    DROP TEMPORARY TABLE IF EXISTS temp_schedule_ids;
    CREATE TEMPORARY TABLE temp_schedule_ids (
        id INT AUTO_INCREMENT PRIMARY KEY,
        schedule_id INT NOT NULL
    );
    
    -- Insert schedule IDs into temporary table
    SET @sql = CONCAT("INSERT INTO temp_schedule_ids (schedule_id) VALUES ('", 
                REPLACE(p_schedule_ids, ",", "'),('"), "')");
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Get cargo details
    SELECT 
        cargo_id, description, cargo_type, weight, dimensions
    FROM 
        cargo
    WHERE 
        cargo_id = p_cargo_id AND user_id = p_user_id;
    
    -- Get segments data
    SELECT
        s.schedule_id,
        s.ship_id,
        ships.name AS ship_name,
        ships.ship_type,
        r.origin_port_id,
        op.name AS origin_port,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        r.destination_port_id,
        dp.name AS destination_port,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        s.departure_date,
        s.arrival_date,
        r.cost_per_kg,
        r.distance,
        t.id AS segment_order
    FROM
        temp_schedule_ids t
    JOIN
        schedules s ON t.schedule_id = s.schedule_id
    JOIN
        routes r ON s.route_id = r.route_id
    JOIN
        ships ON s.ship_id = ships.ship_id
    JOIN
        ports op ON r.origin_port_id = op.port_id
    JOIN
        ports dp ON r.destination_port_id = dp.port_id
    ORDER BY
        t.id;
    
    -- Get username
    SELECT username FROM users WHERE user_id = p_user_id;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS temp_schedule_ids;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_connected_booking_for_cancel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_connected_booking_for_cancel`(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT cb.cargo_id, cbs.schedule_id
    FROM connected_bookings cb
    JOIN connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
    WHERE cb.connected_booking_id = p_booking_id AND cb.user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_connected_booking_segments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_connected_booking_segments`(
    IN p_booking_id INT
)
BEGIN
    SELECT 
        cbs.segment_id,
        cbs.segment_order,
        cbs.schedule_id,
        cbs.segment_price,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        op.port_id AS origin_port_id,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        dp.name AS destination_port,
        dp.port_id AS destination_port_id,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        r.distance,
        ships.name AS ship_name,
        ships.ship_type
    FROM 
        connected_booking_segments cbs
    JOIN 
        schedules s ON cbs.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        cbs.connected_booking_id = p_booking_id
    ORDER BY 
        cbs.segment_order;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_connected_route_endpoints` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_connected_route_endpoints`(
    IN p_first_schedule_id INT,
    IN p_last_schedule_id INT
)
BEGIN
    SELECT 
        r1.origin_port_id AS origin_port_id,
        r2.destination_port_id AS destination_port_id
    FROM 
        schedules s1
    JOIN 
        routes r1 ON s1.route_id = r1.route_id
    JOIN 
        schedules s2 ON s2.schedule_id = p_last_schedule_id
    JOIN 
        routes r2 ON s2.route_id = r2.route_id
    WHERE 
        s1.schedule_id = p_first_schedule_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_connection_time` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_connection_time`(
    IN p_first_schedule_id INT,
    IN p_second_schedule_id INT
)
BEGIN
    SELECT
        TIMESTAMPDIFF(HOUR, s1.arrival_date, s2.departure_date) / 24.0
    FROM
        schedules s1, schedules s2
    WHERE
        s1.schedule_id = p_first_schedule_id AND s2.schedule_id = p_second_schedule_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_customer_cargo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_customer_cargo`(
    IN p_user_id INT,
    IN p_description VARCHAR(255),
    IN p_cargo_type VARCHAR(50),
    IN p_status VARCHAR(50)
)
BEGIN
    SELECT 
        cargo_id, 
        description, 
        cargo_type, 
        weight, 
        dimensions, 
        special_instructions, 
        status,
        created_at
    FROM cargo
    WHERE user_id = p_user_id
      AND (p_description IS NULL OR description LIKE CONCAT('%', p_description, '%'))
      AND (p_cargo_type IS NULL OR cargo_type = p_cargo_type)
      AND (p_status IS NULL OR status = p_status)
    ORDER BY created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_customer_dashboard_stats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_customer_dashboard_stats`(
    IN p_user_id INT
)
BEGIN
    -- Get cargo count
    SELECT COUNT(*) AS cargo_count FROM cargo WHERE user_id = p_user_id;
    
    -- Get active bookings count (direct bookings)
    SELECT COUNT(*) AS direct_active_bookings 
    FROM cargo_bookings 
    WHERE user_id = p_user_id AND booking_status IN ('pending', 'confirmed');
    
    -- Get active bookings count (connected bookings)
    SELECT COUNT(*) AS connected_active_bookings 
    FROM connected_bookings 
    WHERE user_id = p_user_id AND booking_status IN ('pending', 'confirmed');
    
    -- Get shipments in transit
    SELECT COUNT(*) AS in_transit_count 
    FROM cargo 
    WHERE user_id = p_user_id AND status = 'in_transit';
    
    -- Get completed shipments
    SELECT COUNT(*) AS completed_count 
    FROM cargo 
    WHERE user_id = p_user_id AND status = 'delivered';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_customer_recent_bookings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_customer_recent_bookings`(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    -- Using UNION to combine direct and connected bookings
    (SELECT 
        'direct' as type,
        b.booking_id,
        c.description as cargo_description,
        c.cargo_type,
        p1.name as origin_port,
        p2.name as destination_port,
        s.departure_date,
        NULL as first_departure,
        b.booking_status,
        b.booking_id as connected_booking_id
    FROM cargo_bookings b
    JOIN cargo c ON b.cargo_id = c.cargo_id
    JOIN schedules s ON b.schedule_id = s.schedule_id
    JOIN routes r ON s.route_id = r.route_id
    JOIN ports p1 ON r.origin_port_id = p1.port_id
    JOIN ports p2 ON r.destination_port_id = p2.port_id
    WHERE b.user_id = p_user_id)
    
    UNION ALL
    
    (SELECT 
        'connected' as type,
        cb.connected_booking_id as booking_id,
        c.description as cargo_description,
        c.cargo_type,
        p1.name as origin_port,
        p2.name as destination_port,
        NULL as departure_date,
        (SELECT MIN(s.departure_date) 
         FROM connected_booking_segments cbs
         JOIN schedules s ON cbs.schedule_id = s.schedule_id
         WHERE cbs.connected_booking_id = cb.connected_booking_id) as first_departure,
        cb.booking_status,
        cb.connected_booking_id
    FROM connected_bookings cb
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    JOIN ports p1 ON cb.origin_port_id = p1.port_id
    JOIN ports p2 ON cb.destination_port_id = p2.port_id
    WHERE cb.user_id = p_user_id)
    
    ORDER BY booking_status = 'confirmed' DESC, 
             booking_status = 'pending' DESC,
             booking_status = 'completed' DESC,
             COALESCE(departure_date, first_departure) DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_customer_upcoming_shipments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_customer_upcoming_shipments`(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    (SELECT 
        c.description as cargo_description,
        p1.name as origin_port,
        p2.name as destination_port,
        s.departure_date,
        DATEDIFF(s.departure_date, NOW()) as days_until
    FROM cargo_bookings b
    JOIN cargo c ON b.cargo_id = c.cargo_id
    JOIN schedules s ON b.schedule_id = s.schedule_id
    JOIN routes r ON s.route_id = r.route_id
    JOIN ports p1 ON r.origin_port_id = p1.port_id
    JOIN ports p2 ON r.destination_port_id = p2.port_id
    WHERE b.user_id = p_user_id AND b.booking_status = 'confirmed' 
    AND s.departure_date > CURRENT_DATE())
    
    UNION ALL
    
    (SELECT 
        c.description as cargo_description,
        p1.name as origin_port,
        p2.name as destination_port,
        (SELECT MIN(s.departure_date) 
         FROM connected_booking_segments cbs
         JOIN schedules s ON cbs.schedule_id = s.schedule_id
         WHERE cbs.connected_booking_id = cb.connected_booking_id
         AND s.departure_date > NOW()) as departure_date,
        DATEDIFF((SELECT MIN(s.departure_date) 
                  FROM connected_booking_segments cbs
                  JOIN schedules s ON cbs.schedule_id = s.schedule_id
                  WHERE cbs.connected_booking_id = cb.connected_booking_id
                  AND s.departure_date > NOW()), NOW()) as days_until
    FROM connected_bookings cb
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    JOIN ports p1 ON cb.origin_port_id = p1.port_id
    JOIN ports p2 ON cb.destination_port_id = p2.port_id
    WHERE cb.user_id = p_user_id AND cb.booking_status = 'confirmed'
    HAVING departure_date IS NOT NULL)
    
    ORDER BY days_until ASC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_direct_booking_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_direct_booking_details`(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        c.cargo_type,
        c.weight AS cargo_weight,
        c.dimensions AS cargo_dimensions,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        dp.name AS destination_port,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        r.distance,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        b.notes,
        ships.name AS ship_name,
        ships.ship_type
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.booking_id = p_booking_id AND b.user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_direct_booking_for_cancel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_direct_booking_for_cancel`(
    IN p_booking_id INT,
    IN p_user_id INT
)
BEGIN
    SELECT cargo_id, schedule_id, price
    FROM cargo_bookings
    WHERE booking_id = p_booking_id AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_filtered_schedules` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_filtered_schedules`(
    IN p_user_id INT,
    IN p_ship_name VARCHAR(100),
    IN p_port_name VARCHAR(100),
    IN p_status VARCHAR(20),
    IN p_date_from VARCHAR(20),
    IN p_date_to VARCHAR(20),
    IN p_berth_number VARCHAR(20)
)
BEGIN
    -- Build the base query with proper JOIN to berth_assignments
    SET @base_query = '
        SELECT 
            s.schedule_id,
            s.ship_id,
            ships.name AS ship_name,
            ships.ship_type AS ship_type,
            s.route_id,
            r.name AS route_name,
            op.name AS origin_port,
            dp.name AS destination_port,
            s.departure_date,
            s.arrival_date,
            s.status,
            s.max_cargo,
            s.notes,
            origin_ba.berth_id AS origin_berth_id,
            ob.berth_number AS origin_berth_number,
            ob.type AS origin_berth_type,
            origin_ba.arrival_time AS origin_berth_start,
            origin_ba.departure_time AS origin_berth_end,
            dest_ba.berth_id AS destination_berth_id,
            db.berth_number AS destination_berth_number,
            db.type AS destination_berth_type,
            dest_ba.arrival_time AS destination_berth_start,
            dest_ba.departure_time AS destination_berth_end
        FROM 
            schedules s
        JOIN 
            ships ON s.ship_id = ships.ship_id
        JOIN 
            routes r ON s.route_id = r.route_id
        JOIN 
            ports op ON r.origin_port_id = op.port_id
        JOIN 
            ports dp ON r.destination_port_id = dp.port_id
        LEFT JOIN 
            berth_assignments origin_ba ON 
                s.schedule_id = origin_ba.schedule_id AND 
                origin_ba.status = "active" AND
                EXISTS (
                    SELECT 1 FROM berths b 
                    JOIN ports p ON b.port_id = p.port_id
                    WHERE b.berth_id = origin_ba.berth_id 
                    AND p.port_id = r.origin_port_id
                )
        LEFT JOIN 
            berths ob ON origin_ba.berth_id = ob.berth_id
        LEFT JOIN 
            berth_assignments dest_ba ON 
                s.schedule_id = dest_ba.schedule_id AND 
                dest_ba.status = "active" AND
                EXISTS (
                    SELECT 1 FROM berths b 
                    JOIN ports p ON b.port_id = p.port_id
                    WHERE b.berth_id = dest_ba.berth_id 
                    AND p.port_id = r.destination_port_id
                )
        LEFT JOIN 
            berths db ON dest_ba.berth_id = db.berth_id
        WHERE 
            ships.owner_id = ?
    ';
    
    -- Initialize parameters array
    SET @params = p_user_id;
    
    -- Add filters conditionally
    IF p_ship_name IS NOT NULL AND p_ship_name != '' THEN
        SET @base_query = CONCAT(@base_query, ' AND ships.name LIKE CONCAT("%", ?, "%")');
        SET @params = CONCAT(@params, ',', QUOTE(p_ship_name));
    END IF;
    
    IF p_port_name IS NOT NULL AND p_port_name != '' THEN
        SET @base_query = CONCAT(@base_query, ' AND (op.name LIKE CONCAT("%", ?, "%") OR dp.name LIKE CONCAT("%", ?, "%"))');
        SET @params = CONCAT(@params, ',', QUOTE(p_port_name), ',', QUOTE(p_port_name));
    END IF;
    
    IF p_status IS NOT NULL AND p_status != '' THEN
        SET @base_query = CONCAT(@base_query, ' AND s.status = ?');
        SET @params = CONCAT(@params, ',', QUOTE(p_status));
    END IF;
    
    IF p_date_from IS NOT NULL AND p_date_from != '' THEN
        SET @base_query = CONCAT(@base_query, ' AND (s.departure_date >= ? OR s.arrival_date >= ?)');
        SET @params = CONCAT(@params, ',', QUOTE(p_date_from), ',', QUOTE(p_date_from));
    END IF;
    
    IF p_date_to IS NOT NULL AND p_date_to != '' THEN
        SET @base_query = CONCAT(@base_query, ' AND (s.departure_date <= ? OR s.arrival_date <= ?)');
        SET @params = CONCAT(@params, ',', QUOTE(p_date_to), ',', QUOTE(p_date_to));
    END IF;
    
    IF p_berth_number IS NOT NULL AND p_berth_number != '' THEN
        SET @base_query = CONCAT(@base_query, ' AND (ob.berth_number LIKE CONCAT("%", ?, "%") OR db.berth_number LIKE CONCAT("%", ?, "%"))');
        SET @params = CONCAT(@params, ',', QUOTE(p_berth_number), ',', QUOTE(p_berth_number));
    END IF;
    
    -- Add ordering
    SET @base_query = CONCAT(@base_query, ' ORDER BY s.departure_date DESC');
    
    -- Prepare and execute the dynamic SQL
    SET @sql = @base_query;
    
    PREPARE stmt FROM @sql;
    
    -- Convert the params string to variables for execution
    SET @p1 = p_user_id;
    SET @p_count = 1;
    
    IF p_ship_name IS NOT NULL AND p_ship_name != '' THEN
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_ship_name));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
    END IF;
    
    IF p_port_name IS NOT NULL AND p_port_name != '' THEN
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_port_name));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
        
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_port_name));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
    END IF;
    
    IF p_status IS NOT NULL AND p_status != '' THEN
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_status));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
    END IF;
    
    IF p_date_from IS NOT NULL AND p_date_from != '' THEN
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_date_from));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
        
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_date_from));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
    END IF;
    
    IF p_date_to IS NOT NULL AND p_date_to != '' THEN
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_date_to));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
        
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_date_to));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
    END IF;
    
    IF p_berth_number IS NOT NULL AND p_berth_number != '' THEN
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_berth_number));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
        
        SET @p_count = @p_count + 1;
        SET @sql_set = CONCAT('SET @p', @p_count, ' = ', QUOTE(p_berth_number));
        PREPARE set_stmt FROM @sql_set;
        EXECUTE set_stmt;
        DEALLOCATE PREPARE set_stmt;
    END IF;
    
    -- Create the EXECUTE statement dynamically
    SET @execute_str = 'EXECUTE stmt USING @p1';
    
    IF @p_count > 1 THEN
        SET @counter = 2;
        WHILE @counter <= @p_count DO
            SET @execute_str = CONCAT(@execute_str, ', @p', @counter);
            SET @counter = @counter + 1;
        END WHILE;
    END IF;
    
    -- Execute the dynamic EXECUTE statement
    PREPARE exec_stmt FROM @execute_str;
    EXECUTE exec_stmt;
    
    -- Cleanup
    DEALLOCATE PREPARE stmt;
    DEALLOCATE PREPARE exec_stmt;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_monthly_shipping_activity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_shipping_activity`(
    IN p_user_id INT,
    IN p_days_back INT
)
BEGIN
    -- Calculate start date
    SET @start_date = DATE_SUB(CURDATE(), INTERVAL p_days_back DAY);
    
    SELECT 
        DATE_FORMAT(booking_date, '%Y-%m') as month,
        COUNT(*) as booking_count,
        SUM(c.weight) as total_weight
    FROM 
        (
            SELECT 
                cb.booking_date,
                cb.cargo_id
            FROM 
                cargo_bookings cb
            WHERE 
                cb.user_id = p_user_id AND
                cb.booking_date >= @start_date
                
            UNION ALL
            
            SELECT 
                cnb.booking_date,
                cnb.cargo_id
            FROM 
                connected_bookings cnb
            WHERE 
                cnb.user_id = p_user_id AND
                cnb.booking_date >= @start_date
        ) as bookings
    JOIN 
        cargo c ON bookings.cargo_id = c.cargo_id
    GROUP BY 
        DATE_FORMAT(booking_date, '%Y-%m')
    ORDER BY 
        month;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_monthly_shipping_revenue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_shipping_revenue`(
    IN p_user_id INT,
    IN p_days_back INT
)
BEGIN
    -- Calculate start date
    SET @start_date = DATE_SUB(CURDATE(), INTERVAL p_days_back DAY);
    
    -- Create temporary table to hold combined revenue data
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_monthly_revenue (
        month VARCHAR(7),
        booking_count INT,
        total_revenue DOUBLE  -- Change from DECIMAL to DOUBLE for JSON compatibility
    );
    
    -- Insert direct booking revenue
    INSERT INTO temp_monthly_revenue
    SELECT 
        DATE_FORMAT(cb.booking_date, '%Y-%m') as month,
        COUNT(*) as booking_count,
        SUM(cb.price) as total_revenue
    FROM cargo_bookings cb
    JOIN schedules s ON cb.schedule_id = s.schedule_id
    JOIN ships sh ON s.ship_id = sh.ship_id
    WHERE sh.owner_id = p_user_id
      AND cb.booking_date >= @start_date
      AND cb.booking_status != 'cancelled'
    GROUP BY month;
    
    -- Insert connected booking segment revenue
    INSERT INTO temp_monthly_revenue
    SELECT 
        DATE_FORMAT(cb.booking_date, '%Y-%m') as month,
        COUNT(DISTINCT cb.connected_booking_id) as booking_count,
        SUM(cbs.segment_price) as total_revenue
    FROM connected_booking_segments cbs
    JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
    JOIN schedules s ON cbs.schedule_id = s.schedule_id
    JOIN ships sh ON s.ship_id = sh.ship_id
    WHERE sh.owner_id = p_user_id
      AND cb.booking_date >= @start_date
      AND cb.booking_status != 'cancelled'
    GROUP BY month;
    
    -- Return aggregated results
    SELECT 
        month,
        SUM(booking_count) as booking_count,
        SUM(total_revenue) as total_revenue
    FROM temp_monthly_revenue
    GROUP BY month
    ORDER BY month;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS temp_monthly_revenue;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_popular_shipping_routes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_popular_shipping_routes`(
    IN p_limit INT
)
BEGIN
    SELECT 
        r.route_id,
        op.port_id as origin_id,
        dp.port_id as destination_id,
        op.name as origin_port,
        dp.name as destination_port,
        r.duration,
        COUNT(DISTINCT s.ship_id) as available_ships,
        AVG(r.cost_per_kg) as avg_cost_per_kg
    FROM 
        routes r
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    LEFT JOIN 
        schedules s ON r.route_id = s.route_id AND 
                       s.departure_date > NOW() AND
                       s.status = 'scheduled'
    WHERE 
        r.status = 'active'
    GROUP BY 
        r.route_id, op.name, dp.name, r.duration
    ORDER BY 
        COUNT(DISTINCT s.schedule_id) DESC, 
        AVG(r.cost_per_kg) ASC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_revenue_by_route` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_revenue_by_route`(
    IN p_user_id INT
)
BEGIN
    SELECT 
        r.name,
        (
            /* Revenue from direct bookings */
            (SELECT COALESCE(SUM(cb.price), 0)
             FROM schedules s
             JOIN cargo_bookings cb ON s.schedule_id = cb.schedule_id
             WHERE s.route_id = r.route_id
               AND cb.booking_status != 'cancelled')
            +
            /* Revenue from connected booking segments */
            (SELECT COALESCE(SUM(cbs.segment_price), 0)
             FROM schedules s
             JOIN connected_booking_segments cbs ON s.schedule_id = cbs.schedule_id
             JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
             WHERE s.route_id = r.route_id
               AND cb.booking_status != 'cancelled')
        ) AS total_revenue
    FROM routes r
    WHERE r.owner_id = p_user_id
      AND r.status = 'active'
    HAVING total_revenue > 0
    ORDER BY total_revenue DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_route_segment_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_route_segment_details`(IN p_schedule_id INT)
BEGIN
    SELECT
        s.schedule_id,
        s.ship_id,
        ships.name AS ship_name,
        ships.ship_type,
        r.origin_port_id,
        op.name AS origin_port,
        ST_Y(op.location) AS origin_lat,
        ST_X(op.location) AS origin_lng,
        r.destination_port_id,
        dp.name AS destination_port,
        ST_Y(dp.location) AS destination_lat,
        ST_X(dp.location) AS destination_lng,
        s.departure_date,
        s.arrival_date,
        TIMESTAMPDIFF(DAY, s.departure_date, s.arrival_date) AS duration
    FROM
        schedules s
    JOIN
        routes r ON s.route_id = r.route_id
    JOIN
        ships ON s.ship_id = ships.ship_id
    JOIN
        ports op ON r.origin_port_id = op.port_id
    JOIN
        ports dp ON r.destination_port_id = dp.port_id
    WHERE
        s.schedule_id = p_schedule_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_schedule_berth_assignments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_schedule_berth_assignments`(
    IN p_schedule_id INT
)
BEGIN
    SELECT 
        ba.assignment_id,
        ba.berth_id,
        b.berth_number,
        p.name AS port_name,
        ba.ship_id,
        s.name AS ship_name,
        ba.arrival_time,
        ba.departure_time,
        ba.status AS assignment_status,
        CASE
            WHEN ba.status = 'inactive' THEN 'cancelled'
            WHEN NOW() < ba.arrival_time THEN 'scheduled'
            WHEN NOW() BETWEEN ba.arrival_time AND ba.departure_time THEN 'current'
            ELSE 'completed'
        END AS operational_status
    FROM 
        berth_assignments ba
    JOIN 
        berths b ON ba.berth_id = b.berth_id
    JOIN 
        ports p ON b.port_id = p.port_id
    JOIN 
        ships s ON ba.ship_id = s.ship_id
    WHERE 
        ba.schedule_id = p_schedule_id
    ORDER BY 
        ba.arrival_time;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_schedule_data` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_schedule_data`(
    IN p_user_id INT,
    IN p_ship_name VARCHAR(100),
    IN p_port_name VARCHAR(100),
    IN p_status VARCHAR(20),
    IN p_date_from VARCHAR(20),
    IN p_date_to VARCHAR(20),
    IN p_berth_number VARCHAR(20)
)
BEGIN
    SET @ship_filter = CASE WHEN p_ship_name = '' THEN '' ELSE CONCAT('%', p_ship_name, '%') END;
    SET @port_filter = CASE WHEN p_port_name = '' THEN '' ELSE CONCAT('%', p_port_name, '%') END;
    SET @berth_filter = CASE WHEN p_berth_number = '' THEN '' ELSE CONCAT('%', p_berth_number, '%') END;
    SET @date_from_filter = CASE WHEN p_date_from = '' THEN NULL ELSE STR_TO_DATE(p_date_from, '%Y-%m-%d') END;
    SET @date_to_filter = CASE WHEN p_date_to = '' THEN NULL ELSE STR_TO_DATE(CONCAT(p_date_to, ' 23:59:59'), '%Y-%m-%d %H:%i:%s') END;

    SELECT 
        s.schedule_id,
        s.ship_id,
        ships.name AS ship_name,
        ships.ship_type,
        s.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        s.departure_date,
        s.arrival_date,
        s.status,
        s.max_cargo,
        s.notes,
        MAX(origin_ba.berth_id) AS origin_berth_id,
        MAX(ob.berth_number) AS origin_berth_number,
        MAX(ob.type) AS origin_berth_type,
        MAX(origin_ba.arrival_time) AS origin_berth_start,
        MAX(origin_ba.departure_time) AS origin_berth_end,
        MAX(dest_ba.berth_id) AS destination_berth_id,
        MAX(db.berth_number) AS destination_berth_number,
        MAX(db.type) AS destination_berth_type,
        MAX(dest_ba.arrival_time) AS destination_berth_start,
        MAX(dest_ba.departure_time) AS destination_berth_end
    FROM 
        schedules s
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    LEFT JOIN 
        berth_assignments origin_ba ON s.schedule_id = origin_ba.schedule_id 
        AND origin_ba.status = 'active'
    LEFT JOIN 
        berths ob ON origin_ba.berth_id = ob.berth_id AND ob.port_id = r.origin_port_id
    LEFT JOIN 
        berth_assignments dest_ba ON s.schedule_id = dest_ba.schedule_id 
        AND dest_ba.status = 'active'
    LEFT JOIN 
        berths db ON dest_ba.berth_id = db.berth_id AND db.port_id = r.destination_port_id
    WHERE 
        ships.owner_id = p_user_id
        AND (p_ship_name = '' OR ships.name LIKE @ship_filter)
        AND (p_port_name = '' OR op.name LIKE @port_filter OR dp.name LIKE @port_filter)
        AND (p_status = '' OR s.status = p_status)
        AND (p_date_from = '' OR s.departure_date >= @date_from_filter OR s.arrival_date >= @date_from_filter)
        AND (p_date_to = '' OR s.departure_date <= @date_to_filter OR s.arrival_date <= @date_to_filter)
        AND (p_berth_number = '' OR ob.berth_number LIKE @berth_filter OR db.berth_number LIKE @berth_filter)
    GROUP BY 
        s.schedule_id, s.ship_id, ships.name, ships.ship_type, s.route_id, 
        r.name, op.name, dp.name, s.departure_date, s.arrival_date, 
        s.status, s.max_cargo, s.notes
    ORDER BY 
        s.departure_date DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_schedule_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_schedule_details`(IN p_schedule_id INT)
BEGIN
    SELECT 
        s.schedule_id,
        s.ship_id,
        ships.name AS ship_name,
        ships.ship_type,
        r.route_id,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        s.departure_date,
        s.arrival_date,
        r.cost_per_kg,
        r.distance
    FROM 
        schedules s
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        s.schedule_id = p_schedule_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_schedule_status_counts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_schedule_status_counts`(
    IN p_user_id INT
)
BEGIN
    SELECT s.status, COUNT(*) 
    FROM schedules s
    JOIN ships ON s.ship_id = ships.ship_id
    WHERE ships.owner_id = p_user_id
    GROUP BY s.status;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_shipowner_dashboard_stats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_shipowner_dashboard_stats`(
    IN p_user_id INT
)
BEGIN
    -- Get total ships count
    SELECT COUNT(*) AS ship_count 
    FROM ships 
    WHERE owner_id = p_user_id AND status != 'deleted';
    
    -- Get active routes count
    SELECT COUNT(*) AS active_routes 
    FROM routes 
    WHERE owner_id = p_user_id AND status = 'active';
    
    -- Get scheduled voyages count
    SELECT COUNT(*) AS scheduled_voyages 
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    WHERE sh.owner_id = p_user_id AND s.status = 'scheduled';
    
    -- Get in-transit voyages count
    SELECT COUNT(*) AS in_transit_voyages 
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    WHERE sh.owner_id = p_user_id AND s.status = 'in_progress';
    
    -- Get total revenue (from direct AND connected bookings)
    SELECT (
        -- Revenue from direct bookings
        (SELECT COALESCE(SUM(cb.price), 0)
        FROM cargo_bookings cb
        JOIN schedules s ON cb.schedule_id = s.schedule_id
        JOIN ships sh ON s.ship_id = sh.ship_id
        WHERE sh.owner_id = p_user_id 
          AND cb.booking_status != 'cancelled'
          AND cb.payment_status = 'paid')
        +
        -- Revenue from connected bookings
        (SELECT COALESCE(SUM(cbs.segment_price), 0)
        FROM connected_booking_segments cbs
        JOIN schedules s ON cbs.schedule_id = s.schedule_id
        JOIN ships sh ON s.ship_id = sh.ship_id
        JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
        WHERE sh.owner_id = p_user_id
          AND cb.booking_status != 'cancelled'
          AND cb.payment_status = 'paid')
    ) AS total_revenue;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_shipowner_recent_bookings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_shipowner_recent_bookings`(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    -- Combine direct and connected bookings in a UNION query
    (SELECT 
        'direct' AS booking_type,
        cb.booking_id AS id,
        s.schedule_id,
        sh.name AS ship_name,
        r.name AS route_name,
        u.username AS customer_name,
        c.description AS cargo_description,
        cb.booking_status,
        cb.price AS revenue,
        cb.booking_date
    FROM cargo_bookings cb
    JOIN schedules s ON cb.schedule_id = s.schedule_id
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    WHERE sh.owner_id = p_user_id)
    
    UNION ALL
    
    (SELECT 
        'connected' AS booking_type,
        cb.connected_booking_id AS id,
        cbs.schedule_id,
        sh.name AS ship_name,
        r.name AS route_name,
        u.username AS customer_name,
        c.description AS cargo_description,
        cb.booking_status,
        cbs.segment_price AS revenue,
        cb.booking_date
    FROM connected_booking_segments cbs
    JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
    JOIN schedules s ON cbs.schedule_id = s.schedule_id
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    JOIN users u ON cb.user_id = u.user_id
    JOIN cargo c ON cb.cargo_id = c.cargo_id
    WHERE sh.owner_id = p_user_id)
    
    ORDER BY booking_date DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_shipowner_upcoming_voyages` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_shipowner_upcoming_voyages`(
    IN p_user_id INT,
    IN p_limit INT
)
BEGIN
    SELECT 
        s.schedule_id,
        sh.name AS ship_name, 
        r.name AS route_name,
        s.departure_date,
        s.arrival_date,
        s.status,
        -- Count bookings for this schedule (both direct and connected)
        (
            (SELECT COUNT(*) FROM cargo_bookings 
             WHERE schedule_id = s.schedule_id AND booking_status != 'cancelled')
            +
            (SELECT COUNT(*) FROM connected_booking_segments cbs
             JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
             WHERE cbs.schedule_id = s.schedule_id AND cb.booking_status != 'cancelled')
        ) AS booking_count,
        -- Calculate utilization percentage
        ROUND(
            COALESCE(
                (
                    -- Get weight from direct bookings
                    (SELECT COALESCE(SUM(c.weight), 0) 
                     FROM cargo_bookings cb
                     JOIN cargo c ON cb.cargo_id = c.cargo_id 
                     WHERE cb.schedule_id = s.schedule_id AND cb.booking_status != 'cancelled')
                    +
                    -- Get weight from connected bookings
                    (SELECT COALESCE(SUM(c.weight), 0) 
                     FROM connected_booking_segments cbs
                     JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
                     JOIN cargo c ON cb.cargo_id = c.cargo_id 
                     WHERE cbs.schedule_id = s.schedule_id AND cb.booking_status != 'cancelled')
                ) / NULLIF(s.max_cargo, 0) * 100,
            0)
        ) AS utilization_percent
    FROM schedules s
    JOIN ships sh ON s.ship_id = sh.ship_id
    JOIN routes r ON s.route_id = r.route_id
    WHERE sh.owner_id = p_user_id
      AND s.status IN ('scheduled', 'in_progress')  
      AND s.departure_date >= CURRENT_DATE()
    ORDER BY s.departure_date ASC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_ship_berth_assignments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_ship_berth_assignments`(
    IN p_ship_id INT
)
BEGIN
    SELECT 
        ba.assignment_id,
        ba.berth_id,
        b.berth_number,
        p.name AS port_name,
        p.country AS port_country,
        ba.arrival_time,
        ba.departure_time,
        ba.status,
        s.ship_id,
        s.name AS ship_name,
        sc.schedule_id,
        r.name AS route_name
    FROM berth_assignments ba
    JOIN berths b ON ba.berth_id = b.berth_id
    JOIN ports p ON b.port_id = p.port_id
    JOIN ships s ON ba.ship_id = s.ship_id
    JOIN schedules sc ON ba.schedule_id = sc.schedule_id
    JOIN routes r ON sc.route_id = r.route_id
    WHERE ba.ship_id = p_ship_id
    ORDER BY ba.arrival_time DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_ship_utilization` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_ship_utilization`(
    IN p_user_id INT
)
BEGIN
    SELECT 
        sh.name,
        COALESCE(
            ROUND(
                (
                    /* Calculate total weight from direct bookings */
                    (SELECT COALESCE(SUM(c.weight), 0) 
                     FROM cargo_bookings cb
                     JOIN cargo c ON cb.cargo_id = c.cargo_id 
                     JOIN schedules s ON cb.schedule_id = s.schedule_id
                     WHERE s.ship_id = sh.ship_id 
                       AND cb.booking_status != 'cancelled'
                       AND s.status IN ('scheduled', 'in_progress'))
                    +
                    /* Add weight from connected bookings */
                    (SELECT COALESCE(SUM(c.weight), 0)
                     FROM connected_booking_segments cbs
                     JOIN connected_bookings cb ON cbs.connected_booking_id = cb.connected_booking_id
                     JOIN cargo c ON cb.cargo_id = c.cargo_id
                     JOIN schedules s ON cbs.schedule_id = s.schedule_id
                     WHERE s.ship_id = sh.ship_id
                       AND cb.booking_status != 'cancelled'
                       AND s.status IN ('scheduled', 'in_progress'))
                ) / 
                /* Divide by total capacity */
                (SELECT COALESCE(SUM(s.max_cargo), 1) 
                 FROM schedules s 
                 WHERE s.ship_id = sh.ship_id 
                   AND s.status IN ('scheduled', 'in_progress')) * 100,
            0)
        ) AS utilization_percent
    FROM ships sh
    WHERE sh.owner_id = p_user_id
      AND sh.status != 'deleted'
      AND EXISTS (
          SELECT 1 FROM schedules s 
          WHERE s.ship_id = sh.ship_id 
            AND s.status IN ('scheduled', 'in_progress')
      )
    ORDER BY utilization_percent DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_bookings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_bookings`(
    IN p_user_id INT
)
BEGIN
    -- Get direct bookings
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        ships.name AS ship_name,
        'direct' AS booking_type
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.user_id = p_user_id
    ORDER BY 
        b.booking_date DESC;
    
    -- Get connected bookings
    SELECT 
        cb.connected_booking_id AS booking_id,
        cb.cargo_id,
        c.description AS cargo_description,
        op.name AS origin_port,
        dp.name AS destination_port,
        cb.booking_status,
        cb.payment_status,
        cb.total_price AS price,
        cb.booking_date,
        COUNT(cbs.segment_id) AS total_segments,
        'connected' AS booking_type,
        MIN(s.departure_date) AS first_departure,
        MAX(s.arrival_date) AS last_arrival
    FROM 
        connected_bookings cb
    JOIN 
        cargo c ON cb.cargo_id = c.cargo_id
    JOIN 
        ports op ON cb.origin_port_id = op.port_id
    JOIN 
        ports dp ON cb.destination_port_id = dp.port_id
    JOIN 
        connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
    JOIN
        schedules s ON cbs.schedule_id = s.schedule_id
    WHERE 
        cb.user_id = p_user_id
    GROUP BY 
        cb.connected_booking_id, cb.cargo_id, c.description, op.name, dp.name,
        cb.booking_status, cb.payment_status, cb.total_price, cb.booking_date
    ORDER BY 
        cb.booking_date DESC;
    
    -- Get username
    SELECT username FROM users WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_cargo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_cargo`(IN p_user_id INT)
BEGIN
    SELECT cargo_id, description, cargo_type, weight, dimensions 
    FROM cargo 
    WHERE user_id = p_user_id
    AND status IN ('pending', 'booked')
    ORDER BY created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_connected_bookings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_connected_bookings`(IN p_user_id INT)
BEGIN
    SELECT 
        cb.connected_booking_id,
        cb.cargo_id,
        c.description AS cargo_description,
        op.name AS origin_port,
        dp.name AS destination_port,
        cb.booking_status,
        cb.payment_status,
        cb.total_price,
        cb.booking_date,
        COUNT(cbs.segment_id) AS total_segments
    FROM 
        connected_bookings cb
    JOIN 
        cargo c ON cb.cargo_id = c.cargo_id
    JOIN 
        ports op ON cb.origin_port_id = op.port_id
    JOIN 
        ports dp ON cb.destination_port_id = dp.port_id
    JOIN 
        connected_booking_segments cbs ON cb.connected_booking_id = cbs.connected_booking_id
    WHERE 
        cb.user_id = p_user_id
    GROUP BY 
        cb.connected_booking_id
    ORDER BY 
        cb.booking_date DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_direct_bookings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_direct_bookings`(IN p_user_id INT)
BEGIN
    SELECT 
        b.booking_id,
        b.cargo_id,
        c.description AS cargo_description,
        b.schedule_id,
        s.departure_date,
        s.arrival_date,
        r.name AS route_name,
        op.name AS origin_port,
        dp.name AS destination_port,
        b.booking_status,
        b.payment_status,
        b.price,
        b.booking_date,
        ships.name AS ship_name
    FROM 
        cargo_bookings b
    JOIN 
        cargo c ON b.cargo_id = c.cargo_id
    JOIN 
        schedules s ON b.schedule_id = s.schedule_id
    JOIN 
        routes r ON s.route_id = r.route_id
    JOIN 
        ships ON s.ship_id = ships.ship_id
    JOIN 
        ports op ON r.origin_port_id = op.port_id
    JOIN 
        ports dp ON r.destination_port_id = dp.port_id
    WHERE 
        b.user_id = p_user_id
    ORDER BY 
        b.booking_date DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_username` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_username`(IN p_user_id INT)
BEGIN
    SELECT username FROM users WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `restore_schedule_capacity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `restore_schedule_capacity`(
    IN p_schedule_id INT,
    IN p_cargo_weight DECIMAL(10,2)
)
BEGIN
    UPDATE schedules
    SET max_cargo = max_cargo + p_cargo_weight
    WHERE schedule_id = p_schedule_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_cargo_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_cargo_status`(
    IN p_cargo_id INT,
    IN p_user_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE cargo 
    SET status = p_status
    WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_customer_cargo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_customer_cargo`(
    IN p_cargo_id INT,
    IN p_user_id INT,
    IN p_description VARCHAR(255),
    IN p_cargo_type VARCHAR(50),
    IN p_weight DECIMAL(10,2),
    IN p_dimensions VARCHAR(100),
    IN p_special_instructions TEXT
)
BEGIN
    DECLARE cargo_exists INT;
    DECLARE update_allowed INT;
    
    -- Check if cargo exists and belongs to the user
    SELECT COUNT(*) INTO cargo_exists
    FROM cargo
    WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
    
    -- Check if cargo is in a state that allows updates
    SELECT COUNT(*) INTO update_allowed
    FROM cargo
    WHERE cargo_id = p_cargo_id 
      AND user_id = p_user_id
      AND (status = 'pending' OR status = 'booked');
    
    -- Only update if cargo exists, belongs to the user, and is in an updatable state
    IF cargo_exists > 0 AND update_allowed > 0 THEN
        UPDATE cargo 
        SET description = p_description,
            cargo_type = p_cargo_type,
            weight = p_weight,
            dimensions = p_dimensions,
            special_instructions = p_special_instructions
        WHERE cargo_id = p_cargo_id AND user_id = p_user_id;
        
        -- Return success code
        SELECT 1 AS status;
    ELSE
        -- Return failure code
        SELECT 0 AS status;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_schedule_status_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_schedule_status_proc`(
    IN p_schedule_id INT,
    IN p_new_status VARCHAR(20),
    IN p_reason TEXT,
    IN p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_ship_id INT;
    DECLARE v_owner_id INT;
    DECLARE v_origin_berth_id INT;
    DECLARE v_destination_berth_id INT;
    DECLARE logs_table_exists INT;
    
    -- First, verify that the schedule belongs to the user's ships
    SELECT s.ship_id, ships.owner_id 
    INTO v_ship_id, v_owner_id
    FROM schedules s
    JOIN ships ON s.ship_id = ships.ship_id
    WHERE s.schedule_id = p_schedule_id;
    
    IF v_owner_id IS NULL OR v_owner_id != p_user_id THEN
        SET p_success = FALSE;
        SET p_message = 'You do not have permission to update this schedule';
    ELSE
        -- Start transaction
        START TRANSACTION;
        
        -- Get berth IDs from assignments
        SELECT origin_ba.berth_id, dest_ba.berth_id
        INTO v_origin_berth_id, v_destination_berth_id
        FROM schedules s
        JOIN routes r ON s.route_id = r.route_id
        LEFT JOIN berth_assignments origin_ba ON 
            s.schedule_id = origin_ba.schedule_id AND 
            origin_ba.status = 'active' AND
            EXISTS (
                SELECT 1 FROM berths b 
                JOIN ports p ON b.port_id = p.port_id
                WHERE b.berth_id = origin_ba.berth_id 
                AND p.port_id = r.origin_port_id
            )
        LEFT JOIN berth_assignments dest_ba ON 
            s.schedule_id = dest_ba.schedule_id AND 
            dest_ba.status = 'active' AND
            EXISTS (
                SELECT 1 FROM berths b 
                JOIN ports p ON b.port_id = p.port_id
                WHERE b.berth_id = dest_ba.berth_id 
                AND p.port_id = r.destination_port_id
            )
        WHERE s.schedule_id = p_schedule_id;

        -- Update schedule status
        UPDATE schedules 
        SET status = p_new_status 
        WHERE schedule_id = p_schedule_id;

        -- Check if the status logs table exists
        SELECT COUNT(*) INTO logs_table_exists
        FROM information_schema.tables 
        WHERE table_schema = DATABASE() 
        AND table_name = 'schedule_status_logs';
        
        -- Log status change if logs table exists
        IF logs_table_exists > 0 THEN
            INSERT INTO schedule_status_logs 
            (schedule_id, old_status, new_status, reason, changed_by, changed_at)
            SELECT s.schedule_id, s.status, p_new_status, p_reason, p_user_id, NOW()
            FROM schedules s
            WHERE s.schedule_id = p_schedule_id;
        END IF;

        -- Handle status-specific operations
        IF p_new_status = 'completed' THEN
            -- Update destination berth if assigned
            IF v_destination_berth_id IS NOT NULL THEN
                UPDATE berths 
                SET status = 'active'
                WHERE berth_id = v_destination_berth_id AND status = 'occupied';
                
                -- Update berth assignment status
                UPDATE berth_assignments
                SET status = 'inactive'
                WHERE berth_id = v_destination_berth_id 
                AND schedule_id = p_schedule_id;
            END IF;
            
            -- Update ship status
            UPDATE ships 
            SET status = 'docked', 
                current_port_id = (
                    SELECT r.destination_port_id 
                    FROM schedules s
                    JOIN routes r ON s.route_id = r.route_id
                    WHERE s.schedule_id = p_schedule_id
                )
            WHERE ship_id = v_ship_id;
            
        ELSEIF p_new_status = 'in_progress' THEN
            -- Update origin berth if assigned
            IF v_origin_berth_id IS NOT NULL THEN
                UPDATE berths 
                SET status = 'active'
                WHERE berth_id = v_origin_berth_id AND status = 'occupied';
                
                -- Update berth assignment status
                UPDATE berth_assignments
                SET status = 'inactive'
                WHERE berth_id = v_origin_berth_id 
                AND schedule_id = p_schedule_id;
            END IF;
            
            -- Update ship status
            UPDATE ships 
            SET status = 'in_transit', 
                current_port_id = NULL
            WHERE ship_id = v_ship_id;
            
        ELSEIF p_new_status = 'cancelled' THEN
            -- Free both berths if assigned
            IF v_origin_berth_id IS NOT NULL THEN
                UPDATE berths 
                SET status = 'active'
                WHERE berth_id = v_origin_berth_id AND status IN ('occupied', 'reserved');
                
                -- Update berth assignment status
                UPDATE berth_assignments
                SET status = 'inactive'
                WHERE berth_id = v_origin_berth_id 
                AND schedule_id = p_schedule_id;
            END IF;
            
            IF v_destination_berth_id IS NOT NULL THEN
                UPDATE berths 
                SET status = 'active'
                WHERE berth_id = v_destination_berth_id AND status IN ('occupied', 'reserved');
                
                -- Update berth assignment status
                UPDATE berth_assignments
                SET status = 'inactive'
                WHERE berth_id = v_destination_berth_id 
                AND schedule_id = p_schedule_id;
            END IF;
        END IF;
        
        COMMIT;
        
        SET p_success = TRUE;
        SET p_message = CONCAT('Schedule status updated to ', p_new_status);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-18  1:17:50
