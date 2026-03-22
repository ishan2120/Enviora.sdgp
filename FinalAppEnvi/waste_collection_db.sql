-- ============================================================
--  CLEANTECH (PVT) LIMITED - DISTRICT 05
--  Solid Waste Collection Route Plan Database
--  Hotline: 011-2368768 (24 hrs service)
--
--  Municipal Wards:
--    Bambalapitiya | Milagiriya | Havelock Town
--    Wellawatta North | Wellawatta South | Pamankada West
--
--  Contact Officers:
--    Senior Operations Manager : Mr. H.M.S.S.Abeyratne  - 0717345017
--    Operations Manager        : Mr. M.P.J.Seneviratne  - 0717785698
--    Area Manager              : Mr. U.S.D Hettiarachchi - 0717345023
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

-- ============================================================
-- CREATE DATABASE
-- ============================================================
CREATE DATABASE IF NOT EXISTS `cleantech_district05`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `cleantech_district05`;

-- ============================================================
-- TABLE: wards
-- Municipal ward / area name
-- ============================================================
DROP TABLE IF EXISTS `wards`;
CREATE TABLE `wards` (
  `id`            TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ward_name`     VARCHAR(100)     NOT NULL,
  `district`      VARCHAR(20)      NOT NULL DEFAULT 'District 05',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ward` (`ward_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Municipal wards under District 05';

-- ============================================================
-- TABLE: collection_types
-- Perishable Garbage | Non Recyclable Garbage | Recyclable Items
-- ============================================================
DROP TABLE IF EXISTS `collection_types`;
CREATE TABLE `collection_types` (
  `id`    TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type`  VARCHAR(60)      NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: trucks
-- ============================================================
DROP TABLE IF EXISTS `trucks`;
CREATE TABLE `trucks` (
  `id`           TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `truck_label`  VARCHAR(30)      NOT NULL COMMENT 'e.g. Lorry-1, 1st Truck, 2nd Truck',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_truck` (`truck_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: schedule_days
-- Stores collection day patterns: Monday, Tuesday & Friday, Daily, etc.
-- ============================================================
DROP TABLE IF EXISTS `schedule_days`;
CREATE TABLE `schedule_days` (
  `id`       SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `day_pattern` VARCHAR(40)    NOT NULL COMMENT 'e.g. Monday, Tuesday & Friday, Daily, Wed. & Sat.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_day` (`day_pattern`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: route_schedules
-- One row per (ward × collection_type × truck × day_pattern × load_number)
-- ============================================================
DROP TABLE IF EXISTS `route_schedules`;
CREATE TABLE `route_schedules` (
  `id`                 INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `ward_id`            TINYINT UNSIGNED  NOT NULL,
  `collection_type_id` TINYINT UNSIGNED  NOT NULL,
  `truck_id`           TINYINT UNSIGNED  NOT NULL,
  `day_id`             SMALLINT UNSIGNED NOT NULL,
  `load_number`        TINYINT UNSIGNED      NULL COMMENT 'NULL for point-to-point routes; 1=1st Load etc.',
  `time_starting`      TIME                  NULL,
  `time_ending`        TIME                  NULL COMMENT 'ETA back / end of load',
  PRIMARY KEY (`id`),
  KEY `fk_rs_ward`  (`ward_id`),
  KEY `fk_rs_ctype` (`collection_type_id`),
  KEY `fk_rs_truck` (`truck_id`),
  KEY `fk_rs_day`   (`day_id`),
  CONSTRAINT `fk_rs_ward`  FOREIGN KEY (`ward_id`)            REFERENCES `wards`            (`id`),
  CONSTRAINT `fk_rs_ctype` FOREIGN KEY (`collection_type_id`) REFERENCES `collection_types` (`id`),
  CONSTRAINT `fk_rs_truck` FOREIGN KEY (`truck_id`)           REFERENCES `trucks`           (`id`),
  CONSTRAINT `fk_rs_day`   FOREIGN KEY (`day_id`)             REFERENCES `schedule_days`    (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: route_stops
-- Individual roads/lanes per schedule, with optional From/Up-to
-- ============================================================
DROP TABLE IF EXISTS `route_stops`;
CREATE TABLE `route_stops` (
  `id`                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `route_schedule_id`   INT UNSIGNED NOT NULL,
  `stop_order`          TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `road_name`           VARCHAR(200) NOT NULL,
  `from_location`       VARCHAR(150)     NULL COMMENT 'Start point on road (From column)',
  `up_to_location`      VARCHAR(150)     NULL COMMENT 'End point on road (Up to column)',
  `remark`              VARCHAR(200)     NULL,
  PRIMARY KEY (`id`),
  KEY `fk_stop_sched` (`route_schedule_id`),
  CONSTRAINT `fk_stop_sched` FOREIGN KEY (`route_schedule_id`)
    REFERENCES `route_schedules` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- LOOKUP VIEW (handy for phpMyAdmin browsing)
-- ============================================================
CREATE OR REPLACE VIEW `v_full_schedule` AS
SELECT
  w.ward_name                                  AS `Ward`,
  ct.type                                      AS `Collection Type`,
  t.truck_label                                AS `Truck`,
  sd.day_pattern                               AS `Day(s)`,
  CASE WHEN rs.load_number IS NULL THEN '—'
       ELSE CONCAT(rs.load_number,
                   CASE rs.load_number WHEN 1 THEN 'st' WHEN 2 THEN 'nd'
                        WHEN 3 THEN 'rd' ELSE 'th' END, ' Load')
  END                                          AS `Load`,
  TIME_FORMAT(rs.time_starting,'%h:%i %p')     AS `Time Starting`,
  TIME_FORMAT(rs.time_ending,  '%h:%i %p')     AS `ETA (Time Ending)`,
  stop.stop_order                              AS `Stop #`,
  stop.road_name                               AS `Road Name`,
  IFNULL(stop.from_location, '—')              AS `From`,
  IFNULL(stop.up_to_location,'—')              AS `Up To`,
  IFNULL(stop.remark,        '—')              AS `Remark`
FROM route_schedules rs
JOIN wards            w   ON w.id   = rs.ward_id
JOIN collection_types ct  ON ct.id  = rs.collection_type_id
JOIN trucks           t   ON t.id   = rs.truck_id
JOIN schedule_days    sd  ON sd.id  = rs.day_id
JOIN route_stops      stop ON stop.route_schedule_id = rs.id
ORDER BY w.ward_name, ct.type, sd.id, t.truck_label, rs.load_number, stop.stop_order;

-- ============================================================
-- SEED DATA
-- ============================================================

-- Wards
INSERT INTO `wards` (`ward_name`) VALUES
  ('Pamankada West'),
  ('Wellawattha South'),
  ('Wellawattha North'),
  ('Havelock Town'),
  ('Bambalapitiya'),
  ('Milagiriya'),
  ('Night Ward');

-- Collection Types
INSERT INTO `collection_types` (`type`) VALUES
  ('Recyclable Item Collection'),
  ('Perishable Garbage'),
  ('Non Recyclable Garbage');

-- Trucks
INSERT INTO `trucks` (`truck_label`) VALUES
  ('Lorry-1'),
  ('Lorry-2'),
  ('Lorry-3'),
  ('1st Truck'),
  ('2nd Truck');

-- Schedule Days
INSERT INTO `schedule_days` (`day_pattern`) VALUES
  ('Monday'),
  ('Tuesday'),
  ('Wednesday'),
  ('Thursday'),
  ('Friday'),
  ('Saturday'),
  ('Sunday'),
  ('Daily'),
  ('Tuesday & Friday'),
  ('Wed. & Sat.'),
  ('Mon. & Thu'),
  ('Wed. & Sat. (Col B)');

-- ============================================================
-- ============================================================
--  SECTION 1: RECYCLABLE ITEM COLLECTION ROUTES
--  Source: g10.jpg (Pamankada West - Monday)
--          Screenshots: Wellawattha South Sat, Wellawattha North Tue,
--                       Havelock Town Wed, Bambalapitiya Thu,
--                       Milagiriya Fri
-- ============================================================
-- ============================================================

-- ============================================================
-- WARD: PAMANKADA WEST | Recyclable | Monday
-- Source: g10.jpg
-- ============================================================

-- Pamankada West | Recyclable | Lorry-1 | Monday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,1,1,1,'07:30:00','10:30:00'); -- id=1
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(1,1,'Hampden Lane',NULL),
(1,2,'Pinto Place',NULL),
(1,3,'Rasawalli Place',NULL),
(1,4,'Daya Road',NULL),
(1,5,'Arethusa Lane',NULL),
(1,6,'Canal Road','By Hand Carts');

-- Pamankada West | Recyclable | Lorry-1 | Monday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,1,1,2,'11:30:00','14:30:00'); -- id=2
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(2,1,'Perera Lane',NULL),
(2,2,'Madangahawatte Lane',NULL),
(2,3,'Rudra Mawatha',NULL),
(2,4,'55th Lane',NULL),
(2,5,'32th Lane','By Hand Carts'),
(2,6,'33th Lane',NULL);

-- Pamankada West | Recyclable | Lorry-1 | Monday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,1,1,3,'15:30:00','17:30:00'); -- id=3
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(3,1,'St.Lawrence Road',NULL),
(3,2,'Fussels Road',NULL),
(3,3,'53rd Road',NULL),
(3,4,'57th Lane',NULL);

-- Pamankada West | Recyclable | Lorry-2 | Monday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,2,1,1,'07:30:00','10:30:00'); -- id=4
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(4,1,'Murugan Place',NULL),
(4,2,'Fonseka Road',NULL),
(4,3,'Maura Place',NULL),
(4,4,'Havelock City',NULL);

-- Pamankada West | Recyclable | Lorry-2 | Monday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,2,1,2,'11:30:00','14:30:00'); -- id=5
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(5,1,'Swarna Road',NULL),
(5,2,'Earward Lane',NULL),
(5,3,'Havelock Gardens',NULL),
(5,4,'Maya Avenue',NULL);

-- Pamankada West | Recyclable | Lorry-2 | Monday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,2,1,3,'15:30:00','17:30:00'); -- id=6
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(6,1,'Havelock Road',NULL),
(6,2,'Kulapathi Road',NULL),
(6,3,'427th Lane',NULL),
(6,4,'Dharmarama Road',NULL);

-- Pamankada West | Recyclable | Lorry-3 | Monday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,3,1,1,'07:30:00','10:30:00'); -- id=7
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(7,1,'W.A.Silva Mawatha','Both side 6 by lane'),
(7,2,'Pamankada Lane',NULL),
(7,3,'Manning Place',NULL),
(7,4,'Maheshwari Road',NULL);

