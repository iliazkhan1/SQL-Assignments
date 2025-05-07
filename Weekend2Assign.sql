--##########################################################################################
--1.	 Lab Activity 1: Creating a View for High-Earning Employees

-- Create Employees table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

-- Insert sample data into Employees
INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, Salary) VALUES
(1, 'Aaron', 'Miller', 'IT', 58000.00),
(2, 'Beth', 'Evans', 'HR', 52000.00),
(3, 'Carlos', 'Lopez', 'Finance', 73000.00),
(4, 'Diana', 'Nguyen', 'IT', 64000.00),
(5, 'Ethan', 'Carter', 'Marketing', 47000.00),
(6, 'Fiona', 'Scott', 'Finance', 69000.00),
(7, 'George', 'Perez', 'HR', 55000.00),
(8, 'Hannah', 'Bennett', 'IT', 68000.00),
(9, 'Ian', 'Reed', 'Marketing', 46000.00),
(10, 'Jasmine', 'Morgan', 'Finance', 71000.00),
(11, 'Kevin', 'Cook', 'IT', 54000.00),
(12, 'Laura', 'Bailey', 'HR', 57000.00),
(13, 'Mark', 'Foster', 'Finance', 75000.00),
(14, 'Nina', 'Howard', 'Marketing', 52000.00),
(15, 'Owen', 'Young', 'IT', 63000.00),
(16, 'Paula', 'Gray', 'HR', 51000.00),
(17, 'Quentin', 'King', 'Finance', 74000.00),
(18, 'Rachel', 'Green', 'IT', 70000.00),
(19, 'Steve', 'Adams', 'Marketing', 48000.00),
(20, 'Tina', 'Bell', 'Finance', 76000.00);

-- Create DepartmentAverages table
CREATE TABLE DepartmentAverages (
    Department VARCHAR(50) PRIMARY KEY,
    AvgSalary DECIMAL(10, 2)
);

-- Insert average salaries into DepartmentAverages
INSERT INTO DepartmentAverages (Department, AvgSalary)
SELECT Department, AVG(Salary)
FROM Employees
GROUP BY Department;

-- End of batch before CREATE VIEW
GO

-- Create view with schemabinding
CREATE VIEW HighEarningEmployeesIndexed
WITH SCHEMABINDING
AS
SELECT 
    E.EmployeeID, 
    E.FirstName, 
    E.LastName, 
    E.Department, 
    E.Salary, 
    CAST(E.Salary * 0.10 AS DECIMAL(10,2)) AS Bonus
FROM dbo.Employees E
JOIN dbo.DepartmentAverages DA 
    ON E.Department = DA.Department
WHERE E.Salary > DA.AvgSalary;
GO

-- Create a unique clustered index on the view
CREATE UNIQUE CLUSTERED INDEX IX_HighEarningEmployees
ON HighEarningEmployeesIndexed (EmployeeID);
GO

-- Query the view
SELECT * FROM HighEarningEmployeesIndexed;



--##########################################################################################
--2. Lab Activity 2: Using Correlated Subqueries for Recent Orders
-- STEP 1: Create Customers and Orders tables
-- Create the Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    ContactName VARCHAR(100),
    Country VARCHAR(100)
);

-- Insert sample data into Customers table
INSERT INTO Customers VALUES
(1, 'John Doe', 'Jane Smith', 'USA'),
(2, 'Alice Johnson', 'Alice Brown', 'UK'),
(3, 'Bob Lee', 'Robert Lee', 'Canada');

-- Create the Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME,
    OrderAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Insert sample data into Orders table
INSERT INTO Orders VALUES
(1, 1, '2025-01-15', 250.00),
(2, 1, '2025-03-10', 150.00),
(3, 2, '2025-02-05', 300.00),
(4, 3, '2025-04-01', 500.00),
(5, 2, '2025-04-10', 200.00);

-- STEP 2: Use a correlated subquery to find the latest order per customer

-- Correlated subquery to fetch the latest order per customer
SELECT c.CustomerID, c.CustomerName, c.Country, o.OrderDate
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderDate = (
    SELECT MAX(OrderDate)
    FROM Orders
    WHERE CustomerID = c.CustomerID
);

-- STEP 3: Retrieve customer details along with the most recent order date
-- This query will display the customer's details along with the latest order date.

SELECT c.CustomerID, c.CustomerName, c.Country, o.OrderDate
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderDate = (
    SELECT MAX(OrderDate)
    FROM Orders
    WHERE CustomerID = c.CustomerID
);

-- ENHANCEMENT 1: Modify the query to include order amount

-- Modified query to include the latest order amount
SELECT c.CustomerID, c.CustomerName, c.Country, o.OrderDate, o.OrderAmount
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderDate = (
    SELECT MAX(OrderDate)
    FROM Orders
    WHERE CustomerID = c.CustomerID
);

-- ENHANCEMENT 2: Optimize query performance with indexing on OrderDate

-- Create an index on OrderDate to optimize query performance
CREATE NONCLUSTERED INDEX idx_OrderDate ON Orders (OrderDate);






