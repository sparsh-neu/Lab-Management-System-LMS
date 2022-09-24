-- Team 14
-- Lab Management System
-- Krishna Pal Singh - NUID - 002954173 
-- Mohit Malani - NUID - 001568891
-- Nagashree Seshadri - NUID - 001050979
-- Rajiv Ranjan Sahu - NUID - 002101619
-- Sparsh Sinha - NUID - 001000390



-- Our SQL code implements the database design and each entities have at least 10 rows.
-- We have used insert script and stored procedures to create data for each entity
-- The 19 entities in our database includes precise data types all the primary and foreign keys are implemented 
-- We have created 6 views that span multiple tables and used for ease of lookup since our database houses a large volume of tables and data.
-- 2 table level check constraints are implemented - Zip Code and Payment Type Checker
-- Multiple computed columns are implemented - age, diagnostic center review, test infection severity
-- The ID's of all the entities are auto incremented And are prefixed with entity type (PIDxxx1, INSxxx1), 
-- Implemented column data encryption for SSN in patient entity
-- We have also created a backup of our database in the server to prevent downtime

--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

-- NOTE: We have auto-incremented columns (PK, FK) that are referred in multiple tables, deleting a record might interefere with the referenced records.

--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------
-------------------------------------------------------------





-- 1. DDL (Create Tables)

CREATE TABLE [Address](
[ID] INT IDENTITY(1,1) NOT NULL,
[Address_id] AS 'ADD_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Address_line1] VARCHAR(80) NOT NULL,
[City] VARCHAR(30) NOT NULL,
[Zipcode] CHAR(5) NOT NULL, --have a table level constraint to check to see if the entry is restricted to just 5 characters i.e. numbers
[State] VARCHAR(40) NOT NULL,
PRIMARY KEY (Address_id)
);

select * from [Address];

-----------------------------------------------

CREATE TABLE Insurance(
[ID] INT IDENTITY(1,1) NOT NULL,
[Insurance_id] AS 'INS_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Insurance_company] VARCHAR(40) NOT NULL,
PRIMARY KEY ([Insurance_id])
);

select * from Insurance;

-----------------------------------------------------

-- Use VARBINARY as the data type for the encrypted column
CREATE TABLE Patient(
[ID] INT IDENTITY(1,1) NOT NULL,
[Patient_id] AS 'PID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Patient_first_name] VARCHAR(40) NOT NULL,
[Patient_last_name] VARCHAR(40) NOT NULL,
[Patient_contact_number] VARCHAR(20) NOT NULL,
[Patient_email_address] VARCHAR(60) NOT NULL,
[Patient_date_of_birth] DATE NOT NULL, 
[Patient_age] AS DATEDIFF(hour,[Patient_date_of_birth], GETDATE())/8766,
[Patient_ssn] VARBINARY(256), 
[Patient_emergency_contact_number] VARCHAR(20),
[Patient_emergency_contact_relationship] VARCHAR(30),
[Patient_covid_history] BIT NOT NULL,
[Insurance_id] VARCHAR(16),
[Address_id] VARCHAR(16),
PRIMARY KEY ([Patient_id]),
FOREIGN KEY ([Insurance_id]) REFERENCES [Insurance]([Insurance_id]),
FOREIGN KEY ([Address_id]) REFERENCES [Address]([Address_id])
);

select * from Patient;

--------------------------------------------

CREATE TABLE Account(
[ID] INT IDENTITY(1,1) NOT NULL,
[Account_id] AS 'ACCID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Total_due_amount] DECIMAL(13,2), 
[Due_date] DATE, 
[Payment_type] VARCHAR(30), 
[Last_paid_date] DATE, 
[Patient_id] VARCHAR(13),
[Insurance_id] VARCHAR(16),
PRIMARY KEY ([Account_id]),
FOREIGN KEY ([Patient_id]) REFERENCES Patient([Patient_id]),
FOREIGN KEY ([Insurance_id]) REFERENCES [Insurance]([Insurance_id])
);

select * from Account;

-------------------------------------------------

CREATE TABLE Appointment(
[ID] INT IDENTITY(1,1) NOT NULL,
[Appointment_id] AS 'APPT_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Appointment_date] DATE, 
[Patient_id] VARCHAR(13),
FOREIGN KEY ([Patient_id]) REFERENCES Patient([Patient_id]),
PRIMARY KEY ([Appointment_id])
);

select * from Appointment;

-----------------------------------------------------------

CREATE TABLE Hospital(
[ID] INT IDENTITY(1,1) NOT NULL,
[Hospital_id] AS 'HOS_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Hospital_name] VARCHAR(60) NOT NULL,
[Hospital_phone] VARCHAR(20) NOT NULL,
[Hospital_email_address] VARCHAR(60),
[Hospital_website] VARCHAR(60),
[Address_id] VARCHAR(16),
FOREIGN KEY ([Address_id]) REFERENCES [Address]([Address_id]),
PRIMARY KEY ([Hospital_id])
);

select * from Hospital;

-------------------------------------------------------------------

CREATE TABLE Doctor(
[ID] INT IDENTITY(1,1) NOT NULL,
[Doctor_id] AS 'DOC_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Doctor_first_name] VARCHAR(40) NOT NULL,
[Doctor_last_name] VARCHAR(40) NOT NULL,
[Doctor_email_address] VARCHAR(60),
[Doctor_contact_number] VARCHAR(20) NOT NULL,
[Patient_id] VARCHAR(13),
[Hospital_id] VARCHAR(16),
FOREIGN KEY ([Patient_id]) REFERENCES Patient([Patient_id]),
FOREIGN KEY ([Hospital_id]) REFERENCES Hospital([Hospital_id]),
PRIMARY KEY([Doctor_id])
);

select * from Doctor;

------------------------------------------------------------------------------------------

CREATE TABLE Diagnostic_center(
[ID] INT IDENTITY(1,1) NOT NULL,
[Diagnostic_center_id] AS 'DC_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Diagnostic_center_name] VARCHAR(40) NOT NULL,
[Diagnostic_center_contact_number] VARCHAR(20) NOT NULL,
[Diagnostic_center_email_address] VARCHAR(60),
[Diagnostic_center_website] VARCHAR(60),
[Diagnostic_center_rating] DECIMAL(2,1), 
[Address_id] VARCHAR(16),
[Appointment_id] VARCHAR(17),
[Diagnostic_centre_review] AS 
(CASE
WHEN [Diagnostic_center_rating] >= 3.5 THEN 'Excellent' 
WHEN [Diagnostic_center_rating] > 2.5 THEN 'Fair' 
ELSE 'Poor'
END),
FOREIGN KEY ([Address_id]) REFERENCES [Address]([Address_id]),
FOREIGN KEY ([Appointment_id]) REFERENCES [Appointment]([Appointment_id]),
PRIMARY KEY([Diagnostic_center_id])
);

select * from [Diagnostic_center];

------------------------------------------------------------------------

CREATE TABLE Supplier(
[ID] INT IDENTITY(1,1) NOT NULL,
[Supplier_id] AS 'SUP_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Supplier_first_name] VARCHAR(40) NOT NULL,
[Supplier_last_name] VARCHAR(40) NOT NULL,
[Supplier_type] VARCHAR(40),
[Supply_quantity] INT,
[Supplier_contact_number] VARCHAR(20),
[Supplier_website] VARCHAR(60),
[Supplier_email_address] VARCHAR(60),
PRIMARY KEY([Supplier_id])
);

select * from Supplier;

---------------------------------------------------------------------------

CREATE TABLE Supply_kit(
[ID] INT IDENTITY(1,1) NOT NULL,
[Supply_kit_id]    AS 'KIT_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Supply_kit_type] VARCHAR(60),
[Supplier_id] VARCHAR(16),
FOREIGN KEY ([Supplier_id]) REFERENCES Supplier([Supplier_id]),
PRIMARY KEY([Supply_kit_id])
);

