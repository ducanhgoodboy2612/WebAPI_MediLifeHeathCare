USE [QLyNhaThuoc]
GO

/****** Object:  Table [dbo].[Employee]    Script Date: 11/10/2023 8:19:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Employee](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Gender] [int] NULL,
	[YoB] [int] NULL,
	[Address] [nvarchar](max) NULL,
	[Phone] [nvarchar](20) NULL,
	[Salary] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE PROCEDURE sp_GetEmployeeById
    @EmployeeId INT
AS
BEGIN
    SELECT * FROM Employee
    WHERE ID = @EmployeeId;
END

CREATE PROCEDURE sp_AddEmployee
    @Name NVARCHAR(255),
    @Gender INT,
    @YoB INT,
    @Address NVARCHAR(MAX),
    @Phone NVARCHAR(20),
    @Salary INT
AS
BEGIN
    INSERT INTO Employee (Name, Gender, YoB, Address, Phone, Salary)
    VALUES (@Name, @Gender, @YoB, @Address, @Phone, @Salary);
END


CREATE PROCEDURE sp_UpdateEmployee
    @EmployeeId INT,
    @Name NVARCHAR(255),
    @Gender INT,
    @YoB INT,
    @Address NVARCHAR(MAX),
    @Phone NVARCHAR(20),
    @Salary INT
AS
BEGIN
    UPDATE Employee
    SET Name = @Name,
        Gender = @Gender,
        YoB = @YoB,
        Address = @Address,
        Phone = @Phone,
        Salary = @Salary
    WHERE ID = @EmployeeId;
END

CREATE PROCEDURE [dbo].[sp_DeleteEmployee]
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM [dbo].[Employee] WHERE [ID] = @EmployeeId)
    BEGIN
 
        DELETE FROM [dbo].[Employee] WHERE [ID] = @EmployeeId;
        SELECT 'Employee deleted successfully.' AS Result;
    END
    ELSE
    BEGIN
    
        SELECT 'Employee not found.' AS Result;
    END
END
ALTER PROCEDURE sp_DeleteEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Employee
    WHERE ID = @EmployeeId;

END


EXEC [dbo].[sp_employee_search2] 
    @page_index = 1, 
    @page_size = 10, 
    @name = 'Lee', 
    @address = '222 Cedar St, City, Country';

CREATE PROCEDURE [dbo].[sp_employee_search2]
    @page_index INT, 
    @page_size INT,
    @name NVARCHAR(50),
    @address NVARCHAR(250)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF (@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        SELECT ROW_NUMBER() OVER (ORDER BY Name ASC) AS RowNumber, 
                e.ID,
							  e.Name,
							  e.Gender,
							  e.YoB,
							  e.Phone,
							  e.Address,
							  e.Salary
        INTO #Results1
        FROM Employee AS e
        WHERE (@name = '' OR e.Name LIKE N'%' + @name + '%')
          AND (@address = '' OR e.Address LIKE N'%' + @address + '%');

        SELECT @RecordCount = COUNT(*)
        FROM #Results1;

        SELECT *, 
               @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1 AND ((@page_index - 1) * @page_size + 1) + @page_size - 1
            OR @page_index = -1;

        DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        SELECT ROW_NUMBER() OVER (ORDER BY Name ASC) AS RowNumber, 
                e.ID,
							  e.Name,
							  e.Gender,
							  e.YoB,
							  e.Phone,
							  e.Address,
							  e.Salary
        INTO #Results2
        FROM Employee AS e
        WHERE (@name = '' OR e.Name LIKE N'%' + @name + '%')
          AND (@address = '' OR e.Address LIKE N'%' + @address + '%');

        SELECT @RecordCount = COUNT(*)
        FROM #Results2;

        SELECT *, 
               @RecordCount AS RecordCount
        FROM #Results2;

        DROP TABLE #Results2;
    END;
END;

CREATE PROCEDURE sp_SearchEmployee
    @Name NVARCHAR(255),
    @fr_Salary INT = NULL,
    @to_Salary INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Employee
    WHERE 
        Name LIKE '%' + @Name + '%' AND
        (
			(@fr_Salary IS NULL AND @to_Salary IS NULL) OR
            (@fr_Salary IS NULL AND Salary < @to_Salary) OR
            (@to_Salary IS NULL AND Salary > @fr_Salary) OR
            (Salary > @fr_Salary AND Salary < @to_Salary)
        );
END

EXEC [dbo].[sp_search_emp] 
    @page_index = 1, 
    @page_size = 10, 
    @emp_name = ' ', 
    @fr_Salary = 1400;
create PROCEDURE [dbo].[sp_search_emp] (@page_index  INT, 
                                       @page_size   INT,
									    @emp_name NVARCHAR(255),
										@fr_Salary INT = NULL,
										@to_Salary INT = NULL
									   )
AS
    BEGIN
        DECLARE @RecordCount BIGINT;
        IF(@page_size <> 0)
            BEGIN
						SET NOCOUNT ON;
                        SELECT(ROW_NUMBER() OVER(
                              ORDER BY e.Salary ASC)) AS RowNumber, 
                              e.ID,
							  e.Name,
							  e.Gender,
							  e.YoB,
							  e.Phone,
							  e.Address,
							  e.Salary
                        INTO #Results1
                        FROM Employee  e
						
					    WHERE  Name LIKE '%' + @emp_name + '%' AND
								(
									(@fr_Salary IS NULL AND @to_Salary IS NULL) OR
									(@fr_Salary IS NULL AND Salary < @to_Salary) OR
									(@to_Salary IS NULL AND Salary > @fr_Salary) OR
									(Salary > @fr_Salary AND Salary < @to_Salary)
								);  
                        SELECT @RecordCount = COUNT(*)
                        FROM #Results1;
                        SELECT *, 
                               @RecordCount AS RecordCount
                        FROM #Results1
                        WHERE ROWNUMBER BETWEEN(@page_index - 1) * @page_size + 1 AND(((@page_index - 1) * @page_size + 1) + @page_size) - 1
                              OR @page_index = -1;
                        DROP TABLE #Results1; 
            END;
            ELSE
            BEGIN
						SET NOCOUNT ON;
                         SELECT(ROW_NUMBER() OVER(
                              ORDER BY e.Salary ASC)) AS RowNumber, 
                              e.ID,
							  e.Name,
							  e.Gender,
							  e.YoB,
							  e.Phone,
							  e.Address,
							  e.Salary
                        INTO #Results2
                        FROM Employee  e
						
					    WHERE  Name LIKE '%' + @emp_name + '%' AND
								(
									(@fr_Salary IS NULL AND @to_Salary IS NULL) OR
									(@fr_Salary IS NULL AND Salary < @to_Salary) OR
									(@to_Salary IS NULL AND Salary > @fr_Salary) OR
									(Salary > @fr_Salary AND Salary < @to_Salary)
								);   
                        SELECT @RecordCount = COUNT(*)
                        FROM #Results2;
                        SELECT *, 
                               @RecordCount AS RecordCount
                        FROM #Results2                        
                        DROP TABLE #Results2; 
        END;
    END;
GO

EXEC sp_search_emp 
    @page_index = 1,
    @page_size = 10,
    @emp_name = 'Jane Smith',
    @fr_Salary = 1000,
    @to_Salary = 3000;

CREATE TABLE Cate (
    Cate_id INT PRIMARY KEY,
    Cate_name NVARCHAR(200),
    Descript NVARCHAR(200)
);

INSERT INTO Cate (Cate_id, Cate_name, Descript)
VALUES 
   
	(3, N'Thuốc nội tiết', 'Description 3'),
	(4, N'Mẹ và bé', 'Description 4'),
	(5, N'Thuốc chữa bệnh ngoài da', 'Description 5')
   ;

CREATE PROCEDURE sp_cate_getAll
   
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Cate
   
END;

CREATE PROCEDURE sp_cate_getAll
   
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Cate
   
END;
CREATE PROCEDURE sp_AddCate
    @CateID INT,
    @CateName NVARCHAR(200),
    @Description NVARCHAR(200)
AS
BEGIN
    INSERT INTO Cate (Cate_id, Cate_name, Descript)
    VALUES (@CateID, @CateName, @Description)
END;

CREATE PROCEDURE sp_DeleteCategory
    @CategoryID INT
AS
BEGIN
    BEGIN TRANSACTION; 

    DELETE FROM Product
    WHERE Cate_Id = @CategoryID;

    DELETE FROM Cate
    WHERE Cate_id = @CategoryID;

    COMMIT TRANSACTION;
END;


alter PROCEDURE sp_cate2_getbyid
    @CateId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Cate
    WHERE Cate_id = @CateId;
END;
exec sp_cate2_getbyid @CateId= 1
DROP TABLE Customer
CREATE TABLE Customer (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Gender BIT,
    Address NVARCHAR(255),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    AccPoint INT
);

INSERT INTO Customer (Name, Gender, Address, Phone, Email, AccPoint)
VALUES 
    ('John Faker', 1, '123 Main St', '123-456-7890', 'john@example.com', 100),
    ('Tina Smith', 0, '456 Oak St', '987-654-3210', 'jane@example.com', 75),
    ('Alice Johnson', 0, '789 Elm St', '111-222-3333', 'alice@example.com', 150),
    ('Bob Brown', 1, '567 Pine St', '444-555-6666', 'bob@example.com', 50),
    ('Emily Davis', 0, '101 Cedar St', '777-888-9999', 'emily@example.com', 120),
    ('Michael Wilson', 1, '222 Birch St', '222-333-4444', 'michael@example.com', 200),
    ('Sophia Miller', 0, '333 Maple St', '555-666-7777', 'sophia@example.com', 90),
    ('William Garcia', 1, '444 Walnut St', '888-999-0000', 'william@example.com', 80),
    ('Olivia Rodriguez', 0, '555 Ash St', '333-444-5555', 'olivia@example.com', 110),
    ('Liam Martinez', 1, '666 Cherry St', '666-777-8888', 'liam@example.com', 130),
    ('Ava Hernandez', 0, '777 Poplar St', '999-000-1111', 'ava@example.com', 70),
    ('Noah Lopez', 1, '888 Cedar St', '000-111-2222', 'noah@example.com', 180),
    ('Emma Gonzalez', 0, '999 Pine St', '111-222-3333', 'emma@example.com', 95),
    ('James Perez', 1, '121 Oak St', '222-333-4444', 'james@example.com', 140);

CREATE PROCEDURE sp_Customer_GetByName
    @CustomerName NVARCHAR(100)
AS
BEGIN
    SELECT * FROM Customer WHERE Name LIKE '%' + @CustomerName + '%';
END

CREATE PROCEDURE sp_AddCustomer
    @Name NVARCHAR(100),
    @Gender BIT,
    @Address NVARCHAR(255),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(100),
    @AccPoint INT
AS
BEGIN
    INSERT INTO Customer (Name, Gender, Address, Phone, Email, AccPoint)
    VALUES (@Name, @Gender, @Address, @Phone, @Email, @AccPoint);
END

CREATE PROCEDURE sp_UpdateCustomer
    @CustomerId INT,
    @Name NVARCHAR(100),
    @Gender BIT,
    @Address NVARCHAR(255),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(100),
    @AccPoint INT
AS
BEGIN
    UPDATE Customer
    SET Name = @Name, Gender = @Gender, Address = @Address, Phone = @Phone, Email = @Email, AccPoint = @AccPoint
    WHERE Id = @CustomerId;
END

CREATE PROCEDURE sp_DeleteCustomer
    @CustomerId INT
AS
BEGIN
    DELETE FROM Customer WHERE Id = @CustomerId;
END

SELECT * FROM SalesInvoice

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[sp_customer_get_by_id](@id int)
AS
    BEGIN
      SELECT  *
      FROM Customer
      where Id= @id;
    END;
GO


--Product

CREATE TABLE Product (
    Product_Id INT IDENTITY(1,1) PRIMARY KEY,
    Cate_Id INT,
    Product_Name NVARCHAR(200),
    Unit NVARCHAR(50),
    Unit_Price INT,
    Quantity_In_Stock INT
);

INSERT INTO Product (Cate_Id, Product_Name, Unit, Unit_Price, Quantity_In_Stock)
VALUES
    (1, N'Viên vai gáy Thái Dương (2 vỉ x 6 viên)', N'hộp', 102000, 40),
    (2, N'Thực phẩm chức năng hỗ trợ cai rượu Boni Ancol (60 viên)', N'hộp', 122000, 20),
    (3, N'Acnacare (3 vỉ x 10 viên/hộp)', N'hộp', 134000, 42),
    (4, N'Khăn ướt em bé', N'hộp', 12000, 12)
 ;

 INSERT INTO Product (Cate_Id, Product_Name, Unit, Unit_Price, Quantity_In_Stock)
VALUES
    (5, N'Dầu mù u Thái Dương', N'hộp', 30000, 15),
    (5, N'Tên sản phẩm 2', N'hộp', 35000, 20),
    (5, N'Tên sản phẩm 3', N'hộp', 40000, 18),
    (5, N'Tên sản phẩm 4', N'hộp', 420000, 25),
    (5, N'Tên sản phẩm 5', N'hộp', 380000, 30),
    (6, N'Tên sản phẩm 6', N'hộp', 310000, 12),
    (6, N'Tên sản phẩm 7', N'hộp', 330000, 28),
    (6, N'Tên sản phẩm 8', N'hộp', 350000, 22),
    (6, N'Tên sản phẩm 9', N'hộp', 390000, 35),
    (6, N'Tên sản phẩm 10', N'hộp', 420000, 48),
    (7, N'Tên sản phẩm 11', N'hộp', 320000, 20),
    (7, N'Tên sản phẩm 12', N'hộp', 340000, 16),
    (7, N'Tên sản phẩm 13', N'hộp', 370000, 24),
    (7, N'Tên sản phẩm 14', N'hộp', 400000, 30),
    (7, N'Tên sản phẩm 15', N'hộp', 420000, 18),
    (8, N'Tên sản phẩm 16', N'hộp', 350000, 22),
    (8, N'Tên sản phẩm 17', N'hộp', 380000, 26),
    (8, N'Tên sản phẩm 18', N'hộp', 410000, 32),
    (8, N'Tên sản phẩm 19', N'hộp', 420000, 40),
    (8, N'Tên sản phẩm 20', N'hộp', 390000, 10);


SELECT * FROM Cate
CREATE PROCEDURE sp_Product_GetById
    @ProductId INT
AS
BEGIN
    SELECT *
    FROM Product
    WHERE Product_Id = @ProductId;
END

CREATE PROCEDURE sp_Product_GetAll
AS
BEGIN
    SELECT *
    FROM Product;
END

exec sp_Product_GetAllByCate @CategoryName = N'bé'
ALTER PROCEDURE sp_Product_GetAllByCate
    @CategoryName NVARCHAR(200)
AS
BEGIN
    SELECT p.Product_Id, p.Cate_Id, p.Product_Name, p.Unit, p.Unit_Price, p.Quantity_In_Stock
    FROM Product p
    INNER JOIN Cate c ON p.Cate_Id = c.Cate_id
    WHERE c.Cate_name LIKE '%'+ @CategoryName +'%';
END;

CREATE PROCEDURE sp_Product_GetAllByCateid
    @CategoryID INT
AS
BEGIN
    SELECT p.Product_Id, p.Cate_Id, p.Product_Name, p.Unit, p.Unit_Price, p.Quantity_In_Stock, p.Picture
    FROM Product p
    
    WHERE p.Cate_Id = @CategoryID;
END;

CREATE PROCEDURE sp_Product_GetNewP
AS
BEGIN
    SELECT TOP 5 *
    FROM Product
    ORDER BY Product_Id DESC;
END;
GO


CREATE PROCEDURE sp_AddProduct
    @Cate_Id INT,
    @Product_Name NVARCHAR(200),
    @Unit NVARCHAR(50),
    @Unit_Price INT,
    @Quantity_In_Stock INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Cate WHERE Cate_id = @Cate_Id)
    BEGIN
        INSERT INTO Product (Cate_Id, Product_Name, Unit, Unit_Price, Quantity_In_Stock)
        VALUES (@Cate_Id, @Product_Name, @Unit, @Unit_Price, @Quantity_In_Stock);
    END
    ELSE
    BEGIN
        RAISERROR('Cate_Id does not exist in Cate table.', 11, 1);
    END
END

CREATE PROCEDURE sp_UpdateProduct
    @Product_Id INT,
    @Cate_Id INT,
    @Product_Name NVARCHAR(200),
    @Unit NVARCHAR(50),
    @Unit_Price INT,
    @Quantity_In_Stock INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Cate WHERE Cate_id = @Cate_Id)
    BEGIN
        UPDATE Product
        SET Cate_Id = @Cate_Id,
            Product_Name = @Product_Name,
            Unit = @Unit,
            Unit_Price = @Unit_Price,
            Quantity_In_Stock = @Quantity_In_Stock
        WHERE Product_Id = @Product_Id;
    END
    ELSE
    BEGIN
        RAISERROR('Cate_Id does not exist in Cate table.', 16, 1);
    END
END
CREATE PROCEDURE sp_DeleteProduct
    @Product_Id INT
AS
BEGIN
    DELETE FROM Product
    WHERE Product_Id = @Product_Id;
END

CREATE PROCEDURE [dbo].[sp_search_product] (
    @page_index INT,
    @page_size INT,
    @product_name NVARCHAR(255) = NULL,
    @fr_Price INT = NULL,
    @to_Price INT = NULL,
    @cate_name NVARCHAR(200) = NULL -- Thêm tham số tìm kiếm theo cate_name
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF (@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        IF @cate_name IS NOT NULL -- Nếu có nhập cate_name
        BEGIN
            IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
                DROP TABLE #Results1;

            SELECT ROW_NUMBER() OVER (ORDER BY p.Unit_Price ASC) AS RowNumber,
                   p.Product_Id,
                   p.Cate_Id,
                   p.Product_Name,
                   p.Unit,
                   p.Unit_Price,
                   p.Quantity_In_Stock
            INTO #Results1
            FROM Product p
            INNER JOIN Cate c ON p.Cate_Id = c.Cate_id -- Join với bảng Cate
            WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%')
              AND (
                      (c.Cate_name LIKE '%' + @cate_name + '%') -- Tìm kiếm tương đối cate_name thông qua cate_id
                      OR
                      (@fr_Price IS NULL AND @to_Price IS NULL)
                      OR
                      (@fr_Price IS NULL AND p.Unit_Price < @to_Price)
                      OR
                      (@to_Price IS NULL AND p.Unit_Price > @fr_Price)
                      OR
                      (p.Unit_Price > @fr_Price AND p.Unit_Price < @to_Price)
                  );
        END
        ELSE -- Nếu không nhập cate_name
        BEGIN
            IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
                DROP TABLE #Results1;

            SELECT ROW_NUMBER() OVER (ORDER BY p.Unit_Price ASC) AS RowNumber,
                   p.Product_Id,
                   p.Cate_Id,
                   p.Product_Name,
                   p.Unit,
                   p.Unit_Price,
                   p.Quantity_In_Stock
            INTO #Results1
            FROM Product p
            WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%')
              AND (
                      (@fr_Price IS NULL AND @to_Price IS NULL)
                      OR
                      (@fr_Price IS NULL AND p.Unit_Price < @to_Price)
                      OR
                      (@to_Price IS NULL AND p.Unit_Price > @fr_Price)
                      OR
                      (p.Unit_Price > @fr_Price AND p.Unit_Price < @to_Price)
                  );
        END;

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1 AND ((@page_index - 1) * @page_size + 1) + @page_size - 1
            OR @page_index = -1;

        IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
            DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        IF @cate_name IS NOT NULL -- Nếu có nhập cate_name
        BEGIN
            IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
                DROP TABLE #Results2;

            SELECT ROW_NUMBER() OVER (ORDER BY p.Unit_Price ASC) AS RowNumber,
                   p.Product_Id,
                   p.Cate_Id,
                   p.Product_Name,
                   p.Unit,
                   p.Unit_Price,
                   p.Quantity_In_Stock
            INTO #Results2
            FROM Product p
            INNER JOIN Cate c ON p.Cate_Id = c.Cate_id -- Join với bảng Cate
            WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%')
              AND (
                      (c.Cate_name LIKE '%' + @cate_name + '%') -- Tìm kiếm tương đối cate_name thông qua cate_id
                      OR
                      (@fr_Price IS NULL AND @to_Price IS NULL)
                      OR
                      (@fr_Price IS NULL AND p.Unit_Price < @to_Price)
                      OR
                      (@to_Price IS NULL AND p.Unit_Price > @fr_Price)
                      OR
                      (p.Unit_Price > @fr_Price AND p.Unit_Price < @to_Price)
                  );
        END
        ELSE -- Nếu không nhập cate_name
        BEGIN
            IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
                DROP TABLE #Results2;

            SELECT ROW_NUMBER() OVER (ORDER BY p.Unit_Price ASC) AS RowNumber,
                   p.Product_Id,
                   p.Cate_Id,
                   p.Product_Name,
                   p.Unit,
                   p.Unit_Price,
                   p.Quantity_In_Stock
            INTO #Results2
            FROM Product p
            WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%')
              AND (
                      (@fr_Price IS NULL AND @to_Price IS NULL)
                      OR
                      (@fr_Price IS NULL AND p.Unit_Price < @to_Price)
                      OR
                      (@to_Price IS NULL AND p.Unit_Price > @fr_Price)
                      OR
                      (p.Unit_Price > @fr_Price AND p.Unit_Price < @to_Price)
                  );
        END;

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results2;

        IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
            DROP TABLE #Results2;
    END;
END;

ALTER PROCEDURE [dbo].[sp_product_search_full] (
    @page_index INT,
    @page_size INT,
    @product_name NVARCHAR(255),
    @cate_name NVARCHAR(200),
    @fr_Price INT = NULL,
    @to_Price INT = NULL
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF (@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
            DROP TABLE #Results1;

        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber,
               p.Product_Id,
               p.Cate_Id,
               p.Product_Name,
               p.Unit,
               p.Unit_Price,
               p.Quantity_In_Stock
        INTO #Results1
        FROM Product p
        INNER JOIN Cate c ON p.Cate_Id = c.Cate_id
        WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%')
          AND (@cate_name IS NULL OR c.Cate_name LIKE '%' + @cate_name + '%')
          AND (
                  (@fr_Price IS NULL AND @to_Price IS NULL)
                  OR
                  (@fr_Price IS NULL AND p.Unit_Price < @to_Price)
                  OR
                  (@to_Price IS NULL AND p.Unit_Price > @fr_Price)
                  OR
                  (p.Unit_Price > @fr_Price AND p.Unit_Price < @to_Price)
              );

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1 AND ((@page_index - 1) * @page_size + 1) + @page_size - 1
            OR @page_index = -1;

        IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
            DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
            DROP TABLE #Results2;

        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber,
               p.Product_Id,
               p.Cate_Id,
               p.Product_Name,
               p.Unit,
               p.Unit_Price,
               p.Quantity_In_Stock
        INTO #Results2
        FROM Product p
        INNER JOIN Cate c ON p.Cate_Id = c.Cate_id
        WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%')
          AND (@cate_name IS NULL OR c.Cate_name LIKE '%' + @cate_name + '%')
          AND (
                  (@fr_Price IS NULL AND @to_Price IS NULL)
                  OR
                  (@fr_Price IS NULL AND p.Unit_Price < @to_Price)
                  OR
                  (@to_Price IS NULL AND p.Unit_Price > @fr_Price)
                  OR
                  (p.Unit_Price > @fr_Price AND p.Unit_Price < @to_Price)
              );

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results2;

        IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
            DROP TABLE #Results2;
    END;
END;
GO


EXEC sp_product_search_full_v2 @page_index = 1, @page_size = 10,@product_name = '', @cate_id='';

create PROCEDURE [dbo].[sp_search_product] (@page_index  INT, 
                                       @page_size   INT,
									    @product_name NVARCHAR(255),
										@fr_Price INT = NULL,
										@to_Price INT = NULL
									   )
AS
    BEGIN
        DECLARE @RecordCount BIGINT;
        IF(@page_size <> 0)
            BEGIN
						SET NOCOUNT ON;
                        SELECT(ROW_NUMBER() OVER(
                              ORDER BY p.Unit_Price ASC)) AS RowNumber, 
                              p.Product_Id,
							  p.Cate_Id,
							  p.Product_Name,
							  p.Unit,
							  p.Unit_Price,
							  p.Quantity_In_Stock
                        INTO #Results1
                        FROM Product p
						
					    WHERE  Product_Name LIKE '%' + @product_name + '%' AND 
								(
									(@fr_Price IS NULL AND @to_Price IS NULL) OR
									(@fr_Price IS NULL AND Unit_Price < @to_Price) OR
									(@to_Price IS NULL AND Unit_Price > @fr_Price) OR
									(Unit_Price > @fr_Price AND Unit_Price < @to_Price)
								);  
                        SELECT @RecordCount = COUNT(*)
                        FROM #Results1;
                        SELECT *, 
                               @RecordCount AS RecordCount
                        FROM #Results1
                        WHERE ROWNUMBER BETWEEN(@page_index - 1) * @page_size + 1 AND(((@page_index - 1) * @page_size + 1) + @page_size) - 1
                              OR @page_index = -1;
                        DROP TABLE #Results1; 
            END;
            ELSE
            BEGIN
						SET NOCOUNT ON;
                         SELECT(ROW_NUMBER() OVER(
                              ORDER BY p.Unit_Price ASC)) AS RowNumber, 
                              p.Product_Id,
							  p.Cate_Id,
							  p.Product_Name,
							  p.Unit,
							  p.Unit_Price,
							  p.Quantity_In_Stock
                        INTO #Results2
                        FROM Product p
						
					    WHERE  Product_Name LIKE '%' + @product_name + '%' AND
								(
									(@fr_Price IS NULL AND @to_Price IS NULL) OR
									(@fr_Price IS NULL AND Unit_Price < @to_Price) OR
									(@to_Price IS NULL AND Unit_Price > @fr_Price) OR
									(Unit_Price > @fr_Price AND Unit_Price < @to_Price)
								);  
                        SELECT @RecordCount = COUNT(*)
                        FROM #Results2;
                        SELECT *, 
                               @RecordCount AS RecordCount
                        FROM #Results2                        
                        DROP TABLE #Results2; 
        END;
    END;
GO
--------------
create PROCEDURE sp_product_search_full (@page_index  INT, 
                                       @page_size   INT,
									    @product_name NVARCHAR(255),
										@cate_name NVARCHAR(200),
										@fr_Price INT = NULL,
										@to_Price INT = NULL
										
									   )
AS
    BEGIN
        DECLARE @RecordCount BIGINT;
        IF(@page_size <> 0)
            BEGIN
						SET NOCOUNT ON;
                        SELECT(ROW_NUMBER() OVER(
                              ORDER BY p.Unit_Price ASC)) AS RowNumber, 
                              p.Product_Id,
							  p.Cate_Id,
							  p.Product_Name,
							  p.Unit,
							  p.Unit_Price,
							  p.Quantity_In_Stock
                        INTO #Results1
                        FROM Product p
						INNER JOIN Cate c ON p.Cate_Id = c.Cate_id -- Join với bảng Cate
						WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%') AND (@cate_name IS NULL OR c.Cate_name LIKE '%' + @product_name + '%') AND
						
					    --WHERE  Product_Name LIKE '%' + @product_name + '%' AND 
								(
									(@fr_Price IS NULL AND @to_Price IS NULL) OR
									(@fr_Price IS NULL AND Unit_Price < @to_Price) OR
									(@to_Price IS NULL AND Unit_Price > @fr_Price) OR
									(Unit_Price > @fr_Price AND Unit_Price < @to_Price)
								);  
                        SELECT @RecordCount = COUNT(*)
                        FROM #Results1;
                        SELECT *, 
                               @RecordCount AS RecordCount
                        FROM #Results1
                        WHERE ROWNUMBER BETWEEN(@page_index - 1) * @page_size + 1 AND(((@page_index - 1) * @page_size + 1) + @page_size) - 1
                              OR @page_index = -1;
                        DROP TABLE #Results1; 
            END;
            ELSE
            BEGIN
						SET NOCOUNT ON;
                         SELECT(ROW_NUMBER() OVER(
                              ORDER BY p.Unit_Price ASC)) AS RowNumber, 
                              p.Product_Id,
							  p.Cate_Id,
							  p.Product_Name,
							  p.Unit,
							  p.Unit_Price,
							  p.Quantity_In_Stock
                        INTO #Results2
                       FROM Product p
						INNER JOIN Cate c ON p.Cate_Id = c.Cate_id -- Join với bảng Cate
						WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%') AND (@cate_name IS NULL OR c.Cate_name LIKE '%' + @product_name + '%') AND
								(
									(@fr_Price IS NULL AND @to_Price IS NULL) OR
									(@fr_Price IS NULL AND Unit_Price < @to_Price) OR
									(@to_Price IS NULL AND Unit_Price > @fr_Price) OR
									(Unit_Price > @fr_Price AND Unit_Price < @to_Price)
								);  
                        SELECT @RecordCount = COUNT(*)
                        FROM #Results2;
                        SELECT *, 
                               @RecordCount AS RecordCount
                        FROM #Results2                        
                        DROP TABLE #Results2; 
        END;
    END;
GO

alter PROCEDURE sp_product_search_full (
    @page_index INT,
    @page_size INT,
    @product_name NVARCHAR(255),
    @cate_name NVARCHAR(200),
    @fr_Price INT = NULL,
    @to_Price INT = NULL
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF (@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
            DROP TABLE #Results1;

        SELECT ROW_NUMBER() OVER (ORDER BY p.Unit_Price ASC) AS RowNumber,
               p.Product_Id,
               p.Cate_Id,
               p.Product_Name,
               p.Unit,
               p.Unit_Price,
               p.Quantity_In_Stock
        INTO #Results1
        FROM Product p
        INNER JOIN Cate c ON p.Cate_Id = c.Cate_id
        WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%')
          AND (@cate_name IS NULL OR c.Cate_name LIKE '%' + @cate_name + '%')
          AND (
                  (@fr_Price IS NULL AND @to_Price IS NULL)
                  OR
                  (@fr_Price IS NULL AND p.Unit_Price < @to_Price)
                  OR
                  (@to_Price IS NULL AND p.Unit_Price > @fr_Price)
                  OR
                  (p.Unit_Price > @fr_Price AND p.Unit_Price < @to_Price)
              );

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1 AND ((@page_index - 1) * @page_size + 1) + @page_size - 1
            OR @page_index = -1;

        IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
            DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
            DROP TABLE #Results2;

        SELECT ROW_NUMBER() OVER (ORDER BY p.Unit_Price ASC) AS RowNumber,
               p.Product_Id,
               p.Cate_Id,
               p.Product_Name,
               p.Unit,
               p.Unit_Price,
               p.Quantity_In_Stock
        INTO #Results2
        FROM Product p
        INNER JOIN Cate c ON p.Cate_Id = c.Cate_id
        WHERE (@product_name IS NULL OR p.Product_Name LIKE '%' + @product_name + '%')
          AND (@cate_name IS NULL OR c.Cate_name LIKE '%' + @cate_name + '%')
          AND (
                  (@fr_Price IS NULL AND @to_Price IS NULL)
                  OR
                  (@fr_Price IS NULL AND p.Unit_Price < @to_Price)
                  OR
                  (@to_Price IS NULL AND p.Unit_Price > @fr_Price)
                  OR
                  (p.Unit_Price > @fr_Price AND p.Unit_Price < @to_Price)
              );

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results2;

        IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
            DROP TABLE #Results2;
    END;
END;


--SUPPLIERS


CREATE TABLE Supplier (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100),
    Address NVARCHAR(255),
    Phone NVARCHAR(20),
	Email NVARCHAR(50)
);
INSERT INTO Supplier (SupplierName, Address, Phone, Email)
VALUES 
    (N'Công ty Cổ phần Traphaco', N'75 Yên Ninh, Ba Đình, Hà Nội', '1800 6612','info@traphaco.com.vn'),
    (N'Công ty Cổ phần PYMEPHARCO', N'166 – 170 Nguyễn Huệ, Tuy Hòa, Phú Yên', '025 7382 9165','hcns@pymepharco.com'),
    (N'Công ty Cổ phần Dược phẩm ImexPharm', N'Số 4, Đường 30/4, Phường 1, TP Cao Lãnh, Đồng Tháp', '027 7385 1941','info@imex.com.vn'),
    (N'Medtronic PLC', N'Minneapolis, Minnesota, USA', '1000 6912','info@medtronic.com.vn')
    ;

CREATE PROCEDURE sp_Supplier_GetByID
    @SupplierID INT
AS
BEGIN
    SELECT *
    FROM Supplier
    WHERE SupplierID = @SupplierID;
END;

CREATE PROCEDURE sp_AddSupplier
    @SupplierName NVARCHAR(100),
    @Address NVARCHAR(255),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(50)
AS
BEGIN
    INSERT INTO Supplier (SupplierName, Address, Phone, Email)
    VALUES (@SupplierName, @Address, @Phone, @Email);
END;

CREATE PROCEDURE sp_UpdateSupplier
    @SupplierID INT,
    @SupplierName NVARCHAR(100),
    @Address NVARCHAR(255),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(50)
AS
BEGIN
    UPDATE Supplier
    SET SupplierName = @SupplierName,
        Address = @Address,
        Phone = @Phone,
        Email = @Email
    WHERE SupplierID = @SupplierID;
END;

CREATE PROCEDURE sp_DeleteSupplier
    @SupplierID INT
AS
BEGIN
    DELETE FROM Supplier
    WHERE SupplierID = @SupplierID;
END;

--SALE INVOICES

CREATE TABLE SalesInvoice (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
 
    CreatedDate DATE,
    Status BIT,
    CustomerName NVARCHAR(100),
    Phone NVARCHAR(20),
    Address NVARCHAR(250)
);

CREATE TABLE Invoice_Detail (
    InvoiceID INT,
	Product_Id INT,
    Quantity INT,
    Total_Price INT
);
INSERT INTO SalesInvoice (CreatedDate, Status, CustomerName, Phone, Address)
VALUES
    ('2023-11-01', 1, 'John Doe', '123-456-7890', '123 Main St'),
    ('2023-11-02', 0, 'Jane Smith', '987-654-3210', '456 Oak St'),
    ('2023-11-03', 1, 'Alice Johnson', '555-123-4567', '789 Elm St'),
    ('2023-11-04', 2, 'Bob Brown', '444-555-6666', '234 Maple Ave'),
    ('2023-11-05', 1, 'Eva Williams', '777-888-9999', '567 Pine St'),
    ('2023-11-06', 0, 'Michael Davis', '222-333-4444', '890 Cedar St'),
    ('2023-11-07', 1, 'Sarah Wilson', '666-777-8888', '345 Birch St'),
    ('2023-11-08', 2, 'Chris Lee', '333-444-5555', '678 Walnut St'),
    ('2023-11-09', 1, 'Olivia Garcia', '999-888-7777', '901 Spruce St'),
    ('2023-11-10', 0, 'Daniel Rodriguez', '111-222-3333', '432 Pineapple St'),
    ('2023-11-11', 1, 'Sophia Martinez', '777-999-1111', '765 Cherry St'),
    ('2023-11-12', 0, 'Emily Hernandez', '222-333-4444', '987 Grape St'),
    ('2023-11-13', 1, 'William Lopez', '888-777-6666', '234 Orange St'),
    ('2023-11-14', 2, 'Isabella Gonzalez', '555-666-7777', '876 Mango St'),
    ('2023-11-15', 1, 'Mia Perez', '444-555-6666', '345 Coconut St'),
    ('2023-11-16', 0, 'Jacob Torres', '333-444-5555', '789 Kiwi St'),
    ('2023-11-17', 1, 'Amelia Flores', '222-333-4444', '567 Avocado St'),
    ('2023-11-18', 2, 'Matthew Cruz', '111-222-3333', '890 Banana St'),
    ('2023-11-19', 1, 'Grace Gonzales', '999-888-7777', '123 Lemon St'),
    ('2023-11-20', 0, 'Elijah Rivera', '888-999-1111', '456 Lime St');
DROP PROCEDURE [dbo].[sp_sales_invoice_create];

CREATE PROCEDURE [dbo].[sp_sales_invoice_search] (
    @page_index INT,
    @page_size INT,
    @phone NVARCHAR(20),
    @fr_Date DATE = NULL,
    @to_Date DATE = NULL
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF (@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
            DROP TABLE #Results1;

        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber,
               si.InvoiceID,
               si.CreatedDate,
               si.Status,
               si.CustomerName,
               si.Phone,
               si.Address
        INTO #Results1
        FROM SalesInvoice si
        WHERE (@phone IS NULL OR si.Phone = @phone)
          AND (
                (@fr_Date IS NULL AND @to_Date IS NULL)
                OR
                (@fr_Date IS NULL AND si.CreatedDate <= @to_Date)
                OR
                (@to_Date IS NULL AND si.CreatedDate >= @fr_Date)
                OR
                (si.CreatedDate BETWEEN @fr_Date AND @to_Date)
              );

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1 AND ((@page_index - 1) * @page_size + 1) + @page_size - 1
            OR @page_index = -1;

        IF OBJECT_ID('tempdb..#Results1') IS NOT NULL
            DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
            DROP TABLE #Results2;

        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber,
               si.InvoiceID,
               si.CreatedDate,
               si.Status,
               si.CustomerName,
               si.Phone,
               si.Address
        INTO #Results2
        FROM SalesInvoice si
        WHERE (@phone IS NULL OR si.Phone = @phone)
          AND (
                (@fr_Date IS NULL AND @to_Date IS NULL)
                OR
                (@fr_Date IS NULL AND si.CreatedDate <= @to_Date)
                OR
                (@to_Date IS NULL AND si.CreatedDate >= @fr_Date)
                OR
                (si.CreatedDate BETWEEN @fr_Date AND @to_Date)
              );

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results2;

        IF OBJECT_ID('tempdb..#Results2') IS NOT NULL
            DROP TABLE #Results2;
    END;
END;
GO

ALTER PROCEDURE [dbo].[sp_Add_sales_invoice]
(@CustomerName       NVARCHAR(100),
 @Phone				 NVARCHAR(20),
 @Address            NVARCHAR(250),
 @Status             BIT,
 @list_json_invoice_details NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @InvoiceID INT;
    INSERT INTO SalesInvoice
        (CreatedDate, Status, CustomerName, Phone, Address)
    VALUES
        (GETDATE(), @Status, @CustomerName, @Phone, @Address);

    SET @InvoiceID = SCOPE_IDENTITY();
    IF (@list_json_invoice_details IS NOT NULL)
    BEGIN
        INSERT INTO Invoice_Detail
            (InvoiceID, Product_Id, Quantity, Total_Price)
        SELECT
            @InvoiceID AS InvoiceID,
            JSON_VALUE(p.value, '$.product_Id') AS Product_Id,
            JSON_VALUE(p.value, '$.quantity') AS Quantity,
            JSON_VALUE(p.value, '$.total_Price') AS Total_Price
        FROM OPENJSON(@list_json_invoice_details) AS p;
    END;

    SELECT '';
END;
GO

CREATE PROCEDURE [dbo].[sp_Add_import_invoice]
    @SupplierID INT,
    @EmployeeID INT,
    @CarrierName NVARCHAR(150),
    @Status BIT,
    @list_json_invoice_details NVARCHAR(MAX)
AS
BEGIN
    DECLARE @InvoiceID INT;

    INSERT INTO ImportInvoice
        (SupplierID, EmployeeID, CarrierName, CreatedDate, Status)
    VALUES
        (@SupplierID, @EmployeeID, @CarrierName, GETDATE(), @Status);

    SET @InvoiceID = SCOPE_IDENTITY();

    IF (@list_json_invoice_details IS NOT NULL)
    BEGIN
        INSERT INTO Import_Invoice_Detail
            (InvoiceID, Product_Id, Quantity, Price)
        SELECT
            @InvoiceID AS InvoiceID,
            JSON_VALUE(p.value, '$.product_Id') AS Product_Id,
            JSON_VALUE(p.value, '$.quantity') AS Quantity,
            JSON_VALUE(p.value, '$.price') AS Price
        FROM OPENJSON(@list_json_invoice_details) AS p;
    END;

    SELECT '';
END;

CREATE PROCEDURE [dbo].[sp_Add_sales_invoice_V2]
(
    @CustomerName       NVARCHAR(100),
    @Phone              NVARCHAR(20),
    @Address            NVARCHAR(250),
    @Status             BIT,
	@Email              NVARCHAR(100),
    @list_json_invoice_details NVARCHAR(MAX)
    
)
AS
BEGIN
    DECLARE @Id INT;
    DECLARE @InvoiceID INT;

    SELECT @Id = Id FROM Customer WHERE Phone = @Phone;

    IF @Id IS NULL
    BEGIN
        INSERT INTO Customer (Name, Address, Phone, Email, AccPoint)
        VALUES (@CustomerName, @Address, @Phone, @Email, 0);
        SET @Id = SCOPE_IDENTITY();
    END;
	INSERT INTO SalesInvoice
        (CreatedDate, Status, CustomerName, Phone, Address)
    VALUES
        (GETDATE(), @Status, @CustomerName, @Phone, @Address);

    SET @InvoiceID = SCOPE_IDENTITY();

    IF (@list_json_invoice_details IS NOT NULL)
    BEGIN
        INSERT INTO Invoice_Detail (InvoiceID, Product_Id, Quantity, Total_Price)
        SELECT
            @InvoiceID AS InvoiceID,
            JSON_VALUE(p.value, '$.product_Id') AS Product_Id,
            JSON_VALUE(p.value, '$.quantity') AS Quantity,
            JSON_VALUE(p.value, '$.total_Price') AS Total_Price
        FROM OPENJSON(@list_json_invoice_details) AS p;
    END;

    SELECT ''; -- Trả về một giá trị bất kỳ (trống trong trường hợp này)
END;
GO

EXEC [dbo].[sp_Add_sales_invoice_V2]
    @CustomerName = N'Beanz',
    @Phone = '0002314',
    @Address = N'abc',
    @Status = 1,
    @Email = 'tom@email',
    @list_json_invoice_details = N'[{"product_Id": 13, "quantity": 1, "total_Price": 36000}]';


DROP PROCEDURE [dbo].[sp_invoice_details_GetById]
CREATE PROCEDURE [dbo].[sp_invoice_details_GetById]
    @InvoiceID INT
AS
BEGIN
 SELECT h.*, 
        (
            SELECT c.*
            FROM Invoice_Detail AS c
            WHERE h.InvoiceID = c.InvoiceID FOR JSON PATH
        ) AS list_json_invoice_detail
        FROM SalesInvoice AS h
        WHERE  h.InvoiceID = @InvoiceID;
END;
GO

ALTER PROCEDURE [dbo].[sp_ImportInvoice_details_GetById]
    @InvoiceID INT
AS
BEGIN
    SELECT i.*, 
        (
            SELECT d.InvoiceID, d.Product_Id, d.Quantity, d.Price
            FROM Import_Invoice_Detail AS d
            WHERE i.InvoiceID = d.InvoiceID FOR JSON PATH
        ) AS list_json_invoice_detail
    FROM ImportInvoice AS i
    WHERE i.InvoiceID = @InvoiceID;
END;

exec [dbo].[sp_ImportInvoice_details_GetById] @InvoiceID = 1

select * from Product

ALTER PROCEDURE [dbo].[sp_Update_Sales_invoice]
(
    @InvoiceID INT,
    @CustomerName NVARCHAR(100),
    @Phone NVARCHAR(20),
    @Address NVARCHAR(250),
    @Status BIT,
    @list_json_invoice_details NVARCHAR(MAX)
)
AS
BEGIN
   
        -- Update SalesInvoice table
        UPDATE SalesInvoice
        SET
            CustomerName = @CustomerName,
            Phone = @Phone,
            Address = @Address,
            Status = @Status
        WHERE InvoiceID = @InvoiceID;

        IF (@list_json_invoice_details IS NOT NULL)
        BEGIN
            -- Insert data to temp table 
            SELECT
                JSON_VALUE(p.value, '$.invoiceID') as InvoiceID,
                JSON_VALUE(p.value, '$.product_Id') as Product_Id,
                JSON_VALUE(p.value, '$.quantity') as Quantity,
                JSON_VALUE(p.value, '$.total_Price') as Total_Price,
                JSON_VALUE(p.value, '$.status') as Status
            INTO #Results 
            FROM OPENJSON(@list_json_invoice_details) AS p;

            -- Insert new data into Invoice_Detail with Status = 1
            INSERT INTO Invoice_Detail (InvoiceID, Product_Id, Quantity, Total_Price)
            SELECT
                @InvoiceID as InvoiceID,
                #Results.Product_Id,
                #Results.Quantity,
                #Results.Total_Price
            FROM #Results
            WHERE #Results.Status = '1';

            -- Update existing data in Invoice_Detail with Status = 2
            UPDATE Invoice_Detail 
            SET
                Quantity = #Results.Quantity,
                Total_Price = #Results.Total_Price
            FROM #Results 
            WHERE  Invoice_Detail.InvoiceID = #Results.InvoiceID AND Invoice_Detail.Product_Id = #Results.Product_Id AND #Results.Status = '2';

            -- Delete data from Invoice_Detail with Status = 3
            DELETE C
            FROM Invoice_Detail C
            INNER JOIN #Results R
                ON C.InvoiceID = R.InvoiceID AND C.Product_Id = R.Product_Id
            WHERE R.Status = '3';

            DROP TABLE #Results;
        END;

        SELECT '';
  
   
END;

EXEC sp_Update_Sales_invoice 
    @InvoiceID = 25, -- Thay đổi giá trị theo nhu cầu của bạn
    @CustomerName = 'Timo',
    @Phone = '034443',
    @Address = N'Thanh Hà',
    @Status = 1, -- Thay đổi giá trị theo nhu cầu của bạn
    @list_json_invoice_details = '[{"invoiceID": 25, "product_Id": 4, "quantity": 3, "total_Price": 36000, "status": 1}]' -- JSON data

CREATE PROCEDURE sp_DeleteInvoice
    @InvoiceID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Xóa các bản ghi trong bảng Invoice_Detail dựa trên InvoiceID
        DELETE FROM Invoice_Detail
        WHERE InvoiceID = @InvoiceID;

        -- Xóa bản ghi trong bảng SalesInvoice dựa trên InvoiceID
        DELETE FROM SalesInvoice
        WHERE InvoiceID = @InvoiceID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Thông báo lỗi nếu có vấn đề xảy ra
        THROW;
    END CATCH;
END;

alter PROCEDURE sp_Product_GetTop_ByQuantity
    @N INT
AS
BEGIN
    SELECT TOP (@N) 
        p.Product_Id,
		p.Cate_Id,
        p.Product_Name,
        p.Unit,
        p.Unit_Price,
        p.Quantity_In_Stock,
        SUM(id.Quantity) AS Total_Quantity_Sold
    FROM 
        Product p
    INNER JOIN 
        Invoice_Detail id ON p.Product_Id = id.Product_Id
    GROUP BY 
        p.Product_Id,
		p.Cate_Id,
        p.Product_Name,
        p.Unit,
        p.Unit_Price,
        p.Quantity_In_Stock
    ORDER BY 
        SUM(id.Quantity) DESC;
END;

exec sp_Product_GetTop_BySales @N=40

ALTER PROCEDURE sp_Product_GetTop_BySales
    @N INT
AS
BEGIN
    SELECT TOP (@N) 
        p.Product_Id,
		p.Cate_Id,
        p.Product_Name,
        p.Unit,
        p.Unit_Price,
        p.Quantity_In_Stock,
		p.Picture,
        SUM(id.Total_Price) AS Total_Sales_Amount
    FROM 
        Product p
    INNER JOIN 
        Invoice_Detail id ON p.Product_Id = id.Product_Id
    GROUP BY 
        p.Product_Id,
		p.Cate_Id,
        p.Product_Name,
        p.Unit,
        p.Unit_Price,
        p.Quantity_In_Stock,
		p.Picture
    ORDER BY 
        SUM(id.Total_Price) DESC;
END;


ALTER PROCEDURE [dbo].[sp_Update_Import_invoice]
(
    @InvoiceID INT,
    @SupplierID INT,
    @EmployeeID INT,
    @CarrierName NVARCHAR(150),
    @CreatedDate DATE,
    @Status BIT,
    @list_json_invoice_details NVARCHAR(MAX)
)
AS
BEGIN
   
    UPDATE ImportInvoice
    SET
        SupplierID = @SupplierID,
        EmployeeID = @EmployeeID,
        CarrierName = @CarrierName,
        CreatedDate = @CreatedDate,
        Status = @Status
    WHERE InvoiceID = @InvoiceID;

    IF (@list_json_invoice_details IS NOT NULL)
    BEGIN
        -- Insert data to temp table 
        SELECT
            JSON_VALUE(p.value, '$.invoiceID') as InvoiceID,
            JSON_VALUE(p.value, '$.product_Id') as Product_Id,
            JSON_VALUE(p.value, '$.quantity') as Quantity,
            JSON_VALUE(p.value, '$.price') as Price,
			JSON_VALUE(p.value, '$.status') as Status
        INTO #Results 
        FROM OPENJSON(@list_json_invoice_details) AS p;

        -- Insert new data into Import_Invoice_Detail with Status = 1
        INSERT INTO Import_Invoice_Detail (InvoiceID, Product_Id, Quantity, Price)
        SELECT
            @InvoiceID as InvoiceID,
            #Results.Product_Id,
            #Results.Quantity,
            #Results.Price
        FROM #Results
        WHERE #Results.InvoiceID = @InvoiceID AND #Results.Status = '1';

        -- Update existing data in Import_Invoice_Detail with Status = 2
        UPDATE Import_Invoice_Detail 
        SET
            Quantity = #Results.Quantity,
            Price = #Results.Price
        FROM #Results 
        WHERE  Import_Invoice_Detail.InvoiceID = #Results.InvoiceID AND Import_Invoice_Detail.Product_Id = #Results.Product_Id AND #Results.Status = '2';

        -- Delete data from Import_Invoice_Detail with Status = 3
        DELETE C
        FROM Import_Invoice_Detail C
        INNER JOIN #Results R
            ON C.InvoiceID = R.InvoiceID AND C.Product_Id = R.Product_Id
        WHERE R.Status = '3';

        DROP TABLE #Results;
    END;

    SELECT '';
END;

CREATE PROCEDURE [dbo].[sp_Delete_Import_Invoice_By_ID]
(
    @InvoiceID INT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Import_Invoice_Detail WHERE InvoiceID = @InvoiceID;
        DELETE FROM ImportInvoice WHERE InvoiceID = @InvoiceID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;


create PROCEDURE [dbo].[sp_hoa_don_update]
(@MaHoaDon        int, 
 @TenKH              NVARCHAR(50), 
 @Diachi          NVARCHAR(250), 
 @TrangThai         bit,  
 @list_json_chitiethoadon NVARCHAR(MAX)
)
AS
    BEGIN
		UPDATE HoaDons
		SET
			TenKH  = @TenKH ,
			Diachi = @Diachi,
			TrangThai = @TrangThai
		WHERE MaHoaDon = @MaHoaDon;
		
		IF(@list_json_chitiethoadon IS NOT NULL) 
		BEGIN
			 -- Insert data to temp table 
		   SELECT
			  JSON_VALUE(p.value, '$.maChiTietHoaDon') as maChiTietHoaDon,
			  JSON_VALUE(p.value, '$.maHoaDon') as maHoaDon,
			  JSON_VALUE(p.value, '$.maSanPham') as maSanPham,
			  JSON_VALUE(p.value, '$.soLuong') as soLuong,
			  JSON_VALUE(p.value, '$.tongGia') as tongGia,
			  JSON_VALUE(p.value, '$.status') AS status 
			  INTO #Results 
		   FROM OPENJSON(@list_json_chitiethoadon) AS p;
		 
		 -- Insert data to table with STATUS = 1;
			INSERT INTO ChiTietHoaDons (MaSanPham, 
						  MaHoaDon,
                          SoLuong, 
                          TongGia ) 
			   SELECT
				  #Results.maSanPham,
				  @MaHoaDon,
				  #Results.soLuong,
				  #Results.tongGia			 
			   FROM  #Results 
			   WHERE #Results.status = '1' 
			
			-- Update data to table with STATUS = 2
			  UPDATE ChiTietHoaDons 
			  SET
				 SoLuong = #Results.soLuong,
				 TongGia = #Results.tongGia
			  FROM #Results 
			  WHERE  ChiTietHoaDons.maChiTietHoaDon = #Results.maChiTietHoaDon AND #Results.status = '2';
			
			-- Delete data to table with STATUS = 3
			DELETE C
			FROM ChiTietHoaDons C
			INNER JOIN #Results R
				ON C.maChiTietHoaDon=R.maChiTietHoaDon
			WHERE R.status = '3';
			DROP TABLE #Results;
		END;
        SELECT '';
    END;
	
GO

---IMPORT INVOICE

CREATE TABLE ImportInvoice (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT,
	EmployeeID INT,
	CarrierName NVARCHAR(150),
    CreatedDate DATE,
    Status BIT

);

CREATE TABLE Import_Invoice_Detail (
    InvoiceID INT,
	Product_Id INT,
    Quantity INT,
    Price INT
);

INSERT INTO ImportInvoice (SupplierID, EmployeeID, CarrierName, CreatedDate, Status)
VALUES 
    (3, 2, N'Nguyễn Văn A', '2023-12-04', 1),
    (1, 4, N'Trần Thị B', '2023-12-04', 1),
    (1, 3, N'Lê Thị C', '2023-12-04', 0),
    (2, 4, N'Phạm Văn D', '2023-12-04', 1),
    (4, 2, N'Hồ Văn E', '2023-12-04', 0)
;

INSERT INTO Import_Invoice_Detail (InvoiceID, Product_Id, Quantity, Price)
VALUES 
    (1, 3, 45, 28500),
    (2, 8, 50, 30000),
    (3, 5, 38, 27500),
    (4, 10, 42, 29000),
    (5, 2, 55, 29500),
    (1, 7, 48, 29500),
    (2, 11, 33, 28000),
    (3, 4, 57, 30500),
    (4, 9, 40, 29000),
    (5, 6, 47, 30000),
    (1, 12, 36, 28000),
    (2, 1, 52, 31000),
    (3, 3, 39, 27500),
    (4, 8, 58, 30000),
    (5, 10, 41, 29000),
    (1, 5, 50, 30000),
    (2, 7, 47, 29500),
    (3, 11, 35, 28500),
    (4, 4, 43, 29200),
    (5, 9, 60, 31000);

--ACCOUNT

drop table UserAccount
CREATE TABLE UserAccount (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    UserType INT,
    Username VARCHAR(255),
    Pass VARCHAR(255),
    Email VARCHAR(255)
    
);

CREATE PROCEDURE [dbo].[sp_login]
    @username VARCHAR(255),
    @pass VARCHAR(255)
AS
BEGIN
    SELECT *
    FROM UserAccount
    WHERE Username = @username AND Pass = @pass;
END;
GO

INSERT INTO UserAccount (UserType, Username, Pass, Email)
VALUES
    (0, 'bardtommy123', '1234', 'email1@gmail.com'),
    (1, 'john_doe', 'password', 'john@gmail.com'),
    (0, 'alice_doe', 'pass123', 'alice@gmail.com'),
    (1, 'bob_smith', 'pass456', 'bob@gmail.com'),
    (0, 'emily_jones', 'abc123', 'emily@gmail.com'),
    (1, 'david_williams', 'qwerty', 'david@gmail.com'),
    (0, 'sarah_green', 'iloveyou', 'sarah@gmail.com'),
    (1, 'michael_brown', 'letmein', 'michael@gmail.com'),
    (0, 'olivia_wilson', 'testing123', 'olivia@gmail.com'),
	(1, 'abc', '1234', 'ducanh@gmail.com'),
    (1, 'charlotte_anderson', 'securepass', 'charlotte@gmail.com');

---USER

CREATE TABLE [dbo].[User](
    [UserID] [int] PRIMARY KEY IDENTITY(1,1) ,
    [FullName] [nvarchar](250) NULL,
    [DateOfBirth] [date] NULL,
    [Gender] [nvarchar](20) NULL,
    
    [Address] [nvarchar](1500) NULL,
    [Email] [nvarchar](100) NULL,
    [PhoneNumber] [char](20) NULL,
    [Status] int NULL
)

----
DROP TABLE Promotion
CREATE TABLE Promotion (
	Sale_Id INT IDENTITY(1,1) PRIMARY KEY,
    Product_Id INT,
    
    Discount FLOAT,
    Start_Date DATE,
    End_Date DATE
);

INSERT INTO Promotion (Product_Id, Discount, Start_Date, End_Date)
VALUES
    (1, 0.1, '2023-01-15', '2023-05-20'),
    (2, 0.25, '2023-03-01', '2023-08-15'),
    (3, 0.2, '2023-02-10', '2023-06-30'),
    (4, 0.1, '2023-01-25', '2023-12-30'),
    (5, 0.25, '2023-04-05', '2023-12-22');

exec sp_GetProductsInPromotion
CREATE PROCEDURE sp_GetProductsInPromotion
AS
BEGIN
    DECLARE @CurrentDate DATE;
    SET @CurrentDate = GETDATE(); 

    SELECT 
        p.Product_Id, p.Product_Name, p.Unit, p.Unit_Price, p.Quantity_In_Stock,
        pr.Sale_Id, pr.Discount, pr.Start_Date, pr.End_Date
    FROM 
        Product p
    INNER JOIN 
        Promotion pr ON p.Product_Id = pr.Product_Id
    WHERE 
        @CurrentDate BETWEEN pr.Start_Date AND pr.End_Date;
END;

CREATE PROCEDURE sp_GetTotalRevenue
AS
BEGIN
    SELECT SUM(Total_Price) AS TotalRevenue
    FROM Invoice_Detail d INNER JOIN SalesInvoice s ON d.InvoiceID = s.InvoiceID
    WHERE s.Status = 1; 
END
GO

CREATE PROCEDURE sp_GetTotalRevenue2
AS
BEGIN
    DECLARE @TotalRevenue DECIMAL(18, 2);

    SELECT @TotalRevenue = SUM(CONVERT(DECIMAL(18, 2), Total_Price)) 
    FROM Invoice_Detail d INNER JOIN SalesInvoice s ON d.InvoiceID = s.InvoiceID
    WHERE s.Status = 1; 

    SELECT @TotalRevenue AS TotalRevenue; 

END
GO


ALTER PROCEDURE sp_GetTotalRevenue_ByDateRange
@StartDate DATE,
@EndDate DATE
AS
BEGIN
    DECLARE @TotalRevenue DECIMAL(18, 2); -- Định nghĩa biến để lưu trữ tổng doanh thu

    SELECT @TotalRevenue = SUM(CONVERT(DECIMAL(18, 2), Total_Price)) -- Chuyển đổi Total_Price sang decimal
    FROM Invoice_Detail d INNER JOIN SalesInvoice s ON d.InvoiceID = s.InvoiceID
    WHERE s.Status = 1 AND CreatedDate BETWEEN @StartDate AND @EndDate; 

    SELECT @TotalRevenue AS TotalRevenue; -- Trả về giá trị decimal

END
GO

CREATE PROCEDURE sp_GetTotalImport_ByDateRange
@StartDate DATE,
@EndDate DATE
AS
BEGIN
    DECLARE @Total DECIMAL(18, 2);

    SELECT @Total = SUM(CONVERT(DECIMAL(18, 2), d.Quantity * d.Price))
    FROM Import_Invoice_Detail d
    INNER JOIN ImportInvoice i ON d.InvoiceID = i.InvoiceID
    WHERE i.Status = 1 AND i.CreatedDate BETWEEN @StartDate AND @EndDate; 

    SELECT @Total AS TotalRevenue;

END
GO

select * from ImportInvoice
exec sp_GetTotalImport_ByDateRange @StartDate = '2023-12-10' ,  @EndDate = '2023-12-19'