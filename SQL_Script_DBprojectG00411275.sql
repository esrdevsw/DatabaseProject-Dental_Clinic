-- Database Design and Development
--  Database Project GMIT HDip
--     Edivagner Ribeiro
--     G00411275@gmit.ie

/*
 In this document we present the scripts for the construction of the database,
 from the creation of tables and the insertion of data.
 There are also typical queries in each step and searching for information for each type of table.

 To meet the business rules presented in the narrative, it was necessary to
 automate some tasks through procedures:

    NEW_PATIENT------->>> Insert the new patient data and check if the EirCode already exists in the address table
    NEW_PATIENT_DETAIL->> Enter the new patient's address data
    NEW_PATIENT_ALL---->> In a single command, insert the patient's data in both tables, if the EirCode already exists,
                          it searches for the reference key
    CHECK_DIARY ------->> Search available times to schedule an appointment. The daily table presents the appointment
                          data and the patient data as well as the available hours as a NULL value.
    WEEKS_APPOINTMENTS -> Searches appointments and available times to schedule an appointment with an interval of
                          7 days from the date of entry.
    SET_NEW_APPOINTMENT-> Schedule a new appointment
    DELETE_APPOINTMENTS-> This procedure deletes an appointment from the table and checks the date of the appointment,
                          if it is a cancellation on the same day as the appointment, then it generates an bill in the
                          amount of 10 euros.
    TREATMENT_RECORD -->> This procedure saves the treatment record and generates the respective Bill to be paid
    MAKE_PAYMENT ------>> The record of payments made is generated based on the bill ID, patient ID and the amount
                          to be paid. The procedure updates the amounts that the customer is paying from the
                          Bill and its payment status, thus enabling a control of small payments for the same Bill.

 */


-- ##############################################################################################
-- ******************************      CREATE TABLE Patient Detail        #######################
-- ##############################################################################################
/*
The relationship between the patient and address tables must be
established one-many, as more than one patient may share the same address.

 */

-- ************************************** Patient Detail
-- Create the patient address table.

DROP
    TABLE IF EXISTS patientdetail;

CREATE TABLE IF NOT EXISTS patientdetail
(
    AddressID     SMALLINT NOT NULL AUTO_INCREMENT,
    StreetAddress VARCHAR(255) DEFAULT NULL,
    PostalCode    VARCHAR(12)  DEFAULT NULL,
    City          VARCHAR(45)  DEFAULT NULL,
    PRIMARY KEY (AddressID)
);

ALTER TABLE patientdetail
    AUTO_INCREMENT = 2001;


-- ************************************** Patient
-- Create the patient table
DROP
    TABLE IF EXISTS Patient;
CREATE TABLE IF NOT EXISTS Patient
(
    Patient_ID SMALLINT    NOT NULL AUTO_INCREMENT,
    FirstName  VARCHAR(45) NOT NULL,
    Surname    VARCHAR(45) NOT NULL,
    DOB        DATE,
    PhoneHome  VARCHAR(15) NULL,
    CellPhone  VARCHAR(15) NULL,
    AddressID  SMALLINT    NULL,

    PRIMARY KEY (Patient_ID),
    FOREIGN KEY (AddressID)
        REFERENCES patientdetail (AddressID)
        ON DELETE SET NULL
);

ALTER TABLE patient
    AUTO_INCREMENT = 101;

-- ************************************** Patient detail Insert data

INSERT INTO patientdetail(StreetAddress, PostalCode, City)
VALUES ('3521 Mi St.', 'T81 B4L28', 'Drimoleague'),
       ('Ap #770-7345 Nec Rd.', 'T15 G7P77', 'Leap'),
       ('Ap #112-724 Neque St.', 'T82 Y5D75', 'Rosscarbery'),
       ('6806 Aliquam Rd.', 'T95 Y8T28', 'Glengarriff'),
       ('Ap #940-7557 Maecenas St.', 'T15 D5A05', 'Durrus'),
       ('Ap #601-4750 Donec Rd.', 'T41 L2E03', 'Dunmanway'),
       ('Ap #539-4808 Nisi St.', 'T16 S5S34', 'Ballydehob'),
       ('438-3644 Cubilia Road', 'T48 U2N28', 'Glengarriff'),
       ('P.O. Box 509, 3402 Maecenas Rd.', 'T36 I0B28', 'Union Hall'),
       ('3139 Rutrum St.', 'T17 O6V97', 'Castletownbere'),
       ('968-630 Nullam Road', 'T35 S8M02', 'Schull '),
       ('6314 Non, Rd.', 'T66 S3V65', 'Courtmacsherry'),
       ('P.O. Box 407, 8242 A St.', 'T41 Q5U55', 'Ballydehob'),
       ('4241 In, Rd.', 'T64 I1X82', 'Baltimore'),
       ('6570 Auctor, St.', 'T37 X8N71', 'Dunmanway'),
       ('1408 Enim Avenue', 'T56 O8Z52', 'Glengarriff');


-- ************************************** Patient Insert data