select * from Supply_kit;

---------------------------------------------------

CREATE TABLE Lab(
[ID] INT IDENTITY(1,1) NOT NULL,
[Lab_id] AS 'LAB_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Lab_type] VARCHAR(40) NOT NULL,
[Lab_capacity] INT,
[Diagnostic_center_id] VARCHAR(15),
[Supply_kit_id] VARCHAR(16),
FOREIGN KEY ([Diagnostic_center_id]) REFERENCES [Diagnostic_center]([Diagnostic_center_id]),
FOREIGN KEY ([Supply_kit_id]) REFERENCES [Supply_kit]([Supply_kit_id]),
PRIMARY KEY ([Lab_id])
);

select * from Lab;

-----------------------------------------------------------------

CREATE TABLE Lab_technician(
[ID] INT IDENTITY(1,1) NOT NULL,
[Lab_technician_id]    AS 'LT_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Lab_technician_first_name]    VARCHAR(40) NOT NULL,
[Lab_technician_last_name] VARCHAR(40) NOT NULL,
[Lab_technician_email_address] VARCHAR(60),
[Lab_technician_contact_number] VARCHAR(20),
[Address_id] VARCHAR(16),
[Lab_id] VARCHAR(16),
FOREIGN KEY ([Lab_id]) REFERENCES Lab([Lab_id]),
FOREIGN KEY ([Address_id]) REFERENCES [Address]([Address_id]),
PRIMARY KEY ([Lab_technician_id])
);

select * from Lab_technician;

---------------------------------------------------

CREATE TABLE Lab_device(
[ID] INT IDENTITY(1,1) NOT NULL,
[Lab_device_id] AS 'DEV_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Lab_device_name] VARCHAR(40) NOT NULL,
[Lab_device_status] BIT NOT NULL,
[Lab_id] VARCHAR(16),
FOREIGN KEY ([Lab_id]) REFERENCES Lab([Lab_id]),
PRIMARY KEY ([Lab_device_id])
);

select * from Lab_device;

----------------------------------------------------------------------

CREATE TABLE Test(
[ID] INT IDENTITY(1,1) NOT NULL,
[Test_id] AS 'TEST_ID' + RIGHT('00' + CAST(ID AS VARCHAR(8)),20) PERSISTED,
[Test_date]    DATE NOT NULL,
[Test_type]    VARCHAR(40) NOT NULL,
[Test_result] VARCHAR(40) NOT NULL,
[Test_infection_severity] DECIMAL(2,1), -- restrict rating upto 5
[Test_remarks] AS
(CASE
WHEN [Test_infection_severity] > 4 THEN 'Critical'
WHEN [Test_infection_severity] > 3 THEN 'Moderate'
ELSE
'Rest advised'
END), 
[Lab_id] VARCHAR(16),
[Doctor_id] VARCHAR(16),
[Patient_id] VARCHAR(13),
FOREIGN KEY ([Lab_id]) REFERENCES [Lab] ([Lab_id]),
FOREIGN KEY ([Doctor_id]) REFERENCES [Doctor] ([Doctor_id]),
FOREIGN KEY ([Patient_id]) REFERENCES [Patient] ([Patient_id]),
PRIMARY KEY ([Test_id])
);

select * from Test;

---------------------------------------------------------------------

CREATE TABLE Lab_supply_kit(
[Lab_id] VARCHAR(16),
[Supply_kit_id] VARCHAR(16),
PRIMARY KEY([Lab_id], [Supply_kit_id]), 
FOREIGN KEY ([Lab_id]) REFERENCES [Lab]([Lab_id]),
FOREIGN KEY ([Supply_kit_id]) REFERENCES [Supply_kit]([Supply_kit_id])
);

select * from Lab_supply_kit;

------------------------------------------------------------------------------

CREATE TABLE Supply_kit_suppliers(
[Supply_kit_id] VARCHAR(16),
[Supplier_id] VARCHAR(16),
PRIMARY KEY(Supply_kit_id, Supplier_id),
FOREIGN KEY ([Supply_kit_id]) REFERENCES [Supply_kit]([Supply_kit_id]),
FOREIGN KEY ([Supplier_id]) REFERENCES [Supplier]([Supplier_id])
);

select * from Supply_kit_suppliers;

-----------------------------------------------------------

CREATE TABLE Patient_doctor(
[Patient_id] VARCHAR(13),
[Doctor_id] VARCHAR(16),
PRIMARY KEY([Patient_id], [Doctor_id]),
FOREIGN KEY ([Patient_id]) REFERENCES Patient([Patient_id]),
FOREIGN KEY ([Doctor_id]) REFERENCES Doctor([Doctor_id])
);

select * from Patient_doctor;

-------------------------------------------------

CREATE TABLE Test_doctor(
[Test_id] VARCHAR(17),
[Doctor_id] VARCHAR(16),
PRIMARY KEY([Test_id], Doctor_id),
FOREIGN KEY ([Test_id]) REFERENCES Test([Test_id]),
FOREIGN KEY ([Doctor_id]) REFERENCES Doctor([Doctor_id])
);

select * from Test_doctor;

-------------------------------------------------------

CREATE TABLE Hospital_doctor(
[Hospital_id] VARCHAR(16), 
[Doctor_id] VARCHAR(16),
PRIMARY KEY([Hospital_id], [Doctor_id]),
FOREIGN KEY ([Hospital_id]) REFERENCES Hospital([Hospital_id]),
FOREIGN KEY ([Doctor_id]) REFERENCES Doctor([Doctor_id])
);

select * from Hospital_doctor;



-------------------------------------------------------------
-------------------------------------------------------------


-- 2. Views

-- View to check the addresses for each of the Hospitals

GO
CREATE VIEW Hospital_name_and_address 
AS
select h.Hospital_id, h.Hospital_name,ad.Address_id, ad.Address_line1, ad.City, ad.State, ad.Zipcode
from Hospital h
join Address ad
on h.Address_id = ad.Address_id;

select * from Hospital_name_and_address;

--View to check the diagnostic centre addressess

GO
CREATE VIEW Diagnostic_name_and_address
AS
select dc.Diagnostic_center_id, dc.Diagnostic_center_name, dc.Diagnostic_centre_review, ad.Address_id, ad.Address_line1, ad.City, ad.State, ad.Zipcode
from Diagnostic_center dc
join Address ad
on dc.Address_id = ad.Address_id;

select * from Diagnostic_name_and_address;

---Patient addresses VIEW

GO
CREATE VIEW Patient_name_and_address
AS
select p.Patient_id, Patient_first_name, p.Patient_last_name, ad.Address_id, ad.Address_line1, ad.City, ad.State, ad.Zipcode
from Patient p
join Address ad
on p.Address_id = ad.Address_id;

select * from Patient_name_and_address;

--View lab technician addresses

GO
CREATE VIEW Lab_technician_name_and_address
AS
select lt.Lab_technician_id, lt.Lab_technician_first_name, lt.Lab_technician_last_name, ad.Address_id, ad.Address_line1, ad.City, ad.State, ad.Zipcode
from Lab_technician lt
join Address ad
on lt.Address_id = ad.Address_id;

select * from Lab_technician_name_and_address;

--check what happens to the views once this is complete

GO
CREATE VIEW Diagnostic_centre_and_labs
AS
with diag_lab as
(select d.ID, d.Diagnostic_center_id, d.Diagnostic_center_name, d.Diagnostic_center_rating, d.Diagnostic_centre_review, l.Lab_id
from Diagnostic_center d
join Lab l
on d.Diagnostic_center_id = l.Diagnostic_center_id)


