/*
Praktikum-0 [12/03/2025-17/03/2025]

Razi Rachman Widyadhana - 13523004

Operasi Dasar SQL
*/


-- Query 1

SHOW TABLES FROM prak0;


-- Query 2

SHOW COLUMNS FROM prak0.customers;


-- Query 3

SELECT LOWER(customerName) 
FROM customers;


-- Query 4

SELECT customerName 
FROM customers 
WHERE city = 'Bern'  
LIMIT 5;


-- Query 5

SELECT CONCAT(E.firstName, ' ', E.lastName) AS employeeName
FROM employees E, offices O
WHERE E.officeCode = O.officeCode
AND O.country = 'Australia';


-- Query 6
SELECT DISTINCT C.customerName
FROM customers C, payments P
WHERE C.customerNumber = P.customerNumber
AND P.amount > 50000;


-- Query 7

SELECT DISTINCT C.customerName
FROM customers C, employees E, offices O
WHERE E.officeCode = O.officeCode
AND C.salesRepEmployeeNumber = E.employeeNumber
AND O.country = 'Japan'


-- Query 8

SELECT DISTINCT P.productName 
FROM products P, orderdetails OD, orders O 
WHERE P.productCode = OD.productCode
AND OD.orderNumber = O.orderNumber
AND P.buyPrice > 50 
AND MONTH(O.orderDate) BETWEEN 4 AND 9;


-- Query 9

SELECT DISTINCT CONCAT(E.firstName, ' ', E.lastName) AS employeeName 
FROM employees E, customers C, employees Manager
WHERE E.employeeNumber = C.salesRepEmployeeNumber
AND E.reportsTo = Manager.employeeNumber
AND Manager.firstName = 'Anthony' 
AND Manager.lastName = 'Bow'
AND (C.city = 'Brickhaven' OR C.city = 'Las Vegas');