/* alternative to psql -v ON_ERROR_STOP=1 for tracking exit codes from psql*/
\set ON_ERROR_STOP on 

START TRANSACTION;
    CREATE TABLE IF NOT EXISTS NewOrders(ID SERIAL, Title VARCHAR(80) NOT NULL, Price INTEGER DEFAULT 0, PRIMARY KEY (ID, Price)) PARTITION BY RANGE (Price);
    CREATE TABLE IF NOT EXISTS OrdersPart1 PARTITION OF NewOrders FOR VALUES FROM (MinValue) TO (500);
    CREATE TABLE IF NOT EXISTS OrdersPart2 PARTITION OF NewOrders FOR VALUES FROM (500) TO (MaxValue);
    INSERT INTO NewOrders SELECT * FROM Orders;
    DROP TABLE Orders;
    ALTER TABLE NewOrders RENAME TO Orders;
COMMIT;

