CREATE TABLE bankdata (
    branchCodeNo INT,
    STATE VARCHAR(100),
    Address TEXT,
    CITY VARCHAR(100)
);

COPY bankdata
FROM 'C:/Program Files/PostgreSQL/17/data/mydata/bankdata.csv'
DELIMITER ','
CSV HEADER;

--------------------------------------------

CREATE TABLE bonddata (
    Unique_key VARCHAR(20),
    Denomination INT
);

COPY bonddata
FROM 'C:/Program Files/PostgreSQL/17/data/mydata/bonddata.csv'
DELIMITER ','
CSV HEADER;

-----------------------------------------------

CREATE TABLE donordata (
    Urn VARCHAR(50),
    JournalDate DATE,
    PurchaseDate DATE,
    ExpiryDate DATE,
    Purchaser TEXT,
    PayBranchCode INT,
    PayTeller INT,
    Unique_key VARCHAR(20)
);

COPY donordata
FROM 'C:/Program Files/PostgreSQL/17/data/mydata/donordata.csv'
DELIMITER ','
CSV HEADER;

---------------------------------------------------

CREATE TABLE receiverdata (
    DateEncashment DATE,
    PartyName TEXT,
    AccountNum TEXT,
    PayBranchCode INT,
    PayTeller INT,
    Unique_key VARCHAR(20)
);


COPY receiverdata
FROM 'C:/Program Files/PostgreSQL/17/data/mydata/receiverdata.csv'
DELIMITER ','
CSV HEADER;

------------------------------------------------------------




