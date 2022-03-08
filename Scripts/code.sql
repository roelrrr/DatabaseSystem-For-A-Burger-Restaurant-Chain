use project;


#### Q1.
## List all the customer’s names, dates, and products or services used/booked/rented/bought by
## these customers in a range of two dates.

# since it is a restaurant management system we do not have names of customers
# instead I use the order_ID
# I chose the orders that have been made between 2020-01-01 and 2020-12-31

SELECT o.ORDER_ID Name_, m.product_name item, o.Order_date order_date from orders o
JOIN order_has_items ohi ON ohi.order_ID = o.order_id
JOIN menu m on m.menu_ID = ohi.menu_ID
WHERE (o.order_date BETWEEN '2020-01-01' AND '2020-12-31')
order by o.order_ID
;

#### Q2.
## List the best three customers/products/services/places (you are free to define the criteria for
## what means “best”)

# I chose what the top three burgers is that have been sold
# The cheese burger is the most populair burger since it has

SELECT m.product_name Burger, count(m.product_name) count_burger from orders o
JOIN order_has_items ohi ON ohi.order_ID = o.order_id
JOIN menu m on m.menu_ID = ohi.menu_ID
WHERE m.menu_ID in (6,7,8)
GROUP BY m.menu_ID
ORDER by count_burger desc
;
#### Q3.
## Get the average amount of sales/bookings/rents/deliveries for a period that involves 2 or more
## years, as in the following example.

# I chose a period time of 2 years 2020-01-01 - 2021-12-31

SELECT concat(MIN(DATE(cc.payment_date)), ' - 2021-12-31') Period_of_Sale, sum(cc.total_paid) total_sales,
round((sum(cc.total_paid)/2), 2) yearly_avg, round((sum(cc.total_paid)/24), 2) monthly_avg 
from checkout_customer cc
where cc.payment_date BETWEEN '2020-01-01 00:00:00' AND '2021-12-31 23:59:59'
;

#### Q4.
## Get the total sales/bookings/rents/deliveries by geographical location (city/country).

# in my data I have 2 locations - Lisboa & Porto
# the total sales can be derived from the total paid in table and includes the tips

# from the result we see that Porto has more sales than the location in Lisbon

SELECT r.city, sum(cc.total_paid) total_sales from restaurant r
JOIN restaurant_tables t ON t.restaurant_ID = r.restaurant_ID
JOIN orders o ON o.table_ID = t.table_ID
JOIN checkout_customer cc ON cc.order_ID = o.order_ID
group by r.restaurant_ID
ORDER by total_sales DESC
;

#### Q5.
## List all the locations where products/services were sold, and the product has customer’s ratings

# Ratings are between 1 and 5

SELECT r.city, round(avg(cc.rating),2) rating from restaurant r
JOIN restaurant_tables t ON t.restaurant_ID = r.restaurant_ID
JOIN orders o ON o.table_ID = t.table_ID
JOIN checkout_customer cc ON cc.order_ID = o.order_ID
group by r.restaurant_ID
ORDER by rating DESC
;

## create view for invoice


CREATE VIEW invoice_detail AS 
SELECT r.city
from restaurant r;


CREATE VIEW invoice_head AS 
SELECT o.order_ID as Order_number, 
o.order_date as order_date,
concat(o.total_price_order, ' €') as total_price,
concat(round((o.Total_price_order - ((o.tax_rate /100) * o.Total_price_order) ), 2), ' €') as sub_total, 
concat(o.tax_rate, ' %') as tax_rate, 
concat(round((o.tax_rate /100) * o.Total_price_order, 2), ' €') as tax,
r.restaurant_ID as restaurant_name, 
r.address as address, 
r.city as city, 
r.postal_code as postal_code, 
r.phonenumber as phonenumber 
from restaurant as r
JOIN restaurant_tables t ON t.restaurant_ID = r.restaurant_ID
JOIN orders o ON o.table_ID = t.table_ID
JOIN checkout_customer cc ON cc.order_ID = o.order_ID
;



CREATE VIEW invoice_detail AS 
SELECT ohi.order_ID, m.product_name as Product, m.price as price, ohi.quantity as quantity, ohi.price as combined_price 
from order_has_items ohi 
JOIN menu m ON m.menu_ID = ohi.Menu_ID 
order by ohi.order_ID
;