INSERT INTO patient(FirstName, Surname, DOB, PhoneHome, CellPhone, AddressID)
VALUES ('Hamish', 'Riley', '1987-07-16', '01 239 5971', '084 017 2983', 2001),
       ('Octavius', 'Riley', '1972-07-15', NULL, '055 257 7834', 2001),
       ('Murphy', 'Riley', '1960-07-18', NULL, '084 121 4277', 2001),
       ('Mariam', 'Riley', '1983-10-22', NULL, '088 881 1538', 2001),
       ('Dennis', 'Riley', '2017-01-22', NULL, NULL, 2001),
       ('Honorato', 'Hammond', '1974-01-08', '01 916 4675', '057 643 5135', 2002),
       ('Phillip', 'Riley', '2015-10-25', NULL, NULL, 2001),
       ('Basia', 'Humphrey', '1971-04-25', '01 545 9033', '055 876 7776', 2003),
       ('Nita', 'Byrd', '1986-12-21', '01 823 4322', '051 238 6727', 2004),
       ('Stella', 'Stanley', '1963-04-10', '01 484 1381', '058 126 4451', 2005),
       ('Maryam', 'Reed', '1974-10-18', '01 725 6363', '053 414 3171', 2006),
       ('Eric', 'Bird', '1971-05-11', '01 725 6363', '051 893 7886', 2006),
       ('Myra', 'Bird', '2012-03-24', '01 725 6363', NULL, 2006),
       ('Zia', 'Benjamin', '1975-10-16', '01 748 4526', '081 915 7525', 2007),
       ('Alexis', 'Holmes', '1982-07-01', '01 274 6781', '082 353 9185', 2008),
       ('Kyle', 'Bird', '2013-06-22', '01 725 6363', NULL, 2006),
       ('Mohammad', 'Wall', '2003-06-29', '01 837 3665', '080 196 4776', 2009),
       ('Sophia', 'Slater', '1960-05-01', '01 013 6831', '086 684 2397', 2010),
       ('Whitney', 'Santos', '2003-08-16', '01 563 7607', '055 578 8875', 2011),
       ('Mollie', 'Decker', '1998-05-12', '01 667 5863', '088 814 4133', 2012),
       ('Herrod', 'Turner', '1998-04-07', '01 408 3342', '052 170 3657', 2013),
       ('Dacey', 'Gonzalez', '1981-04-13', '01 818 2722', '088 304 2552', 2014),
       ('Oren', 'Mclaughlin', '2008-08-25', '01 675 2785', NULL, 2015),
       ('Lionel', 'Mclaughlin', '1972-06-24', '01 675 2785', '058 468 9775', 2015),
       ('Brent', 'Graves', '1993-02-07', '01 957 4823', '084 678 8538', 2016);


-- To manually insert data into the tables it is necessary to generate the following commands.


INSERT INTO patient(FirstName, Surname, DOB, PhoneHome, CellPhone)
VALUES ('xxxx', 'xxxx', '1987-07-16', '01 239 5971', '084 017 2983');


-- in this case there is no foreign key to link between the tables, so the value will be NULL.
-- Then we enter the data in the patient details table.


INSERT INTO patientdetail(StreetAddress, PostalCode, City)
VALUES ('Street Address detail', 'the EirCode', 'City Name');


-- After inserting the data in the table, we will have a new key,
-- which must be updated in the patient table.
-- To get the last key generated we can use the following commands.


SELECT *
FROM patientdetail
WHERE AddressID = (SELECT MAX(AddressID) FROM patientdetail);

UPDATE patient
SET AddressID = (SELECT patientdetail.AddressID
                 FROM patientdetail
                 WHERE AddressID = (SELECT MAX(AddressID) FROM patientdetail))
WHERE Patient_ID = 126;
-- replace 126 with the patient ID for which you want to change the address

-- To delete a patient from the database
DELETE
FROM patient
WHERE Patient_ID = 126;
DELETE
FROM patientdetail
WHERE AddressID = 2017;

-- If you delete information from the details table,
-- the foreign key is deleted and the patient table is updated to NULL value.


/*
 To insert data into multiple tables (patient and patient detail) at the same time and
 ensure data integrity, we created a specific procedure to add a new patient that checks
 if the address already exists by searching for the EirCode and establishes the link.
 If the EirCode is not in the list, a new primary key is created in the patient details
 table and then we call a second procedure to complete the data.
 */


-- ****************************** SET NEW_PATIENT PROCEDURE


DROP
    PROCEDURE IF EXISTS NEW_PATIENT;
DELIMITER $$
CREATE PROCEDURE NEW_PATIENT(IN NEWFirstName VARCHAR(45), IN NewSurname VARCHAR(45), IN NewDOB DATE,
                             IN Phone1 VARCHAR(15), IN Phone2 VARCHAR(15), IN EirCode VARCHAR(12))
BEGIN
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

END $$
DELIMITER ;


-- ****************************** SET NEW_PATIENT_DETAIL PROCEDURE


DROP
    PROCEDURE IF EXISTS NEW_PATIENT_DETAIL;
DELIMITER  $$
CREATE PROCEDURE NEW_PATIENT_DETAIL(IN NStreetAddress VARCHAR(100), IN NCity VARCHAR(45), IN EirCode VARCHAR(12))
BEGIN
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

END $$
DELIMITER ;


CALL NEW_PATIENT('JOAO', 'PEREIRA', '1987-07-16', '01 239 5971', '084 017 2983', 'T81 B4L28X');

CALL NEW_PATIENT_DETAIL('StreetAddress', 'City YY', ' abc 123');


/*
 We can enter the complete data of the new patient with a single procedure,
 requiring at least the information of First name, Surname and EirCode
 because the other values can be NULL value.
 */

DROP
    PROCEDURE IF EXISTS NEW_PATIENT_ALL;
DELIMITER $$
CREATE PROCEDURE NEW_PATIENT_ALL(IN NEWFirstName VARCHAR(45), IN NEWSurname VARCHAR(45), IN NewDOB DATE,
                                 IN Phone1 VARCHAR(15), IN Phone2 VARCHAR(15),
                                 IN NStreetAddress VARCHAR(100), IN NCity VARCHAR(45), IN EirCode VARCHAR(12))
