CREATE DATABASE IF NOT EXISTS `Project` DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';

use project;

CREATE TABLE IF NOT EXISTS `restaurant` (
  `RESTAURANT_ID` INTEGER NOT NULL DEFAULT '0',
  `ADDRESS` varchar(45) DEFAULT NULL,
  `POSTAL_CODE` varchar(12) DEFAULT NULL,
  `CITY` varchar(45) DEFAULT NULL,
  `Phonenumber` INTEGER(15) DEFAULT NULL,
  PRIMARY KEY (`RESTAURANT_ID`)
) ;

CREATE TABLE IF NOT EXISTS `restaurant_tables` (
  `Table_ID` INTEGER NOT NULL DEFAULT 0,
  `table_capacity` INT(2) DEFAULT NULL,
  `Restaurant_ID` INTEGER DEFAULT NULL,
  PRIMARY KEY (`Table_ID`)
) ;

CREATE TABLE IF NOT EXISTS `Orders` (
  `Order_ID` INTEGER NOT NULL DEFAULT 0,
  `Order_date` DATE DEFAULT NULL,
  `Total_price_order` DECIMAL(4,2) DEFAULT NULL,
  `Table_ID` INTEGER DEFAULT NULL,
  `Employee_ID` INTEGER DEFAULT NULL,
  `tax_rate` int(2) DEFAULT NULL,
  PRIMARY KEY (`Order_ID`)
) ;

CREATE TABLE IF NOT EXISTS `Checkout_customer` (
  `Checkout_customer_ID` INTEGER NOT NULL DEFAULT 0,
  `invoice_status` boolean DEFAULT NULL,
  `Payment_method_ID` INT(1) DEFAULT NULL,
  `Payment_date` DATETIME DEFAULT NULL,
  `Total_Paid` DECIMAL(6,2) DEFAULT NULL,
  `Tip` DECIMAL(5,2) DEFAULT NULL,
  `Rating` INTEGER(1) DEFAULT NULL,
  `Order_ID` INTEGER DEFAULT NULL,
  PRIMARY KEY (`Checkout_customer_ID`)
) ;

CREATE TABLE IF NOT EXISTS `Payment_method` (
  `Payment_method_ID` INTEGER NOT NULL DEFAULT 0,
  `Payment_method_name` VARCHAR(40) DEFAULT NULL,
  PRIMARY KEY (`Payment_method_ID`)
) ;

CREATE TABLE IF NOT EXISTS `Employee` (
	`EMPLOYEE_ID` INTEGER NOT NULL DEFAULT 0,
	`FIRST_NAME` varchar(20) NOT NULL,
	`LAST_NAME` varchar(25) NOT NULL,
	`PHONE_NUMBER` varchar(20) DEFAULT NULL,
    `Address` varchar(60) DEFAULT NULL,
	`City` varchar(60) DEFAULT NULL,
    `Postalcode` varchar(10) DEFAULT NULL,
	`Start_DATE` date NOT NULL,
    `Employee_title_ID` INTEGER DEFAULT NULL,
	`Restaurant_ID` INTEGER DEFAULT NULL,
  PRIMARY KEY (`Employee_ID`)
) ;

CREATE TABLE IF NOT EXISTS `Employee_title` (
  `Employee_title_ID` INTEGER NOT NULL DEFAULT 0,
  `Employee_title` VARCHAR(25) NOT NULL,
  `Salary` DECIMAL(9,2) DEFAULT NULL,
  PRIMARY KEY (`Employee_title_ID`)
) ;

CREATE TABLE IF NOT EXISTS `Menu_type` (
  `Menu_type_ID` INTEGER NOT NULL DEFAULT 0,
  `Menu_type_name` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`Menu_type_ID`)
) ;

CREATE TABLE IF NOT EXISTS `Menu` (
  `Menu_ID` INTEGER NOT NULL DEFAULT 0,
  `Product_name` VARCHAR(100) DEFAULT NULL,
  `Price` DECIMAL(6,2) DEFAULT NULL,
  `Description` VARCHAR(250) DEFAULT NULL,
  `Menu_type_ID` INT(1) DEFAULT NULL,
  PRIMARY KEY (`Menu_ID`)
) ;

