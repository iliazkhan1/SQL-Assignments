--#############################################################################################
--Assignment 1: Customer Order Management
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(15)
);
GO

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    OrderTotal DECIMAL(10, 2),
    OrderStatus VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT 
        OrderID,
        OrderDate,
        OrderTotal,
        OrderStatus
    FROM Orders
    WHERE CustomerID = @CustomerID;
END;
GO

CREATE PROCEDURE UpdateOrderStatus
    @OrderID INT,
    @NewStatus VARCHAR(20)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        UPDATE Orders
        SET OrderStatus = @NewStatus
        WHERE OrderID = @OrderID;

        PRINT 'Order status updated successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Error: OrderID does not exist.';
    END
END;
GO



--#########################################################################################
--Assignment 2: Inventory Stock Management

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    StockQuantity INT,
    Price DECIMAL(10, 2)
);
GO

CREATE TABLE RestockLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    RestockDate DATETIME,
    QuantityAdded INT,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

CREATE PROCEDURE GetLowStockProducts
    @Threshold INT
AS
BEGIN
    SELECT 
        ProductID,
        ProductName,
        Category,
        StockQuantity,
        Price
    FROM Products
    WHERE StockQuantity < @Threshold;
END;
GO

CREATE PROCEDURE RestockProduct
    @ProductID INT,
    @QuantityToAdd INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
    BEGIN
        UPDATE Products
        SET StockQuantity = StockQuantity + @QuantityToAdd
        WHERE ProductID = @ProductID;

        INSERT INTO RestockLog (ProductID, RestockDate, QuantityAdded)
        VALUES (@ProductID, GETDATE(), @QuantityToAdd);

        SELECT StockQuantity
        FROM Products
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        PRINT 'Error: ProductID does not exist.';
    END
END;
GO
