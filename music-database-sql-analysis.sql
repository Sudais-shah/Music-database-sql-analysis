-- Database: music database

/* Q1: Who is the senior most employee based on job title? */
SELECT   employee_id,first_name,last_name,levels FROM  employee 
order by levels desc limit 1 ;

/* Q2: Which countries have the most Invoices? */
SELECT billing_country , count(*)
from invoice group by billing_country 
order by billing_country DESC ;

/* Q3: What are top 3 values of total invoice? */
SELECT total FROM invoice order by 
total desc limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional 
Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,sum(total) from invoice group by billing_city 
order by sum desc limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
SELECT customer.customer_id,customer.first_name,customer.last_name,  sum(total) as total_spend FROM customer
join invoice on invoice.customer_id = customer.customer_id
group by customer.customer_id
order by total_spend desc limit 1 ;


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
SELECT  Distinct customer.first_name, customer.last_name , customer.email,genre.name 
FROM customer
join invoice on invoice.customer_id = customer.customer_id 
join invoice_line on invoice_line.invoice_id = invoice.invoice_id 
join track on track.track_id = invoice_line.track_id 
join genre on genre.genre_id = track.genre_id 
where genre.name like 'Rock'
order by email;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
SELECT artist.name as Artist_Name , count(artist.name) as Total_Track
from artist
JOIN album ON artist.artist_id =  album.artist_id 
JOIN track ON track.album_id = album.album_id
JOIN genre ON genre.genre_id = track.genre_id 
where genre.name like 'Rock'
group by Artist_Name
order by Total_track Desc
limit 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
SELECT name , sum(track.milliseconds) AS ms from track 
WHERE track.milliseconds > (select avg(milliseconds) from track)
GROUP BY name order by ms desc ;

/* Q9: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent */

with top_artist as (
SELECT artist.name as Artist_Name, customer.customer_id as CI , customer.first_name as CN,
sum(invoice_line.unit_price * invoice_line.quantity) as Total_spent FROM artist 
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON track.album_id = album.album_id 
JOIN invoice_line ON invoice_line.track_id = track.track_id 
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id 
GROUP BY artist.name,customer.customer_id, customer.first_name
ORDER BY 
sum(invoice_line.unit_price * invoice_line.quantity) DESC
limit 1 )

SELECT Artist_Name,CI,CN,Total_spent from top_artist 


/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with cte as (
SELECT  invoice.billing_country as Country ,genre.name as top_genre , count(invoice_line.quantity) as total,
ROW_NUMBER() OVER (PARTITION BY  invoice.billing_country ORDER BY count(invoice_line.quantity) desc  ) as row_numbers
FROM invoice 
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id 
JOIN track ON track.track_id = invoice_line.track_id 
JOIN genre ON genre.genre_id = track.genre_id 
group by  1,2
ORDER BY total DESC
)
SELect  Country ,
 top_genre ,  total 
FROM cte WHERE row_numbers = 1
 
/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH cte AS (
SELECT customer.customer_id as id, customer.first_name as first_name, customer.last_name as last_name , 
invoice.billing_country as Country , ROUND(sum(invoice.total)) as total_spent,
ROW_NUMBER() OVER (PARTITION BY Country ORDER BY  sum(invoice.total) DESC) AS row_no
FROM customer 
JOIN invoice ON invoice.customer_id = customer.customer_id 
group by 1,2,3,4
ORDER BY total_spent DESC,Country ASC
)
SELECT  id , first_name , last_name, Country,total_spent , row_no 
FROM cte WHERE row_no = 1 


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

    