-- Pamankada West | Recyclable | Lorry-3 | Monday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,3,1,2,'11:30:00','14:30:00'); -- id=8
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(8,1,'Ashtip Road',NULL),
(8,2,'Anula Road',NULL),
(8,3,'Sri Suddharama',NULL),
(8,4,'Suivisudarama Road',NULL);

-- Pamankada West | Recyclable | Lorry-3 | Monday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (1,1,3,1,3,'15:30:00','17:30:00'); -- id=9
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(9,1,'Gorakagaha Avenue',NULL),
(9,2,'Perakumba Lane',NULL),
(9,3,'Perakumba Place',NULL);

-- ============================================================
-- WARD: WELLAWATTHA SOUTH | Recyclable | Saturday
-- Source: Screenshot_162447.png
-- ============================================================

-- WS | Recyclable | Lorry-1 | Saturday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,1,6,1,'07:30:00','10:30:00'); -- id=10
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(10,1,'Nelson Place',NULL),
(10,2,'Moor''s Road',NULL),
(10,3,'Boswell Place',NULL);

-- WS | Recyclable | Lorry-1 | Saturday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,1,6,2,'11:30:00','14:30:00'); -- id=11
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(11,1,'Fernando Road',NULL),
(11,2,'Vaverset Place',NULL),
(11,3,'I.B.C Road',NULL);

