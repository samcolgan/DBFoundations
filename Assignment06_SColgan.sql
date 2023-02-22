--*************************************************************************--
-- Title: Assignment06
-- Author: SColgan
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2023-02-20,SColgan,Changed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SColgan')
	 Begin 
	  Alter Database [Assignment06DB_SColgan] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SColgan;
	 End
	Create Database Assignment06DB_SColgan;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SColgan;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
/* Scaffolding
-- Select base tables
Select * From Categories;
Select * From Products;
Select * From Employees;
Select * From Inventories;

-- Select base tables by column names
Select [CategoryID], [CategoryName]
  From Categories

Select [ProductID], [ProductName], [CategoryID], [UnitPrice]
  From Products

Select [EmployeeID], [EmployeeFirstName], [EmployeeLastName], [ManagerID]
  From Employees

Select [InventoryID], [InventoryDate], [EmployeeID], [ProductID], [Count]
  From Inventories 
*/
Go
Create View vCategories
With Schemabinding 
As
Select [CategoryID], [CategoryName]
  From dbo.Categories
;
Go

Create View vProducts
With Schemabinding
As 
Select [ProductID], [ProductName], [CategoryID], [UnitPrice]
  From dbo.Products
;
Go

Create View vEmployees
With Schemabinding
As
Select [EmployeeID], [EmployeeFirstName], [EmployeeLastName], [ManagerID]
  From dbo.Employees
;
Go

Create View vInventories
With Schemabinding
As 
Select [InventoryID], [InventoryDate], [EmployeeID], [ProductID], [Count]
  From dbo.Inventories 
;
Go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
/* Scaffolding
-- Deny permissions for tables, but grant them for views.
*/
Deny Select On Categories to Public;
Grant Select On vCategories to Public;
Go

Deny Select On Products to Public;
Grant Select On vProducts to Public;
Go

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;
Go

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/* Scaffolding
-- Select all data from both tables
Select * From Categories;
Select * From Products;

-- Select specific columns from both tables
Select [CategoryName] 
  From Categories;

Select [ProductName], [UnitPrice]
  From Products;

-- Join both tables
Select [CategoryName], [ProductName], [UnitPrice]
  From Categories Inner Join Products
  On Categories.[CategoryID] = Products.[CategoryID];

-- Order by category and by product
Select [CategoryName], [ProductName], [UnitPrice]
  From Categories Inner Join Products
  On Categories.[CategoryID] = Products.[CategoryID]
  Order By [CategoryName], [ProductName];

-- Add aliases
*/
Create View vProductsByCategories
As 
Select Top 10000 [CategoryName], [ProductName], [UnitPrice]
  From Categories as C Inner Join Products as P
  On C.[CategoryID] = P.[CategoryID]
  Order By [CategoryName], [ProductName]
;
Go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
/* Scaffolding
-- Select all data from both tables
Select * From Products;
Select * From Inventories;

-- Select desired columns from both tables
Select [ProductName]
  From Products;

Select [InventoryDate], [Count]
  From Inventories;

-- Join both tables
Select [ProductName], [InventoryDate], [Count]
  From Products Inner Join Inventories
  On Products.[ProductID] = Inventories.[ProductID];

-- Order by date, then product name, then inventory count
Select [ProductName], [InventoryDate], [Count]
  From Products Inner Join Inventories
  On Products.[ProductID] = Inventories.[ProductID]
  Order By [ProductName], [InventoryDate], [Count];

-- Add aliases
*/
Create View vInventoriesByProductsByDates
As 
Select Top 10000 [ProductName], [InventoryDate], [Count]
  From Products as P Inner Join Inventories as I
  On P.[ProductID] = I.[ProductID]
  Order By [ProductName], [InventoryDate], [Count]
;
Go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
/* Scaffolding
-- Select all data from both tables
Select * From Inventories;
Select * From Employees;

-- Select desired columns from both tables
Select [InventoryDate]
  From Inventories;

Select [EmployeeFirstName], [EmployeeLastName]
  From Employees;

-- Join both tables
Select [InventoryDate], [EmployeeFirstName], [EmployeeLastName]
  From Inventories Inner Join Employees
  On Inventories.[EmployeeID] = Employees.[EmployeeID];

-- Add aliases
Select [InventoryDate], [EmployeeFirstName], [EmployeeLastName]
  From Inventories as I Inner Join Employees as E
  On I.[EmployeeID] = E.[EmployeeID];

-- Filter out repeating rows
Select Distinct [InventoryDate], [EmployeeFirstName], [EmployeeLastName]
  From Inventories as I Inner Join Employees as E
  On I.[EmployeeID] = E.[EmployeeID];

--Use table alias to merge first and last name columns
*/
Create View vInventoriesByEmployeesByDates
As
Select Distinct Top 10000 [InventoryDate], [EmployeeName] = [EmployeeFirstName] + ' ' + [EmployeeLastName]
  From Inventories as I Inner Join Employees as E
  On I.[EmployeeID] = E.[EmployeeID]
  Order By [InventoryDate], [EmployeeName]
