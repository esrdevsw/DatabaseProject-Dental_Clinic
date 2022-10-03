-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 25, 2022 at 04:45 AM
-- Server version: 10.4.22-MariaDB
-- PHP Version: 8.1.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dbprojectg00411275edivagner`
--
CREATE DATABASE IF NOT EXISTS `dbprojectg00411275edivagner` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `dbprojectg00411275edivagner`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `CHECK_DIARY`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CHECK_DIARY` (IN `DateVisitA` INT)  BEGIN
    DECLARE TempAppointmentID SMALLINT;
    DECLARE CurrentDate TIME;
    DECLARE ID_patient2 SMALLINT;
    DECLARE Name_patient2 varchar(45);
    DECLARE Surname_patient2 varchar(45);

    DELETE FROM diary WHERE id BETWEEN (select min(id) FROM diary) and (select max(id) FROM diary);
    ALTER TABLE diary
        AUTO_INCREMENT = 1;
    SET
        CurrentDate = '09:00:00';
    WHILE CurrentDate < '17:30:00'
        DO
            SELECT Appointment_ID
            INTO TempAppointmentID
            FROM appointment
            WHERE DateVisit = DateVisitA
              AND TimeVisit = CurrentDate
            order by TimeVisit DESC
            LIMIT 1;

            SELECT Patient_ID
            INTO ID_patient2
            FROM appointment
            WHERE DateVisit = DateVisitA
              AND TimeVisit = CurrentDate
            order by TimeVisit DESC
            LIMIT 1;

            SELECT FirstName
            INTO Name_patient2
            FROM patient
            WHERE Patient_ID = ID_patient2
            order by Patient_ID DESC
            LIMIT 1;

            SELECT Surname
            INTO Surname_patient2
            FROM patient
            WHERE Patient_ID = ID_patient2
            order by Patient_ID DESC
            LIMIT 1;

            IF TempAppointmentID > 0 THEN
                SET TempAppointmentID = TempAppointmentID,
                    ID_patient2 = ID_patient2,
                    Name_patient2 = Name_patient2,
                    Surname_patient2 = Surname_patient2;
            ELSE
                SET TempAppointmentID = NULL,
                    ID_patient2 = NULL,
                    Name_patient2 = NULL,
                    Surname_patient2 = NULL;
            END IF;

            INSERT INTO diary(time_slot, HOUR, MINUTE, Appointment_ID, Patient_ID, FirstName, Surname)
            VALUES (CurrentDate,
                    HOUR(CurrentDate),
                    MINUTE(CurrentDate),
                    TempAppointmentID,
                    ID_patient2,
                    Name_patient2,
                    Surname_patient2);
            SET TempAppointmentID = NULL;
            SET
                CurrentDate = ADDDATE(
                        CurrentDate,
                        INTERVAL 30 MINUTE
                    );
        END WHILE;

END$$

DROP PROCEDURE IF EXISTS `DELETE_APPOINTMENTS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DELETE_APPOINTMENTS` (IN `Appointment_NUM` SMALLINT)  BEGIN
    DECLARE DEL_apptID smallint;
    DECLARE Visit_apptID date;
    DECLARE APPOINTMENT_STATUS varchar(15);

    SELECT appointment.Patient_ID
    INTO DEL_apptID
    FROM appointment
    WHERE Appointment_ID = Appointment_NUM
    ORDER BY Appointment_ID
    LIMIT 1;

    SELECT appointment.DateVisit
    INTO Visit_apptID
    FROM appointment
    WHERE Appointment_ID = Appointment_NUM
    ORDER BY Appointment_ID
    LIMIT 1;

    SELECT appointment.StatusAppointment
    INTO APPOINTMENT_STATUS
    FROM appointment
    WHERE Appointment_ID = Appointment_NUM
    ORDER BY Appointment_ID
    LIMIT 1;

    -- late cancellations are charged a €10 late cancellation fee
    IF Visit_apptID = current_date AND APPOINTMENT_STATUS IS NULL THEN
        INSERT INTO Patient_Bill(Appointment_ID, Speciality_ID, Speciality_Area, DescriptionBill, TotalAmount, isPaid,
                                 date_Bill)
        VALUES (Appointment_NUM, NULL, NULL, 'CANCELLATION', 10, 'NO', SYSDATE());

        UPDATE appointment
        SET StatusAppointment = 'CANCEL'
        WHERE Appointment_ID = Appointment_NUM;
    ELSEIF APPOINTMENT_STATUS IS NULL THEN
        DELETE
        FROM appointment
        WHERE Appointment_ID = Appointment_NUM;
    END IF;


END$$

DROP PROCEDURE IF EXISTS `MAKE_PAYMENT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `MAKE_PAYMENT` (IN `MP_Bill_ID` SMALLINT, IN `MP_PatientID` SMALLINT, IN `MP_AmountPay` INT)  BEGIN
    DECLARE TotalBillPatient INT;
    DECLARE Bill_Amount INT;

    SELECT SUM(Patient_Bill.TotalAmount)
    INTO TotalBillPatient
    FROM patient_bill
             INNER JOIN appointment ON appointment.Appointment_ID = Patient_Bill.Appointment_ID
             INNER JOIN Patient ON Patient.Patient_ID = appointment.Patient_ID
    WHERE Patient.Patient_ID = 130;

    SELECT TotalAmount INTO Bill_Amount FROM patient_bill WHERE Bill_ID = MP_Bill_ID;

    IF Bill_Amount > 0 THEN
        IF Bill_Amount = MP_AmountPay THEN
            UPDATE patient_bill
            SET isPaid      = 'YES',
                TotalAmount = Bill_Amount - MP_AmountPay
            WHERE Bill_ID = MP_Bill_ID;
        ELSE
            UPDATE patient_bill
            SET TotalAmount = Bill_Amount - MP_AmountPay
            WHERE Bill_ID = MP_Bill_ID;
        END IF;

        INSERT INTO Payment(Patient_ID, Amount_To_Pay, Bill_ID, TotalAmountBill, datePay, Amount_Paid, New_Total_To_Pay)
        VALUES (MP_PatientID, TotalBillPatient, MP_Bill_ID, Bill_Amount, SYSDATE(), MP_AmountPay,
                (Bill_Amount - MP_AmountPay));
    END IF;
    SELECT TotalAmount INTO Bill_Amount FROM patient_bill WHERE Bill_ID = MP_Bill_ID;
    IF Bill_Amount <= 0 THEN
        UPDATE patient_bill
        SET isPaid = 'YES'
        WHERE Bill_ID = MP_Bill_ID;
    END IF;

END$$

DROP PROCEDURE IF EXISTS `NEW_PATIENT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `NEW_PATIENT` (IN `NEWFirstName` VARCHAR(45), IN `NewSurname` VARCHAR(45), IN `NewDOB` DATE, IN `Phone1` VARCHAR(15), IN `Phone2` VARCHAR(15), IN `EirCode` VARCHAR(12))  BEGIN
    DECLARE newPostalCode varchar(12) DEFAULT NULL;
    DECLARE TempAddressID SMALLINT;
    DECLARE TempAddressID2 SMALLINT;

    SELECT PostalCode
    INTO newPostalCode
    FROM patientdetail
    WHERE PostalCode = EirCode
    ORDER BY PostalCode DESC
    LIMIT 1;

    SELECT AddressID
    INTO TempAddressID
    FROM patientdetail
    WHERE PostalCode = EirCode
    ORDER BY PostalCode DESC
    LIMIT 1;

    IF newPostalCode = EirCode THEN
        INSERT INTO patient(FirstName, Surname, DOB, PhoneHome, CellPhone, AddressID)
        VALUES (NEWFirstName, NewSurname, NewDOB, Phone1, Phone2, TempAddressID);

    ELSE
        INSERT INTO PatientDetail(PostalCode)
        VALUES (EirCode);

        SELECT AddressID
        INTO TempAddressID2
        FROM patientdetail
        WHERE PostalCode = EirCode
        ORDER BY PostalCode DESC
        LIMIT 1;

        INSERT INTO patient(FirstName, Surname, DOB, PhoneHome, CellPhone, AddressID)
        VALUES (NEWFirstName, NewSurname, NewDOB, Phone1, Phone2, TempAddressID2);

    END IF;

