-- Q1: Who is the senior most employee based on job title?
select * from employee order by levels desc limit 1;

-- Q2: Which countries have the most Invoices?
select count(*) as c, billing_country
	from invoice group by billing_country
	order by c desc;

-- Q3: What are top 3 values of total invoice?
select total from invoice order by total desc limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select sum(total) as sum_of_invoice, billing_city from invoice
	group by billing_city order by sum_of_invoice desc limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select cust.customer_id, first_name, last_name, sum(total) as total_spending
	from customer cust 
	join invoice inv
	on inv.customer_id = cust.customer_id
	group by cust.customer_id
	order by sum(total) desc limit 1;



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select email, first_name, last_name, genre.name as name from genre
	join track on genre.genre_id = track.genre_id
	join invoice_line on invoice_line.track_id = track.track_id
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	where genre.name = 'Rock' order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id, artist.name, count(track.*) as rock_music from artist 
	join album on artist.artist_id = album.artist_id
	join track on track.album_id = album.album_id
	join genre on genre.genre_id = track.genre_id
	where genre.name = 'Rock'
	group by artist.artist_id
	order by rock_music desc
	limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds from track 
	where milliseconds > (select avg(milliseconds) as avg_track_length from track)      
	order by milliseconds desc;



/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, 
artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name,   
	sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
	from artist join album on artist.artist_id = album.artist_id
	join track on album.album_id = track.album_id
	join invoice_line on invoice_line.track_id = track.track_id
	group by 1
	order by 3 desc limit 1
) 
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price * il.quantity) as amt_spend
from customer c join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album a on t.album_id = a.album_id
join best_selling_artist bsa on a.artist_id = bsa.artist_id
group by 1,2,3,4
order by 5 desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method: 1 => using with */

with popular_genre as
	(
	select c.country, g.name as music_genre, g.genre_id, count(i.total) as purchases,
	row_number()over(partition by c.country order by count(i.total) desc) as RowNo
	from genre g join track t on g.genre_id = t.genre_id
	join invoice_line il on t.track_id = il.track_id
	join invoice i on il.invoice_id = i.invoice_id
	join customer c on c.customer_id = i.customer_id
	group by 1,2,3
	order by 1 asc, 4 desc
	)
select * from popular_genre where rowno <=1;


/* Method: 2 => using recursive */

with recursive
sales_per_country as(
	select count(*) as purchases_per_genre, c.country, g.name, g.genre_id
	from customer c
	join invoice i on c.customer_id = i.customer_id
	join invoice_line il on i.invoice_id = il.invoice_id
	join track t on il.track_id = t.track_id
	join genre g on t.genre_id = g.genre_id
	group by 2,3,4
	order by 2
	
), 
max_genre_per_country as(
	select max(purchases_per_genre) as max_genre_number, country
	from sales_per_country
	group by 2
	order by 2)
	
select sales_per_country.* from sales_per_country
join max_genre_per_country
on max_genre_per_country.country = sales_per_country.country
where sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: Using Recursive */

WITH RECURSIVE
     customer_with_country as (
	         select c.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
	            from invoice i 
	            join customer c on i.customer_id = c.customer_id
	            group by 1,2,3,4
	            order by 2,3 desc
	 ),
     country_max_spending as(
	         select max(total_spending) as max_spending, billing_country
	             from customer_with_country
	             group by 2
	          )
select cc.* from customer_with_country cc
join country_max_spending 
on country_max_spending.billing_country = cc.billing_country
where country_max_spending.max_spending = cc.total_spending
	order by cc.billing_country;



/* Method 2: using CTE */

WITH customer_with_country as(
	select c.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
	Row_Number() Over(Partition By billing_country Order By sum(total) Desc) as RowNo
	from invoice i
	join customer c on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 4 Asc, 5 desc	)
select  * from customer_with_country where RowNo <=1;