select distinct diag_lab.Diagnostic_center_id, diag_lab.Diagnostic_center_name, diag_lab.Diagnostic_centre_review,
STUFF((select ', ' + CAST(dl.Lab_id as varchar)
      from diag_lab dl
	  where diag_lab.Diagnostic_center_id = dl.Diagnostic_center_id
	  order by dl.ID
	  for xml path('')), 1, 2, '') as Labs_in_diagnostic_center
from
diag_lab;

select*
from Diagnostic_centre_and_labs;

select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'Diagnostic_centre_and_labs';

--View that tells which lab technicians are employed by what lab

GO
CREATE VIEW Lab_and_Lab_technicians
AS
with lab_tech as
(select l.ID, l.Lab_id, l.Lab_type, l.Lab_capacity, lt.Lab_technician_id, lt.Lab_technician_first_name, lt.Lab_technician_last_name
from Lab l
join Lab_technician lt
on l.Lab_id = lt.Lab_id)

select distinct ID, Lab_id, Lab_type, Lab_capacity, 
STUFF(   
               (
                       SELECT DISTINCT ', ' + isnull(convert(varchar(20),fin.Lab_technician_id),'')
					   + '  ' + isnull(convert(varchar(20),fin.Lab_technician_first_name),'') + ' ' 
					   + isnull(convert(varchar(20),fin.Lab_technician_last_name),'') 
                       FROM lab_tech fin --use the cte table and give it an alias
                       WHERE fin.Lab_id = lab_tech.Lab_id --use the cte table name join it on the alias's name
                       FOR XML PATH('')
                   )
               , 1, 2, ''
           ) [Lab_technicians_at_work]
from
lab_tech;











































-------------------------------------------------------------
-------------------------------------------------------------


-- 3. Creating Database



-- DROP DATABASE TEAM14_LMS;

CREATE DATABASE TEAM14_LMS;

Use TEAM14_LMS;




-------------------------------------------------------------
-------------------------------------------------------------



-- 4. Creating Key and Certificate for Encryption


-- Create DMK
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'LMSP@sswOrd';

-- Create certificate to protect symmetric key
CREATE CERTIFICATE LMSCertificate
WITH SUBJECT = 'LMS Certificate',
EXPIRY_DATE = '2026-10-31';

-- Create symmetric key to encrypt data
CREATE SYMMETRIC KEY LMSSymmetricKey
WITH ALGORITHM = AES_128
ENCRYPTION BY CERTIFICATE LMSCertificate;

-- Open symmetric key
OPEN SYMMETRIC KEY LMSSymmetricKey
DECRYPTION BY CERTIFICATE LMSCertificate;






---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------



-- 5. TABLE LEVEL CONSTRAINTS USING FUNCTIONS


-- checking if zip is of length 5
GO
CREATE FUNCTION ufCheckZip(@getZip CHAR(5))
RETURNS BIT
AS
BEGIN
	DECLARE @flag bit;
	IF ISNUMERIC(@getZip) = 1 AND LEN(@getZip) = 5
		BEGIN
			SET @flag = 1;
		END
	ELSE
		BEGIN 
			SET @flag = 0;
		END
	RETURN @flag;
END
GO



ALTER TABLE [Address]
ADD CONSTRAINT numericZipCheck CHECK (dbo.ufCheckZip([Zipcode]) = 1);

-- Have a constraint to check if payment values are cash, check or card

GO
CREATE FUNCTION ufPaymentTypeChecker(@paymentType VARCHAR(30))
RETURNS BIT
AS
BEGIN
	DECLARE @flag BIT;
	IF ((LOWER(@paymentType) = 'card') OR (LOWER(@paymentType) = 'cheque') OR (LOWER(@paymentType) = 'cash') OR ((LOWER(@paymentType) = 'insurance')))
		BEGIN
			SET @flag = 1
		END 
	ELSE
		BEGIN
			SET @flag = 0
		END
	RETURN @flag;
END

ALTER TABLE Account
ADD CONSTRAINT payTypeChecker CHECK (dbo.ufPaymentTypeChecker([Payment_type]) = 1);



---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------



-- 6. TRIGGERS



-- Delete a patient and the patient's corresponding address

GO
CREATE TRIGGER trPatientAddDelete ON Patient
FOR DELETE

AS BEGIN
	declare @patID VARCHAR(13);
	declare @addID VARCHAR(16);

	select @patID= del.Patient_id FROM deleted del;

	select @addID= del.Address_id FROM deleted del;

DELETE FROM Patient 
WHERE Patient_id = @patID;

DELETE FROM Address 
WHERE Address_id = @addID;
END
GO

select * from Patient order by ID;
select * from Address order by ID;

-- delete from Patient
-- where Patient_id = 'PID001';

---------------------------------------------

-- Delete a hospital and its corresponding address

-- select h.Hospital_id, a.Address_id
-- from Hospital h
-- join Address a
-- on h.Address_id = a.Address_id
-- order by h.ID;

GO
CREATE TRIGGER trHosAddrsDelete ON Hospital
FOR DELETE

AS BEGIN
	declare @hosID VARCHAR(13);
	declare @addID VARCHAR(16);

	select @hosID= del.Hospital_id FROM deleted del;

	select @addID= del.Address_id FROM deleted del;

DELETE FROM Hospital
WHERE Hospital_id = @hosID;

DELETE FROM Address 
WHERE Address_id = @addID;
END
GO

-- delete from Hospital
-- where Hospital_id = 'HOS_ID001';


------------------------------------------

-- Delete diagnostic center and its address from corresponding tables.

select d.Diagnostic_center_id, a.Address_id
from Diagnostic_center d
join Address a
on d.Address_id = a.Address_id
order by d.ID;

GO
CREATE TRIGGER trDiaCenAddrsDelete ON Diagnostic_center
FOR DELETE

AS BEGIN
	declare @diaID VARCHAR(13);
	declare @addID VARCHAR(16);

	select @diaID= del.Diagnostic_center_id FROM deleted del;

	select @addID= del.Address_id FROM deleted del;

DELETE FROM Diagnostic_center
WHERE Diagnostic_center_id = @diaID;

-- delete from Diagnostic_center 
-- where Diagnostic_center_id = 'DC_ID001';

-- DELETE FROM Address 
-- WHERE Address_id = @addID;
-- END
-- GO

-----------------------------------------------------

-- Delete lab technician's address everytime a lab technician entry is removed from the table

select * from Lab_technician order by ID;
select * from Address order by ID;

GO
CREATE TRIGGER trLabTechAddrsDelete ON Lab_technician
FOR DELETE

AS BEGIN
	declare @ltID VARCHAR(13);
	declare @addID VARCHAR(16);

	select @ltID= del.Lab_technician_id FROM deleted del;

	select @addID= del.Address_id FROM deleted del;

DELETE FROM Lab_technician
WHERE Lab_technician_id = @ltID;

DELETE FROM Address 
WHERE Address_id = @addID;
END
GO

-- delete from Lab_technician 
-- where Lab_technician_id = 'LT_ID001';



----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------


-- 7. Stored Procedures for Data Insertion

-- Inserting data in order of References

CREATE PROCEDURE FillAddressTable
       @add_line1  VARCHAR (80), 
       @cityVar VARCHAR (30),
       @zipVar CHAR (5),
       @stateVar VARCHAR (40)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Address]([Address_line1],[City],[Zipcode],[State])
        VALUES 
        (@add_line1, @cityVar, @zipVar, @stateVar)
END;

select * from Address Order by ID ;


