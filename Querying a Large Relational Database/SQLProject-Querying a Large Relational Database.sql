/* 
        Project – Querying a Large Relational Database


Problem Statement:
How to get details about customers by querying a database? 


Topics: 
In this project, first, you will work on downloading a database and restoring it on the server. 
You will then query the database to get customer details like name, phone number, email ID, 
sales made in a particular month, increase in month-on-month sales, and even the total sales 
made to a particular customer. 


Highlights: 
 Table basics and data types 
 Various SQL operators 
 Various SQL functions


Tasks to be performed: 

Step-1: Download the Adventure Works database from the following location and restore it 
in your server 

Location: https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks 

File Name: AdventureWorks2012.bak

AdventureWorks is a sample database shipped with SQL Server, and it can be downloaded 
from the GitHub site. AdventureWorks has replaced Northwind and Pubs sample databases 
that were available in SQL Server 2005. Microsoft keeps updating the sample database as it 
releases new versions. 


Step-2: Restore Backup 

Follow the below steps to restore a backup of your database using SQL Server Management 
Studio: 
 Open SQL Server Management Studio and connect to the target SQL Server instance 
 Right-click on the Databases node and select Restore Database 
 Select Device and click on the ellipsis (...) 
 In the dialog, select Backup devices, click on Add, navigate to the database backup in 
the file system of the server, select the backup, and click on OK. 
 If needed, change the target location for the data and log files in the Files pane 
Note: It is a best practice to place the data and log files on different drives. 
 Now, click on OK 
This will initiate the database restore. After it completes, you will have the 
AdventureWorks database installed on your SQL Server instance.

 
Step-3: Perform the following with help of the above database */


-- (1)Get all the details from the person table including email ID, phone number, and phone number type

SELECT 
   p.BusinessEntityID,
   p.FirstName,
   p.LastName,
   p.EmailPromotion,
   e.EmailAddress,
   pp.PhoneNumber,
   pnt.Name AS PhoneNumberType
FROM 
   Person.Person p
   LEFT JOIN Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID
   LEFT JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
   LEFT JOIN Person.PhoneNumberType pnt ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID;


-- (2)Get the details of the sales header order made in May 2011

SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2011-05-01' AND '2011-05-31';


-- (3)Get the details of the sales details order made in the month of May 2011:

SELECT *
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE OrderDate BETWEEN '2011-05-01' AND '2011-05-31';


-- (4)Get the total sales made in May 2011:

SELECT SUM(TotalDue) as TotalSales
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2011-05-01' AND '2011-05-31';


-- (5)Get the total sales made in the year 2011 by month order by increasing sales:

SELECT 
    MONTH(OrderDate) as Month,
	SUM(TotalDue) as TotalSales
FROM 
    Sales.SalesOrderHeader
WHERE
    YEAR(OrderDate) = 2011
GROUP BY
    MONTH(OrderDate)
ORDER BY
    TotalSales;


-- (6)Get the total sales made to the customer with FirstName='Gustavo' and LastName='Achong':

SELECT 
   p.FirstName, 
   p.LastName,
   SUM(soh.TotalDue) AS TotalSales
FROM 
   Sales.SalesOrderHeader soh
   JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
   JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE 
   FirstName='Gustavo' and LastName='Achong'
GROUP BY
   p.FirstName, p.LastName;


/*Explanation
Restoring the Database: 
Follow the steps outlined to restore the AdventureWorks database from the provided backup file.

Queries: 
Each query retrieves the required data based on the specified criteria using SQL JOINs, 
aggregate functions, and filtering with WHERE and GROUP BY clauses. 
The results include details from tables like Person, SalesOrderHeader,
and SalesOrderDetail to gather comprehensive customer and sales information. */