END$$

DROP PROCEDURE IF EXISTS `NEW_PATIENT_ALL`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `NEW_PATIENT_ALL` (IN `NEWFirstName` VARCHAR(45), IN `NEWSurname` VARCHAR(45), IN `NewDOB` DATE, IN `Phone1` VARCHAR(15), IN `Phone2` VARCHAR(15), IN `NStreetAddress` VARCHAR(100), IN `NCity` VARCHAR(45), IN `EirCode` VARCHAR(12))  BEGIN
    DECLARE newPostalCode VARCHAR(12) DEFAULT NULL;

    SELECT PostalCode
    INTO newPostalCode
    FROM patientdetail
    WHERE PostalCode = EirCode
    ORDER BY PostalCode DESC
    LIMIT 1;

    IF newPostalCode = EirCode THEN
        INSERT INTO patient(FirstName, Surname, DOB, PhoneHome, CellPhone, AddressID)
        VALUES (NEWFirstName, NEWSurname, NewDOB, Phone1, Phone2, (SELECT AddressID
                                                                   FROM patientdetail
                                                                   WHERE PostalCode = EirCode
                                                                   ORDER BY PostalCode DESC
                                                                   LIMIT 1));
    ELSE
        INSERT INTO patientdetail(StreetAddress, PostalCode, City)
        VALUES (NStreetAddress, EirCode, NCity);

        INSERT INTO patient(FirstName, Surname, DOB, PhoneHome, CellPhone, AddressID)
        VALUES (NEWFirstName, NEWSurname, NewDOB, Phone1, Phone2, (SELECT AddressID
                                                                   FROM patientdetail
                                                                   WHERE PostalCode = EirCode
                                                                   ORDER BY PostalCode DESC
                                                                   LIMIT 1));

    END IF;

END$$

DROP PROCEDURE IF EXISTS `NEW_PATIENT_DETAIL`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `NEW_PATIENT_DETAIL` (IN `NStreetAddress` VARCHAR(100), IN `NCity` VARCHAR(45), IN `EirCode` VARCHAR(12))  BEGIN
    DECLARE NewAddressID smallint;

    SELECT AddressID
    INTO NewAddressID
    FROM patientdetail
    ORDER BY AddressID DESC
    LIMIT 1;

    UPDATE patientdetail
    SET StreetAddress = NStreetAddress,
        City          = NCity,
        PostalCode    = EirCode
    WHERE AddressID = NewAddressID;

END$$

DROP PROCEDURE IF EXISTS `SET_NEW_APPOINTMENT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SET_NEW_APPOINTMENT` (IN `NUMBER_Patient_ID` SMALLINT, IN `APPOINTMENT_DAY` INT, IN `APPOINTMENT_MONTH` INT, IN `APPOINTMENT_HOUR` INT, IN `APPOINTMENT_MINUTE` INT)  BEGIN
    DECLARE NEW_date date;
    DECLARE NEW_time TIME;
    DECLARE APPTfree smallint;

    SET NEW_date = CONCAT(2022, '-', APPOINTMENT_MONTH, '-', APPOINTMENT_DAY);
    SET NEW_time = STR_TO_DATE((CONCAT(APPOINTMENT_HOUR, ':', APPOINTMENT_MINUTE, ':00')), '%H:%i:%s');

    CALL CHECK_DIARY(NEW_date);
    SELECT Appointment_ID INTO APPTfree FROM diary WHERE time_slot = NEW_time;

    IF (SELECT ISNULL(APPTfree)) = 1 THEN

        INSERT INTO Appointment(Patient_ID, DateVisit, TimeVisit)
        VALUES (NUMBER_Patient_ID,
                NEW_date,
                NEW_time);
    END IF;
    CALL CHECK_DIARY(NEW_date);
END$$

