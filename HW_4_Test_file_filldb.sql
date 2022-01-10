-- MariaDB dump 10.19  Distrib 10.5.12-MariaDB, for Linux (x86_64)
--
-- Host: mysql.hostinger.ro    Database: u574849695_22
-- ------------------------------------------------------
-- Server version	10.5.12-MariaDB-cll-lve

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Test`
--

DROP TABLE IF EXISTS `Test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Test` (
  `id` int(9) unsigned NOT NULL AUTO_INCREMENT,
  `firstname` varchar(100) NOT NULL,
  `lastname` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Test`
--

LOCK TABLES `Test` WRITE;
/*!40000 ALTER TABLE `Test` DISABLE KEYS */;
INSERT INTO `Test` VALUES (1,'Virgil','Pouros'),(2,'Rebekah','Toy'),(3,'Luigi','Mills'),(4,'Linda','Zemlak'),(5,'Leila','Walker'),(6,'Tara','Walker'),(7,'Hildegard','Kuhn'),(8,'Lavern','D\'Amore'),(9,'Dante','Casper'),(10,'Daphne','Lueilwitz'),(11,'Emelie','Yundt'),(12,'Dayne','Hamill'),(13,'Malika','Wiza'),(14,'Brayan','Abernathy'),(15,'Sigrid','Tillman'),(16,'Mortimer','Klocko'),(17,'Philip','Turner'),(18,'Maurice','DuBuque'),(19,'Celia','Crooks'),(20,'Dudley','Erdman'),(21,'Ephraim','Dach'),(22,'Wilbert','O\'Keefe'),(23,'Pasquale','Ward'),(24,'Kareem','Adams'),(25,'Leora','Hodkiewicz'),(26,'Hassie','Bayer'),(27,'Shanel','Mayert'),(28,'Theo','O\'Hara'),(29,'Billie','Satterfield'),(30,'Dashawn','McLaughlin'),(31,'Myrtie','Kshlerin'),(32,'Axel','Pfannerstill'),(33,'Jamir','Bergnaum'),(34,'Katlynn','Reichel'),(35,'Gia','Witting'),(36,'Gardner','Mante'),(37,'Arvel','Dibbert'),(38,'Rhianna','Altenwerth'),(39,'Reynold','Schultz'),(40,'Kris','Rowe'),(41,'Roscoe','Smitham'),(42,'Bryce','Cartwright'),(43,'Tony','Homenick'),(44,'Laney','Johnson'),(45,'Clair','Upton'),(46,'Johnson','Lakin'),(47,'Candido','Nikolaus'),(48,'Melvina','Buckridge'),(49,'Roy','Tillman'),(50,'Beaulah','Mayer'),(51,'Ken','Veum'),(52,'Cecil','Mann'),(53,'Forest','Feil'),(54,'Nya','Gulgowski'),(55,'Yadira','Strosin'),(56,'Caroline','Hilll'),(57,'Sadye','Walter'),(58,'Reta','Ankunding'),(59,'Zander','Gerhold'),(60,'Myrl','Gleason'),(61,'Kiara','Emmerich'),(62,'Brielle','Boehm'),(63,'Pete','Quigley'),(64,'Marvin','Ferry'),(65,'Eddie','Stamm'),(66,'Velma','Hermann'),(67,'Dannie','Mitchell'),(68,'Justyn','Rippin'),(69,'Ned','Fisher'),(70,'Rene','Rosenbaum'),(71,'Abby','Kub'),(72,'Julian','Klocko'),(73,'Colin','Bartoletti'),(74,'Ottis','Ruecker'),(75,'Buster','Streich'),(76,'Ismael','Mante'),(77,'Dolly','Weissnat'),(78,'Madonna','Wyman'),(79,'Telly','Block'),(80,'Vallie','Spencer'),(81,'Destiney','Ankunding'),(82,'Dwight','Nikolaus'),(83,'Serena','Morissette'),(84,'Garret','Pfeffer'),(85,'Madison','McKenzie'),(86,'Laron','Murphy'),(87,'Providenci','Morissette'),(88,'Solon','Rath'),(89,'Jennie','Heathcote'),(90,'Rubie','Spinka'),(91,'Orie','Ondricka'),(92,'Lloyd','Gorczany'),(93,'Gerry','Gusikowski'),(94,'Briana','Gusikowski'),(95,'Arch','Anderson'),(96,'Chet','Crist'),(97,'Ally','Stehr'),(98,'Yoshiko','Kuphal'),(99,'Gwendolyn','Satterfield'),(100,'Michelle','Runte');
/*!40000 ALTER TABLE `Test` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-11-01 14:57:42
