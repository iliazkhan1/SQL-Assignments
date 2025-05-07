--######################################################################################################################
--1. Create and Execute a Stored Procedure with Parameters
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    DepartmentID INT,
    JobTitle VARCHAR(100),
    Salary DECIMAL(10,2)
);
GO

INSERT INTO Employees VALUES
(1, 'Alice', 101, 'Developer', 60000.00),
(2, 'Bob', 102, 'Analyst', 50000.00),
(3, 'Charlie', 101, 'Tester', 45000.00),
(4, 'Diana', 103, 'Manager', 75000.00),
(5, 'Evan', 102, 'Support', 40000.00);
GO

CREATE PROCEDURE GetEmployeesByDepartment
    @DeptID INT
AS
BEGIN
    SELECT 
        EmployeeID,
        Name,
        DepartmentID,
        JobTitle,
        Salary
    FROM Employees
    WHERE DepartmentID = @DeptID;
END;
GO

EXEC GetEmployeesByDepartment @DeptID = 101;
GO

EXEC GetEmployeesByDepartment @DeptID = 102;
GO

EXEC GetEmployeesByDepartment @DeptID = 103;
GO


--####################################################################################################################
--2. Implement Error Handling in Stored Procedures
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) UNIQUE,
    Price DECIMAL(10,2)
);
GO

CREATE TABLE ErrorLogs (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorMessage NVARCHAR(4000),
    ErrorTime DATETIME
);
GO

CREATE PROCEDURE InsertProduct
    @ProductID INT,
    @ProductName VARCHAR(100),
    @Price DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Products (ProductID, ProductName, Price)
        VALUES (@ProductID, @ProductName, @Price);
    END TRY
    BEGIN CATCH
        INSERT INTO ErrorLogs (ErrorMessage, ErrorTime)
        VALUES (ERROR_MESSAGE(), GETDATE());
    END CATCH
END;
GO


EXEC InsertProduct @ProductID = 1, @ProductName = 'Laptop', @Price = 80000.00;
GO


EXEC InsertProduct @ProductID = 1, @ProductName = 'Tablet', @Price = 30000.00;
GO


EXEC InsertProduct @ProductID = 2, @ProductName = 'Laptop', @Price = 75000.00;
GO


SELECT * FROM ErrorLogs;
GO

--######################################################################################################################
--3. Stored Procedure for Data Modification
CREATE TABLE employee (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    DepartmentID INT,
    JobTitle VARCHAR(100),
    Salary DECIMAL(10,2)
);
GO

INSERT INTO employee VALUES
(1, 'Alice', 101, 'Developer', 60000.00),
(2, 'Bob', 102, 'Analyst', 50000.00),
(3, 'Charlie', 101, 'Tester', 45000.00),
(4, 'Diana', 103, 'Manager', 75000.00),
(5, 'Evan', 102, 'Support', 40000.00);
GO

CREATE PROCEDURE UpdateEmployeeSalary
    @EmpID INT,
    @NewSalary DECIMAL(10,2)
AS
BEGIN
    UPDATE employee
    SET Salary = @NewSalary
    WHERE EmployeeID = @EmpID;
END;
GO

EXEC UpdateEmployeeSalary @EmpID = 1, @NewSalary = 65000.00;
GO

EXEC UpdateEmployeeSalary @EmpID = 3, @NewSalary = 50000.00;
GO

EXEC UpdateEmployeeSalary @EmpID = 5, @NewSalary = 45000.00;
GO

SELECT * FROM employee;
GO


--#######################################################################################################################
--4. Stored Procedure with a Conditional Query
CREATE TABLE product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);
GO

INSERT INTO product VALUES
(1, 'Laptop', 'Electronics', 80000.00),
(2, 'Tablet', 'Electronics', 30000.00),
(3, 'Sofa', 'Furniture', 25000.00),
(4, 'Chair', 'Furniture', 5000.00),
(5, 'Book', 'Books', 400.00);
GO

-- 3. Create Stored Procedure with Conditional Query
CREATE PROCEDURE GetProductsByCategory
    @CategoryName VARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM product WHERE Category = @CategoryName)
    BEGIN
        SELECT ProductID, ProductName, Category, Price
        FROM product
        WHERE Category = @CategoryName;
    END
    ELSE
    BEGIN
        PRINT 'Category not found';
    END
END;
GO

EXEC GetProductsByCategory @CategoryName = 'Electronics';
GO

EXEC GetProductsByCategory @CategoryName = 'Furniture';
GO

EXEC GetProductsByCategory @CategoryName = 'Toys';
GO


--#######################################################################################################################
--5. Stored Procedure with Output Parameters
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    CustomerID INT,
    SaleAmount DECIMAL(10,2),
    SaleDate DATE
);
GO

INSERT INTO Sales VALUES
(1, 101, 250.00, '2025-04-01'),
(2, 101, 150.00, '2025-04-02'),
(3, 102, 300.00, '2025-04-03'),
(4, 103, 500.00, '2025-04-04'),
(5, 101, 450.00, '2025-04-05');
GO

-- 3. Create Stored Procedure with Output Parameter
CREATE PROCEDURE GetTotalSales
    @CustomerID INT,
    @TotalSales DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @TotalSales = SUM(SaleAmount)
    FROM Sales
    WHERE CustomerID = @CustomerID;
END;
GO


DECLARE @SalesAmount DECIMAL(10,2);
EXEC GetTotalSales @CustomerID = 101, @TotalSales = @SalesAmount OUTPUT;
SELECT @SalesAmount AS TotalSalesForCustomer101;

DECLARE @SalesAmount2 DECIMAL(10,2);
EXEC GetTotalSales @CustomerID = 102, @TotalSales = @SalesAmount2 OUTPUT;
SELECT @SalesAmount2 AS TotalSalesForCustomer102;

DECLARE @SalesAmount3 DECIMAL(10,2);
EXEC GetTotalSales @CustomerID = 103, @TotalSales = @SalesAmount3 OUTPUT;
SELECT @SalesAmount3 AS TotalSalesForCustomer103;
GO