DROP PROCEDURE IF EXISTS `TREATMENT_RECORD`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TREATMENT_RECORD` (IN `R_Speciality_ID` INT, IN `R_Appointment_ID` SMALLINT, IN `R_Treat_ID1` SMALLINT, IN `R_Treat_ID2` SMALLINT, IN `R_Treat_ID3` SMALLINT, `R_Record_Treat` VARCHAR(255))  BEGIN
    DECLARE Treat_newID INT;
    DECLARE totalTreat INT;

    DECLARE Bill_treatID smallint;
    -- DECLARE Patient_treatID smallint;
    DECLARE R_Speciality varchar(45);

    SELECT Speciality_Area
    INTO R_Speciality
    FROM speciality
    WHERE Speciality_ID = R_Speciality_ID;

    INSERT INTO treatment(Speciality_ID, Appointment_ID, Treat_ID1, Treat_ID2, Treat_ID3, Record_Treat,
                          Speciality_Detail)
    VALUES (R_Speciality_ID,
            R_Appointment_ID,
            R_Treat_ID1,
            R_Treat_ID2,
            R_Treat_ID3,
            R_Record_Treat,
            R_Speciality);

    SELECT Treatment_ID INTO Treat_newID FROM treatment ORDER BY Treatment_ID DESC LIMIT 1;

    SELECT SUM(TotalSum)
    INTO totalTreat
    FROM (SELECT SUM(treatfeesbook.TreatFees) AS TotalSum
          FROM treatfeesbook
          WHERE treatfeesbook.Treat_ID = (select treatment.Treat_ID1
                                          from treatment
                                          WHERE treatment.Treatment_ID = Treat_newID)
          UNION ALL
          SELECT SUM(treatfeesbook.TreatFees) AS TotalSum
          FROM treatfeesbook
          WHERE treatfeesbook.Treat_ID = (select treatment.Treat_ID2
                                          from treatment
                                          WHERE treatment.Treatment_ID = Treat_newID)
          UNION ALL
          SELECT SUM(treatfeesbook.TreatFees) AS TotalSum
          FROM treatfeesbook
          WHERE treatfeesbook.Treat_ID = (select treatment.Treat_ID3
                                          from treatment
                                          WHERE treatment.Treatment_ID = Treat_newID)) tbl;


    INSERT INTO Patient_Bill(Appointment_ID, Speciality_ID, Speciality_Area, DescriptionBill, TotalAmount, isPaid,
                             date_Bill)
    VALUES (R_Appointment_ID,
            R_Speciality_ID,
            R_Speciality,
            'TREATMENT',
            totalTreat,
            'NO',
            SYSDATE());

    SELECT Bill_ID INTO Bill_treatID FROM patient_bill ORDER BY Bill_ID DESC LIMIT 1;

    UPDATE treatment
    SET Bill_ID = Bill_treatID
    WHERE Treatment_ID = Treat_newID;

    UPDATE appointment
    SET StatusAppointment = 'FINISHED'
    WHERE Appointment_ID = R_Appointment_ID;

END$$

DROP PROCEDURE IF EXISTS `WEEKS_APPOINTMENTS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `WEEKS_APPOINTMENTS` (IN `DateVisitA` INT)  BEGIN
    DECLARE TempAppointmentID SMALLINT;
    DECLARE CurrentTime TIME;
    DECLARE CurrentDay DATE;
    DECLARE DateVisitB DATE;
    DECLARE CaseDay INT;

    DELETE FROM WeekDiary WHERE id BETWEEN (select min(id) FROM WeekDiary) and (select max(id) FROM WeekDiary);
    ALTER TABLE WeekDiary
        AUTO_INCREMENT = 1;

    SET
        CurrentDay = DateVisitA,
        DateVisitB = ADDDATE(CurrentDay, 7),
        CaseDay = 1;
    WHILE CurrentDay < DateVisitB
        DO
            SET CurrentTime = '09:00:00';
            WHILE CurrentTime < '17:30:00'
                DO
                    SELECT Appointment_ID
                    INTO TempAppointmentID
                    FROM appointment
                    WHERE DateVisit = CurrentDay
                      AND TimeVisit = CurrentTime
                    order by TimeVisit DESC
                    LIMIT 1;

                    IF TempAppointmentID > 0 THEN
                        SET TempAppointmentID = TempAppointmentID;
                    ELSE
                        SET TempAppointmentID = NULL;
                    END IF;

                    IF CaseDay = 1 THEN
                        INSERT INTO WeekDiary(time_slot, HOUR, MINUTE, Appointment_ID1)
                        VALUES (CurrentTime,
                                HOUR(CurrentTime),
                                MINUTE(CurrentTime),
                                TempAppointmentID);
                    ELSEIF CaseDay = 2 THEN
                        UPDATE WeekDiary
                        SET Appointment_ID2 = TempAppointmentID
                        WHERE time_slot = CurrentTime;

                    ELSEIF CaseDay = 3 THEN
                        UPDATE WeekDiary
                        SET Appointment_ID3 = TempAppointmentID
                        WHERE time_slot = CurrentTime;
                    ELSEIF CaseDay = 4 THEN
                        UPDATE WeekDiary
                        SET Appointment_ID4 = TempAppointmentID
                        WHERE time_slot = CurrentTime;
                    ELSEIF CaseDay = 5 THEN
                        UPDATE WeekDiary
                        SET Appointment_ID5 = TempAppointmentID
                        WHERE time_slot = CurrentTime;
                    ELSEIF CaseDay = 6 THEN
                        UPDATE WeekDiary
                        SET Appointment_ID6 = TempAppointmentID
                        WHERE time_slot = CurrentTime;
                    ELSEIF CaseDay = 7 THEN
                        UPDATE WeekDiary
                        SET Appointment_ID7 = TempAppointmentID
                        WHERE time_slot = CurrentTime;

                    END IF;

                    SET TempAppointmentID = NULL;
                    SET CurrentTime = ADDDATE(CurrentTime, INTERVAL 30 MINUTE);
                END WHILE;
            SET CaseDay = CaseDay + 1;
            SET CurrentDay = ADDDATE(CurrentDay, 1);
        END WHILE;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `appointment`
--