EXECUTE FillAddressTable '14 Copenger St','Boston','12220','MA';
EXECUTE FillAddressTable '160 Cambridge St','Winchester','12044','MA';
EXECUTE FillAddressTable '5921 NE 66th St','Oklahoma City','73141','OK';
EXECUTE FillAddressTable '1201 Rt 300','Newburgh','12550','NY';
EXECUTE FillAddressTable '4765 Commercial Drive','New Hartford','13413','NY';
EXECUTE FillAddressTable '41 Anawana Lake Road','Monticello','12701','NY';
EXECUTE FillAddressTable '288 Larkin','Monroe','10950','NY';
EXECUTE FillAddressTable '3133 E Main St','Mohegan Lake','10547','NY';
EXECUTE FillAddressTable '470 Route 211 East','Middletown','10940','NY';
EXECUTE FillAddressTable '750 Middle Country Road','Middle Island','11953','NY';
EXECUTE FillAddressTable '43 Stephenville St','Massena','13662','NY';
EXECUTE FillAddressTable '200 Sunrise Mall','Massapequa','11758','NY';
EXECUTE FillAddressTable '301 Falls Blvd','Quincy','21691','MA';
EXECUTE FillAddressTable '300 Colony Place','Plymouth','23610','MA';
EXECUTE FillAddressTable '555 Hubbard Ave-Suite 12','Pittsfield','12031','MA';
EXECUTE FillAddressTable '555 East Main St','Orange','11364','MA';
EXECUTE FillAddressTable '180 North King Street','Northampton','10160','MA';
EXECUTE FillAddressTable '224 South Queen Street','Northampton','10160','MA';
EXECUTE FillAddressTable '200 Otis Street','Northborough','15320','MA';
EXECUTE FillAddressTable '72 Main St','North Reading','18640','MA';
EXECUTE FillAddressTable '742 Main Street','North Oxford','15370','MA';
EXECUTE FillAddressTable '506 State Road','North Dartmouth','27470','MA';
EXECUTE FillAddressTable '1470 S Washington St','North Attleboro','27600','MA';
EXECUTE FillAddressTable '337 Russell St','Hadley','10350','MA';
EXECUTE FillAddressTable '295 Plymouth Street','Halifax','23380','MA';
EXECUTE FillAddressTable '1775 Washington St','Hanover','23390','MA';
EXECUTE FillAddressTable '280 Washington Street','Hudson','17490','MA';
EXECUTE FillAddressTable '20 Soojian Dr','Leicester','15240','MA';
EXECUTE FillAddressTable '11 Jungle Road','Leominster','14530','MA';
EXECUTE FillAddressTable '301 Massachusetts Ave','Lunenburg','11462','MA';
EXECUTE FillAddressTable '780 Lynnway','Lynn','11905','MA';
EXECUTE FillAddressTable '70 Pleasant Valley Street','Methuen','11844','MA';
EXECUTE FillAddressTable '830 Curran Memorial Hwy','North Adams','11247','MA';
EXECUTE FillAddressTable '777 Brockton Avenue','Abington','12351','MA';
EXECUTE FillAddressTable '30 Memorial Drive','Avon','12322','MA';
EXECUTE FillAddressTable '250 Hartford Avenue','Bellingham','12019','MA';
EXECUTE FillAddressTable '700 Oak Street','Brockton','12301','MA';
EXECUTE FillAddressTable '66-4 Parkhurst Rd','Chelmsford','11824','MA';
EXECUTE FillAddressTable '591 Memorial Dr','Chicopee','11020','MA';
EXECUTE FillAddressTable '55 Brooksby Village Way','Danvers','11923','MA';
EXECUTE FillAddressTable '137 Teaticket Hwy','East Falmouth','12536','MA';
EXECUTE FillAddressTable '42 Fairhaven Commons Way','Fairhaven','12719','MA';
EXECUTE FillAddressTable '374 William S Canning Blvd','Fall River','12721','MA';
EXECUTE FillAddressTable '121 Worcester Rd','Framingham','11701','MA';
EXECUTE FillAddressTable '677 Timpany Blvd','Gardner','11440','MA';
EXECUTE FillAddressTable '224 South Queen Street','Northampton','10160','MA';
EXECUTE FillAddressTable '116 Peter Pan Blvd','Coronado','92123','CA'; 
EXECUTE FillAddressTable '78 Rancho Rd','San Jose','95002','CA';
EXECUTE FillAddressTable '45 Fresno Blvd','Fresno','93650','CA';
EXECUTE FillAddressTable '72-1 North Minister Street','Northampton','95035','CA';

-----------------------------------------------------

GO
CREATE PROCEDURE FillInsuranceTable
       @ins_cmp VARCHAR (40)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Insurance]([Insurance_company])
        VALUES 
        (@ins_cmp)
END;


select * from Insurance order by ID;


EXECUTE FillInsuranceTable 'Blue Cross Blue Shield';
EXECUTE FillInsuranceTable 'HSA Insurance';
EXECUTE FillInsuranceTable 'Human Health Insurance';
EXECUTE FillInsuranceTable 'Common Wealth Health Insurance';
EXECUTE FillInsuranceTable 'Mass Association of Health';
EXECUTE FillInsuranceTable 'United Healthcare';
EXECUTE FillInsuranceTable 'Health Plan Inc';
EXECUTE FillInsuranceTable 'Devoted Health, Inc';
EXECUTE FillInsuranceTable 'UniCare Massachusetts';
EXECUTE FillInsuranceTable 'Human Specialty Benefits';

--------------------------------------------------------------


-- Inserting into Patient for handling Encryption
-- Patient is referrinf Address and Insurance

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],
[Patient_ssn],[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Krish','Cena',
'(678)-976-5432','cena.k@gmail.com','1994-04-12',
EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '123-56-3556')),'(678)-976-5435','Brother',
'1','INS_ID001','ADD_ID001');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],
[Patient_ssn],[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('John','Peter',
'(567)-487-9034','peter.j@gmail.com','1998-04-20',
EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '245-65-8765')),'(564)-356-9872','Sister',
'0','INS_ID002','ADD_ID002');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],
[Patient_ssn],[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Kevin','Nash',
'(568)-790-7645','nash.k@gmail.com','1998-09-25',
EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '456-34-8976')),
'(543)-806-3216','Father','1','INS_ID006','ADD_ID003');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],
[Patient_ssn],[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Jayesh','Patel',
'(674)-677-8976','patel.j@gmail.com','1978-08-12',
EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '234-76-4536')),
'(648)-730-8628','Mother','0','INS_ID002','ADD_ID004');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],
[Patient_ssn],[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Thomas','Edison',
'(987)-654-3456','edison.t@gmail.com','1990-03-16',EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '265-76-7689')),
'(543)-806-2815','Nephew','0','INS_ID0010','ADD_ID005');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],
[Patient_ssn],[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Vince','Mathew',
'(657)-834-5267','Mathew.v@gmail.com','1996-04-13',EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '456-98-4132')),
'(647)-854-0976','Brother','1','INS_ID009','ADD_ID006');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],[Patient_ssn],
[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Savita','Tiwari',
'(564)-352-7648','tiwari.s@gmail.com','1976-02-05',EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '452-98-7689')),
'(783)-647-8109','Father','0','INS_ID002','ADD_ID007');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],
[Patient_ssn],[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Priya','Singh',
'(764)-899-3421','singh.p@gmail.com','1996-04-09',EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '987-12-3916')),
'(782)-4561-865','Sister','0','INS_ID008','ADD_ID008');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],[Patient_ssn],
[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Anjali','Patel',
'(564)-789-2453','patel.a@gmail.com','1991-05-06',EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '702-65-1723')),
'(780)-256-3876','Brother','1','INS_ID002','ADD_ID009');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],[Patient_ssn],
[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Meena','Kumar','(546)-782-4356','kumar.m@gmail.com','1994-06-07',EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '983-28-1098')),
'(135)-678-3567','Mother','0','INS_ID0010','ADD_ID0010');

INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],[Patient_ssn],
[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Matt','Hardy',
'(453)-983-1095','hardy.m@gmail.com','1992-03-03',EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '723-56-1456')),
'(986)-534-7689','Son','1','INS_ID008','ADD_ID0011');


