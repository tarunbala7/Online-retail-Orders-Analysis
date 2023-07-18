show databases;

use orders;

show tables;

#question 1

select customer_id,Case when customer_gender='M' then upper(concat('Mr.',customer_fname,' ',customer_lname))
else upper(concat('MS.',customer_fname,' ',customer_lname))  end as customer_fullname,
customer_email, Year(customer_creation_date) as customer_creation_year,
case when year(customer_creation_date)<2005 then 'category A' 
when year(customer_creation_date)>=2005 and year(customer_creation_date)<2011 then 'category B'
else 'category C'end as customers_category from online_customer;

#question 2

select product_id,product_desc,product_quantity_avail,product_price,
product_quantity_avail * product_price as inventory_values,
case when product_price > 20000 then product_price * 0.8
when product_price> 10000 then product_price * 0.85
else product_price * 0.9 end as New_Price 
from product p where p.product_id not in(
select o.product_id from order_items o
) order by product_quantity_avail * product_price desc;

# question 3

select p.product_class_code,c.Product_class_desc, count(p.product_id) as countofproductctypr,sum(p.product_quantity_avail * p.product_price) as inventory_value
from product p join product_class c on p.product_class_code = c.product_class_code
group by p.product_class_code,c.Product_class_desc
having sum(p.product_quantity_avail * p.product_price) >100000
order by sum(p.product_quantity_avail * p.product_price) desc;

# question 4

select o.customer_id,Concat(customer_fname,' ',customer_lname) as fullname,customer_email,
customer_phone,country from online_customer o join address a on a.address_id = o.address_id 
where o.customer_id in (select h.customer_id from order_header h where h.order_status='Cancelled')
and o.customer_id not in (select h.customer_id from order_header h where h.order_status!='Cancelled');

#question 5

select s.shipper_name,a.city,count(c.customer_id) as customercarter,Case when o.order_status='Shipped'
 then count(c.customer_id) end as consignmentDelievred 
from shipper s join order_header o
on s.shipper_id=o.shipper_id join online_customer c on c.customer_id = o.customer_id
join address a on a.address_id=c.address_id
where s.shipper_name='DHL' 
group by a.city,s.shipper_name,o.order_status;

#question 6

select p.product_id , p.product_desc ,p.product_quantity_avail,Case when sum(o.product_quantity)> 0 then sum(o.product_quantity)
else 0 end as Quantity_sold,
Case when ((c.product_class_desc='Electronics' or c.product_class_desc='Computer') and sum(o.product_quantity)/p.product_quantity_avail >=0.5)
then 'Sufficient inventory'
when ((c.product_class_desc='Electronics' or c.product_class_desc='Computer') and sum(o.product_quantity)/p.product_quantity_avail <0.5 and sum(o.product_quantity)/p.product_quantity_avail >=0.1)
then 'Medium inventory, need to add some inventory' 
when ((c.product_class_desc='Electronics' or c.product_class_desc='Computer') and sum(o.product_quantity)/p.product_quantity_avail <0.1 and sum(o.product_quantity)/p.product_quantity_avail >0)
then 'Less inventory, need to add inventory' 
when ((c.product_class_desc='Mobiles' or c.product_class_desc='Watches') and sum(o.product_quantity)/p.product_quantity_avail >=0.6)
then 'Sufficient inventory'
when ((c.product_class_desc='Mobiles' or c.product_class_desc='Watches') and sum(o.product_quantity)/p.product_quantity_avail <0.6 and sum(o.product_quantity)/p.product_quantity_avail >=0.2)
then 'Medium inventory, need to add some inventory'  
when ((c.product_class_desc='Mobiles' or c.product_class_desc='Watches') and sum(o.product_quantity)/p.product_quantity_avail <0.2 and sum(o.product_quantity)/p.product_quantity_avail >0)
then 'Less inventory, need to add inventory' 
when (sum(o.product_quantity)/p.product_quantity_avail >=0.7)
then 'Sufficient inventory'
when (sum(o.product_quantity)/p.product_quantity_avail <0.7 and sum(o.product_quantity)/p.product_quantity_avail >=0.3)
then 'Medium inventory, need to add some inventory'  
when (sum(o.product_quantity)/p.product_quantity_avail <0.3 and sum(o.product_quantity)/p.product_quantity_avail >0)
then 'Less inventory, need to add inventory' 
else 'No Sales in past, give discount to reduce inventory'
end as Inventory_status
 from product p join
product_class c on c.product_class_code = p.product_class_code left join 
order_items o on p.product_id = o.product_id
group by p.product_id,p.product_desc,p.product_quantity_avail,c.product_class_desc
order by p.product_id;

#question 7

select o.order_id, sum(p.len * p.width *p.height)as volumeofBiggestorder
from order_items o join product p on o.product_id= p.product_id
group by order_id
having sum(p.len * p.width *p.height)<= ( select c.len*c.width*c.height from carton c where carton_id=10)
order by sum(p.len * p.width *p.height) desc
limit 1;

#question 8

select c.customer_id,concat(customer_fname,' ',customer_lname) as full_name,sum(o.product_quantity) as totalquantity
,sum(p.product_price * o.product_quantity) as total_value
from online_customer c join order_header h on c.customer_id = h.customer_id 
join order_items o on o.order_id = h.order_id
join product p on p.product_id = o.product_id
where upper(customer_lname) like 'G%'
and h.payment_mode = 'Cash' and h.order_status='Shipped'
group by c.customer_id;

#question 9

select p.product_id,p.product_desc,sum(o.product_quantity) as Total_quantity_of_products from product p 
join order_items o on p.product_id = o.product_id 
join order_header h on h.order_id = o.order_id
join online_customer c on c.customer_id = h.customer_id
join address a on a.address_id = c.address_id
where o.order_id in ( select oo.order_id from order_items oo where oo.product_id=201)
and p.product_id != 201
and a.city not in ('Bangalore','Chennai')
group by p.product_id,p.product_desc
order by sum(o.product_quantity) desc;

#question10

select o.order_id,c.customer_id,concat(c.customer_fname,' ',c.customer_lname) as customer_fullname,
sum(o.product_quantity) as TotalquanityofProducts from order_items o 
join order_header h on h.order_id = o.order_id
join online_customer c on c.customer_id = h.customer_id
join address a on a.address_id = c.address_id
where h.order_status = 'Shipped'
and o.order_id % 2 =0
and a.pincode not like '5%'
group by o.order_id,c.customer_id;