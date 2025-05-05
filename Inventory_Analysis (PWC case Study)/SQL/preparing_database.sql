create database pwc_caseStudy;
use pwc_casestudy;

create table Purchaseprice(
	brand int,
    Description varchar(100),
    price double,
    size varchar(15),
    volume_in_ml varchar(15),
    classification tinyint check(classification in (1,2)),
    purchaseprice double,
    vendorNumber int,
    vendorName varchar(200)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PurchasePrices.csv'
INTO TABLE purchaseprice
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


CREATE TABLE purchasefinal (
    InventoryId VARCHAR(50),   -- Unique identifier, alphanumeric
    Store INT,                             -- Store number (integer)
    Brand INT,                             -- Brand ID (integer)
    Description VARCHAR(255),              -- Product description
    Size VARCHAR(20),                      -- Size (e.g., "750mL", "1.75L")
    VendorNumber INT,                      -- Vendor ID (integer)
    VendorName VARCHAR(255),               -- Vendor name
    PONumber INT,                          -- Purchase Order number
    PODate DATE,                           -- Date format: YYYY-MM-DD
    ReceivingDate DATE,                    -- Date format: YYYY-MM-DD
    InvoiceDate DATE,                      -- Date format: YYYY-MM-DD
    PayDate DATE,                          -- Date format: YYYY-MM-DD
    PurchasePrice DECIMAL(10,2),           -- Price with 2 decimal places
    Quantity INT,                           -- Integer quantity
    Dollars DECIMAL(10,2),                  -- Dollar value
    Classification INT                      -- Integer classification
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PurchasesFINAL.csv'
INTO TABLE purchasefinal
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InventoryId, Store, Brand, Description, Size, VendorNumber, VendorName, PONumber, @PODate, @ReceivingDate, @InvoiceDate, @PayDate, PurchasePrice, Quantity, Dollars, Classification)
SET 
    PODate = STR_TO_DATE(@PODate, '%Y-%m-%d'),
    ReceivingDate = STR_TO_DATE(@ReceivingDate, '%Y-%m-%d'),
    InvoiceDate = STR_TO_DATE(@InvoiceDate, '%Y-%m-%d'),
    PayDate = STR_TO_DATE(@PayDate, '%Y-%m-%d');



CREATE TABLE Beginvdec (
    InventoryId VARCHAR(50),  -- Unique identifier
    Store INT,                            -- Store number
    City VARCHAR(100),                    -- City name
    Brand INT,                            -- Brand ID
    Description VARCHAR(255),             -- Product description
    Size VARCHAR(20),                     -- Product size (e.g., "750mL")
    onHand INT,                           -- Stock quantity
    Price DECIMAL(10,2),                  -- Price with two decimal places
    startDate DATE                        -- Start date (YYYY-MM-DD format)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/BeginvFINAL.csv' 
INTO TABLE Beginvdec 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(InventoryId, Store, City, Brand, Description, Size, onHand, Price, @startDate)
SET startDate = STR_TO_DATE(@startDate, '%Y-%m-%d');


CREATE TABLE Endinvfinal (
    InventoryId VARCHAR(50),  -- Unique identifier
    Store INT,                            -- Store number
    City VARCHAR(100),                    -- City name
    Brand INT,                            -- Brand ID
    Description VARCHAR(255),             -- Product description
    Size VARCHAR(20),                     -- Product size (e.g., "750mL")
    onHand INT,                           -- Stock quantity
    Price DECIMAL(10,2),                  -- Price with two decimal places
    endDate DATE                          -- End date (YYYY-MM-DD format)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/EndInvFINAL.csv' 
INTO TABLE Endinvfinal
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(InventoryId, Store, City, Brand, Description, Size, onHand, Price, @endDate)
SET endDate = STR_TO_DATE(@endDate, '%Y-%m-%d');

CREATE TABLE InvoicePurchases (
    VendorNumber INT,                     -- Vendor ID
    VendorName VARCHAR(255),              -- Vendor name
    InvoiceDate DATE,                     -- Date of invoice
    PONumber INT,                         -- Purchase Order number
    PODate DATE,                           -- Purchase Order date
    PayDate DATE,                          -- Payment date
    Quantity INT,                          -- Quantity of items
    Dollars DECIMAL(10,2),                 -- Total cost
    Freight DECIMAL(10,2),                 -- Freight cost
    Approval VARCHAR(50)                   -- Approval status
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/InvoicePurchases.csv' 
INTO TABLE InvoicePurchases
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS 
(VendorNumber, VendorName, @InvoiceDate, PONumber, @PODate, @PayDate, Quantity, Dollars, Freight, Approval)
SET 
    InvoiceDate = STR_TO_DATE(@InvoiceDate, '%Y-%m-%d'),
    PODate = STR_TO_DATE(@PODate, '%Y-%m-%d'),
    PayDate = STR_TO_DATE(@PayDate, '%Y-%m-%d');

CREATE TABLE SalesFINAL (
    InventoryId VARCHAR(50),
    Store INT,
    Brand INT,
    Description VARCHAR(255),
    Size VARCHAR(50),
    SalesQuantity INT,
    SalesDollars DECIMAL(10,2),
    SalesPrice DECIMAL(10,2),
    SalesDate DATE,
    Volume INT,
    Classification INT,
    ExciseTax DECIMAL(10,2),
    VendorNo INT,
    VendorName VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/SalesFINAL.csv' 
INTO TABLE SalesFINAL 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS 
(InventoryId, Store, Brand, Description, Size, SalesQuantity, SalesDollars, SalesPrice, @SalesDate, Volume, Classification, ExciseTax, VendorNo, VendorName)
SET 
    SalesDate = STR_TO_DATE(@SalesDate, '%Y-%m-%d');
    


alter table beginvdec rename to BeginningInventory;
alter table endinvfinal rename to EndingInventory;
alter table invoicepurchases rename to vendorInvoices;
alter table purchasefinal rename to purchases;
alter table purchaseprice rename to PurchasesPrices;
alter table salesfinal rename to Sales;



SET SQL_SAFE_UPDATES = 0;
update  vendorinvoices set vendorname = 'MARTIGNETTI COMPANIES'  where vendorname = 'MARTIGNETTI COMPANIES ';
update  vendorinvoices set vendorname = 'SOUTHERN GLAZERS W&S OF NE '  where vendorname = 'SOUTHERN WINE & SPIRITS NE ';
update  vendorinvoices set vendorname = 'VINEYARD BRANDS INC        '  where vendorname = 'VINEYARD BRANDS LLC        ';

update  sales set vendorname = 'MARTIGNETTI COMPANIES'  where vendorname = 'MARTIGNETTI COMPANIES ';
update  sales set vendorname = 'SOUTHERN GLAZERS W&S OF NE '  where vendorname = 'SOUTHERN WINE & SPIRITS NE ';
update  sales set vendorname = 'VINEYARD BRANDS INC        '  where vendorname = 'VINEYARD BRANDS LLC        ';



update  purchases set vendorname = 'MARTIGNETTI COMPANIES'  where vendorname = 'MARTIGNETTI COMPANIES ';
update  purchases set vendorname = 'SOUTHERN GLAZERS W&S OF NE '  where vendorname = 'SOUTHERN WINE & SPIRITS NE ';
update  purchases set vendorname = 'VINEYARD BRANDS INC        '  where vendorname = 'VINEYARD BRANDS LLC        ';



update  purchasesprices set vendorname = 'MARTIGNETTI COMPANIES'  where vendorname = 'MARTIGNETTI COMPANIES ';
update  purchasesprices set vendorname = 'SOUTHERN GLAZERS W&S OF NE '  where vendorname = 'SOUTHERN WINE & SPIRITS NE ';
update  purchasesprices set vendorname = 'VINEYARD BRANDS INC        '  where vendorname = 'VINEYARD BRANDS LLC        ';