BEGIN
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

END $$
DELIMITER ;

-- CALL NEW_PATIENT_ALL( First Name ,  Surname , DOB, PhoneHome, CellPhone, StreetAddress, City, EirCode);
CALL NEW_PATIENT_ALL('joao', 'Yyyy3', NULL, NULL, NULL, NULL, NULL, 'DEF1-456');



-- ##############################################################################################
-- ******************************      CREATE TABLE appointment        #######################
-- ##############################################################################################
/*
 The patient can request an appointment with the secretariat
 Appointment details are written on the patient chart.
 Appointments can be arranged or cancelled.
 Late cancellations are charged a €10 late cancellation fee.
 */

-- ************************************** appointment table
-- For the appointment table, we need the patient's key, time and date
-- We assume that appointments are 30 minutes apart
-- starting at 9:30 am to 12:00 and from 14:30  to 17:00
-- The CHECK constraint is used to limit the value range that can be placed in a column TimeVisit.

DROP
    TABLE IF EXISTS appointment;

CREATE TABLE IF NOT EXISTS appointment
(
    Appointment_ID    SMALLINT    NOT NULL AUTO_INCREMENT,
    Patient_ID        SMALLINT,
    DateVisit         DATE,
    TimeVisit         TIME CHECK (TimeVisit IN
                                  (93000, 100000, 103000, 110000, 113000, 120000,
                                   143000, 150000, 153000, 160000, 163000, 17000)),
    StatusAppointment VARCHAR(15) NULL,
    PRIMARY KEY (Appointment_ID),
    FOREIGN KEY (Patient_ID)
        REFERENCES patient (Patient_ID)
        ON DELETE CASCADE
);
/*
 FOREIGN KEY (Patient_ID) REFERENCES patient (Patient_ID) ON DELETE RESTRICT -
 We do not want to delete a patient from the PATIENT table if there are appointment for
 that patient in the appointment table. If there is no appointment for that patient, it
 is safe to delete the patient and the deletion will be allowed to proceed. If there
 are some appointment for the patient that we want to delete, then the deletion will fail.
 */


-- To manually insert data into the appointment tables it is necessary to generate the following commands.
-- The date format is the SQL standard YYYYMMDD and the same goes for the HHmmss time format.
-- If the input value for the hours is not one of the established values, returns an error.

INSERT INTO appointment(Patient_ID, DateVisit, TimeVisit)
VALUES (101, 20220424, 93000),
       (102, 20220424, 103000);

INSERT INTO Appointment(Patient_ID, DateVisit, TimeVisit)
VALUES (103, 20220426, 153000),
       (104, 20220426, 93000),
       (105, 20220426, 103000),
       (106, 20220426, 143000),
       (107, 20220427, 93000),
       (108, 20220428, 100000),
       (109, 20220429, 103000),
       (110, 20220430, 110000),
       (111, 20220501, 113000),
       (112, 20220502, 120000),
       (113, 20220503, 143000),
       (114, 20220504, 150000);


-- to delete an appointment we use the following command
DELETE
FROM appointment
WHERE Appointment_ID = 2;

-- The foreign key here is defined as DELETE CASCADE, if we delete the patient, the point records are also deleted.
DELETE
FROM patient
WHERE Patient_ID = 101;


-- To schedule a new appointment, it would be necessary to query the appointment table with a
-- search by day and time and check availability.

SELECT *
FROM appointment
WHERE DateVisit = 20220426;

-- To find patient information for a specific appointment use the following command

SELECT patient.*, patientdetail.*, appointment.*
FROM patient,
     patientdetail,
     appointment
WHERE (patient.Patient_ID = appointment.Patient_ID AND appointment.Appointment_ID = 3)
GROUP BY appointment.Appointment_ID;


-- To makes a list of all next week's appointments we can get with the following command.
SELECT *
FROM appointment
WHERE DateVisit BETWEEN 20220426 AND 20220502;

/*
 To check which available times we have in a day, as well as the
 appointments scheduled for the day, we created the following procedure
 where we only need the date and we have the appointment information as a return.
 Use a WHILE loop condition to check all times of day and compare with appointment table
 */


DROP TABLE IF EXISTS
    diary;
CREATE TABLE diary
(
    id             INTEGER PRIMARY KEY AUTO_INCREMENT,
    time_slot      TIME    NOT NULL,
    HOUR           INTEGER NOT NULL,
    MINUTE         INTEGER NOT NULL,
    Appointment_ID smallint,
    Patient_ID     smallint,
    FirstName      varchar(45),
    Surname        varchar(45),

    FOREIGN KEY (Patient_ID) REFERENCES patient (Patient_ID) ON DELETE CASCADE,
    FOREIGN KEY (Appointment_ID) REFERENCES appointment (Appointment_ID) ON DELETE CASCADE
);


DROP
    PROCEDURE IF EXISTS CHECK_DIARY;
DELIMITER $$
CREATE PROCEDURE CHECK_DIARY(IN DateVisitA INT)

BEGIN
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

END $$
DELIMITER ;

-- To consult the day's agenda, use the following command.
CALL CHECK_DIARY(20220426);
SELECT *
FROM diary;

/*
 To check the appointments for the whole week with
 clear information on available times,
 we present the following procedure.
 */


DROP TABLE IF EXISTS
    WeekDiary;