;
Go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
/* Scaffolding
-- Select all data from all tables
Select * From Categories;
Select * From Products;
Select * From Inventories;

-- Select desired columns from all tables
Select [CategoryName]
  From Categories;

Select [ProductName]
  From Products;

Select [InventoryDate], [Count]
  From Inventories;

-- Join the three tables
Select [CategoryName], [ProductName], [InventoryDate], [Count]
  From Categories Inner Join Products
  On Categories.[CategoryID] = Products.[CategoryID]
  Inner Join Inventories
  On Inventories.[ProductID] = Products.[ProductID];

-- Order by category, then product, then date, and then by count 
Select [CategoryName], [ProductName], [InventoryDate], [Count]
  From Categories Inner Join Products
  On Categories.[CategoryID] = Products.[CategoryID]
  Inner Join Inventories
  On Inventories.[ProductID] = Products.[ProductID]
  Order By [CategoryName], [ProductName], [InventoryDate], [Count];

-- Add aliases
*/
Create View vInventoriesByProductsByCategories
As
Select Top 10000 [CategoryName], [ProductName], [InventoryDate], [Count]
  From Categories as C Inner Join Products as P
  On C.[CategoryID] = P.[CategoryID]
  Inner Join Inventories as I
  On P.[ProductID] = I.[ProductID]
  Order By [CategoryName], [ProductName], [InventoryDate], [Count]
;
Go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
/* Scaffolding
-- Select all columns from all tables
Select * From Categories;
Select * From Products;
Select * From Inventories;
Select * From Employees;

-- Select desired columns from all tables
Select [CategoryName]
  From Categories;

Select [ProductName]
  From Products;

Select [InventoryDate], [Count]
  From Inventories;

Select [EmployeeFirstName], [EmployeeLastName]
  From Employees;

-- Join all tables together
Select [CategoryName], [ProductName], [InventoryDate], [Count], [EmployeeFirstName], [EmployeeLastName]
  From Categories Inner Join Products
  On Categories.[CategoryID] = Products.[CategoryID]
  Inner Join Inventories 
  On Inventories.[ProductID] = Products.[ProductID]
  Inner Join Employees
  On Employees.[EmployeeID] = Inventories.[EmployeeID];

-- Order by inventory date, category name, product name, and then by employee last and first names
Select [CategoryName], [ProductName], [InventoryDate], [Count], [EmployeeFirstName], [EmployeeLastName]
  From Categories Inner Join Products
  On Categories.[CategoryID] = Products.[CategoryID]
  Inner Join Inventories 
  On Inventories.[ProductID] = Products.[ProductID]
  Inner Join Employees
  On Employees.[EmployeeID] = Inventories.[EmployeeID]
  Order By [InventoryDate], [CategoryName], [ProductName], [EmployeeLastName], [EmployeeFirstName];

-- Add table aliases
Select [CategoryName], [ProductName], [InventoryDate], [Count], [EmployeeFirstName], [EmployeeLastName]
  From Categories as C Inner Join Products as P
  On C.[CategoryID] = P.[CategoryID]
  Inner Join Inventories as I
  On I.[ProductID] = P.[ProductID]
  Inner Join Employees as E
  On E.[EmployeeID] = I.[EmployeeID]
  Order By [InventoryDate], [CategoryName], [ProductName], [EmployeeLastName], [EmployeeFirstName];

--Merge employee first and last names using a column alias
*/
Create View vInventoriesByProductsByEmployees
As 
Select Top 10000 [CategoryName], [ProductName], 
				 [InventoryDate], [Count], 
				 [EmployeeName] = [EmployeeFirstName] + ' ' + [EmployeeLastName]
  From Categories as C Inner Join Products as P
  On C.[CategoryID] = P.[CategoryID]
  Inner Join Inventories as I
  On P.[ProductID] = I.[ProductID]
  Inner Join Employees as E
  On I.[EmployeeID] = E.[EmployeeID]
  Order By [InventoryDate], [CategoryName], [ProductName], [EmployeeName]