-- WS | Recyclable | Lorry-1 | Saturday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,1,6,3,'03:30:00','05:30:00'); -- id=12
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(12,1,'36th Lane',NULL),
(12,2,'40th Lane',NULL),
(12,3,'42nd Lane',NULL),
(12,4,'E.A Kure Mawatha',NULL);

-- WS | Recyclable | Lorry-2 | Saturday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,2,6,1,'07:30:00','10:30:00'); -- id=13
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(13,1,'Roxy Garden',NULL),
(13,2,'Ram Krishna Road',NULL),
(13,3,'Vivekananda Road',NULL),
(13,4,'47th Lane',NULL),
(13,5,'Ranjan Wijerathna pura',NULL);

-- WS | Recyclable | Lorry-2 | Saturday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,2,6,2,'11:30:00','14:30:00'); -- id=14
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(14,1,'Marin Drive',NULL),
(14,2,'Ranjaguru Road Sri subuthi Road',NULL);

-- WS | Recyclable | Lorry-2 | Saturday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,2,6,3,'03:30:00','05:30:00'); -- id=15
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(15,1,'Canal Road',NULL),
(15,2,'Vihara Road',NULL);

-- WS | Recyclable | Lorry-3 | Saturday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,3,6,1,'07:30:00','10:30:00'); -- id=16
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(16,1,'Roxy Garden',NULL),
(16,2,'47th Lane',NULL),
(16,3,'Ranjan Wijathunga Patumaga',NULL);

-- WS | Recyclable | Lorry-3 | Saturday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,3,6,2,'11:30:00','14:30:00'); -- id=17
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(17,1,'Marin Drive',NULL),
(17,2,'Ranjaguru Road Sri subuthi Road',NULL),
(17,3,'Rajasinghe Road',NULL);

-- WS | Recyclable | Lorry-3 | Saturday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (2,1,3,6,3,'03:30:00','05:30:00'); -- id=18
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(18,1,'Canal Road',NULL),
(18,2,'Vishar Road',NULL);

-- ============================================================
-- WARD: WELLAWATTHA NORTH | Recyclable | Tuesday
-- Source: Screenshot_162501.png
-- ============================================================

-- WN | Recyclable | Lorry-1 | Tuesday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,1,2,1,'07:30:00','10:30:00'); -- id=19
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(19,1,'Peterson Road',NULL),
(19,2,'Dhammarama Road',NULL),
(19,3,'Peterson Lane',NULL),
(19,4,'Rohini Road',NULL),
(19,5,'Mallika Lane',NULL);

-- WN | Recyclable | Lorry-1 | Tuesday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,1,2,2,'11:30:00','14:30:00'); -- id=20
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(20,1,'Sinsapa Road',NULL),
(20,2,'Fredrica Road',NULL),
(20,3,'Kokila Road','By Hand cart'),
(20,4,'Vincent Lane','By Hand cart');

-- WN | Recyclable | Lorry-1 | Tuesday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,1,2,3,'03:30:00','05:30:00'); -- id=21
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(21,1,'Sri Vijaya Road','By Hand cart'),
(21,2,'Vijaya Lane','By Hand cart'),
(21,3,'2nd Chaple Lane','By Hand cart');

-- WN | Recyclable | Lorry-2 | Tuesday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,2,2,1,'07:30:00','10:30:00'); -- id=22
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(22,1,'1st Chaple Lane',NULL),
(22,2,'Galle Road','Both side Collecting'),
(22,3,'W.A Silva Mawatha',NULL),
(22,4,'Nazir Garden',NULL);

-- WN | Recyclable | Lorry-2 | Tuesday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,2,2,2,'11:30:00','14:30:00'); -- id=23
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(23,1,'Kalan Kaduwa Road',NULL),
(23,2,'Hamer''s avenue',NULL),
(23,3,'Collingwood Place',NULL);

-- WN | Recyclable | Lorry-2 | Tuesday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,2,2,3,'03:30:00','05:30:00'); -- id=24
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(24,1,'Lily Avenue',NULL),
(24,2,'Hames Avenue',NULL);

-- WN | Recyclable | Lorry-3 | Tuesday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,3,2,1,'07:30:00','10:30:00'); -- id=25
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(25,1,'Station Road',NULL),
(25,2,'Station Avenue',NULL),
(25,3,'Wellawatta Police station',NULL);

-- WN | Recyclable | Lorry-3 | Tuesday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,3,2,2,'11:30:00','14:30:00'); -- id=26
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(26,1,'France Road',NULL),
(26,2,'Alexandra Road',NULL);

-- WN | Recyclable | Lorry-3 | Tuesday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (3,1,3,2,3,'03:30:00','05:30:00'); -- id=27
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(27,1,'Charlemont Road',NULL),
(27,2,'Marin Drive',NULL);

-- ============================================================
-- WARD: HAVELOCK TOWN | Recyclable | Wednesday
-- Source: Screenshot_162514.png
-- ============================================================

-- HT | Recyclable | Lorry-1 | Wednesday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,1,3,1,'07:30:00','10:30:00'); -- id=28
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(28,1,'Frankfort Place',NULL),
(28,2,'Bambalapitiya Flats',NULL),
(28,3,'Clifford Place',NULL);

-- HT | Recyclable | Lorry-1 | Wednesday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,1,3,2,'11:30:00','14:30:00'); -- id=29
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(29,1,'Sagara Road',NULL),
(29,2,'Castle Lane',NULL),
(29,3,'Mary''s Road',NULL);

-- HT | Recyclable | Lorry-1 | Wednesday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,1,3,3,'03:30:00','05:30:00'); -- id=30
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(30,1,'Galle Road',NULL),
(30,2,'Marin Drive',NULL),
(30,3,'Thibirigasyaya Road',NULL);

-- HT | Recyclable | Lorry-2 | Wednesday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,2,3,1,'07:30:00','10:30:00'); -- id=31
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(31,1,'Kinross Avenue',NULL),
(31,2,'Ridgeway Place',NULL),
(31,3,'St. Peter''s Place',NULL);