CREATE TABLE IF NOT EXISTS `Order_has_items` (
  `Order_ID` INTEGER NOT NULL DEFAULT 0,
  `Menu_ID` INTEGER NOT NULL DEFAULT 0,
  `quantity` INTEGER(2) DEFAULT 0,
  `price` DECIMAL(6,2) DEFAULT 0,
  CONSTRAINT `fk_Order_has_items`
    FOREIGN KEY (`Order_ID`)
    REFERENCES `project`.`Orders` (`Order_ID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Order_has_items_2`
    FOREIGN KEY (`Menu_ID`)
    REFERENCES `project`.`Menu` (`Menu_ID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ; 

CREATE TABLE log (
LOG_ID INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
DT DATETIME NOT NULL,
USR VARCHAR(63),
EV VARCHAR(15),
MSG VARCHAR(255)
);

ALTER TABLE `restaurant_tables`
ADD CONSTRAINT `fk_restaurant_ID`
  FOREIGN KEY (`RESTAURANT_ID`)
  REFERENCES `project`.`restaurant` (`RESTAURANT_ID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

ALTER TABLE `Orders`
ADD CONSTRAINT `fk_Table_ID`
  FOREIGN KEY (`Table_ID`)
  REFERENCES `project`.`restaurant_tables` (`Table_ID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
;

ALTER TABLE `Checkout_customer`
ADD CONSTRAINT `fk_Order_ID`
  FOREIGN KEY (`Order_ID`)
  REFERENCES `project`.`Orders` (`Order_ID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
;

ALTER TABLE `Checkout_customer`
ADD CONSTRAINT `fk_Payment_method_ID`
  FOREIGN KEY (`Payment_method_ID`)
  REFERENCES `project`.`Payment_method` (`Payment_method_ID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
;

ALTER TABLE `Orders`
ADD CONSTRAINT `fk_employee_ID`
  FOREIGN KEY (`Employee_ID`)
  REFERENCES `project`.`Employee` (`Employee_ID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
;

ALTER TABLE `Employee`
ADD CONSTRAINT `fk_restaurant_ID_2`
  FOREIGN KEY (`Restaurant_ID`)
  REFERENCES `project`.`restaurant` (`Restaurant_ID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
;

ALTER TABLE `Employee`
ADD CONSTRAINT `fk_Employee_title_ID`
  FOREIGN KEY (`Employee_title_ID`)
  REFERENCES `project`.`Employee_title` (`Employee_title_ID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
;

ALTER TABLE `Menu`
ADD CONSTRAINT `fk_Menu_type_ID`
  FOREIGN KEY (`Menu_type_ID`)
  REFERENCES `project`.`Menu_type` (`Menu_type_ID`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
;

## this trigger will update the log after there an insert in orders
## It will insert in the log a the current time when the order has been submitted
## Which employee it was, and insert add and the message 'new order'
DELIMITER $$
CREATE TRIGGER log_order_with_employee AFTER INSERT
ON orders
FOR EACH ROW
	BEGIN INSERT log (DT,USR,EV,MSG)
    VALUES (NOW(),new.employee_ID,"add",CONCAT('New order'));
END $$
DELIMITER ;

## This trigger will be done when there is an update in checkout_customer
## It will only insert a new row in our log table when the invoice status will go from 0 to 1.alter
## when this is the case, it will insert a row with the time of this event, plus the text update order has been paid.

DELIMITER $$
CREATE TRIGGER payment_finished AFTER UPDATE
ON Checkout_customer
FOR EACH ROW 
BEGIN 
if new.invoice_status = 1 then 
INSERT log (DT,EV,MSG)
    VALUES (NOW(),"update",'order has been paid');
END if;
END $$
DELIMITER ;

INSERT INTO `restaurant` (`RESTAURANT_ID`, `ADDRESS`, `POSTAL_CODE`, `CITY`, `Phonenumber`) VALUES
(1,'Rua 1', 1150-123, 'Lisboa',531239432),
(2,'Rua 2', 1150-345, 'Porto',623945023)
;

INSERT INTO `restaurant_tables` (`Table_ID`, `table_capacity`,`Restaurant_ID`) VALUES
(1,2,1),
(2,4,1),
(3,6,1),
(4,8,1),
(5,4,1),
(6,6,2),
(7,4,2),
(8,8,2),
(9,2,2),
(10,6,2),
(11,10,2),
(12,7,2),
(13,4,2),
(14,5,2),
(15,3,2)
;

INSERT INTO `Menu_type` (`Menu_type_ID`, `Menu_type_name`) VALUES
(1,'Drinks'),
(2,'Burgers'),
(3,'Side_Dish')
;

INSERT INTO `Menu` (`Menu_ID`, `Product_name`, `Description`, `Price`, `Menu_type_ID`) VALUES
(1,'Cola','',1.50, 1),
(2,'Fanta','',1.50, 1),
(3,'Sagres','',1.50, 1),
(4,'Red wine','',1.50, 1),
(5,'Classic -not so classy - Burger','Homemade vegan patty with lettuce, tomata and our homemade secret sauce', 10.50, 2),
(6,'Cheese Burger','Homemade vega patty with lettuce, tomato, grilled vegan cheese with and our homemade secret sauce', 11.00, 2),
(7,'Chick chick burger','Homemade vega patty with special chicken species on a homemade bun', 10.50, 2),
(8,'Fries','Homemade fries', 2.00, 3),
(9,'Sweet patato fries','Homemade sweet patato fries',2.50, 3),
(10,'Salad','Daily changing mixed salad with seasonal products',4.50, 3)
;

INSERT INTO `Employee_title` (`Employee_title_ID`, `Employee_title`, `Salary`) VALUES
(1,'Waiter',12000.00),
(2,'Chef',15000.00),
(3,'Manager',21000.00),
(4,'Owner',30000.00)
;

INSERT INTO `Employee` (`EMPLOYEE_ID`, `FIRST_NAME`, `LAST_NAME`, `PHONE_NUMBER`, 
`ADDRESS`, `CITY`, `Postalcode`, `Start_DATE`, `Employee_title_ID`,
`Restaurant_ID`) VALUES
(1, 'roel', 'rensink', '1234678595', 'Rua convento', 'Lisboa', '1123-123', '2019-04-01', 4, 1),
(2, 'Steven', 'King', 5151234567, 'Rua 12', 'Lisboa', '1150-123', '2019-05-01',1,1),
(3, 'Neena', 'Kochhar', 5151234569, 'Rua 14', 'Lisboa', '1149-149', '2019-05-01',2,1),
(4, 'Lex', 'De Haan', 5151234569, 'Rua 22', 'Lisboa', '1239-129', '2019-05-01',3,1),
(5, 'Alexander', 'Hunold', 5904234567, 'Rua 24', 'Lisboa', '1212-121', '2019-05-01',2,2),
(6, 'Lex', 'De Haan', 5151234569, 'Rua 22', 'Lisboa', '1239-129', '2019-05-01',1,2),
(7, 'Bruce', 'Ernst', 5904234569, 'Rua 17', 'Lisboa', '1178-199', '2019-05-01',3,2)
;

INSERT INTO `Orders` (`Order_ID`, `Order_date`, `Total_price_order`, `Table_ID`, 
`Employee_ID`,`tax_rate`) VALUES
(1, '2020-01-01', 36.00,1, 2,9),
(2, '2020-02-01', 29.00, 1, 2,9),
(3, '2020-03-01', 116.00, 2, 2,9),
(4, '2020-04-01', 58.00, 2, 2,9),
(5, '2020-05-01', 113.00, 3, 2,9),
(6, '2021-06-01', 58.00, 3, 2,9),
(7, '2021-07-01', 230.00, 4, 2,9),
(8, '2021-08-01', 150.00, 4, 2,9),
(9, '2021-09-01', 70.00, 5, 2,9),
(10, '2021-10-01', 75.00, 5, 2,9),
(11, '2020-01-01', 172.00, 6, 6,9),
(12, '2020-02-01', 71.00, 7, 6,9),
(13, '2020-03-01', 193.00, 8, 6,9),
(14, '2020-04-01', 33.00, 9, 6,9),
(15, '2020-05-01', 127.00, 10, 6,9),
(16, '2021-06-01', 227.00, 11, 6,9),
(17, '2021-07-01', 161.00, 12, 6,9),
(18, '2021-08-01', 75.00, 13, 6,9),
(19, '2021-09-01', 88.00, 14, 6,9),
(20, '2021-10-01', 70.00, 15, 6,9)
;

INSERT INTO `Order_has_items` (`Order_ID`, `Menu_ID`, `Quantity`, 
`Price`) VALUES
(1, 1, 2, '3.00'),
(2, 2, 2, '3.00'),
(3, 3, 4, '6.00'),
(4, 4, 4, '6.00'),
(5, 1, 6, '9.00'),
(6, 2, 6, '9.00'),
(7, 3, 8, '12.00'),
(8, 4, 8, '12.00'),
(9, 1, 4, '6.00'),
(10, 2, 4, '6.00'),
(11, 3, 6, '9.00'),
(12, 4, 4, '6.00'),
(13, 2, 8, '12.00'),
(14, 3, 2, '3.00'),
(15, 1, 6, '9.00'),
(16, 4, 10, '15.00'),
(17, 3, 7, '10.50'),
(18, 2, 4, '6.00'),
(19, 1, 5, '7.50'),
(20, 1, 3, '4.50'),
(1, 5, 1, '10.50'),
(1, 6, 1, '11.00'),
(2, 7, 2, '21.00'),
(3, 5, 1, '10.50'),
(3, 6, 2, '22.00'),
(3, 7, 3, '10.50'),
(4, 6, 4, '44.00'),
(5, 6, 3, '33.00'),
(5, 7, 3, '31.50'),
(6, 6, 2, '22.00'),
(7, 5, 3, '31.50'),
(7, 6, 3, '33.00'),
(7, 7, 2, '21.00'),
(8, 5, 4, '42.00'),
(8, 6, 4, '44.00'),
(9, 5, 2, '21.00'),
(9, 7, 2, '21.00'),
(10, 6, 2, '22.00'),
(10, 7, 2, '21.00'),
(11, 5, 2, '21.00'),
(11, 7, 2, '21.00'),
(11, 6, 2, '22.00'),
(12, 5, 2, '21.00'),
(12, 6, 2, '22.00'),
(13, 5, 3, '31.50'),
(13, 6, 3, '33.00'),
(13, 7, 2, '31.50'),
(14, 7, 2, '21.00'),
(15, 5, 1, '10.50'),
(15, 6, 1, '11.00'),
(15, 7, 4, '42.00'),
(16, 7, 2, '21.00'),
(16, 6, 4, '44.00'),
(16, 5, 4, '42.00'),
(17, 7, 4, '42.00'),
(17, 6, 3, '33.00'),
(18, 6, 2, '22.00'),
(18, 7, 2, '21.00'),
(19, 5, 3, '30.50'),
(19, 7, 2, '21.00'),
(20, 6, 1, '11.00'),
(20, 5, 2, '21.00'),
(1, 8, 2, '4.00'),
(2, 9, 2, '5.00'),
(3, 10, 4, '18.00'),
(4, 8, 4, '8.00'),
(5, 9, 6, '15.00'),
(6, 10, 6, '27.00'),
(7, 10, 8, '36.00'),
(8, 9, 8, '20.00'),
(9, 8, 4, '8.00'),
(10, 9, 4, '10.00'),
(11, 10, 6, '27.00'),
(12, 8, 4, '8.00'),
(13, 9, 8, '20.00'),
(14, 10, 2, '9.00'),
(15, 8, 6, '12.00'),
(16, 9, 10, '25.00'),
(17, 10, 7, '31.50'),
(18, 9, 4, '10.00'),
(19, 8, 5, '10.00'),
(20, 10, 3, '13.50')
;

INSERT INTO `Payment_method` (`Payment_Method_ID`, `Payment_method_name`) VALUES
(1,'Cash'),
(2, 'Bank payment')
;


INSERT INTO `Checkout_customer` (`Checkout_customer_ID`, `invoice_status`, `Payment_method_ID`,`Payment_date`, `Total_Paid`,`Tip`, `Rating`, `Order_ID`) VALUES
(1,1,1,'2020-01-01 12:00:00',40.00,4.00,4,1),
(2,1,2,'2020-02-01 12:00:00',32.00,3.00,5,2),
(3,1,2,'2020-03-01 12:00:00',126.00,10.00,5,3),
(4,1,1,'2020-04-01 12:00:00',64.00,6.00,4,4),
(5,1,1,'2020-05-01 12:00:00',126.00,13.00,3,5),
(6,1,2,'2021-06-01 12:00:00',72.00,14.00,3,6),
(7,1,2,'2021-07-01 12:00:00',250.00,20.00,5,7),
(8,1,1,'2021-08-01 12:00:00',175.00,15.00,5,8),
(9,1,1,'2021-09-01 12:00:00',80.00,10.00,4,9),
(10,1,1,'2021-10-01 12:00:00',80.00,5.00,5,10),
(11,1,2,'2020-01-01 12:00:00',200.00,28.00,4,11),
(12,1,1,'2020-02-01 12:00:00',80.00,9.00,4,12),
(13,1,2,'2020-03-01 12:00:00',210.00,17.00,4,13),
(14,1,1,'2020-04-01 12:00:00',37.00,4.00,4,14),
(15,1,2,'2020-05-01 12:00:00',140.00,13.00,4,15),
(16,1,1,'2021-06-01 12:00:00',250.00,23.00,4,16),
(17,1,2,'2021-07-01 12:00:00',180.00,19.00,4,17),
(18,1,2,'2021-08-01 12:00:00',85.00,10.00,4,18),
(19,1,1,'2021-09-01 12:00:00',97.00,9.00,4,19),
(20,1,2,'2021-10-01 12:00:00',93.00,23.00,4,20)
;