CREATE TABLE WeekDiary
(
    id              INTEGER PRIMARY KEY AUTO_INCREMENT,
    time_slot       TIME    NOT NULL,
    HOUR            INTEGER NOT NULL,
    MINUTE          INTEGER NOT NULL,
    Appointment_ID1 smallint DEFAULT NULL,
    Appointment_ID2 smallint DEFAULT NULL,
    Appointment_ID3 smallint DEFAULT NULL,
    Appointment_ID4 smallint DEFAULT NULL,
    Appointment_ID5 smallint DEFAULT NULL,
    Appointment_ID6 smallint DEFAULT NULL,
    Appointment_ID7 smallint DEFAULT NULL,

    FOREIGN KEY (Appointment_ID1) REFERENCES appointment (Appointment_ID) ON DELETE CASCADE,
    FOREIGN KEY (Appointment_ID2) REFERENCES appointment (Appointment_ID) ON DELETE CASCADE,
    FOREIGN KEY (Appointment_ID3) REFERENCES appointment (Appointment_ID) ON DELETE CASCADE,
    FOREIGN KEY (Appointment_ID4) REFERENCES appointment (Appointment_ID) ON DELETE CASCADE,
    FOREIGN KEY (Appointment_ID5) REFERENCES appointment (Appointment_ID) ON DELETE CASCADE,
    FOREIGN KEY (Appointment_ID6) REFERENCES appointment (Appointment_ID) ON DELETE CASCADE,
    FOREIGN KEY (Appointment_ID7) REFERENCES appointment (Appointment_ID) ON DELETE CASCADE

);


DROP
    PROCEDURE IF EXISTS WEEKS_APPOINTMENTS;
DELIMITER $$
CREATE PROCEDURE WEEKS_APPOINTMENTS(IN DateVisitA INT)

BEGIN
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

END $$
DELIMITER ;

-- The following procedure checks the appointments within 7 days of the input date,
-- so we can check a week's schedule with a single command line.
CALL WEEKS_APPOINTMENTS(20220426);
SELECT *
FROM WeekDiary;


/*
The following procedure makes the appointment of new appointments
verifying in advance that the date and time are available.
When executing CALL CHECK_DIARY(NEW_date) we check the time availability on the day,
if the return when verified within an IF condition is NULL,
we have an available time and the appointment is recorded.
This procedure prevents us from having duplicate appointments.
 */
-- ##############################################################################################
-- ******************************      PROCEDURE  NEW_APPOINTMENT         #######################
-- ##############################################################################################

-- ****************************** create procedure Set new appointment

DROP
    PROCEDURE IF EXISTS SET_NEW_APPOINTMENT;
DELIMITER
    $$
CREATE PROCEDURE SET_NEW_APPOINTMENT(IN NUMBER_Patient_ID smallint, IN APPOINTMENT_DAY INT,
                                     IN APPOINTMENT_MONTH INT, IN APPOINTMENT_HOUR INT, IN APPOINTMENT_MINUTE INT)
BEGIN
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
END $$
DELIMITER ;

-- If you try to book another patient for the same time and day, the appointment will not be performed.
CALL SET_NEW_APPOINTMENT(115, 05, 05, 10, 30);

-- This appointment will not be executed because it has the same date and time
-- as an already existing appointment in the table (same as the appointment of patient number 115).
CALL SET_NEW_APPOINTMENT(116, 05, 05, 10, 30);

-- These appointments will be executed because the times are available.
CALL SET_NEW_APPOINTMENT(117, 05, 05, 11, 30);
CALL SET_NEW_APPOINTMENT(118, 05, 05, 12, 00);



-- ##############################################################################################
-- ******************************          CREATE treatments table         #######################
-- ##############################################################################################

/*
 Registration in the treatments table depends on the appointment key and the treatments fee book key.
 Each consultation can have more than one treatment and for each treatment we
 have an bill with the total value of treatments performed.
 */
-- ************************************** TreatFeesBook
CREATE TABLE IF NOT EXISTS TreatFeesBook
(
    Treat_ID  smallint    NOT NULL,
    Treatment varchar(45) NOT NULL,
    TreatFees float       NOT NULL,

    PRIMARY KEY (Treat_ID)
);
-- ****************************** populating TreatFeesBook
-- ****************************** dental-treatments-prices https://www.dentalcareireland.ie/

INSERT INTO TreatFeesBook(Treat_ID, Treatment, TreatFees)
VALUES (00000, 'No treatment', 0),
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


-- Table of experts for handling specialized cases when necessary.
-- ****************************** Dummy data https://generatedata.com/generator
-- ****************************** speciality list  http://www.specialistdentistry.ie/do-i-need-a-specialist

CREATE TABLE IF NOT EXISTS Speciality
(
    Speciality_ID   int(2)      NOT NULL,
    Speciality_Area varchar(45) NOT NULL,

    PRIMARY KEY (Speciality_ID)
);

INSERT INTO Speciality (Speciality_ID, Speciality_Area)
VALUES (0, 'Clinic Treatment'),
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

-- ************************************** SpecialistDetail

CREATE TABLE IF NOT EXISTS SpecialistDetail
(
    SpeClinic_ID   int          NOT NULL,
    FirstNameSp    varchar(45)  NOT NULL,
    SurnameSp      varchar(45)  NOT NULL,
    StreetClinic   varchar(255) NOT NULL,
    PhoneClinic    varchar(100),
    PostalCode     varchar(100),
    City           varchar(45)  NOT NULL,
    Speciality_ID1 int default NULL,
    Speciality_ID2 int default NULL,
    Speciality_ID3 int default NULL,

    PRIMARY KEY (SpeClinic_ID),
    FOREIGN KEY (Speciality_ID1) REFERENCES Speciality (Speciality_ID) ON DELETE SET NULL,
    FOREIGN KEY (Speciality_ID2) REFERENCES Speciality (Speciality_ID) ON DELETE SET NULL,
    FOREIGN KEY (Speciality_ID3) REFERENCES Speciality (Speciality_ID) ON DELETE SET NULL
);