-- HT | Recyclable | Lorry-2 | Wednesday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,2,3,2,'11:30:00','14:30:00'); -- id=32
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(32,1,'Fareed Place',NULL),
(32,2,'Kensing Gardens',NULL),
(32,3,'Lorenz Road',NULL);

-- HT | Recyclable | Lorry-2 | Wednesday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,2,3,3,'03:30:00','05:30:00'); -- id=33
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(33,1,'Davidson Road',NULL),
(33,2,'R. A De Mel Mawatha',NULL),
(33,3,'Saba Lane',NULL),
(33,4,'Siripa Lane',NULL),
(33,5,'Siripa Road',NULL);

-- HT | Recyclable | Lorry-3 | Wednesday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,3,3,1,'07:30:00','10:30:00'); -- id=34
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(34,1,'Elbank Road',NULL),
(34,2,'Layards Road',NULL),
(34,3,'Skelton Road',NULL),
(34,4,'Skelton Gardens',NULL),
(34,5,'Udayanapura Road',NULL);

-- HT | Recyclable | Lorry-3 | Wednesday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,3,3,2,'11:30:00','14:30:00'); -- id=35
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(35,1,'Lumbini Road',NULL),
(35,2,'Havelok Road',NULL),
(35,3,'Isipathana Road',NULL),
(35,4,'Amarasekara Mawatha',NULL),
(35,5,'Isipathana Avenue',NULL),
(35,6,'Maurice Place',NULL);

-- HT | Recyclable | Lorry-3 | Wednesday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,1,3,3,3,'03:30:00','05:30:00'); -- id=36
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(36,1,'Manthri Place',NULL),
(36,2,'Bois Place',NULL),
(36,3,'Greenland Avene',NULL),
(36,4,'Greenland Garden',NULL),
(36,5,'Gas Lane',NULL),
(36,6,'Park Road',NULL),
(36,7,'Park Avenue',NULL),
(36,8,'Park Place',NULL);

-- ============================================================
-- WARD: BAMBALAPITIYA | Recyclable | Thursday
-- Source: Screenshot_162551.png
-- ============================================================

-- BA | Recyclable | Lorry-1 | Thursday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,1,4,1,'07:30:00','10:30:00'); -- id=37
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(37,1,'Arthur''s Place',NULL),
(37,2,'Adamlee Lane',NULL),
(37,3,'Glen aber Place',NULL),
(37,4,'ST.Kildas''s Lane',NULL),
(37,5,'8th Lane',NULL),
(37,6,'Palmyrah Avenue',NULL),
(37,7,'Schofield Place',NULL),
(37,8,'9th Lane',NULL),
(37,9,'10th Lane',NULL);

-- BA | Recyclable | Lorry-1 | Thursday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,1,4,2,'11:30:00','14:30:00'); -- id=38
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(38,1,'Lower Bagatalle Road',NULL),
(38,2,'Sakura Road',NULL),
(38,3,'Rheinland Place',NULL),
(38,4,'Sirikotha Lane',NULL),
(38,5,'Stamboul Place',NULL),
(38,6,'11th Lane','By Hand carts'),
(38,7,'Nimalka Gardens',NULL);

-- BA | Recyclable | Lorry-1 | Thursday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,1,4,3,'15:30:00','17:30:00'); -- id=39
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(39,1,'Sea Avenue',NULL),
(39,2,'Aloe Avenue',NULL),
(39,3,'12th Lane',NULL),
(39,4,'Galle road',NULL),
(39,5,'Marine Drive',NULL);

-- BA | Recyclable | Lorry-2 | Thursday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,2,4,1,'07:30:00','10:30:00'); -- id=40
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(40,1,'Galle road',NULL),
(40,2,'Temple Lane',NULL),
(40,3,'School Lane',NULL),
(40,4,'Edward Lane',NULL),
(40,5,'Alfred house Garden',NULL);

-- BA | Recyclable | Lorry-2 | Thursday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,2,4,2,'11:30:00','14:30:00'); -- id=41
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(41,1,'Alfred House Avenue',NULL),
(41,2,'Bagatalle Road',NULL),
(41,3,'R.A De Mel Mawatha',NULL),
(41,4,'Alfred Place',NULL);

-- BA | Recyclable | Lorry-2 | Thursday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,2,4,3,'15:30:00','17:30:00'); -- id=42
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(42,1,'6th Lane',NULL),
(42,2,'Pentive Gardens',NULL),
(42,3,'Simon Hawawitharana Road',NULL);

-- BA | Recyclable | Lorry-3 | Thursday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,3,4,1,'07:30:00','10:30:00'); -- id=43
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(43,1,'Charles Charle Avenue',NULL),
(43,2,'5th Lane',NULL),
(43,3,'Queen''s Road (Avenue, Terrace)',NULL),
(43,4,'Deanstone Place',NULL),
(43,5,'Deal Place',NULL),
(43,6,'St. Anthony Mawatha',NULL),
(43,7,'Abdul Gafoor Mawatha',NULL);

-- BA | Recyclable | Lorry-3 | Thursday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,3,4,2,'11:30:00','14:30:00'); -- id=44
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(44,1,'Mile Post Avenue',NULL),
(44,2,'Walukarama Road',NULL),
(44,3,'27th Lane',NULL),
(44,4,'Inner Flower Road',NULL),
(44,5,'Unity Place',NULL),
(44,6,'Conel Jayawardhana Road',NULL);

-- BA | Recyclable | Lorry-3 | Thursday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,1,3,4,3,'15:30:00','17:30:00'); -- id=45
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(45,1,'28th Lane',NULL),
(45,2,'Flower Terrace',NULL),
(45,3,'Thurston Road',NULL);

-- ============================================================
-- WARD: MILAGIRIYA | Recyclable | Friday
-- Source: Screenshot_162600.png
-- ============================================================