;
Go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
/* Scaffolding
-- Get all data from products
Select * From Products;

-- Get desired column from products table
Select [ProductID]
  From Products;

-- Construct subquery such that only product IDs for Chai and Chang are included
Select [ProductID]
  From Products
  Where [ProductName] IN ('Chai', 'Chang');

-- Copy answer from previous problem, leaving out order by employee clause since it's not needed.
Select [CategoryName], [ProductName], [InventoryDate], [Count], [EmployeeFirstName] + ' ' + [EmployeeLastName] as [EmployeeName]
  From Categories as C Inner Join Products as P
  On C.[CategoryID] = P.[CategoryID]
  Inner Join Inventories as I
  On I.[ProductID] = P.[ProductID]
  Inner Join Employees as E
  On E.[EmployeeID] = I.[EmployeeID]
  Order By [InventoryDate], [CategoryName], [ProductName]

--Add where clause with subquery
*/
Create View vInventoriesForChaiAndChangByEmployees
As
Select Top 10000 [CategoryName], [ProductName], 
				 [InventoryDate], [Count],
				 [EmployeeName] = [EmployeeFirstName] + ' ' + [EmployeeLastName]
  From Categories as C Inner Join Products as P
  On C.[CategoryID] = P.[CategoryID]
  Inner Join Inventories as I
  On P.[ProductID] = I.[ProductID]
  Inner Join Employees as E
  On I.[EmployeeID] = E.[EmployeeID]
  Where [ProductName] In ('Chai', 'Chang')
  Order By [InventoryDate], [CategoryName], [ProductName], [EmployeeName]
;
Go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/* Scaffolding
-- Select all data from employees
Select * From Employees;

-- Merge first and last name columns with column aliases
Select [EmployeeFirstName] + ' ' + [EmployeeLastName] as [Name]
  From Employees;

-- Use a self join, matching manager IDs to employee IDs.
Select [EmployeeFirstName] + ' ' + [EmployeeLastName] as [Manager],
	   [EmployeeFirstName] + ' ' + [EmployeeLastName] as [Employee]
  From Employees Inner Join Employees 
  On [ManagerID] = [EmployeeID];

-- Add table and column aliases
Select M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName] as [Manager],
	   E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName] as [Employee]
  From Employees as E Inner Join Employees as M
  On E.[ManagerID] = M.[EmployeeID];

-- Order by manager name, then employee
*/
Create View vEmployeesByManager
As
Select Top 10000 [Manager] = M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName],
				 [EmployeeName] = E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]
  From Employees as E Inner Join Employees as M
  On E.[ManagerID] = M.[EmployeeID]
  Order By [Manager], [EmployeeName]
;
Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
/* Scaffolding
-- Copy question 8 result, but include every column name and order by Primary Keys. 
Select [CategoryID], [CategoryName], 
	   [ProductID], [ProductName], [UnitPrice]
	   [InventoryID], [InventoryDate], [Count],
	   [EmployeeID],
	   [Employee] = [EmployeeFirstName] + ' ' + [EmployeeLastName]
  From Categories as C Inner Join Products as P
  On C.[CategoryID] = P.[CategoryID]
  Inner Join Inventories as I
  On P.[ProductID] = I.[ProductID]
  Inner Join Employees as E
  On I.[EmployeeID] = E.[EmployeeID]
  Where [ProductName] In ('Chai', 'Chang')
  Order By [CategoryID], [ProductID], [InventoryID], [EmployeeID]

-- Add in Manager information from question 9
*/
Create View vInventoriesByProductsByCategoriesByEmployees
As
Select Top 1000 C.[CategoryID], [CategoryName],
				P.[ProductID], [ProductName], [UnitPrice],
				I.[InventoryID], [InventoryDate], [Count],
				E.[EmployeeID], 
				[Employee] = E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName],
				[Manager] = M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName]
  From Categories as C Inner Join Products as P
  On C.[CategoryID] = P.[CategoryID]
  Inner Join Inventories as I
  On P.[ProductID] = I.[ProductID]
  Inner Join Employees as E
  On I.[EmployeeID] = E.[EmployeeID]
  Inner Join Employees as M
  On E.[ManagerID] = M.[EmployeeID]
  Order By [CategoryID], [ProductID], [InventoryID], [EmployeeID]
;
Go


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/