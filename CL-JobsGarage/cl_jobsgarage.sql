CREATE TABLE IF NOT EXISTS `cl_jobsgarage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `station` varchar(50) DEFAULT NULL,
  `vehicle` varchar(50) DEFAULT NULL,
  `mods` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`mods`)),
  `vehicleinfo` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`vehicleinfo`)),
  `status` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `CITIZENID` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