-- MI | Recyclable | Lorry-1 | Friday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,1,5,1,'07:30:00','10:30:00'); -- id=46
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(46,1,'Melbourne Avenue',NULL),
(46,2,'Milagiriya Avenue',NULL),
(46,3,'Jaya Road',NULL),
(46,4,'Nimal Road',NULL),
(46,5,'Retreat Road',NULL),
(46,6,'Shruberry Gardens',NULL),
(46,7,'Ramaya Road',NULL),
(46,8,'Upatissa Road',NULL);

-- MI | Recyclable | Lorry-1 | Friday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,1,5,2,'11:30:00','14:30:00'); -- id=47
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(47,1,'Kotalawala Avenue',NULL),
(47,2,'Ashoka Gardens',NULL),
(47,3,'Indra Lane','By Hand Carts'),
(47,4,'Janaki Lane','By Hand Carts'),
(47,5,'Beltona Lane','By Hand Carts'),
(47,6,'Haig Road',NULL),
(47,7,'St. Alban''s Lane',NULL),
(47,8,'Ransivi Lane',NULL);

-- MI | Recyclable | Lorry-1 | Friday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,1,5,3,'15:30:00','17:30:00'); -- id=48
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(48,1,'Stubbs Place',NULL),
(48,2,'Stafford Road',NULL),
(48,3,'Macleod Road',NULL);

-- MI | Recyclable | Lorry-2 | Friday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,2,5,1,'07:30:00','10:30:00'); -- id=49
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(49,1,'Galle Road',NULL),
(49,2,'Nandana Gardens',NULL),
(49,3,'Hildon Place',NULL),
(49,4,'De Kretser Place',NULL),
(49,5,'Bambalapitiya Drive',NULL),
(49,6,'Bambalapitiya Terrace',NULL),
(49,7,'Bethesda Place',NULL);

-- MI | Recyclable | Lorry-2 | Friday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,2,5,2,'11:30:00','14:30:00'); -- id=50
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(50,1,'Elfindale Avenue',NULL),
(50,2,'De Vos Avenue',NULL),
(50,3,'Josepth''s Lane',NULL);

-- MI | Recyclable | Lorry-2 | Friday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,2,5,3,'15:30:00','17:30:00'); -- id=51
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(51,1,'Lauries Road',NULL),
(51,2,'Majestic Avenue',NULL),
(51,3,'Bauddhaloka Mawatha',NULL);

-- MI | Recyclable | Lorry-3 | Friday | 1st Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,3,5,1,'07:30:00','10:30:00'); -- id=52
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(52,1,'R.A.De Mel Mawatha',NULL),
(52,2,'Fonseka Place',NULL),
(52,3,'Dickman''s Road',NULL),
(52,4,'Vajira Road',NULL),
(52,5,'Vajira Lane',NULL),
(52,6,'Vishaka Road',NULL),
(52,7,'De Fonseka Place',NULL),
(52,8,'De Fonseka Road',NULL);

-- MI | Recyclable | Lorry-3 | Friday | 2nd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,3,5,2,'11:30:00','14:30:00'); -- id=53
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(53,1,'Vajira Road',NULL),
(53,2,'Gomes Path',NULL),
(53,3,'Gomes Street',NULL),
(53,4,'Police Park Avenue',NULL);

-- MI | Recyclable | Lorry-3 | Friday | 3rd Load
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,1,3,5,3,'15:30:00','17:30:00'); -- id=54
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(54,1,'Lauries Road',NULL),
(54,2,'Reid Avenue',NULL),
(54,3,'Havelock Road',NULL);

-- ============================================================
-- ============================================================
--  SECTION 2: GARBAGE COLLECTION (PERISHABLE) ROUTES
--  Source: Screenshot_162619, 162702, 162716
-- ============================================================
-- ============================================================

-- ============================================================
-- WARD: Night | Perishable | 1 Truck | Daily
-- Source: Screenshot_162619.png
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (7,2,4,8,NULL,'19:30:00','12:30:00'); -- id=55
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`from_location`,`up_to_location`) VALUES
(55,1,'Galle Road','Bambalapitiya Junction','Abdul Gapoor Mawatha'),
(55,2,'Duplication Road','Abdul Gapoor Mawatha','Bambalapitiya Junction'),
(55,3,'Bullers Road','Thummulla Junction','Bambalapitiya Junction'),
(55,4,'Havelock Road','Thummulla Junction','W.A. Silva Mw. Junction'),
(55,5,'Galle Road','Savoy Cinema Hall','Roxy Bridge'),
(55,6,'Galle Road','Roxy Bridge','Bambalapitiya Junction');

-- ============================================================
-- WARD: Night | Non Recyclable | 1 Truck | Daily
-- Source: Screenshot_162642.png (top section)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (7,3,4,8,NULL,'19:30:00','12:30:00'); -- id=56
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`from_location`,`up_to_location`) VALUES
(56,1,'Galle Road','Bambalapitiya Junction','Abdul Kapoor Mawatha'),
(56,2,'Duplication Road','Abdul Kapoor Mawatha','Bambalapitiya Junction'),
(56,3,'Bullers Road','Thummulla Junction','Bambalapitiya Junction'),
(56,4,'Havelock Road','Thummulla Junction','W.A. Silva Mw. Junction'),
(56,5,'Galle Road','Savoy Cinema Hall','Roxy Bridge'),
(56,6,'Galle Road','Roxy Bridge','Bambalapitiya Junction');

