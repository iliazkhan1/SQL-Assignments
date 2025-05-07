--########################################################################################################################
--1. PIVOT
CREATE TABLE Sales (
    Region VARCHAR(50),
    Product VARCHAR(50),
    Year INT,
    SalesAmount DECIMAL(10, 2)
);

INSERT INTO Sales (Region, Product, Year, SalesAmount) VALUES
('North', 'Laptop', 2023, 10000.00),
('South', 'Laptop', 2023, 15000.00),
('East', 'Laptop', 2023, 12000.00),
('West', 'Laptop', 2023, 13000.00),
('North', 'Laptop', 2024, 11000.00),
('South', 'Laptop', 2024, 14000.00),
('East', 'Laptop', 2024, 11500.00),
('West', 'Laptop', 2024, 12500.00),
('North', 'Phone', 2023, 5000.00),
('South', 'Phone', 2023, 7000.00),
('East', 'Phone', 2023, 6000.00),
('West', 'Phone', 2023, 5500.00),
('North', 'Phone', 2024, 5200.00),
('South', 'Phone', 2024, 7500.00),
('East', 'Phone', 2024, 6200.00),
('West', 'Phone', 2024, 5800.00);

SELECT Product,
       [2023] AS Sales_2023,
       [2024] AS Sales_2024
FROM (
    SELECT Product, Year, SalesAmount
    FROM Sales
) AS SourceTable
PIVOT (
    SUM(SalesAmount)
    FOR Year IN ([2023], [2024])
) AS PivotTable;

SELECT Product, Year, SalesAmount
FROM (
    SELECT Product, [2023], [2024]
    FROM (
        SELECT Product, Year, SalesAmount
        FROM Sales
    ) AS SourceTable
    PIVOT (
        SUM(SalesAmount)
        FOR Year IN ([2023], [2024])
    ) AS PivotTable
) AS PivotedTable
UNPIVOT (
    SalesAmount FOR Year IN ([2023], [2024])
) AS UnpivotedTable;


--########################################################################################################################
--2. SELECT INTO
CREATE TABLE Employees (
    EmployeeID INT,
    Name VARCHAR(100),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

INSERT INTO Employees (EmployeeID, Name, Department, Salary) VALUES
(1, 'John Doe', 'HR', 55000.00),
(2, 'Jane Smith', 'Finance', 70000.00),
(3, 'Samuel Green', 'IT', 80000.00),
(4, 'Anna White', 'Finance', 65000.00),
(5, 'Michael Brown', 'Marketing', 45000.00),
(6, 'Emily Davis', 'IT', 75000.00);

SELECT EmployeeID, Name, Department, Salary
INTO HighSalaryEmployees
FROM Employees
WHERE Salary > 60000;

SELECT * FROM HighSalaryEmployees;


--########################################################################################################################
--3. CASE
SELECT EmployeeID, 
       Name, 
       Department, 
       Salary,
       CASE 
           WHEN Salary < 40000 THEN 'Low'
           WHEN Salary BETWEEN 40000 AND 60000 THEN 'Medium'
           WHEN Salary > 60000 THEN 'High'
           ELSE 'Unknown'
       END AS SalaryRange
FROM Employees;


--########################################################################################################################
--4. COALESCE
CREATE TABLE Orders (
    OrderID INT,
    CustomerName VARCHAR(100),
    OrderDate DATE,
    ShippedDate DATE
);

INSERT INTO Orders (OrderID, CustomerName, OrderDate, ShippedDate) VALUES
(1, 'John Doe', '2025-04-01', '2025-04-03'),
(2, 'Jane Smith', '2025-04-02', NULL),
(3, 'Samuel Green', '2025-04-05', '2025-04-07'),
(4, 'Anna White', '2025-04-10', NULL),
(5, 'Michael Brown', '2025-04-12', '2025-04-15');

SELECT OrderID, 
       CustomerName, 
       OrderDate, 
       COALESCE(CONVERT(VARCHAR, ShippedDate, 120), 'Not Shipped') AS ShippedDate,
       CASE 
           WHEN ShippedDate IS NOT NULL THEN 'Delivered'
           WHEN ShippedDate IS NULL THEN 'Pending'
       END AS DeliveryStatus
FROM Orders;


--########################################################################################################################
--5. NULLIF
CREATE TABLE Scores (
    StudentID INT,
    Subject VARCHAR(100),
    MarksObtained INT,
    MaximumMarks INT
);

INSERT INTO Scores (StudentID, Subject, MarksObtained, MaximumMarks) VALUES
(1, 'Math', 80, 100),
(2, 'Science', 50, 0),
(3, 'History', 70, 100),
(4, 'English', 90, 0),
(5, 'Geography', 60, 75);

SELECT StudentID, 
       Subject, 
       MarksObtained, 
       MaximumMarks,
       (MarksObtained * 100.0) / NULLIF(MaximumMarks, 0) AS Percentage
FROM Scores;


--########################################################################################################################
--6. DDL Statements with Constraints
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50) UNIQUE
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    StaffName VARCHAR(100) NOT NULL,
    DepartmentID INT,
    Age INT CHECK (Age > 18),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

INSERT INTO Departments VALUES (1, 'HR');
INSERT INTO Departments VALUES (2, 'Finance');
INSERT INTO Departments VALUES (3, 'IT');

INSERT INTO Staff VALUES (1, 'Alice', 1, 25);
INSERT INTO Staff VALUES (2, 'Bob', 2, 30);
INSERT INTO Staff VALUES (3, 'Charlie', 3, 28);

INSERT INTO Departments VALUES (1, 'HR'); 
INSERT INTO Departments VALUES (4, 'HR'); 

INSERT INTO Staff VALUES (1, 'David', 1, 35); 
INSERT INTO Staff VALUES (4, NULL, 2, 26); 
INSERT INTO Staff VALUES (5, 'Eve', 2, 16); 
INSERT INTO Staff VALUES (6, 'Frank', 99, 27); 

--########################################################################################################################
--7. TRUNCATE and DROP
CREATE TABLE TemporaryData (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Value INT
);

INSERT INTO TemporaryData (ID, Name, Value) VALUES (1, 'Test1', 100);
INSERT INTO TemporaryData (ID, Name, Value) VALUES (2, 'Test2', 200);
INSERT INTO TemporaryData (ID, Name, Value) VALUES (3, 'Test3', 300);

TRUNCATE TABLE TemporaryData;

SELECT * FROM TemporaryData;

DROP TABLE TemporaryData;


--########################################################################################################################
--8. Data Types
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2),
    StockQuantity SMALLINT,
    LaunchDate DATE
);

INSERT INTO Products VALUES (1, 'Laptop', 75000.50, 15, '2024-01-10');
INSERT INTO Products VALUES (2, 'Smartphone', 29999.99, 30, '2024-02-15');
INSERT INTO Products VALUES (3, 'Tablet', 18500.00, 20, '2024-03-20');

INSERT INTO Products VALUES (4, 'Smartwatch', 'twenty thousand', 10, '2024-04-01');

INSERT INTO Products VALUES (5, 'Camera', 25000.00, 8, 'launch soon');

INSERT INTO Products VALUES (3, 'Headphones', 1500.00, 25, '2024-05-10');