DROP TABLE IF EXISTS `appointment`;
CREATE TABLE IF NOT EXISTS `appointment` (
  `Appointment_ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `Patient_ID` smallint(6) DEFAULT NULL,
  `DateVisit` date DEFAULT NULL,
  `TimeVisit` time DEFAULT NULL CHECK (`TimeVisit` in (93000,100000,103000,110000,113000,120000,143000,150000,153000,160000,163000,17000)),
  `StatusAppointment` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`Appointment_ID`),
  KEY `Patient_ID` (`Patient_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `appointment`
--

INSERT INTO `appointment` (`Appointment_ID`, `Patient_ID`, `DateVisit`, `TimeVisit`, `StatusAppointment`) VALUES
(3, 103, '2022-04-26', '15:30:00', NULL),
(4, 104, '2022-04-26', '09:30:00', NULL),
(5, 105, '2022-04-26', '10:30:00', NULL),
(6, 106, '2022-04-26', '14:30:00', NULL),
(7, 107, '2022-04-27', '09:30:00', NULL),
(8, 108, '2022-04-28', '10:00:00', NULL),
(9, 109, '2022-04-29', '10:30:00', NULL),
(10, 110, '2022-04-30', '11:00:00', NULL),
(11, 111, '2022-05-01', '11:30:00', NULL),
(12, 112, '2022-05-02', '12:00:00', NULL),
(13, 113, '2022-05-03', '14:30:00', NULL),
(14, 114, '2022-05-04', '15:00:00', NULL),
(15, 115, '2022-05-05', '10:30:00', NULL),
(16, 117, '2022-05-05', '11:30:00', NULL),
(17, 118, '2022-05-05', '12:00:00', NULL),
(18, 117, '2022-04-25', '12:00:00', 'CANCEL'),
(20, 129, '2022-05-06', '14:30:00', 'FINISHED'),
(21, 130, '2022-05-06', '15:00:00', 'FINISHED'),
(22, 129, '2022-05-07', '14:30:00', 'FINISHED'),
(23, 130, '2022-05-07', '15:00:00', 'FINISHED');

-- --------------------------------------------------------

--
-- Table structure for table `diary`
--

DROP TABLE IF EXISTS `diary`;
CREATE TABLE IF NOT EXISTS `diary` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time_slot` time NOT NULL,
  `HOUR` int(11) NOT NULL,
  `MINUTE` int(11) NOT NULL,
  `Appointment_ID` smallint(6) DEFAULT NULL,
  `Patient_ID` smallint(6) DEFAULT NULL,
  `FirstName` varchar(45) DEFAULT NULL,
  `Surname` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Patient_ID` (`Patient_ID`),
  KEY `Appointment_ID` (`Appointment_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `diary`
--

INSERT INTO `diary` (`id`, `time_slot`, `HOUR`, `MINUTE`, `Appointment_ID`, `Patient_ID`, `FirstName`, `Surname`) VALUES
(1, '09:00:00', 9, 0, NULL, NULL, NULL, NULL),
(2, '09:30:00', 9, 30, NULL, NULL, NULL, NULL),
(3, '10:00:00', 10, 0, NULL, NULL, NULL, NULL),
(4, '10:30:00', 10, 30, NULL, NULL, NULL, NULL),
(5, '11:00:00', 11, 0, NULL, NULL, NULL, NULL),
(6, '11:30:00', 11, 30, NULL, NULL, NULL, NULL),
(7, '12:00:00', 12, 0, NULL, NULL, NULL, NULL),
(8, '12:30:00', 12, 30, NULL, NULL, NULL, NULL),
(9, '13:00:00', 13, 0, NULL, NULL, NULL, NULL),
(10, '13:30:00', 13, 30, NULL, NULL, NULL, NULL),
(11, '14:00:00', 14, 0, NULL, NULL, NULL, NULL),
(12, '14:30:00', 14, 30, 22, 129, 'Fallon', 'Ford'),
(13, '15:00:00', 15, 0, 23, 130, 'Eve', 'Ford'),
(14, '15:30:00', 15, 30, NULL, NULL, NULL, NULL),
(15, '16:00:00', 16, 0, NULL, NULL, NULL, NULL),
(16, '16:30:00', 16, 30, NULL, NULL, NULL, NULL),
(17, '17:00:00', 17, 0, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `family_riley`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `family_riley`;
CREATE TABLE IF NOT EXISTS `family_riley` (
`Patient_ID` smallint(6)
,`FirstName` varchar(45)
,`Surname` varchar(45)
,`DOB` date
,`PhoneHome` varchar(15)
,`CellPhone` varchar(15)
,`AddressID` smallint(6)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `info_patient_bill_appointment`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `info_patient_bill_appointment`;
CREATE TABLE IF NOT EXISTS `info_patient_bill_appointment` (
`Patient_ID` smallint(6)
,`FirstName` varchar(45)
,`Surname` varchar(45)
,`Appointment_ID` smallint(6)
,`TotalAmount` float
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `info_patient_total_bill`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `info_patient_total_bill`;
CREATE TABLE IF NOT EXISTS `info_patient_total_bill` (
`Patient_ID` smallint(6)
,`FirstName` varchar(45)
,`Surname` varchar(45)
,`SUM(Patient_Bill.TotalAmount)` double
);

-- --------------------------------------------------------

--
-- Table structure for table `patient`
--

DROP TABLE IF EXISTS `patient`;
CREATE TABLE IF NOT EXISTS `patient` (
  `Patient_ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(45) NOT NULL,
  `Surname` varchar(45) NOT NULL,
  `DOB` date DEFAULT NULL,
  `PhoneHome` varchar(15) DEFAULT NULL,
  `CellPhone` varchar(15) DEFAULT NULL,
  `AddressID` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`Patient_ID`),
  KEY `AddressID` (`AddressID`)
) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `patient`
--

INSERT INTO `patient` (`Patient_ID`, `FirstName`, `Surname`, `DOB`, `PhoneHome`, `CellPhone`, `AddressID`) VALUES
(102, 'Octavius', 'Riley', '1972-07-15', '01 239 5971', '055 257 7834', 2001),
(103, 'Murphy', 'Riley', '1960-07-18', '01 239 5971', '084 121 4277', 2001),
(104, 'Mariam', 'Riley', '1983-10-22', '01 239 5971', '088 881 1538', 2001),
(105, 'Dennis', 'Riley', '2017-01-22', '01 239 5971', NULL, 2001),
(106, 'Honorato', 'Hammond', '1974-01-08', '01 916 4675', '057 643 5135', 2002),
(107, 'Phillip', 'Riley', '2015-10-25', '01 239 5971', NULL, 2001),
(108, 'Basia', 'Humphrey', '1971-04-25', '01 545 9033', '055 876 7776', 2003),
(109, 'Nita', 'Byrd', '1986-12-21', '01 823 4322', '051 238 6727', 2004),
(110, 'Stella', 'Stanley', '1963-04-10', '01 484 1381', '058 126 4451', 2005),
(111, 'Maryam', 'Reed', '1974-10-18', '01 725 6363', '053 414 3171', 2006),
(112, 'Eric', 'Bird', '1971-05-11', '01 725 6363', '051 893 7886', 2006),
(113, 'Myra', 'Bird', '2012-03-24', '01 725 6363', NULL, 2006),
(114, 'Zia', 'Benjamin', '1975-10-16', '01 748 4526', '081 915 7525', 2007),
(115, 'Alexis', 'Holmes', '1982-07-01', '01 274 6781', '082 353 9185', 2008),
(116, 'Kyle', 'Bird', '2013-06-22', '01 725 6363', NULL, 2006),
(117, 'Mohammad', 'Wall', '2003-06-29', '01 837 3665', '080 196 4776', 2009),
(118, 'Sophia', 'Slater', '1960-05-01', '01 013 6831', '086 684 2397', 2010),
(119, 'Whitney', 'Santos', '2003-08-16', '01 563 7607', '055 578 8875', 2011),
(120, 'Mollie', 'Decker', '1998-05-12', '01 667 5863', '088 814 4133', 2012),
(121, 'Herrod', 'Turner', '1998-04-07', '01 408 3342', '052 170 3657', 2013),
(122, 'Dacey', 'Gonzalez', '1981-04-13', '01 818 2722', '088 304 2552', 2014),
(123, 'Oren', 'Mclaughlin', '2008-08-25', '01 675 2785', NULL, 2015),
(124, 'Lionel', 'Mclaughlin', '1972-06-24', '01 675 2785', '058 468 9775', 2015),
(125, 'Brent', 'Graves', '1993-02-07', '01 957 4823', '084 678 8538', 2016),
(127, 'JOAO', 'PEREIRA', '1987-07-16', '01 239 5971', '084 017 2983', 2018),
(128, 'joao', 'Yyyy3', NULL, NULL, NULL, 2019),
(129, 'Fallon', 'Ford', '1980-12-21', '01 368 3803', '054 456 1830', 2020),
(130, 'Eve', 'Ford', '1982-04-18', NULL, '050 318 9301', 2020);

-- --------------------------------------------------------

--
-- Table structure for table `patientdetail`
--

DROP TABLE IF EXISTS `patientdetail`;
CREATE TABLE IF NOT EXISTS `patientdetail` (
  `AddressID` smallint(6) NOT NULL AUTO_INCREMENT,
  `StreetAddress` varchar(255) DEFAULT NULL,
  `PostalCode` varchar(12) DEFAULT NULL,
  `City` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`AddressID`)
) ENGINE=InnoDB AUTO_INCREMENT=2021 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `patientdetail`
--