-- ============================================================
-- WARD: BAMBALAPITIYA | Non Recyclable | 2nd Truck | Monday
-- Source: Screenshot_162642.png (bottom section)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,3,5,1,NULL,'06:45:00','18:30:00'); -- id=57
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(57,1,'Galle Road',NULL),
(57,2,'R.A De Mel Mawatha',NULL),
(57,3,'8th Lane',NULL),
(57,4,'Palmayrah Avenue',NULL),
(57,5,'Schofild Place',NULL),
(57,6,'10th Lane',NULL),
(57,7,'9th Lane',NULL),
(57,8,'Tea Boad Lane',NULL),
(57,9,'Stambol Place',NULL),
(57,10,'Rehinland Place',NULL),
(57,11,'Sirikotha Avenue',NULL),
(57,12,'Aloe Avenue',NULL),
(57,13,'Sea Avenue',NULL),
(57,14,'12th Lane',NULL),
(57,15,'Nimalka Garden',NULL),
(57,16,'Marine Drive',NULL),
(57,17,'Waly Road',NULL),
(57,18,'Edward Lane',NULL),
(57,19,'School Lane',NULL),
(57,20,'Temple Lane',NULL),
(57,21,'6th Lane',NULL),
(57,22,'Pentive Garden',NULL),
(57,23,'Siman Hewawitharana',NULL),
(57,24,'Deanston Place',NULL),
(57,25,'Deanston Place "A"',NULL),
(57,26,'Walukarama Road',NULL),
(57,27,'Abdul Gaffoor Mawatha',NULL),
(57,28,'Mile Post Avenue',NULL),
(57,29,'St.Anthony''s Mawatha',NULL),
(57,30,'Unity Place',NULL),
(57,31,'Col.Jayawardane Mw.',NULL),
(57,32,'27th lane',NULL),
(57,33,'28th Lane',NULL),
(57,34,'28th "A" Lane',NULL);

-- BAMBALAPITIYA | Non Recyclable | 2nd Truck | Sunday
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,3,5,7,NULL,'06:45:00','12:00:00'); -- id=58
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(58,1,'Galle Road',NULL),
(58,2,'R.A.De Mel Mawatha',NULL),
(58,3,'Thurston Road',NULL),
(58,4,'St.Anthony''s Mawatha',NULL);

-- ============================================================
-- WARD: BAMBALAPITIYA | Non Recyclable | 1 Truck | Monday
-- Source: Screenshot_162653.png (top table)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,3,4,1,NULL,'06:45:00','18:15:00'); -- id=59
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(59,1,'Galle Road',NULL),
(59,2,'R.A.De Mel Mawatha',NULL),
(59,3,'Queens Road',NULL),
(59,4,'5th Lane',NULL),
(59,5,'Charls Way',NULL),
(59,6,'Thurstan Road',NULL),
(59,7,'Pediiris Road',NULL),
(59,8,'St.Anthony''s Mawatha',NULL),
(59,9,'Charls Circle',NULL),
(59,10,'Charls Avenue',NULL),
(59,11,'Bagathale Road',NULL),
(59,12,'Alfred Place',NULL),
(59,13,'Lower Bagathale Road',NULL),
(59,14,'Deal Place',NULL),
(59,15,'Alfred House Garden',NULL),
(59,16,'Alfred House Road',NULL),
(59,17,'Alfred House Avenue',NULL),
(59,18,'Sigiri Garden Road',NULL),
(59,19,'Inner Bagathale Road',NULL),
(59,20,'Bagathale Terrece',NULL),
(59,21,'34th Lane',NULL),
(59,22,'37th Lane',NULL),
(59,23,'Queens Lane',NULL);

-- ============================================================
-- WARD: BAMBALAPITIYA | Perishable | 2nd Truck | Tuesday & Friday (Col A)
-- Source: Screenshot_162653.png (bottom table, left column)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,2,5,9,NULL,'06:45:00','18:30:00'); -- id=60
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(60,1,'Edward Lane',NULL),
(60,2,'School Lane',NULL),
(60,3,'Temple Lane',NULL),
(60,4,'6th Lane',NULL),
(60,5,'Siman Hewawitharana',NULL),
(60,6,'Creative Garden',NULL),
(60,7,'Walukarama Road',NULL),
(60,8,'5th Lane',NULL),
(60,9,'Deanston Place',NULL),
(60,10,'Deal Place "A"',NULL),
(60,11,'Abdul Gaffoor Mawatha',NULL),
(60,12,'Mile Post Avenue',NULL),
(60,13,'St.Anthony''s Mawatha',NULL),
(60,14,'Unity Place',NULL),
(60,15,'Col.Jayawardane Mw.',NULL),
(60,16,'27th Lane',NULL),
(60,17,'28th Lane',NULL),
(60,18,'28th "A" Lane',NULL),
(60,19,'Chelsea Garden',NULL),
(60,20,'Flower Terrece',NULL),
(60,21,'Queens Road',NULL),
(60,22,'Thurstan Road',NULL),
(60,23,'R.A.De Mel Mawatha',NULL),
(60,24,'Flower Road',NULL),
(60,25,'Deanston Place "A"',NULL);

-- BAMBALAPITIYA | Perishable | 2nd Truck | Wed. & Sat. (Col B)
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,2,5,10,NULL,'06:45:00','18:30:00'); -- id=61
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(61,1,'Galle Road',NULL),
(61,2,'R.A.De Mel Mawatha',NULL),
(61,3,'Arthur Place',NULL),
(61,4,'Glen Aber Place',NULL),
(61,5,'8th Lane',NULL),
(61,6,'Palmayrah Avenue',NULL),
(61,7,'Schofild Place',NULL),
(61,8,'9th Lane',NULL),
(61,9,'Tea Boad Lane',NULL),
(61,10,'Stambol Place',NULL),
(61,11,'Rehinland Place',NULL),
(61,12,'Sirikotha Avenue',NULL),
(61,13,'Aloe Avenue',NULL),
(61,14,'Sea Avenue',NULL),
(61,15,'Nimalka Garden',NULL),
(61,16,'Marine Drive',NULL),
(61,17,'Waly Road',NULL),
(61,18,'34th Lane',NULL),
(61,19,'37th Lane',NULL);

-- ============================================================
-- WARD: BAMBALAPITIYA | Perishable | 1 Truck | Tue & Fri (Col A)
-- Source: Screenshot_162702.png (top section)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,2,4,9,NULL,'06:45:00','20:30:00'); -- id=62
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(62,1,'Galle Road',NULL),
(62,2,'R.A.De Mel Mawatha',NULL),
(62,3,'Queens Road',NULL),
(62,4,'5th Lane',NULL),
(62,5,'Charls Way',NULL),
(62,6,'Thurstan Road',NULL),
(62,7,'Pediris Road',NULL),
(62,8,'St.Anthony''s Mawatha',NULL),
(62,9,'Charls Circle',NULL),
(62,10,'Charls Avenue',NULL),
(62,11,'Alfred House Road',NULL),
(62,12,'Alfred House Avenue',NULL),
(62,13,'Inner Bagathale Road',NULL),
(62,14,'Alfred House Garden',NULL),
(62,15,'Lower Bagathale Road',NULL),
(62,16,'34th, 37th, 33rd Lane',NULL);