INSERT INTO [Patient]([Patient_first_name],[Patient_last_name],
[Patient_contact_number],[Patient_email_address],[Patient_date_of_birth],[Patient_ssn],
[Patient_emergency_contact_number],[Patient_emergency_contact_relationship],
[Patient_covid_history],[Insurance_id],[Address_id]) 
VALUES ('Shawn','Michael',
'(548)-907-6541','michael.s@gmail.com','1973-05-02',EncryptByKey(Key_GUID(N'LMSSymmetricKey'), convert(varbinary, '876-35-0524')),
'(764)-567-8765','Daughter','0','INS_ID007','ADD_ID0012');

----------------------------------------------------------------------------------------------------------------------------------

-- Testing the encrypted column

-- See what we have in the table
select * from Patient;

-- Use DecryptByKey to decrypt the encrypted data and see what we have in the table
select DecryptByKey(Patient_ssn) as Patient_ssn
from Patient;

-- Use DecryptByKey to decrypt the encrypted data and see what we have in the table
-- DecryptByKey returns VARBINARY with a maximum size of 8,000 bytes
-- Also use CONVERT to convert the decrypted data to VARCHAR so that we can see the plain passwords

select convert(varchar, DecryptByKey(Patient_ssn)) as Decrypted_patient_ssn
from Patient;

----------------------------------------------------------------

CREATE PROCEDURE FillAccountTable
       @tot_d_amt DECIMAL(13,2), 
       @due_dt DATE, 
       @pay_type VARCHAR(30),
       @lst_pay_dt DATE, 
       @pat_id VARCHAR (13),
       @ins_id VARCHAR (16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Account]([Total_due_amount],[Due_date],[Payment_type],[Last_paid_date],[Patient_id],[Insurance_id])
        VALUES 
        (@Tot_d_amt, @Due_dt, @pay_type, @lst_pay_dt, @pat_id, @ins_id)
END;

select * from Account order by ID;


EXECUTE FillAccountTable 1500.55,'2022-04-15','Card','2021-10-29','PID0014','INS_ID001';
EXECUTE FillAccountTable 625.75,'2021-09-16','Insurance','2021-01-17','PID0015','INS_ID002';
EXECUTE FillAccountTable 999.99,'2022-01-27','Insurance','2021-12-20','PID0016','INS_ID003';
EXECUTE FillAccountTable 50.28,'2021-11-25','Cash','2021-06-20','PID0017','INS_ID004';
EXECUTE FillAccountTable 685.13,'2023-02-23','Card','2022-12-19','PID0018','INS_ID006';
EXECUTE FillAccountTable 89.99,'2023-02-24','Cash','2022-11-29','PID0019','INS_ID008';
EXECUTE FillAccountTable 2250.75,'2021-06-14','Cheque','2021-03-23','PID0020','INS_ID009';
EXECUTE FillAccountTable 3200.25,'2022-11-26','Insurance','2022-09-18','PID0021','INS_ID0010';
EXECUTE FillAccountTable 500.88,'2022-12-21','Cheque','2022-10-30','PID0022','INS_ID005'; 
EXECUTE FillAccountTable 340.45,'2022-09-16','Insurance','2022-07-16','PID0023','INS_ID007';
EXECUTE FillAccountTable 500.88,'2022-06-21','Cheque','2022-10-30','PID0024','INS_ID005'; 
EXECUTE FillAccountTable 340.45,'2021-09-16','Card','2022-07-16','PID0025','INS_ID0010';

-------------------------------------------------------------------------

CREATE PROCEDURE FillAppointmentTable
       @app_date DATE, 
       @pat_id VARCHAR (13)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Appointment]([Appointment_date],[Patient_id])
        VALUES 
        (@app_date, @pat_id)
END;

select * from Appointment order by ID;

EXECUTE FillAppointmentTable '2022-09-23','PID0014';
EXECUTE FillAppointmentTable '2022-12-01','PID0018';
EXECUTE FillAppointmentTable '2022-08-25','PID0016';
EXECUTE FillAppointmentTable '2022-09-04','PID0017';
EXECUTE FillAppointmentTable '2022-09-05','PID0022';
EXECUTE FillAppointmentTable '2022-09-08','PID0021';
EXECUTE FillAppointmentTable '2022-09-15','PID0020';
EXECUTE FillAppointmentTable '2022-09-17','PID0019';
EXECUTE FillAppointmentTable '2022-10-09','PID0023';
EXECUTE FillAppointmentTable '2022-10-23','PID0025';

---------------------------------------------------------------------------

CREATE PROCEDURE FillHospitalTable
       @hos_name VARCHAR(60), 
       @hos_ph VARCHAR(20), 
       @hos_email_add VARCHAR(60),
       @hos_web VARCHAR(60), 
       @add_id VARCHAR (16)
       --@app_id VARCHAR (17)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Hospital]([Hospital_name],[Hospital_phone],[Hospital_email_address],[Hospital_website],[Address_id])--,[Appointment_id])
        VALUES 
        (@hos_name, @hos_ph, @hos_email_add, @hos_web, @add_id)-- @app_id)
END;

select * from Hospital order by ID;

--Trigger if Address_id is already taken by Patient, Hospital, Diagnostic center etc

EXECUTE FillHospitalTable 'AdCare Hospital','(508)-799-9000','adcare.h@gmail.com','http://www.adcare.com/','ADD_ID0013';
EXECUTE FillHospitalTable 'Arbour Hospital','(617)-522-4400','arbour.h@gmail.com','http://www.arbourhealth.com/','ADD_ID0014';
EXECUTE FillHospitalTable 'Athol Hospital','(978)-249-3511','athol.h@gmail.com','http://www.atholhospital.org/','ADD_ID0015';
EXECUTE FillHospitalTable 'Baldpate Hospital','(978)-352-2131','baldpate.h@gmail.com','http://www.detoxma.com/','ADD_ID0017';
EXECUTE FillHospitalTable 'BayRidge Hospital','(781)-599-9200','bayridge.h@gmail.com','http://www.beverlyhospital.org/','ADD_ID0018';
EXECUTE FillHospitalTable 'Baystate Franklin Medical Center','(413)-773-0211','baystate.h@gmail.com','http://https//www.baystatehealth.org/','ADD_ID0019';
EXECUTE FillHospitalTable 'Baystate Medical Center','(413)-794-0000','baystatemed.h@gmail.com','http://https//www.baystatehealth.org/locations/baystate-medical-center','ADD_ID0020';
EXECUTE FillHospitalTable 'Baystate Noble Hospital','(413)-568-2811','baystaten.h@gmail.com','http://www.baystatenoblehospital.org/','ADD_ID0021';
EXECUTE FillHospitalTable 'Baystate Wing Hospital','(413)-283-7651','baystatew.h@gmail.com','http://https//www.baystatehealth.org/locations/wing-hospital','ADD_ID0022';
EXECUTE FillHospitalTable 'Austen Riggs Center','(800)-517-4447','austen.h@gmail.com','http://www.austenriggs.org/','ADD_ID0035';

--------------------------------------------------------------------------

CREATE PROCEDURE FillDoctorTable
       @doc_fn VARCHAR(40), 
       @doc_ln VARCHAR(40), 
       @doc_email_add VARCHAR(60),
       @doc_cn VARCHAR(20), 
       @pt_id VARCHAR (13),
       @hos_id VARCHAR (16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Doctor]([Doctor_first_name],[Doctor_last_name],[Doctor_email_address],[Doctor_contact_number],[Patient_id],[Hospital_id])
        VALUES 
        (@doc_fn, @doc_ln, @doc_email_add, @doc_cn, @pt_id, @hos_id)
END;



select * from Doctor order by ID;

