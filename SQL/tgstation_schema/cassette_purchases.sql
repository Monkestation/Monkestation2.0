CREATE TABLE IF NOT EXISTS `SS13_cassette_purchases` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `cassette_id` VARCHAR(32) NOT NULL,
  `cassette_name` VARCHAR(64) NOT NULL,
  `buyer_ckey` VARCHAR(32),
  `purchase_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `server_id` VARCHAR(50),
  PRIMARY KEY (`id`),
  KEY `idx_cassette_id` (`cassette_id`),
  KEY `idx_purchase_date` (`purchase_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