INSERT INTO SpecialistDetail (SpeClinic_ID, FirstNameSp, SurnameSp, StreetClinic, PhoneClinic, PostalCode, City,
                              Speciality_ID1, Speciality_ID2, Speciality_ID3)
VALUES (5000, 'Dr. Ezra', 'Miranda', 'P.O. Box 738, 6751 Sed St.', '(01) 475 0954', 'T06 M1X58', 'Dunmanway', 5, 8,
        NULL),
       (4995, 'Dr. Bevis', 'Clayton', '848-8015 Placerat, Rd.', '(01) 292 7426', 'T34 E3F73', 'Clonakilty', 11, 6, 3),
       (4990, 'Dr. Sierra', 'Kline', 'Ap #180-9214 Nonummy. Road', '(01) 364 8767', 'T81 I1X76', 'Castletownbere', 11,
        4, NULL),
       (4985, 'Dr. Isabelle', 'Dunn', 'Ap #373-9428 A, St.', '(01) 547 3479', 'T34 L2E15', 'Castletownbere', 3, 2, 7),
       (4980, 'Dr. Ulysses', 'Nunez', '1932 Et Road', '(01) 616 2439', 'T75 M8W42', 'Bantry', 9, 4, 6),
       (4975, 'Dr. Hilel', 'Salazar', 'Ap #182-2146 Pede, Av.', '(01) 471 1316', 'T57 B2P42', 'Dunmanway', 3, 12, NULL),
       (4970, 'Dr. David', 'Chavez', '361-2612 In St.', '(01) 553 3968', 'T47 G6M76', 'Clonakilty', 1, 10, 6),
       (4965, 'Dr. Kiara', 'Pate', 'Ap #808-8505 Est, Ave', '(01) 854 0083', 'T20 T2W12', 'Castletownbere', 13, 10, 7),
       (4960, 'Dr. Kirsten', 'Adkins', '836-631 Enim. Ave', '(01) 341 6415', 'T18 C4A44', 'Skibbereen', 9, 10, NULL),
       (4955, 'Dr. Bernard', 'Holcomb', '302-1106 Eu Avenue', '(01) 244 3702', 'T22 K3I39', 'Clonakilty', 5, 10, 3),
       (4950, 'Dr. Alexander', 'Reed', 'Ap #228-6031 Sit Road', '(01) 825 9683', 'T04 U9C26', 'Dunmanway', 13, 4, 5),
       (4945, 'Dr. Abel', 'Walter', 'P.O. Box 605, 7562 Orci Street', '(01) 564 8581', 'T21 V6D41', 'Bantry', 5, NULL,
        3),
       (4940, 'Dr. Tasha', 'Paul', 'Ap #640-8378 Neque St.', '(01) 602 3421', 'T42 V3Z31', 'Skibbereen', 13, 12, 8),
       (4935, 'Dr. Nehru', 'Bolton', 'P.O. Box 245, 9130 Dui Rd.', '(01) 290 7764', 'T15 B9L21', 'Bantry', 9, 12, 6);

CREATE TABLE IF NOT EXISTS treatment
(
    Treatment_ID      int      NOT NULL AUTO_INCREMENT,
    Speciality_ID     int(2),
    Bill_ID           smallint,
    Appointment_ID    smallint NOT NULL,
    Treat_ID1         smallint,
    Treat_ID2         smallint,
    Treat_ID3         smallint,
    Record_Treat      varchar(255),
    Speciality_Detail varchar(45),

    PRIMARY KEY (Treatment_ID)
);

/*
 FOREIGN KEY (Appointment_ID) REFERENCES Appointment (Appointment_ID) ON DELETE RESTRICT -
 We do not want to delete a patient from the PATIENT table if there are treatments for
 that patient in the TREATMENTS table. If there is no treatment for that patient, it
 is safe to delete the patient and the deletion will be allowed to proceed. If there
 are some treatments for the patient that we want to delete, then the deletion will fail.
 */

ALTER TABLE treatment
    ADD FOREIGN KEY (Appointment_ID) REFERENCES Appointment (Appointment_ID) ON DELETE RESTRICT,
    ADD FOREIGN KEY (Treat_ID1) REFERENCES TreatFeesBook (Treat_ID) ON DELETE SET NULL,
    ADD FOREIGN KEY (Treat_ID2) REFERENCES TreatFeesBook (Treat_ID) ON DELETE SET NULL,
    ADD FOREIGN KEY (Treat_ID3) REFERENCES TreatFeesBook (Treat_ID) ON DELETE SET NULL,
    ADD FOREIGN KEY (Speciality_ID) REFERENCES speciality (Speciality_ID) ON DELETE CASCADE;

/*
 To manually insert data into the treatment tables it is necessary to generate the following commands.
 Speciality_ID = 0 = 'Clinic Treatment'
 Bill_ID = NULL - We don't have bill id yet.
 Appointment_ID = 3 is the appointment fot the patient 103 (Murphy Riley)
 Treat_ID1 = (12001, 'Examination', 50),if we has done more then one treatment in the same appointment,
 we can keep adding treatment.
 Speciality_Detail (0, 'Clinic Treatment'),

 SELECT Speciality_Area FROM Speciality WHERE Speciality_ID = 0;

*/

SELECT Speciality_Area
FROM Speciality
WHERE Speciality_ID = 0;