EXECUTE FillDoctorTable 'Sparsh','Sinha','sinha.s@gmail.com','(865)-522-7822','PID0014','HOS_ID001';
EXECUTE FillDoctorTable 'Krishnapal','Singh','krishnapal.s@gmail.com','(898)-232-3772','PID0015','HOS_ID0010';
EXECUTE FillDoctorTable 'Rajiv ','Sahu','rajiv.s@gmail.com','(993)-377-2322','PID0023','HOS_ID005';
EXECUTE FillDoctorTable 'Nagashree','Sheshadari','nagashree.s@gmail.com','(988)-933-7720','PID0016','HOS_ID003';
EXECUTE FillDoctorTable 'Rahul ','Khanna','rahul.k@gmail.com','(992)-277-8888','PID0018', 'HOS_ID003';
EXECUTE FillDoctorTable 'Jatin','Tejwani','jatin.t@gmail.com','(779)-988-8811','PID0025','HOS_ID0010';
EXECUTE FillDoctorTable 'Satveer','Jagwani','satveer.j@gmail.com','(669)-999-1111','PID0020','HOS_ID008';
EXECUTE FillDoctorTable 'Sandeep','Singh','sandeep.s@gmail.com','(909)-998-8877','PID0021','HOS_ID009';
EXECUTE FillDoctorTable 'Jarvish','Patel','jarvish.p@gmail.com','(823)-233-3228','PID0019','HOS_ID008';
EXECUTE FillDoctorTable 'Yusuf','Shaik','yusuf.s@gmail.com','(808)-033-3000','PID0017','HOS_ID003';

-----------------------------------------------------------------------------------------------

CREATE PROCEDURE FillDiag_CentreTable
       @dc_name VARCHAR(40), 
       @dc_cn VARCHAR(20), 
       @dc_email_add VARCHAR(60),
       @dc_web VARCHAR(60), 
       @dc_rate DECIMAL(2,1), 
       @add_id VARCHAR (16),
       @app_id VARCHAR (17)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Diagnostic_center]([Diagnostic_center_name],[Diagnostic_center_contact_number],[Diagnostic_center_email_address],[Diagnostic_center_website], [Diagnostic_center_rating], [Address_id],[Appointment_id])
        VALUES 
        (@dc_name, @dc_cn, @dc_email_add, @dc_web, @dc_rate, @add_id, @app_id)
END;

EXECUTE FillDiag_CentreTable 'Quest Diagnostics','(508)-799-9010','info@questdiagnostic.com','www.questdiagnostic.com',4.5,'ADD_ID0023','APPT_ID001';
EXECUTE FillDiag_CentreTable 'Abbott Laboratories','(617)-522-4410','askus@abbott.com','www.abbott.com',4.7,'ADD_ID0024','APPT_ID002';
EXECUTE FillDiag_CentreTable 'Bio-Reference Laboratories','(800)-517-4443','referenceQuestions@bioreference.com','www.bioreference.com',4.1,'ADD_ID0026','APPT_ID004';
EXECUTE FillDiag_CentreTable 'Spectra Laboratories','(978)-352-2112','askme@spectralabs.com','www.spectralabs.com',1.2,'ADD_ID0027','APPT_ID005';
EXECUTE FillDiag_CentreTable 'Genoptix Medical Laboratory','(781)-599-9241','askus@genoptrix.com','www.genoptrix.com',2.9,'ADD_ID0028','APPT_ID006';
EXECUTE FillDiag_CentreTable 'ARUP Laboratories','(413)-773-0256','info@aruplabs.com','www.aruplabs.com',4.5,'ADD_ID0029','APPT_ID007';
EXECUTE FillDiag_CentreTable 'Clarient, Inc.','(413)-794-0032','infoandquestions@clarient.com','www.clarient.com',3.3,'ADD_ID0030','APPT_ID008';
EXECUTE FillDiag_CentreTable 'Delta Diagnostics','(413)-568-2813','deltainfo@deltadiagnostics.com','www.deltadiagnostics.com',4.3,'ADD_ID0031','APPT_ID009';
EXECUTE FillDiag_CentreTable 'Prima Healthcare Labs','(413)-283-7656','answers@primalabs.com','www.primalabs.com',2.2,'ADD_ID0032','APPT_ID0010';
EXECUTE FillDiag_CentreTable 'Charles River Laboratories, Inc.','(978)-249-3521','info@charlesriver.com','www.charlesriver.com',3.4,'ADD_ID0025','APPT_ID003';

------------------------------------------------------------------------------------------

CREATE PROCEDURE FillSupplierTable
       @sup_fn VARCHAR(40), 
       @sup_ln VARCHAR(40), 
       @sup_type VARCHAR(40),
       @sup_qty INT, 
       @sup_cn VARCHAR(20), 
       @sup_web VARCHAR(60),
       @sup_email VARCHAR(60)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Supplier]([Supplier_first_name],[Supplier_last_name],[Supplier_type],[Supply_quantity],[Supplier_contact_number], [Supplier_website],[Supplier_email_address])
        VALUES 
        (@sup_fn, @sup_ln, @sup_type, @sup_qty, @sup_cn, @sup_web, @sup_email)
END;

EXECUTE FillSupplierTable 'Jordan','Love','Medicine',40,'(678)-976-8943','medhelp.com','medhelp@gmail.com';
EXECUTE FillSupplierTable 'Adam','Cole','Sanitary',30,'(564)-146-9872','mediclaim.com','mediclaim@gmail.com';
EXECUTE FillSupplierTable 'Karen','Hill','Needles',90,'(543)-941-2145','drugdealer.com','drugdealer@gmail.com';
EXECUTE FillSupplierTable 'Robert','Lane','Masks',20,'(789)-123-9348','medisquare.com','medisquare@gmail.com';
EXECUTE FillSupplierTable 'Andrew','Jackson','Vaccines',50,'(543)-806-2845','medicare.com','medicare@gmail.com';
EXECUTE FillSupplierTable 'Jason','Hart','Injections',60,'(647)-854-1976','medicaps.com','medicaps@gmail.com';
EXECUTE FillSupplierTable 'Misty','Berry','Ventilators',56,'(783)-647-8139','medimasti.com','medimasti@gmail.com';
EXECUTE FillSupplierTable 'Kurt','Russell','Personal care',98,'(782)-4561-861','mediscore.com','mediscore@gmail.com';
EXECUTE FillSupplierTable 'Amanda','Munoz','OT Supplies',40,'(760)-256-3876','medmax.com','medmax@gmail.com';
EXECUTE FillSupplierTable 'Nicholas','Norman','Test Kits',50,'(165)-678-3567','medshed.com','medshed@gmail.com';
EXECUTE FillSupplierTable 'Mary','Bush','Needles',87,'(986)-534-7681','covicare.com','covicare@gmail.com';
EXECUTE FillSupplierTable 'Dennis','Farley','Test Kits',48,'(764)-563-8765','covishield.com','covishield@gmail.com';

------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE FillSupply_kitTable
       @sup_kit_type VARCHAR(60), 
       @sup_id VARCHAR(16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Supply_kit]([Supply_kit_type],[Supplier_id])
        VALUES 
        (@sup_kit_type, @sup_id)
END;


EXECUTE FillSupply_kitTable 'Medicine','SUP_ID001';
EXECUTE FillSupply_kitTable 'Covid','SUP_ID003';
EXECUTE FillSupply_kitTable 'First-Aid','SUP_ID002';
EXECUTE FillSupply_kitTable 'Operation Kit','SUP_ID005';
EXECUTE FillSupply_kitTable 'Covid','SUP_ID004';
EXECUTE FillSupply_kitTable 'Medicine','SUP_ID006';
EXECUTE FillSupply_kitTable 'First-Aid','SUP_ID009';
EXECUTE FillSupply_kitTable 'Covid','SUP_ID008';
EXECUTE FillSupply_kitTable 'Operation Kit','SUP_ID007';
EXECUTE FillSupply_kitTable 'Medicine','SUP_ID0012';
EXECUTE FillSupply_kitTable 'Medicine','SUP_ID0010';
EXECUTE FillSupply_kitTable 'First-Aid','SUP_ID0011';

