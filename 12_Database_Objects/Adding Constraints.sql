
-- Creating Primary Key Constraints

-- Including a Primery Key constraint during table creation
-- Notice that we name the Primary Key constraint
-- PK_CreateTablePK_LastName
CREATE TABLE CreateTablePK
(
 FirstName varchar(25) not null,
 LastName varchar(25) not null,
 CONSTRAINT PK_CreateTablePK_LastName PRIMARY KEY CLUSTERED (LastName),
 City	varchar(15) null
)

-- After creating the PK, browse to the table in the Object Explorer
-- and notice the key's name in the Key folder for the table


-- Let's drop the table and create it again and let the system
-- name the primary key
-- You'll see why it's better to name your constraints!

DROP TABLE CreateTablePK

CREATE TABLE CreateTablePK
(
 FirstName varchar(25) not null,
 LastName varchar(25) not null
 PRIMARY KEY CLUSTERED (LastName),
 City	varchar(15) null
)

-- This INSERT will fail because it violates the Primary Key
-- because the PK on the LastName will not allow two Smiths
INSERT INTO CreateTablePK
VALUES
('Bob','Smith','Atlanta'),
('Jack','Smith','Atlanta')


-- Now, let's drop the table and create a new one
-- and create a composite primary key (first and last name columns)

DROP TABLE CreateTablePK

CREATE TABLE CreateTablePK
(
 FirstName varchar(25) not null,
 LastName varchar(25) not null,
 City	varchar(15) null
 CONSTRAINT PK_CreateTablePK_LastName_FirstName PRIMARY KEY CLUSTERED (LastName,FirstName)
)


-- Let's try to add two Smiths again
INSERT INTO CreateTablePK
VALUES
('Bob','Smith','Atlanta'),
('Jack','Smith','Atlanta')

SELECT * FROM CreateTablePK


-- Now let's create two tables
-- TestPK is the Primary Key table that has a primary key that is an IDENTITY COLUMN
-- and also provides a DEFAULT constraint with the value "Black" for the color column
-- TestFK is the Foreign Key table that REFERENCES the Primary Key column
-- in the Primary Key table
CREATE TABLE TestPK
(
  ProdID int IDENTITY(1,1)  NOT NULL,
  ProductName varchar(30) NOT NULL,
  Color varchar(10) DEFAULT 'Black' NULL
   CONSTRAINT PK_TestPK_ProdID PRIMARY KEY CLUSTERED (ProdID)
)

CREATE TABLE TestFK
(
  ProdID int IDENTITY(1,1)  NOT NULL,
  Origin varchar(30) NULL
  CONSTRAINT FK_ProdID_TestPK_ProdID FOREIGN KEY (ProdID) REFERENCES TestPK(ProdID)
)

-- Note that if we insert a row into TestPK and don't include a value for
-- the color column, Black is entered as the default
INSERT TestPK
(ProductName)
VALUES
('Shoes')

select * from TestPK