INSERT INTO treatment(Speciality_ID, Bill_ID, Appointment_ID, Treat_ID1, Treat_ID2, Treat_ID3, Record_Treat,
                      Speciality_Detail)
VALUES (0, NULL, 3, 12001, NULL, NULL, 'THIS IS A TEST', 'Clinic Treatment');

-- 12001 Examination
-- 12004 Small X-Rays
INSERT INTO treatment(Speciality_ID, Bill_ID, Appointment_ID, Treat_ID1, Treat_ID2, Treat_ID3, Record_Treat,
                      Speciality_Detail)
VALUES (0,
        NULL,
        4,
        12001,
        12004,
        NULL,
        'TEST 2 Examination + Small X-Rays ',
        (SELECT Speciality_Area FROM Speciality WHERE Speciality_ID = 0));

-- We can generate an entry in the treatment to register a
-- patient who had a treatment with a specialist, who would have a bill of zero value
INSERT INTO treatment(Speciality_ID, Bill_ID, Appointment_ID, Treat_ID1, Treat_ID2, Treat_ID3, Record_Treat,
                      Speciality_Detail)
VALUES (2,
        NULL,
        5,
        0,
        0,
        0,
        'specialist treatment record',
        (SELECT Speciality_Area FROM Speciality WHERE Speciality_ID = 2));



-- ##############################################################################################
-- ******************************          CREATE Patient_Bill           #######################
-- ##############################################################################################


-- The BILL is relative to the appointment and the total Amount is relative to the treatment cost.

CREATE TABLE IF NOT EXISTS Patient_Bill
(
    Bill_ID         smallint   NOT NULL AUTO_INCREMENT,
    Appointment_ID  smallint   NOT NULL,
    Speciality_ID   int(2)      DEFAULT NULL,
    Speciality_Area varchar(45) DEFAULT NULL,
    DescriptionBill varchar(45) DEFAULT 'NO',
    TotalAmount     float      NOT NULL,
    isPaid          varchar(3) NOT NULL,
    date_Bill       datetime,

    PRIMARY KEY (Bill_ID)
);

ALTER TABLE Patient_Bill
    ADD FOREIGN KEY (Appointment_ID) REFERENCES Appointment (Appointment_ID) ON DELETE RESTRICT,
    ADD FOREIGN KEY (Speciality_ID) REFERENCES Speciality (Speciality_ID) ON DELETE NO ACTION;

-- ********* GET THE TOTAL AMOUNT FOR TREATMENT

SELECT SUM(TotalSum)
from (SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID1 from treatment AS T WHERE T.Treatment_ID = 1)
      UNION ALL
      SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID2 from treatment AS T WHERE T.Treatment_ID = 1)
      UNION ALL
      SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID3 from treatment AS T WHERE T.Treatment_ID = 1)) tbl;

SELECT SUM(TotalSum)
from (SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID1 from treatment AS T WHERE T.Treatment_ID = 2)
      UNION ALL
      SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID2 from treatment AS T WHERE T.Treatment_ID = 2)
      UNION ALL
      SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID3 from treatment AS T WHERE T.Treatment_ID = 2)) tbl;

SELECT SUM(TotalSum)
from (SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID1 from treatment AS T WHERE T.Treatment_ID = 3)
      UNION ALL
      SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID2 from treatment AS T WHERE T.Treatment_ID = 3)
      UNION ALL
      SELECT SUM(TFB.TreatFees) AS TotalSum
      FROM treatfeesbook AS TFB
      WHERE TFB.Treat_ID = (select T.Treat_ID3 from treatment AS T WHERE T.Treatment_ID = 3)) tbl;

/*
 To manually insert data into the treatment tables it is necessary to generate the following commands.
 Speciality_ID = 0 = 'Clinic Treatment'
 Bill_ID = NULL - We don't have bill id yet.
 Appointment_ID = 3 is the appointment fot the patient 103 (Murphy Riley)
 Treat_ID1 = (12001, 'Examination', 50),if we has done more then one treatment in the same appointment,
 we can keep adding treatment.
 Speciality_Detail (0, 'Clinic Treatment'),

 SELECT Speciality_Area FROM Speciality WHERE Speciality_ID = 0;

*/

INSERT INTO Patient_Bill(Appointment_ID, Speciality_ID, Speciality_Area, DescriptionBill, TotalAmount, isPaid,
                         date_Bill)
VALUES (3, 0, 'Clinic Treatment', 'TREATMENT', 50, 'NO', SYSDATE());

INSERT INTO Patient_Bill(Appointment_ID, Speciality_ID, Speciality_Area, DescriptionBill, TotalAmount, isPaid,
                         date_Bill)
VALUES (4,
        0,
        (SELECT Speciality_Area FROM Speciality WHERE Speciality_ID = 0),
        'TREATMENT',
        (SELECT SUM(TotalSum)
         from (SELECT SUM(TFB.TreatFees) AS TotalSum
               FROM treatfeesbook AS TFB
               WHERE TFB.Treat_ID = (select T.Treat_ID1 from treatment AS T WHERE T.Treatment_ID = 2)
               UNION ALL
               SELECT SUM(TFB.TreatFees) AS TotalSum
               FROM treatfeesbook AS TFB
               WHERE TFB.Treat_ID = (select T.Treat_ID2 from treatment AS T WHERE T.Treatment_ID = 2)
               UNION ALL
               SELECT SUM(TFB.TreatFees) AS TotalSum
               FROM treatfeesbook AS TFB
               WHERE TFB.Treat_ID = (select T.Treat_ID3 from treatment AS T WHERE T.Treatment_ID = 2)) tbl),
        'NO',
        SYSDATE());