---------------------------------------------------------------------------------

CREATE PROCEDURE FillLabTable
       @lab_tp VARCHAR(40), 
       @lab_cp INT, 
       @dc_id VARCHAR(15),
       @sup_kt_id VARCHAR(16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Lab]([Lab_type],[Lab_capacity],[Diagnostic_center_id],[Supply_kit_id])
        VALUES 
        (@lab_tp, @lab_cp, @dc_id, @sup_kt_id)
END;



select * from Lab order by ID;

EXECUTE FillLabTable 'COVID',20,'DC_ID001','KIT_ID001';
EXECUTE FillLabTable 'SCAN',25,'DC_ID002','KIT_ID002';
EXECUTE FillLabTable 'PATHOLOGY',27,'DC_ID005','KIT_ID005';
EXECUTE FillLabTable 'SCAN',34,'DC_ID007','KIT_ID007';
EXECUTE FillLabTable 'SCAN',52,'DC_ID004','KIT_ID008';
EXECUTE FillLabTable 'COVID',29,'DC_ID009','KIT_ID0010';
EXECUTE FillLabTable 'SCAN',23,'DC_ID006','KIT_ID004';
EXECUTE FillLabTable 'COVID',21,'DC_ID001','KIT_ID004';
EXECUTE FillLabTable 'SCAN',24,'DC_ID005','KIT_ID002';
EXECUTE FillLabTable 'PATHOLOGY',26,'DC_ID002','KIT_ID005';
EXECUTE FillLabTable 'SCAN',31,'DC_ID004','KIT_ID007';
EXECUTE FillLabTable 'SCAN',53,'DC_ID007','KIT_ID008';

------------------------------------------------------------------------------

CREATE PROCEDURE FillLab_deviceTable
       @ld_name VARCHAR(40), 
       @ld_st BIT,
       @lb_id VARCHAR(16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Lab_device]([Lab_device_name],[Lab_device_status],[Lab_id])
        VALUES 
        (@ld_name, @ld_st, @lb_id)
END;



select * from Lab_device order by ID;


EXECUTE FillLab_deviceTable 'Microscope',1,'LAB_ID005';
EXECUTE FillLab_deviceTable 'Ventilators',1,'LAB_ID001';
EXECUTE FillLab_deviceTable 'Masks',0,'LAB_ID002';
EXECUTE FillLab_deviceTable 'Oxygen Cylinders',1,'LAB_ID0010';
EXECUTE FillLab_deviceTable 'Computed ECG',0,'LAB_ID006';
EXECUTE FillLab_deviceTable 'Sterilizers',0,'LAB_ID0016';
EXECUTE FillLab_deviceTable 'PPE Kit',0,'LAB_ID0013';
EXECUTE FillLab_deviceTable 'Test Tubes',1,'LAB_ID005';
EXECUTE FillLab_deviceTable 'Ultrasound Scanner',1,'LAB_ID0015';
EXECUTE FillLab_deviceTable 'Centrifuge',0,'LAB_ID0017';
EXECUTE FillLab_deviceTable 'CT Scan',1,'LAB_ID0013';

---------------------------------------------------------------------------

CREATE PROCEDURE FillLab_technicianTable
       @lt_fn VARCHAR(40), 
       @lt_ln VARCHAR(40), 
       @lt_email_add VARCHAR(60),
       @lt_cn VARCHAR(20), 
       @add_id VARCHAR (16),
       @lb_id VARCHAR (16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Lab_technician]([Lab_technician_first_name],[Lab_technician_last_name],[Lab_technician_email_address],[Lab_technician_contact_number],[Address_id],[Lab_id])
        VALUES 
        (@lt_fn, @lt_ln, @lt_email_add, @lt_cn, @add_id, @lb_id)
END;


select * from Lab_technician Order by id;

EXECUTE FillLab_technicianTable 'Lisa','Jones','jones.l@gmail.com','(508)-799-9019','ADD_ID0033','LAB_ID001';
EXECUTE FillLab_technicianTable 'Edward','Ryan','ryan.e@gmail.com','(617)-522-4414','ADD_ID0034','LAB_ID002';
EXECUTE FillLab_technicianTable 'Mark','Simon','simon.m@gmail.com','(978)-249-3522','ADD_ID0035','LAB_ID005';
EXECUTE FillLab_technicianTable 'Emma','Newton','newton.e@gmail.com','(781)-599-9249','ADD_ID0038','LAB_ID0010';
EXECUTE FillLab_technicianTable 'Heather','Stephens','stephans.h@gmail.com','(413)-568-2815','ADD_ID0041','LAB_ID0016';
EXECUTE FillLab_technicianTable 'John','Harrison','harrison.j@gmail.com','(617)-522-4419','ADD_ID0044','LAB_ID005';
EXECUTE FillLab_technicianTable 'Harry','King','king.h@hotmail.com','(617)-522-4329','ADD_ID0047','LAB_ID001';
EXECUTE FillLab_technicianTable 'Paul','Nicken','nicken.p@hotmail.com','(617)-522-4423','ADD_ID0048','LAB_ID002';
EXECUTE FillLab_technicianTable 'Lita','Hunter','hunter.lita@hotmail.com','(617)-522-4478','ADD_ID0049','LAB_ID005';
EXECUTE FillLab_technicianTable 'Siya','Gandhi','siya.gandhi@gmail.com','(617)-522-4421','ADD_ID0050','LAB_ID006';
EXECUTE FillLab_technicianTable 'Caroline','Hopkins','hopkins.c@gmail.com','(800)-517-4447','ADD_ID0036','LAB_ID002';
EXECUTE FillLab_technicianTable 'David','Johnson','johnson.d@gmail.com','(978)-352-2111','ADD_ID0037','LAB_ID004';

--------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE FillTestTable
       @t_dt DATE, 
       @t_type VARCHAR(40), 
       @t_res VARCHAR(40),
       @t_inf_sev DECIMAL(2,1), 
       @lb_id VARCHAR(16),
       @doc_id VARCHAR(16),
       @pt_id VARCHAR(13)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Test]([Test_date],[Test_type],[Test_result],[Test_infection_severity],[Lab_id],[Doctor_id],[Patient_id])
        VALUES 
        (@t_dt, @t_type, @t_res, @t_inf_sev, @lb_id, @doc_id, @pt_id)
END;



EXECUTE FillTestTable '06-15-2022','PCR','Positive',4.3,'LAB_ID001','DOC_ID002','PID0014';
EXECUTE FillTestTable '06-06-2022','Blood Glucose','Random blood sugar level levels slighly high',3.7,'LAB_ID005','DOC_ID004','PID0023';
EXECUTE FillTestTable '06-01-2022','Abdomen Scan','Ultrasound images appear normal',1.2,'LAB_ID006','DOC_ID005','PID0024';
EXECUTE FillTestTable '06-11-2022','CT Scan','No inflammation or swelling detected',0.9,'LAB_ID0010','DOC_ID006','PID0016';
EXECUTE FillTestTable '06-24-2022','PCR','Negative',4.9,'LAB_ID0013','DOC_ID007','PID0015';
EXECUTE FillTestTable '06-04-2022','Complete blood count','Not anaemic, go for more greens',1.8,'LAB_ID0015','DOC_ID0011','PID0019';
EXECUTE FillTestTable '06-06-2022','PCR','Positive',3.9,'LAB_ID0010','DOC_ID0010','PID0021';
EXECUTE FillTestTable '06-24-2022','RAT','Negative',2.1,'LAB_ID0010','DOC_ID004','PID0025';
EXECUTE FillTestTable '06-03-2022','Ketones in Urine','Positive',1.6,'LAB_ID0015','DOC_ID004','PID0017';
EXECUTE FillTestTable '06-28-2022','Upper Thorax scan','Lung congestion and viral load detected',2.1,'LAB_ID0014','DOC_ID0011','PID0018';

