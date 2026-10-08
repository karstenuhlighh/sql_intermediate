-- Northwind-Übungen, Lösungen (getestet 08.10.2026)

-- 01
SELECT productname, unitsinstock FROM northwind.products;

-- 02
SELECT * FROM northwind.customers WHERE country = 'Germany';

-- 03
SELECT AVG(shippeddate - orderdate) AS avg_days_to_ship FROM northwind.orders;

-- 04
SELECT productid, productname FROM northwind.products WHERE discontinued = false;

-- 05
SELECT productname, unitprice FROM northwind.products
WHERE unitprice = (SELECT MAX(unitprice) FROM northwind.products)
   OR unitprice = (SELECT MIN(unitprice) FROM northwind.products);

-- 06
SELECT productname, unitprice FROM northwind.products WHERE unitprice < 20;

-- 07
SELECT productname, unitprice FROM northwind.products WHERE unitprice BETWEEN 15 AND 25;

-- 08
SELECT productname, unitprice FROM northwind.products
WHERE unitprice > (SELECT AVG(unitprice) FROM northwind.products);

-- 09
SELECT productname, unitprice FROM northwind.products ORDER BY unitprice DESC LIMIT 10;

-- 10
SELECT productid, productname FROM northwind.products WHERE discontinued = true;

-- 11
SELECT COUNT(*) FILTER (WHERE discontinued = false) AS current_products,
       COUNT(*) FILTER (WHERE discontinued = true) AS discontinued_products
FROM northwind.products;

-- 12
SELECT productname, unitsinstock, unitsonorder FROM northwind.products WHERE unitsinstock < unitsonorder;

-- 13
SELECT c.contactname, SUM(od.unitprice * od.quantity) AS total_amount_order
FROM northwind.orders o
JOIN northwind.order_details od ON o.orderid = od.orderid
JOIN northwind.customers c ON o.customerid = c.customerid
GROUP BY c.customerid, c.contactname
ORDER BY total_amount_order DESC LIMIT 1;

-- 14
SELECT o.orderid, o.orderdate, e.employeeid, e.firstname, e.lastname, c.customerid, c.companyname
FROM northwind.orders o
JOIN northwind.employees e ON o.employeeid = e.employeeid
JOIN northwind.customers c ON o.customerid = c.customerid
WHERE o.employeeid = 1
ORDER BY o.orderid;

-- 15
SELECT employeeid, firstname, lastname, birthdate, hiredate,
       EXTRACT(YEAR FROM hiredate) - EXTRACT(YEAR FROM birthdate) AS hiring_age
FROM northwind.employees ORDER BY employeeid;

-- 16
SELECT city, COUNT(*) AS number_of_customers FROM northwind.customers GROUP BY city ORDER BY number_of_customers DESC;

-- 17
SELECT customerid, COUNT(*) AS total_orders FROM northwind.orders GROUP BY customerid ORDER BY total_orders DESC;

-- 18
SELECT c.categoryname, AVG(p.unitprice) AS avg_price FROM northwind.products p
JOIN northwind.categories c ON p.categoryid = c.categoryid GROUP BY c.categoryname;

-- 19
SELECT e.firstname, e.lastname, t.territorydescription FROM northwind.employees e
JOIN northwind.employee_territories et ON e.employeeid = et.employeeid
JOIN northwind.territories t ON et.territoryid = t.territoryid;

-- 20
SELECT o.orderid, o.orderdate, cu.companyname, p.productname
FROM northwind.orders o
JOIN northwind.customers cu ON o.customerid = cu.customerid
JOIN northwind.order_details od ON o.orderid = od.orderid
JOIN northwind.products p ON od.productid = p.productid
JOIN northwind.categories c ON p.categoryid = c.categoryid
WHERE c.categoryname = 'Beverages'
ORDER BY o.orderid;

-- 21
SELECT COUNT(*) AS orders_1997 FROM northwind.orders WHERE EXTRACT(YEAR FROM orderdate) = 1997;

-- 22
SELECT p.productname, SUM(od.quantity) AS total_quantity_ordered
FROM northwind.order_details od
JOIN northwind.products p ON od.productid = p.productid
GROUP BY p.productname ORDER BY total_quantity_ordered DESC;

-- 23
SELECT cu.customerid, cu.companyname, COUNT(DISTINCT p.categoryid) AS num_categories_ordered
FROM northwind.customers cu
JOIN northwind.orders o ON cu.customerid = o.customerid
JOIN northwind.order_details od ON o.orderid = od.orderid
JOIN northwind.products p ON od.productid = p.productid
GROUP BY cu.customerid, cu.companyname
HAVING COUNT(DISTINCT p.categoryid) > 1
ORDER BY cu.customerid;

-- 24
SELECT c.categoryname, SUM(od.quantity) AS total_quantity_sold,
       SUM(od.unitprice * od.quantity) AS total_sales,
       COUNT(DISTINCT od.orderid) AS num_orders
FROM northwind.order_details od
JOIN northwind.products p ON od.productid = p.productid
JOIN northwind.categories c ON p.categoryid = c.categoryid
GROUP BY c.categoryname ORDER BY c.categoryname;

-- 25
SELECT e.employeeid, e.firstname, e.lastname,
       SUM(od.unitprice * od.quantity) AS total_sales,
       RANK() OVER (ORDER BY SUM(od.unitprice * od.quantity) DESC) AS sales_rank
FROM northwind.employees e
JOIN northwind.orders o ON e.employeeid = o.employeeid
JOIN northwind.order_details od ON o.orderid = od.orderid
GROUP BY e.employeeid, e.firstname, e.lastname
ORDER BY sales_rank;

-- 26
WITH order_sales AS (
    SELECT o.orderid, o.orderdate, SUM(p.unitprice * od.quantity) AS order_sales
    FROM northwind.orders o
    JOIN northwind.order_details od ON o.orderid = od.orderid
    JOIN northwind.products p ON od.productid = p.productid
    GROUP BY o.orderid, o.orderdate)
SELECT orderid, orderdate, order_sales,
       SUM(order_sales) OVER (ORDER BY orderid) AS running_total_sales
FROM order_sales ORDER BY orderid;

-- 27
WITH order_sales AS (
    SELECT o.orderid, o.orderdate, SUM(od.unitprice * od.quantity) AS order_sales
    FROM northwind.orders o
    JOIN northwind.order_details od ON o.orderid = od.orderid
    GROUP BY o.orderid, o.orderdate)
SELECT orderid, orderdate, order_sales,
       LAG(order_sales) OVER (ORDER BY orderdate) AS previous_order_sales,
       order_sales - LAG(order_sales) OVER (ORDER BY orderdate) AS sales_diff
FROM order_sales ORDER BY orderdate;

-- 28
SELECT p.productid, p.productname, SUM(p.unitprice * od.quantity) AS total_sales
FROM northwind.order_details od
JOIN northwind.products p ON od.productid = p.productid
GROUP BY p.productid, p.productname
ORDER BY total_sales DESC LIMIT 5;