INSERT INTO Patient_Bill(Appointment_ID, Speciality_ID, Speciality_Area, DescriptionBill, TotalAmount, isPaid,
                         date_Bill)
VALUES (5,
        2,
        (SELECT Speciality_Area FROM Speciality WHERE Speciality_ID = 2),
        'TREATMENT',
        (SELECT SUM(TotalSum)
         from (SELECT SUM(TFB.TreatFees) AS TotalSum
               FROM treatfeesbook AS TFB
               WHERE TFB.Treat_ID = (select T.Treat_ID1 from treatment AS T WHERE T.Treatment_ID = 3)
               UNION ALL
               SELECT SUM(TFB.TreatFees) AS TotalSum
               FROM treatfeesbook AS TFB
               WHERE TFB.Treat_ID = (select T.Treat_ID2 from treatment AS T WHERE T.Treatment_ID = 3)
               UNION ALL
               SELECT SUM(TFB.TreatFees) AS TotalSum
               FROM treatfeesbook AS TFB
               WHERE TFB.Treat_ID = (select T.Treat_ID3 from treatment AS T WHERE T.Treatment_ID = 3)) tbl),
        'NO',
        SYSDATE());


-- ******************************################################################################
-- ****************************** create procedure TREATMENT RECORD
-- ******************************################################################################
DROP
    PROCEDURE IF EXISTS TREATMENT_RECORD;
DELIMITER  $$
CREATE PROCEDURE TREATMENT_RECORD(IN R_Speciality_ID INT, IN R_Appointment_ID smallint, IN R_Treat_ID1 smallint,
                                  IN R_Treat_ID2 smallint, IN R_Treat_ID3 smallint, R_Record_Treat varchar(255))
BEGIN
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

END $$
DELIMITER ;

-- ##############################################################################################
-- ****************************** CREATE PROCEDURE TO DELETE APPOINTMENTS  #######################
-- ##############################################################################################

-- late cancellations are charged a €10 late cancellation fee.
-- We will assume that appointments canceled on the same day will be charged.

DROP
    PROCEDURE IF EXISTS DELETE_APPOINTMENTS;
DELIMITER $$
CREATE PROCEDURE DELETE_APPOINTMENTS(IN Appointment_NUM SMALLINT)

BEGIN
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


END $$
DELIMITER
    ;

-- ********* APPOINTMENT TEST DELETE PROCEDURE
CALL SET_NEW_APPOINTMENT(117, (SELECT DAY(CURRENT_DATE())),
                         (SELECT MONTH(CURRENT_DATE())), 12, 00);
CALL SET_NEW_APPOINTMENT(117, (SELECT DAY(CURRENT_DATE())),
                         (SELECT MONTH(CURRENT_DATE()) + 1), 12, 00);

-- This appointment will be charged 10 euros, generating a bill and the status on the appointment table will change to CANCEL.
CALL DELETE_APPOINTMENTS(18);

-- Only appointment with value NULL on status can be deleted
-- this prevents a patient from being billed twice, or a patient
-- who has already had the treatment performed from being charged
-- for a cancellation of a treatment already performed.
CALL DELETE_APPOINTMENTS(19);
CALL DELETE_APPOINTMENTS(18);


-- ********* INSERT TWO NEW PATIENTS WHO SHARE THE SAME ADDRESS
-- CALL NEW_PATIENT_ALL( First Name ,  Surname , DOB, PhoneHome, CellPhone, StreetAddress, City, EirCode);
CALL NEW_PATIENT_ALL('Fallon', 'Ford', '1980-12-21', '01 368 3803', '054 456 1830', 'Ap #612-6463 Ullamcorper Av.',
                     'Durrus', 'T82 P7L83');
CALL NEW_PATIENT_ALL('Eve', 'Ford', '1982-04-18', NULL, '050 318 9301', NULL, NULL, 'T82 P7L83');

-- ********* APPOINTMENT FOR TWO NEW PATIENTS
CALL SET_NEW_APPOINTMENT(129, 06, 05, 14, 30);
CALL SET_NEW_APPOINTMENT(130, 06, 05, 15, 00);

-- ********* RECORD TREATMENT FOR TWO NEW PATIENTS
CALL TREATMENT_RECORD(0, 20, 12001, 12004, 12013, 'RECORD Examination, Small X-Rays AND Premolar Tooth');
CALL TREATMENT_RECORD(0, 21, 12001, 0, 0, 'RECORD Examination AND specialist cases referred...');
CALL TREATMENT_RECORD(6, 21, 0, 0, 0, 'RECORD on specialist cases...');



-- ##############################################################################################
-- *********************************    PAYMENT      ******* ##################################
-- ##############################################################################################

/*
 The payment record table made by patients depends on the
 PATIENT_BILL key where we have the information of the
 amount to be paid and the patient's key.
 */
-- ****************************************************
CREATE TABLE IF NOT EXISTS Payment
(
    Pay_ID           smallint NOT NULL AUTO_INCREMENT,
    Patient_ID       smallint,
    Amount_To_Pay    INT      NOT NULL,
    Bill_ID          smallint,
    TotalAmountBill  float,
    datePay          datetime NOT NULL,
    Amount_Paid      float    NOT NULL,
    New_Total_To_Pay INT      NOT NULL,

    PRIMARY KEY (Pay_ID)
);
ALTER TABLE Payment
    ADD FOREIGN KEY (Bill_ID) REFERENCES Patient_Bill (Bill_ID) ON DELETE RESTRICT,
    ADD FOREIGN KEY (Patient_ID) REFERENCES Patient (Patient_ID) ON DELETE RESTRICT;