--##########################################################################################
--3. Lab Activity 3: Creating a Stored Procedure for Dynamic Sales Reports
-- STEP 1: Create a Sales table for sample data
-- STEP 1: Create the Sales table for sample data
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    ProductID INT,
    Region VARCHAR(50),
    SaleAmount DECIMAL(10, 2),
    SaleDate DATETIME
);

-- Insert sample data into Sales table
INSERT INTO Sales VALUES
(1, 101, 'North', 250.00, '2022-01-15'),
(2, 102, 'South', 150.00, '2022-03-10'),
(3, 103, 'East', 300.00, '2022-02-05'),
(4, 101, 'West', 500.00, '2022-04-01'),
(5, 102, 'North', 200.00, '2022-06-15'),
(6, 101, 'East', 650.00, '2022-07-10'),
(7, 103, 'South', 700.00, '2022-08-01'),
(8, 102, 'West', 450.00, '2022-12-12');

-- Separate the batch using GO for procedure creation
GO

-- STEP 2: Create a stored procedure that accepts @Year as input
CREATE PROCEDURE GetTotalSalesByYear
    @Year INT
AS
BEGIN
    -- Error handling using TRY...CATCH
    BEGIN TRY
        -- Aggregate sales by ProductID and Year
        SELECT 
            ProductID, 
            SUM(SaleAmount) AS TotalSales
        FROM Sales
        WHERE YEAR(SaleDate) = @Year
        GROUP BY ProductID
        ORDER BY TotalSales DESC;
    END TRY
    BEGIN CATCH
        -- Handle error if @Year is invalid or any other issues
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END;

-- Separate the batch using GO after creating the procedure
GO

-- STEP 3: Execute the stored procedure with dynamic input for year 2022
EXEC GetTotalSalesByYear @Year = 2022;

-- Separate the batch using GO for the ALTER PROCEDURE statement
GO

-- ENHANCEMENT 1: Modify the procedure to fetch sales per region
-- Alter the stored procedure to include sales by Region
ALTER PROCEDURE GetTotalSalesByYear
    @Year INT
AS
BEGIN
    BEGIN TRY
        -- Aggregate sales by Region and Year
        SELECT 
            Region, 
            SUM(SaleAmount) AS TotalSales
        FROM Sales
        WHERE YEAR(SaleDate) = @Year
        GROUP BY Region
        ORDER BY TotalSales DESC;
    END TRY
    BEGIN CATCH
        -- Handle error if @Year is invalid or any other issues
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END;

-- Separate the batch using GO after altering the procedure
GO

-- Execute the updated stored procedure for year 2022 with sales by region
EXEC GetTotalSalesByYear @Year = 2022;





--##########################################################################################
--4. Stored Procedures: Dynamic Query Execution & Performance Tuning
-- Step 1: Create the Stored Procedure for Employee Bonus Calculation
CREATE PROCEDURE CalculateBonus
    @BaseSalary DECIMAL(10, 2),      -- Base Salary Input
    @PerformanceRating INT,          -- Performance Rating Input
    @BonusAmount DECIMAL(10, 2) OUTPUT -- Output Bonus Amount
AS
BEGIN
    -- Declare local variable for bonus percentage
    DECLARE @BonusPercentage DECIMAL(5, 2);

    -- Determine bonus percentage based on performance rating and salary range
    IF @PerformanceRating >= 9
    BEGIN
        SET @BonusPercentage = 0.20; -- 20% bonus for high performers
    END
    ELSE IF @PerformanceRating >= 7 AND @PerformanceRating < 9
    BEGIN
        SET @BonusPercentage = 0.10; -- 10% bonus for good performers
    END
    ELSE IF @PerformanceRating >= 5 AND @PerformanceRating < 7
    BEGIN
        SET @BonusPercentage = 0.05; -- 5% bonus for average performers
    END
    ELSE
    BEGIN
        SET @BonusPercentage = 0.00; -- No bonus for poor performance
    END

    -- Adjust bonus based on salary range
    IF @BaseSalary >= 80000
    BEGIN
        SET @BonusPercentage = @BonusPercentage + 0.05; -- Additional 5% for high salary
    END
    ELSE IF @BaseSalary < 50000
    BEGIN
        SET @BonusPercentage = @BonusPercentage - 0.02; -- Deduct 2% for low salary
    END

    -- Calculate final bonus
    SET @BonusAmount = @BaseSalary * @BonusPercentage;

    -- Return the final bonus amount
    RETURN;
END;
GO

-- Step 2: Example to call the stored procedure and retrieve the bonus

-- Declare a variable to hold the output bonus amount
DECLARE @CalculatedBonus DECIMAL(10, 2);

-- Calling the procedure with sample values
EXEC CalculateBonus 
    @BaseSalary = 75000,               -- Input Base Salary
    @PerformanceRating = 8,            -- Input Performance Rating
    @BonusAmount = @CalculatedBonus OUTPUT; -- Output Bonus Amount

-- Display the calculated bonus amount
SELECT @CalculatedBonus AS FinalBonusAmount;