INSERT INTO `patientdetail` (`AddressID`, `StreetAddress`, `PostalCode`, `City`) VALUES
(2001, '3521 Mi St.', 'T81 B4L28', 'Drimoleague'),
(2002, 'Ap #770-7345 Nec Rd.', 'T15 G7P77', 'Leap'),
(2003, 'Ap #112-724 Neque St.', 'T82 Y5D75', 'Rosscarbery'),
(2004, '6806 Aliquam Rd.', 'T95 Y8T28', 'Glengarriff'),
(2005, 'Ap #940-7557 Maecenas St.', 'T15 D5A05', 'Durrus'),
(2006, 'Ap #601-4750 Donec Rd.', 'T41 L2E03', 'Dunmanway'),
(2007, 'Ap #539-4808 Nisi St.', 'T16 S5S34', 'Ballydehob'),
(2008, '438-3644 Cubilia Road', 'T48 U2N28', 'Glengarriff'),
(2009, 'P.O. Box 509, 3402 Maecenas Rd.', 'T36 I0B28', 'Union Hall'),
(2010, '3139 Rutrum St.', 'T17 O6V97', 'Castletownbere'),
(2011, '968-630 Nullam Road', 'T35 S8M02', 'Schull '),
(2012, '6314 Non, Rd.', 'T66 S3V65', 'Courtmacsherry'),
(2013, 'P.O. Box 407, 8242 A St.', 'T41 Q5U55', 'Ballydehob'),
(2014, '4241 In, Rd.', 'T64 I1X82', 'Baltimore'),
(2015, '6570 Auctor, St.', 'T37 X8N71', 'Dunmanway'),
(2016, '1408 Enim Avenue', 'T56 O8Z52', 'Glengarriff'),
(2018, 'StreetAddress', ' abc 123', 'City YY'),
(2019, NULL, 'DEF1-456', NULL),
(2020, 'Ap #612-6463 Ullamcorper Av.', 'T82 P7L83', 'Durrus');

-- --------------------------------------------------------

--
-- Stand-in structure for view `patients_age`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `patients_age`;
CREATE TABLE IF NOT EXISTS `patients_age` (
`FirstName` varchar(45)
,`Surname` varchar(45)
,`DOB` date
,`patientAge` int(5)
);

-- --------------------------------------------------------

--
-- Table structure for table `patient_bill`
--