/*
-- ******************************  create new payments
To identify a payment, we need the following data
    Patient_ID , identify the patient
    Amount_To_Pay - total amount of the patient's debt,
    Bill_ID  - identify the bill you want to pay
    TotalAmountBill - Total amount of treatment bill you want to pay
    datePay          datetime N
    Amount_Paid
    New_Total_To_Pay = Amount_To_Pay - Amount_Paid

*** If the bill is paid in full, it must be updated to
*** YES in the isPaid field and the amount must be updated to zero.
*/


INSERT INTO Payment(Patient_ID, Amount_To_Pay, Bill_ID, TotalAmountBill, datePay, Amount_Paid, New_Total_To_Pay)
VALUES (103, 50, 1, 50, SYSDATE(), 40, 10);

UPDATE Patient_Bill
SET TotalAmount = 10
WHERE Bill_ID = 1;

INSERT INTO Payment(Patient_ID, Amount_To_Pay, Bill_ID, TotalAmountBill, datePay, Amount_Paid, New_Total_To_Pay)
VALUES (103, 10, 1, 10, SYSDATE(), 10, 0);

UPDATE Patient_Bill
SET TotalAmount = 0,
    isPaid      = 'YES'
WHERE Bill_ID = 1;


-- ******* GET THE FULL VALUE OF THE ACCOUNT WITH INNER JOIN

SELECT SUM(Patient_Bill.TotalAmount)
FROM patient_bill
         INNER JOIN appointment ON appointment.Appointment_ID = Patient_Bill.Appointment_ID
         INNER JOIN Patient ON Patient.Patient_ID = appointment.Patient_ID
WHERE Patient.Patient_ID = 130;

-- ##############################################################################################
-- **************************   create procedure PAYMENT       ##################################
-- ##############################################################################################

DROP
    PROCEDURE IF EXISTS MAKE_PAYMENT;
DELIMITER
    $$
CREATE PROCEDURE MAKE_PAYMENT(IN MP_Bill_ID SMALLINT, IN MP_PatientID SMALLINT, IN MP_AmountPay INT)
BEGIN
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

END
$$
DELIMITER ;

-- ********* APPOINTMENT FOR TWO NEW PATIENTS
CALL SET_NEW_APPOINTMENT(129, 07, 05, 14, 30);
CALL SET_NEW_APPOINTMENT(130, 07, 05, 15, 00);

-- ********* RECORD TREATMENT FOR TWO NEW PATIENTS
CALL TREATMENT_RECORD(0, 22, 12003, 12005, 12018, 'RECORD TEST');
CALL TREATMENT_RECORD(0, 23, 12009, 12013, 0, 'RECORD TEST...');
CALL TREATMENT_RECORD(6, 23, 0, 0, 0, 'RECORD on specialist cases...');

-- ********* MAKE PAYMENT
CALL MAKE_PAYMENT(8, 129, 100);
CALL MAKE_PAYMENT(8, 129, 50);
CALL MAKE_PAYMENT(8, 129, 5);

CALL MAKE_PAYMENT(9, 129, 1150);


-- ##############################################################################################
-- ******************************#####     CREATE VIEW         ##################################
-- ##############################################################################################

CREATE VIEW PATIENTS_AGE AS
SELECT FirstName,
       Surname,
       DOB,
       year(curdate()) - year(DOB) as patientAge
FROM patient;

CREATE VIEW PEDIATRIC_PATIENTS AS
SELECT PATIENTS_AGE.*,
       patient.Patient_ID,
       patient.AddressID
FROM PATIENTS_AGE
         INNER JOIN patient ON patient.FirstName = PATIENTS_AGE.FirstName AND patient.Surname = PATIENTS_AGE.Surname
WHERE patientAge < 16;

CREATE VIEW FAMILY_Riley AS
SELECT *
FROM patient
WHERE Surname = 'Riley';

UPDATE FAMILY_Riley
SET FAMILY_Riley.PhoneHome = '01 239 5971'
WHERE Surname = 'Riley';

CREATE OR REPLACE VIEW PATIENT_JOIN AS
SELECT patient.Patient_ID,
       patient.FirstName,
       patient.Surname,
       patients_age.patientAge,
       patientdetail.*,
       patient.PhoneHome,
       patient.CellPhone
FROM patient
         INNER JOIN patients_age
                    ON (patients_age.FirstName = patient.FirstName AND patient.Surname = patients_age.Surname)
         LEFT JOIN patientdetail
                   ON patient.AddressID = patientdetail.AddressID;


CREATE OR REPLACE VIEW INFO_PATIENT_BILL_APPOINTMENT AS
SELECT Patient.Patient_ID,
       FirstName,
       Surname,
       appointment.Appointment_ID,
       Patient_Bill.TotalAmount
FROM patient_bill
         INNER JOIN appointment ON appointment.Appointment_ID = Patient_Bill.Appointment_ID
         INNER JOIN Patient ON Patient.Patient_ID = appointment.Patient_ID
GROUP BY appointment.Appointment_ID DESC;


CREATE OR REPLACE VIEW INFO_PATIENT_TOTAL_BILL AS
SELECT Patient.Patient_ID,
       FirstName,
       Surname,
       SUM(Patient_Bill.TotalAmount)
FROM patient_bill
         INNER JOIN appointment ON appointment.Appointment_ID = Patient_Bill.Appointment_ID
         INNER JOIN Patient ON Patient.Patient_ID = appointment.Patient_ID
GROUP BY Patient.Patient_ID;

