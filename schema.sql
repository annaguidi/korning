-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS frequency;


CREATE TABLE employee(
  id SERIAL PRIMARY KEY,
  name varchar(50),
  email varchar(50)
);

CREATE TABLE customer(
  id varchar(50) PRIMARY KEY,
  name varchar(50)
);

CREATE TABLE product(
  id SERIAL PRIMARY KEY,
  product_name varchar(50)
);

CREATE TABLE frequency(
  id SERIAL PRIMARY KEY,
  inv_freq varchar(50)
);

CREATE TABLE invoices(
  id SERIAL PRIMARY KEY,
  inv_num INT,
  sale_amt MONEY,
  units_sold INT,
  date_sold DATE,
  employee_id INT references employee (id),
  customer_id varchar(50) references customer(id),
  frequency_id INT references frequency(id),
  product_id INT references product(id)
);