-- BAMBALAPITIYA | Perishable | 1 Truck | Wed. & Sat. (Col B)
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,2,4,10,NULL,'06:45:00','12:00:00'); -- id=63
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(63,1,'Galle Road',NULL),
(63,2,'R.A.De Mel Mawatha',NULL),
(63,3,'Bagathale Road',NULL),
(63,4,'Alfred Place',NULL),
(63,5,'Lower Bagathale Road',NULL),
(63,6,'Deal Place',NULL),
(63,7,'St.Anthony''s Mawatha',NULL),
(63,8,'Alfred House Garden',NULL),
(63,9,'Alfred House Road',NULL),
(63,10,'Alfred House Avenue',NULL),
(63,11,'Inner Bagathale Road',NULL),
(63,12,'34th, 37th, 33rd Lane',NULL);

-- BAMBALAPITIYA | Perishable | 1 Truck | Sunday (small section)
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (5,2,4,7,NULL,'06:45:00','12:00:00'); -- id=64
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(64,1,'Galle Road',NULL),
(64,2,'R.A.De Mel Mawatha',NULL),
(64,3,'Thurstan Road',NULL),
(64,4,'St.Anthony''s Mawatha',NULL);

-- ============================================================
-- WARD: MILAGIRIYA | Perishable | 2nd Truck | Wed. & Sat. (Col A)
-- Source: Screenshot_162702.png (bottom section)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,2,5,10,NULL,'06:45:00','16:50:00'); -- id=65
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(65,1,'Station Road',NULL),
(65,2,'Laurie''s Road (B)',NULL),
(65,3,'Joseph Lane (B)',NULL),
(65,4,'Daisy Villa Avenue (B)',NULL),
(65,5,'Visaka Privert Road',NULL),
(65,6,'Visaka Road (B)',NULL),
(65,7,'Nandana Garden (B)',NULL),
(65,8,'Ebert Place',NULL),
(65,9,'Stubbs Place',NULL),
(65,10,'Fonseka Road',NULL),
(65,11,'De Krestar Place',NULL),
(65,12,'Fonseka Place',NULL),
(65,13,'Hildan Place',NULL),
(65,14,'Nandana Garden',NULL),
(65,15,'Retret Road',NULL),
(65,16,'Nimal Road',NULL),
(65,17,'Upatissa Road',NULL);

-- MILAGIRIYA | Perishable | 2nd Truck | Mon. & Thu (Col B)
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,2,5,11,NULL,'06:45:00','16:50:00'); -- id=66
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(66,1,'Station Road',NULL),
(66,2,'Laurie''s Road (A)',NULL),
(66,3,'St.Alban Place',NULL),
(66,4,'Daisy Villa Avenue (A)',NULL),
(66,5,'Devos Avenue (A)',NULL),
(66,6,'Vajira Road (A)',NULL),
(66,7,'Visaka Road (A)',NULL),
(66,8,'Fonseka Place (A)',NULL),
(66,9,'Bethesda Place',NULL),
(66,10,'De Krestar Place',NULL),
(66,11,'Hildan Place',NULL),
(66,12,'Nandana Garden',NULL),
(66,13,'Retret Road',NULL),
(66,14,'Nimal Road',NULL),
(66,15,'Upatissa Road',NULL);

-- ============================================================
-- WARD: MILAGIRIYA | Non Recyclable | 2nd Truck | Tuesday
-- Source: Screenshot_162710.png (top section)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,3,5,2,NULL,'06:45:00','18:30:00'); -- id=67
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(67,1,'Station Road',NULL),
(67,2,'St.Alban Place',NULL),
(67,3,'Laurie''s Road',NULL),
(67,4,'Joseph Lane',NULL),
(67,5,'Daisy Villa',NULL),
(67,6,'Devos Avenue',NULL),
(67,7,'Retret Road',NULL),
(67,8,'Vajira Road',NULL),
(67,9,'Visaka Road',NULL),
(67,10,'Fonseka Place',NULL),
(67,11,'Bethesda Place',NULL),
(67,12,'De Krestar Place',NULL),
(67,13,'Hildan Place',NULL),
(67,14,'Nandana Garden',NULL),
(67,15,'Nimal Road',NULL),
(67,16,'Upatissa Road',NULL),
(67,17,'Ebert Place',NULL),
(67,18,'Stubbs Place',NULL),
(67,19,'Gomas Lane',NULL),
(67,20,'Fonseka Road',NULL);

-- MILAGIRIYA | Non Recyclable | 2nd Truck | Sunday
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,3,5,7,NULL,'06:45:00','12:00:00'); -- id=68
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(68,1,'Bauddhaloka Mawatha',NULL),
(68,2,'Havelock Road',NULL),
(68,3,'R.A.De Mel Mawatha',NULL),
(68,4,'Dickmens Road',NULL),
(68,5,'Galle Road',NULL);

-- ============================================================
-- WARD: MILAGIRIYA | Non Recyclable | 1st Truck | Tuesday
-- Source: Screenshot_162710.png (bottom section)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,3,4,2,NULL,'06:45:00','18:45:00'); -- id=69
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(69,1,'Bullers Road',NULL),
(69,2,'Havelock Road',NULL),
(69,3,'R.A.Heva Mawatha',NULL),
(69,4,'Dickman Road',NULL),
(69,5,'Galle Road',NULL),
(69,6,'Marine Drive',NULL),
(69,7,'Melborne Avenue',NULL),
(69,8,'Milagiriya Avenue',NULL),
(69,9,'Jaya Road',NULL),
(69,10,'Sherbery Gardens',NULL),
(69,11,'Kothalawala Avenue',NULL),
(69,12,'Kothalawala Terrace',NULL),
(69,13,'Kothalawala Garden',NULL),
(69,14,'Kothalawala Place',NULL),
(69,15,'Asoka Gardens',NULL),
(69,16,'Haig Road',NULL),
(69,17,'Adams Avenue',NULL),
(69,18,'Gower Street',NULL),
(69,19,'Police Pak Avenue',NULL),
(69,20,'Police Pak Terrace',NULL),
(69,21,'Police Pak Place',NULL);