------------------------------------------------------------------------------------------------------------------

-- Inserting Data for Associative Entities

CREATE PROCEDURE FillLab_supply_kitTable
       @lb_id VARCHAR(16), 
       @s_k_id VARCHAR (16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Lab_supply_kit]([Lab_id],[Supply_kit_id])
        VALUES 
        (@lb_id, @s_k_id)
END;


select * from Lab_supply_kit;

EXECUTE FillLab_supply_kitTable 'LAB_ID001','KIT_ID001';
EXECUTE FillLab_supply_kitTable 'LAB_ID002','KIT_ID002';
EXECUTE FillLab_supply_kitTable 'LAB_ID003','KIT_ID005';
EXECUTE FillLab_supply_kitTable 'LAB_ID004','KIT_ID007';
EXECUTE FillLab_supply_kitTable 'LAB_ID005','KIT_ID008';
EXECUTE FillLab_supply_kitTable 'LAB_ID006','KIT_ID0010';
EXECUTE FillLab_supply_kitTable 'LAB_ID0010','KIT_ID004';
EXECUTE FillLab_supply_kitTable 'LAB_ID0013','KIT_ID003';
EXECUTE FillLab_supply_kitTable 'LAB_ID0014','KIT_ID002';
EXECUTE FillLab_supply_kitTable 'LAB_ID0015','KIT_ID005';
EXECUTE FillLab_supply_kitTable 'LAB_ID0016','KIT_ID007';
EXECUTE FillLab_supply_kitTable 'LAB_ID0017','KIT_ID008';

------------------------------------------------------------------------

CREATE PROCEDURE FillPatient_doctorTable
       @p_id VARCHAR(13),
       @doc_id VARCHAR(16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Patient_doctor]([Patient_id],[Doctor_id])
        VALUES 
        (@p_id, @doc_id)
END;

select * from Patient_doctor;


EXECUTE FillPatient_doctorTable 'PID0014','DOC_ID001';
EXECUTE FillPatient_doctorTable 'PID0015','DOC_ID002';
EXECUTE FillPatient_doctorTable 'PID0016','DOC_ID004';
EXECUTE FillPatient_doctorTable 'PID0018','DOC_ID005';
EXECUTE FillPatient_doctorTable 'PID0025','DOC_ID006';
EXECUTE FillPatient_doctorTable 'PID0020','DOC_ID007';
EXECUTE FillPatient_doctorTable 'PID0021','DOC_ID008';
EXECUTE FillPatient_doctorTable 'PID0019','DOC_ID009';
EXECUTE FillPatient_doctorTable 'PID0017','DOC_ID0010';
EXECUTE FillPatient_doctorTable 'PID0023','DOC_ID0011';

-------------------------------------------------------------------------

CREATE PROCEDURE FillTest_doctorTable
       @t_id VARCHAR(17),
       @doc_id VARCHAR(16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Test_doctor]([Test_id],[Doctor_id])
        VALUES 
        (@t_id, @doc_id)
END;


EXECUTE FillTest_doctorTable 'TEST_ID001','DOC_ID002';
EXECUTE FillTest_doctorTable 'TEST_ID003','DOC_ID004';
EXECUTE FillTest_doctorTable 'TEST_ID004','DOC_ID005';
EXECUTE FillTest_doctorTable 'TEST_ID005','DOC_ID006';
EXECUTE FillTest_doctorTable 'TEST_ID006','DOC_ID007';
EXECUTE FillTest_doctorTable 'TEST_ID009','DOC_ID0011';
EXECUTE FillTest_doctorTable 'TEST_ID0010','DOC_ID0010';
EXECUTE FillTest_doctorTable 'TEST_ID0011','DOC_ID004';
EXECUTE FillTest_doctorTable 'TEST_ID0012','DOC_ID004';
EXECUTE FillTest_doctorTable 'TEST_ID0013','DOC_ID0011';

SELECT * from Test_doctor;

----------------------------------------------------------------------------

CREATE PROCEDURE FillSupply_kit_suppliersTable
       @s_k_id VARCHAR(16),
       @sup_id VARCHAR(16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Supply_kit_suppliers]([Supply_kit_id],[Supplier_id])
        VALUES 
        (@s_k_id, @sup_id)
END;



EXECUTE FillSupply_kit_suppliersTable 'KIT_ID001','SUP_ID001';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID0010', 'SUP_ID0012';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID0011', 'SUP_ID0010';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID0012','SUP_ID0011';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID002','SUP_ID003';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID003','SUP_ID002';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID004','SUP_ID005';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID005', 'SUP_ID004';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID006','SUP_ID006';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID007','SUP_ID009';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID008','SUP_ID008';
EXECUTE FillSupply_kit_suppliersTable 'KIT_ID009','SUP_ID007';

SELECT * from supply_kit_suppliers;

---------------------------------------------------------------------------------

CREATE PROCEDURE FillHospital_doctorTable
       @hos_id VARCHAR(16),
       @doc_id VARCHAR(16)
AS 
BEGIN 
    INSERT INTO 
        [dbo].[Hospital_doctor]([Hospital_id],[Doctor_id])
        VALUES 
        (@hos_id, @doc_id)
END;



EXECUTE FillHospital_doctorTable 'HOS_ID001','DOC_ID001';
EXECUTE FillHospital_doctorTable 'HOS_ID0010','DOC_ID002';
EXECUTE FillHospital_doctorTable 'HOS_ID003','DOC_ID004';
EXECUTE FillHospital_doctorTable 'HOS_ID003','DOC_ID005';
EXECUTE FillHospital_doctorTable 'HOS_ID0010','DOC_ID006';
EXECUTE FillHospital_doctorTable 'HOS_ID008','DOC_ID007';
EXECUTE FillHospital_doctorTable 'HOS_ID009','DOC_ID008';
EXECUTE FillHospital_doctorTable 'HOS_ID008','DOC_ID009';
EXECUTE FillHospital_doctorTable 'HOS_ID003','DOC_ID0010';
EXECUTE FillHospital_doctorTable 'HOS_ID005','DOC_ID0011';


SELECT * from Hospital_doctor;




------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

-- 8. Housekeeping {optional}

-- DROP VIEW Lab_and_Lab_technicians;
-- DROP VIEW Diagnostic_centre_and_labs;
-- DROP VIEW Hospital_name_and_address;
-- DROP VIEW Diagnostic_name_and_address;
-- DROP VIEW Patient_name_and_address;
-- DROP VIEW Lab_technician_name_and_address;

-- HouseKeeping for table level constraints

-- ALTER TABLE [Address]
-- DROP CONSTRAINT numericZipCheck;
-- DROP FUNCTION ufCheckZip;
-- ALTER TABLE Account
-- DROP CONSTRAINT payTypeChecker;
-- DROP FUNCTION ufPaymentTypeChecker;

-- Housekeeping for Tables

-- DROP TABLE Hospital_doctor;
-- DROP TABLE Test_doctor;
-- DROP TABLE Patient_doctor;
-- DROP TABLE Supply_kit_suppliers;
-- DROP TABLE Lab_supply_kit;
-- DROP TABLE Test;
-- DROP TABLE Lab_device;
-- DROP TABLE Lab_technician;
-- DROP TABLE Lab;
-- DROP TABLE Supply_kit;
-- DROP TABLE Supplier;
-- DROP TABLE Diagnostic_center;
-- DROP TABLE Doctor;
-- DROP TABLE Hospital;
-- DROP TABLE Appointment;
-- DROP TABLE Account;
-- DROP TABLE Patient;
-- DROP TABLE Insurance;
-- DROP TABLE [Address];