DROP TABLE IF EXISTS `patient_bill`;
CREATE TABLE IF NOT EXISTS `patient_bill` (
  `Bill_ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `Appointment_ID` smallint(6) NOT NULL,
  `Speciality_ID` int(2) DEFAULT NULL,
  `Speciality_Area` varchar(45) DEFAULT NULL,
  `DescriptionBill` varchar(45) DEFAULT 'NO',
  `TotalAmount` float NOT NULL,
  `isPaid` varchar(3) NOT NULL,
  `date_Bill` datetime DEFAULT NULL,
  PRIMARY KEY (`Bill_ID`),
  KEY `Appointment_ID` (`Appointment_ID`),
  KEY `Speciality_ID` (`Speciality_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `patient_bill`
--

INSERT INTO `patient_bill` (`Bill_ID`, `Appointment_ID`, `Speciality_ID`, `Speciality_Area`, `DescriptionBill`, `TotalAmount`, `isPaid`, `date_Bill`) VALUES
(1, 3, 0, 'Clinic Treatment', 'TREATMENT', 0, 'YES', '2022-04-25 03:42:30'),
(2, 4, 0, 'Clinic Treatment', 'TREATMENT', 70, 'NO', '2022-04-25 03:42:30'),
(3, 5, 2, 'Dental Implants', 'TREATMENT', 0, 'NO', '2022-04-25 03:42:30'),
(4, 18, NULL, NULL, 'CANCELLATION', 10, 'NO', '2022-04-25 03:42:31'),
(5, 20, 0, 'Clinic Treatment', 'TREATMENT', 570, 'NO', '2022-04-25 03:42:31'),
(6, 21, 0, 'Clinic Treatment', 'TREATMENT', 50, 'NO', '2022-04-25 03:42:31'),
(7, 21, 6, 'Surgical Extractions', 'TREATMENT', 0, 'NO', '2022-04-25 03:42:31'),
(8, 22, 0, 'Clinic Treatment', 'TREATMENT', 0, 'YES', '2022-04-25 03:42:31'),
(9, 23, 0, 'Clinic Treatment', 'TREATMENT', 0, 'YES', '2022-04-25 03:42:31'),
(10, 23, 6, 'Surgical Extractions', 'TREATMENT', 0, 'NO', '2022-04-25 03:42:32');

-- --------------------------------------------------------

--
-- Stand-in structure for view `patient_join`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `patient_join`;
CREATE TABLE IF NOT EXISTS `patient_join` (
`Patient_ID` smallint(6)
,`FirstName` varchar(45)
,`Surname` varchar(45)
,`patientAge` int(5)
,`AddressID` smallint(6)
,`StreetAddress` varchar(255)
,`PostalCode` varchar(12)
,`City` varchar(45)
,`PhoneHome` varchar(15)
,`CellPhone` varchar(15)
);

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
CREATE TABLE IF NOT EXISTS `payment` (
  `Pay_ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `Patient_ID` smallint(6) DEFAULT NULL,
  `Amount_To_Pay` int(11) NOT NULL,
  `Bill_ID` smallint(6) DEFAULT NULL,
  `TotalAmountBill` float DEFAULT NULL,
  `datePay` datetime NOT NULL,
  `Amount_Paid` float NOT NULL,
  `New_Total_To_Pay` int(11) NOT NULL,
  PRIMARY KEY (`Pay_ID`),
  KEY `Bill_ID` (`Bill_ID`),
  KEY `Patient_ID` (`Patient_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`Pay_ID`, `Patient_ID`, `Amount_To_Pay`, `Bill_ID`, `TotalAmountBill`, `datePay`, `Amount_Paid`, `New_Total_To_Pay`) VALUES
(1, 103, 50, 1, 50, '2022-04-25 03:42:31', 40, 10),
(2, 103, 10, 1, 10, '2022-04-25 03:42:31', 10, 0),
(3, 129, 1200, 8, 155, '2022-04-25 03:42:32', 100, 55),
(4, 129, 1200, 8, 55, '2022-04-25 03:42:32', 50, 5),
(5, 129, 1200, 8, 5, '2022-04-25 03:42:32', 5, 0),
(6, 129, 1200, 9, 1150, '2022-04-25 03:42:32', 1150, 0);

-- --------------------------------------------------------

--
-- Stand-in structure for view `pediatric_patients`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `pediatric_patients`;
CREATE TABLE IF NOT EXISTS `pediatric_patients` (
`FirstName` varchar(45)
,`Surname` varchar(45)
,`DOB` date
,`patientAge` int(5)
,`Patient_ID` smallint(6)
,`AddressID` smallint(6)
);

-- --------------------------------------------------------

--
-- Table structure for table `specialistdetail`
--

DROP TABLE IF EXISTS `specialistdetail`;
CREATE TABLE IF NOT EXISTS `specialistdetail` (
  `SpeClinic_ID` int(11) NOT NULL,
  `FirstNameSp` varchar(45) NOT NULL,
  `SurnameSp` varchar(45) NOT NULL,
  `StreetClinic` varchar(255) NOT NULL,
  `PhoneClinic` varchar(100) DEFAULT NULL,
  `PostalCode` varchar(100) DEFAULT NULL,
  `City` varchar(45) NOT NULL,
  `Speciality_ID1` int(11) DEFAULT NULL,
  `Speciality_ID2` int(11) DEFAULT NULL,
  `Speciality_ID3` int(11) DEFAULT NULL,
  PRIMARY KEY (`SpeClinic_ID`),
  KEY `Speciality_ID1` (`Speciality_ID1`),
  KEY `Speciality_ID2` (`Speciality_ID2`),
  KEY `Speciality_ID3` (`Speciality_ID3`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `specialistdetail`
--

INSERT INTO `specialistdetail` (`SpeClinic_ID`, `FirstNameSp`, `SurnameSp`, `StreetClinic`, `PhoneClinic`, `PostalCode`, `City`, `Speciality_ID1`, `Speciality_ID2`, `Speciality_ID3`) VALUES
(4935, 'Dr. Nehru', 'Bolton', 'P.O. Box 245, 9130 Dui Rd.', '(01) 290 7764', 'T15 B9L21', 'Bantry', 9, 12, 6),
(4940, 'Dr. Tasha', 'Paul', 'Ap #640-8378 Neque St.', '(01) 602 3421', 'T42 V3Z31', 'Skibbereen', 13, 12, 8),
(4945, 'Dr. Abel', 'Walter', 'P.O. Box 605, 7562 Orci Street', '(01) 564 8581', 'T21 V6D41', 'Bantry', 5, NULL, 3),
(4950, 'Dr. Alexander', 'Reed', 'Ap #228-6031 Sit Road', '(01) 825 9683', 'T04 U9C26', 'Dunmanway', 13, 4, 5),
(4955, 'Dr. Bernard', 'Holcomb', '302-1106 Eu Avenue', '(01) 244 3702', 'T22 K3I39', 'Clonakilty', 5, 10, 3),
(4960, 'Dr. Kirsten', 'Adkins', '836-631 Enim. Ave', '(01) 341 6415', 'T18 C4A44', 'Skibbereen', 9, 10, NULL),
(4965, 'Dr. Kiara', 'Pate', 'Ap #808-8505 Est, Ave', '(01) 854 0083', 'T20 T2W12', 'Castletownbere', 13, 10, 7),
(4970, 'Dr. David', 'Chavez', '361-2612 In St.', '(01) 553 3968', 'T47 G6M76', 'Clonakilty', 1, 10, 6),
(4975, 'Dr. Hilel', 'Salazar', 'Ap #182-2146 Pede, Av.', '(01) 471 1316', 'T57 B2P42', 'Dunmanway', 3, 12, NULL),
(4980, 'Dr. Ulysses', 'Nunez', '1932 Et Road', '(01) 616 2439', 'T75 M8W42', 'Bantry', 9, 4, 6),
(4985, 'Dr. Isabelle', 'Dunn', 'Ap #373-9428 A, St.', '(01) 547 3479', 'T34 L2E15', 'Castletownbere', 3, 2, 7),
(4990, 'Dr. Sierra', 'Kline', 'Ap #180-9214 Nonummy. Road', '(01) 364 8767', 'T81 I1X76', 'Castletownbere', 11, 4, NULL),
(4995, 'Dr. Bevis', 'Clayton', '848-8015 Placerat, Rd.', '(01) 292 7426', 'T34 E3F73', 'Clonakilty', 11, 6, 3),
(5000, 'Dr. Ezra', 'Miranda', 'P.O. Box 738, 6751 Sed St.', '(01) 475 0954', 'T06 M1X58', 'Dunmanway', 5, 8, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `speciality`
--

DROP TABLE IF EXISTS `speciality`;
CREATE TABLE IF NOT EXISTS `speciality` (
  `Speciality_ID` int(2) NOT NULL,
  `Speciality_Area` varchar(45) NOT NULL,
  PRIMARY KEY (`Speciality_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `speciality`
--

INSERT INTO `speciality` (`Speciality_ID`, `Speciality_Area`) VALUES
(0, 'Clinic Treatment'),
(1, 'Orthodontics'),
(2, 'Dental Implants'),
(3, 'Root Canal Treatment'),
(4, 'Oral Rehabilitation'),
(5, 'Bite Splints'),
(6, 'Surgical Extractions'),
(7, 'Oral Biopsies'),
(8, 'Oral Cancer Awareness'),
(9, 'Dental Cysts'),
(10, 'Wisdom Teeth'),
(11, 'Bone Grafting'),
(12, 'Periodontitis'),
(13, 'Panoramic Dental X-ray');

-- --------------------------------------------------------

--
-- Table structure for table `treatfeesbook`
--

DROP TABLE IF EXISTS `treatfeesbook`;
CREATE TABLE IF NOT EXISTS `treatfeesbook` (
  `Treat_ID` smallint(6) NOT NULL,
  `Treatment` varchar(45) NOT NULL,
  `TreatFees` float NOT NULL,
  PRIMARY KEY (`Treat_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `treatfeesbook`
--

INSERT INTO `treatfeesbook` (`Treat_ID`, `Treatment`, `TreatFees`) VALUES
(0, 'No treatment', 0),
(12001, 'Examination', 50),
(12002, 'Examination Children under 16', 30),
(12003, 'Issue of Prescription', 40),
(12004, 'Small X-Rays', 20),
(12005, 'Ceph', 70),
(12006, 'Post Core Preparation', 500),
(12007, 'Crown', 750),
(12008, 'Bridge', 900),
(12009, 'Veneer', 650),
(12010, 'Composite Veneer', 350),
(12011, 'Recement Bridge', 120),
(12012, 'Anterior Tooth', 400),
(12013, 'Premolar Tooth', 500),
(12014, 'Molar Tooth', 650),
(12015, 'Scale and Polish with PRSI', 15),
(12016, 'Scale and Polish (Dentist)', 70),
(12017, 'Scale and Polish (Hygienist)', 80),
(12018, 'Childrens Scale and Polish', 45),
(12019, 'Periodontal Treatment', 150),
(12020, 'Routine Extraction', 120),
(12021, 'Surgical Extraction', 200),
(12022, 'Amalgam Filling Silver', 100),
(12023, 'Composite Filling White', 150),
(12024, 'Temporary Filling', 60),
(12025, 'Pin Retention', 60);

-- --------------------------------------------------------

--
-- Table structure for table `treatment`
--

DROP TABLE IF EXISTS `treatment`;
CREATE TABLE IF NOT EXISTS `treatment` (
  `Treatment_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Speciality_ID` int(2) DEFAULT NULL,
  `Bill_ID` smallint(6) DEFAULT NULL,
  `Appointment_ID` smallint(6) NOT NULL,
  `Treat_ID1` smallint(6) DEFAULT NULL,
  `Treat_ID2` smallint(6) DEFAULT NULL,
  `Treat_ID3` smallint(6) DEFAULT NULL,
  `Record_Treat` varchar(255) DEFAULT NULL,
  `Speciality_Detail` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Treatment_ID`),
  KEY `Appointment_ID` (`Appointment_ID`),
  KEY `Treat_ID1` (`Treat_ID1`),
  KEY `Treat_ID2` (`Treat_ID2`),
  KEY `Treat_ID3` (`Treat_ID3`),
  KEY `Speciality_ID` (`Speciality_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `treatment`
--

INSERT INTO `treatment` (`Treatment_ID`, `Speciality_ID`, `Bill_ID`, `Appointment_ID`, `Treat_ID1`, `Treat_ID2`, `Treat_ID3`, `Record_Treat`, `Speciality_Detail`) VALUES
(1, 0, NULL, 3, 12001, NULL, NULL, 'THIS IS A TEST', 'Clinic Treatment'),
(2, 0, NULL, 4, 12001, 12004, NULL, 'TEST 2 Examination + Small X-Rays ', 'Clinic Treatment'),
(3, 2, NULL, 5, 0, 0, 0, 'specialist treatment record', 'Dental Implants'),
(4, 0, 5, 20, 12001, 12004, 12013, 'RECORD Examination, Small X-Rays AND Premolar Tooth', 'Clinic Treatment'),
(5, 0, 6, 21, 12001, 0, 0, 'RECORD Examination AND specialist cases referred...', 'Clinic Treatment'),
(6, 6, 7, 21, 0, 0, 0, 'RECORD on specialist cases...', 'Surgical Extractions'),
(7, 0, 8, 22, 12003, 12005, 12018, 'RECORD TEST', 'Clinic Treatment'),
(8, 0, 9, 23, 12009, 12013, 0, 'RECORD TEST...', 'Clinic Treatment'),
(9, 6, 10, 23, 0, 0, 0, 'RECORD on specialist cases...', 'Surgical Extractions');

-- --------------------------------------------------------

--
-- Table structure for table `weekdiary`
--

DROP TABLE IF EXISTS `weekdiary`;
CREATE TABLE IF NOT EXISTS `weekdiary` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time_slot` time NOT NULL,
  `HOUR` int(11) NOT NULL,
  `MINUTE` int(11) NOT NULL,
  `Appointment_ID1` smallint(6) DEFAULT NULL,
  `Appointment_ID2` smallint(6) DEFAULT NULL,
  `Appointment_ID3` smallint(6) DEFAULT NULL,
  `Appointment_ID4` smallint(6) DEFAULT NULL,
  `Appointment_ID5` smallint(6) DEFAULT NULL,
  `Appointment_ID6` smallint(6) DEFAULT NULL,
  `Appointment_ID7` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Appointment_ID1` (`Appointment_ID1`),
  KEY `Appointment_ID2` (`Appointment_ID2`),
  KEY `Appointment_ID3` (`Appointment_ID3`),
  KEY `Appointment_ID4` (`Appointment_ID4`),
  KEY `Appointment_ID5` (`Appointment_ID5`),
  KEY `Appointment_ID6` (`Appointment_ID6`),
  KEY `Appointment_ID7` (`Appointment_ID7`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `weekdiary`
--

INSERT INTO `weekdiary` (`id`, `time_slot`, `HOUR`, `MINUTE`, `Appointment_ID1`, `Appointment_ID2`, `Appointment_ID3`, `Appointment_ID4`, `Appointment_ID5`, `Appointment_ID6`, `Appointment_ID7`) VALUES
(1, '09:00:00', 9, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, '09:30:00', 9, 30, 4, 7, NULL, NULL, NULL, NULL, NULL),
(3, '10:00:00', 10, 0, NULL, NULL, 8, NULL, NULL, NULL, NULL),
(4, '10:30:00', 10, 30, 5, NULL, NULL, 9, NULL, NULL, NULL),
(5, '11:00:00', 11, 0, NULL, NULL, NULL, NULL, 10, NULL, NULL),
(6, '11:30:00', 11, 30, NULL, NULL, NULL, NULL, NULL, 11, NULL),
(7, '12:00:00', 12, 0, NULL, NULL, NULL, NULL, NULL, NULL, 12),
(8, '12:30:00', 12, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(9, '13:00:00', 13, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(10, '13:30:00', 13, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(11, '14:00:00', 14, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(12, '14:30:00', 14, 30, 6, NULL, NULL, NULL, NULL, NULL, NULL),
(13, '15:00:00', 15, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(14, '15:30:00', 15, 30, 3, NULL, NULL, NULL, NULL, NULL, NULL),
(15, '16:00:00', 16, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(16, '16:30:00', 16, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(17, '17:00:00', 17, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure for view `family_riley`
--
DROP TABLE IF EXISTS `family_riley`;

DROP VIEW IF EXISTS `family_riley`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `family_riley`  AS SELECT `patient`.`Patient_ID` AS `Patient_ID`, `patient`.`FirstName` AS `FirstName`, `patient`.`Surname` AS `Surname`, `patient`.`DOB` AS `DOB`, `patient`.`PhoneHome` AS `PhoneHome`, `patient`.`CellPhone` AS `CellPhone`, `patient`.`AddressID` AS `AddressID` FROM `patient` WHERE `patient`.`Surname` = 'Riley' ;

-- --------------------------------------------------------

--
-- Structure for view `info_patient_bill_appointment`
--
DROP TABLE IF EXISTS `info_patient_bill_appointment`;

DROP VIEW IF EXISTS `info_patient_bill_appointment`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `info_patient_bill_appointment`  AS SELECT `patient`.`Patient_ID` AS `Patient_ID`, `patient`.`FirstName` AS `FirstName`, `patient`.`Surname` AS `Surname`, `appointment`.`Appointment_ID` AS `Appointment_ID`, `patient_bill`.`TotalAmount` AS `TotalAmount` FROM ((`patient_bill` join `appointment` on(`appointment`.`Appointment_ID` = `patient_bill`.`Appointment_ID`)) join `patient` on(`patient`.`Patient_ID` = `appointment`.`Patient_ID`)) GROUP BY `appointment`.`Appointment_ID` ;

-- --------------------------------------------------------

--
-- Structure for view `info_patient_total_bill`
--
DROP TABLE IF EXISTS `info_patient_total_bill`;

DROP VIEW IF EXISTS `info_patient_total_bill`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `info_patient_total_bill`  AS SELECT `patient`.`Patient_ID` AS `Patient_ID`, `patient`.`FirstName` AS `FirstName`, `patient`.`Surname` AS `Surname`, sum(`patient_bill`.`TotalAmount`) AS `SUM(Patient_Bill.TotalAmount)` FROM ((`patient_bill` join `appointment` on(`appointment`.`Appointment_ID` = `patient_bill`.`Appointment_ID`)) join `patient` on(`patient`.`Patient_ID` = `appointment`.`Patient_ID`)) GROUP BY `patient`.`Patient_ID` ;

-- --------------------------------------------------------

--
-- Structure for view `patients_age`
--
DROP TABLE IF EXISTS `patients_age`;

DROP VIEW IF EXISTS `patients_age`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `patients_age`  AS SELECT `patient`.`FirstName` AS `FirstName`, `patient`.`Surname` AS `Surname`, `patient`.`DOB` AS `DOB`, year(curdate()) - year(`patient`.`DOB`) AS `patientAge` FROM `patient` ;

-- --------------------------------------------------------

--
-- Structure for view `patient_join`
--
DROP TABLE IF EXISTS `patient_join`;

DROP VIEW IF EXISTS `patient_join`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `patient_join`  AS SELECT `patient`.`Patient_ID` AS `Patient_ID`, `patient`.`FirstName` AS `FirstName`, `patient`.`Surname` AS `Surname`, `patients_age`.`patientAge` AS `patientAge`, `patientdetail`.`AddressID` AS `AddressID`, `patientdetail`.`StreetAddress` AS `StreetAddress`, `patientdetail`.`PostalCode` AS `PostalCode`, `patientdetail`.`City` AS `City`, `patient`.`PhoneHome` AS `PhoneHome`, `patient`.`CellPhone` AS `CellPhone` FROM ((`patient` join `patients_age` on(`patients_age`.`FirstName` = `patient`.`FirstName` and `patient`.`Surname` = `patients_age`.`Surname`)) left join `patientdetail` on(`patient`.`AddressID` = `patientdetail`.`AddressID`)) ;

-- --------------------------------------------------------

--
-- Structure for view `pediatric_patients`
--
DROP TABLE IF EXISTS `pediatric_patients`;

DROP VIEW IF EXISTS `pediatric_patients`;
CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `pediatric_patients`  AS SELECT `patients_age`.`FirstName` AS `FirstName`, `patients_age`.`Surname` AS `Surname`, `patients_age`.`DOB` AS `DOB`, `patients_age`.`patientAge` AS `patientAge`, `patient`.`Patient_ID` AS `Patient_ID`, `patient`.`AddressID` AS `AddressID` FROM (`patients_age` join `patient` on(`patient`.`FirstName` = `patients_age`.`FirstName` and `patient`.`Surname` = `patients_age`.`Surname`)) WHERE `patients_age`.`patientAge` < 16 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointment`
--
ALTER TABLE `appointment`
  ADD CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`Patient_ID`) REFERENCES `patient` (`Patient_ID`) ON DELETE CASCADE;

--
-- Constraints for table `diary`
--
ALTER TABLE `diary`
  ADD CONSTRAINT `diary_ibfk_1` FOREIGN KEY (`Patient_ID`) REFERENCES `patient` (`Patient_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `diary_ibfk_2` FOREIGN KEY (`Appointment_ID`) REFERENCES `appointment` (`Appointment_ID`) ON DELETE CASCADE;

--
-- Constraints for table `patient`
--
ALTER TABLE `patient`
  ADD CONSTRAINT `patient_ibfk_1` FOREIGN KEY (`AddressID`) REFERENCES `patientdetail` (`AddressID`) ON DELETE SET NULL;

--
-- Constraints for table `patient_bill`
--
ALTER TABLE `patient_bill`
  ADD CONSTRAINT `patient_bill_ibfk_1` FOREIGN KEY (`Appointment_ID`) REFERENCES `appointment` (`Appointment_ID`),
  ADD CONSTRAINT `patient_bill_ibfk_2` FOREIGN KEY (`Speciality_ID`) REFERENCES `speciality` (`Speciality_ID`) ON DELETE NO ACTION;

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`Bill_ID`) REFERENCES `patient_bill` (`Bill_ID`),
  ADD CONSTRAINT `payment_ibfk_2` FOREIGN KEY (`Patient_ID`) REFERENCES `patient` (`Patient_ID`);

--
-- Constraints for table `specialistdetail`
--
ALTER TABLE `specialistdetail`
  ADD CONSTRAINT `specialistdetail_ibfk_1` FOREIGN KEY (`Speciality_ID1`) REFERENCES `speciality` (`Speciality_ID`) ON DELETE SET NULL,
  ADD CONSTRAINT `specialistdetail_ibfk_2` FOREIGN KEY (`Speciality_ID2`) REFERENCES `speciality` (`Speciality_ID`) ON DELETE SET NULL,
  ADD CONSTRAINT `specialistdetail_ibfk_3` FOREIGN KEY (`Speciality_ID3`) REFERENCES `speciality` (`Speciality_ID`) ON DELETE SET NULL;

--
-- Constraints for table `treatment`
--
ALTER TABLE `treatment`
  ADD CONSTRAINT `treatment_ibfk_1` FOREIGN KEY (`Appointment_ID`) REFERENCES `appointment` (`Appointment_ID`),
  ADD CONSTRAINT `treatment_ibfk_2` FOREIGN KEY (`Treat_ID1`) REFERENCES `treatfeesbook` (`Treat_ID`) ON DELETE SET NULL,
  ADD CONSTRAINT `treatment_ibfk_3` FOREIGN KEY (`Treat_ID2`) REFERENCES `treatfeesbook` (`Treat_ID`) ON DELETE SET NULL,
  ADD CONSTRAINT `treatment_ibfk_4` FOREIGN KEY (`Treat_ID3`) REFERENCES `treatfeesbook` (`Treat_ID`) ON DELETE SET NULL,
  ADD CONSTRAINT `treatment_ibfk_5` FOREIGN KEY (`Speciality_ID`) REFERENCES `speciality` (`Speciality_ID`) ON DELETE CASCADE;

--
-- Constraints for table `weekdiary`
--
ALTER TABLE `weekdiary`
  ADD CONSTRAINT `weekdiary_ibfk_1` FOREIGN KEY (`Appointment_ID1`) REFERENCES `appointment` (`Appointment_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `weekdiary_ibfk_2` FOREIGN KEY (`Appointment_ID2`) REFERENCES `appointment` (`Appointment_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `weekdiary_ibfk_3` FOREIGN KEY (`Appointment_ID3`) REFERENCES `appointment` (`Appointment_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `weekdiary_ibfk_4` FOREIGN KEY (`Appointment_ID4`) REFERENCES `appointment` (`Appointment_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `weekdiary_ibfk_5` FOREIGN KEY (`Appointment_ID5`) REFERENCES `appointment` (`Appointment_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `weekdiary_ibfk_6` FOREIGN KEY (`Appointment_ID6`) REFERENCES `appointment` (`Appointment_ID`) ON DELETE CASCADE,
  ADD CONSTRAINT `weekdiary_ibfk_7` FOREIGN KEY (`Appointment_ID7`) REFERENCES `appointment` (`Appointment_ID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