-- ============================================================
-- WARD: MILAGIRIYA | Perishable | 1st Truck | Wed. & Sat.
-- Source: Screenshot_162716.png (top section)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,2,4,10,NULL,'06:45:00','17:20:00'); -- id=70
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(70,1,'Bullers Road',NULL),
(70,2,'Havelock Road',NULL),
(70,3,'R.A.De Mel Mawatha',NULL),
(70,4,'Dickman Road',NULL),
(70,5,'Galle Road',NULL),
(70,6,'Marine Drive',NULL),
(70,7,'Adams Avenue',NULL),
(70,8,'Milagiriya Avenue',NULL),
(70,9,'Gower Street',NULL),
(70,10,'Jaya Road',NULL),
(70,11,'Sherbery Gardens',NULL),
(70,12,'Kothalawala Avenue',NULL),
(70,13,'Kothalawala Terrace',NULL),
(70,14,'Kothalawala Garden',NULL),
(70,15,'Kothalawala Place',NULL),
(70,16,'Asoka Gardens',NULL),
(70,17,'Haig Road',NULL),
(70,18,'Police Pak Avenue',NULL),
(70,19,'Police Pak Terrace',NULL),
(70,20,'Police Pak Place',NULL);

-- MILAGIRIYA | Perishable | 1st Truck | Mon. & Thu
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,2,4,11,NULL,'06:45:00','17:20:00'); -- id=71
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(71,1,'Bullers Road',NULL),
(71,2,'Havelock Road',NULL),
(71,3,'R.A.De Mel Mawatha',NULL),
(71,4,'Dickman Road',NULL),
(71,5,'Galle Road',NULL),
(71,6,'Marine Drive',NULL),
(71,7,'Melborne Avenue',NULL),
(71,8,'Milagiriya Avenue',NULL),
(71,9,'Jaya Road',NULL),
(71,10,'Sherbery Gardens',NULL),
(71,11,'Kothalawala Avenue',NULL),
(71,12,'Kothalawala Terrace',NULL),
(71,13,'Kothalawala Garden',NULL),
(71,14,'Kothalawala Place',NULL),
(71,15,'Asoka Gardens',NULL),
(71,16,'Haig Road',NULL),
(71,17,'Adams Avenue',NULL),
(71,18,'Gower Street',NULL),
(71,19,'Police Pak Avenue',NULL),
(71,20,'Police Pak Terrace',NULL),
(71,21,'Police Pak Place',NULL);

-- MILAGIRIYA | Perishable | 1st Truck | Sunday
INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (6,2,4,7,NULL,'06:45:00','12:00:00'); -- id=72
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(72,1,'Bauddhaloka Mawatha',NULL),
(72,2,'Havelock Road',NULL),
(72,3,'R.A.De Mel Mawatha',NULL),
(72,4,'Dickmens Road',NULL),
(72,5,'Galle Road',NULL);

-- ============================================================
-- WARD: HAVELOCK TOWN | Non Recyclable | 2nd Truck | Wednesday
-- Source: Screenshot_162716.png (bottom section)
-- ============================================================

INSERT INTO `route_schedules` (`ward_id`,`collection_type_id`,`truck_id`,`day_id`,`load_number`,`time_starting`,`time_ending`)
VALUES (4,3,5,3,NULL,'06:30:00','17:20:00'); -- id=73
INSERT INTO `route_stops` (`route_schedule_id`,`stop_order`,`road_name`,`remark`) VALUES
(73,1,'Fareed Place',NULL),
(73,2,'Rashindale Garden',NULL),
(73,3,'Park Road',NULL),
(73,4,'Park Lane',NULL),
(73,5,'Park Way',NULL),
(73,6,'Park Terrece',NULL),
(73,7,'Manthree Place',NULL),
(73,8,'Spathodia Mawatha',NULL),
(73,9,'Dickmens Road',NULL),
(73,10,'Maurice Place',NULL),
(73,11,'Isipathana Road',NULL),
(73,12,'Greenland Mawatha',NULL),
(73,13,'Greenland Avenue',NULL),
(73,14,'Gas Lane',NULL),
(73,15,'Greenland Garden',NULL),
(73,16,'Bois Place',NULL),
(73,17,'Siripa Road',NULL),
(73,18,'Siripa Lane',NULL),
(73,19,'Saba Lane',NULL);

-- ============================================================
-- WARD: BAMBALAPITIYA | Perishable | 1 Truck | Tue & Fri Col A
-- Source: Screenshot_162702.png (col A section)
-- (already captured as id=62; additional Sunday row captured as id=64)

-- ============================================================
-- SAMPLE USEFUL QUERIES (as comments)
-- ============================================================
-- 1. Today's full schedule for a specific ward:
--    SELECT * FROM v_full_schedule WHERE Ward='Bambalapitiya' AND `Day(s)`='Monday';
--
-- 2. Find which truck covers a specific road:
--    SELECT Ward, `Day(s)`, Truck, `Time Starting`, `ETA (Time Ending)`, `Remark`
--    FROM v_full_schedule WHERE `Road Name` LIKE '%Galle Road%';
--
-- 3. All loads and ETAs for Lorry-1 on Friday:
--    SELECT * FROM v_full_schedule WHERE Truck='Lorry-1' AND `Day(s)`='Friday';
--
-- 4. All roads by collection type:
--    SELECT * FROM v_full_schedule WHERE `Collection Type`='Non Recyclable Garbage';
-- ============================================================

COMMIT;
