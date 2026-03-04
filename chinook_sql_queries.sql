-- Q1) top 5 genre by total sales    (using join)
SELECT Genre.Name AS Genre, round(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity),0) AS totalrevenue
FROM InvoiceLine 
JOIN Track  ON InvoiceLine.TrackId = Track.TrackId
JOIN Genre  ON Track.GenreId = Genre.GenreId
GROUP BY Genre.Name
ORDER BY totalrevenue DESC
limit 5 ;

-- Q2) Best selling playlists     (using join)

SELECT  round(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity),0)AS totalRevenue,playlist.name
FROM Track
JOIN playlisttrack  ON Track.trackid = playlisttrack.trackid
join playlist on playlist.playlistid=playlisttrack.playlistid
JOIN invoiceline  ON InvoiceLine.TrackId = Track.TrackId
GROUP BY playlist.name
ORDER BY totalRevenue DESC;



-- Q3) Total revenue by MediaType     (using join)

SELECT MediaType.Name AS MediaType, round(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity),0)AS totalRevenue
FROM InvoiceLine 
JOIN Track  ON InvoiceLine.TrackId = Track.TrackId
JOIN MediaType  ON Track.MediaTypeId = MediaType.MediaTypeId
GROUP BY MediaType
ORDER BY totalRevenue DESC;

-- Q4) Monthly Revenue (using join)
SELECT MONTHNAME(InvoiceDate) AS Month,
       ROUND(SUM(Total), 0) AS MonthlySales
FROM Invoice
GROUP BY MONTH(InvoiceDate), Month
ORDER BY MONTH(InvoiceDate);

-- Q5) Customers Distribution (using join)
select count(customerid),country from customer
group by country
order by count(customerid)desc ;

-- Q6) Top 5 customers by total sales     (using window)
select concat(customer.firstname," ",customer.lastname) as fullname,round(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity),0) as totalsales,
dense_rank()over(order by round(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity),0) desc) as ranking
from invoice
join customer on customer.customerid=invoice.customerid
join invoiceline on invoice.invoiceid=invoiceline.invoiceid
group by fullname
order by totalsales desc
limit 5;

-- Q7T op 5 customers by #albums     (using window)
select concat(customer.firstname," ",customer.lastname) as fullname,count(distinct track.albumid) as countalbums,
dense_rank()over(order by count(distinct track.albumid))as ranking
from track
join invoiceline on invoiceline.trackid=track.trackid
join invoice on invoice.invoiceid=invoiceline.invoiceid
join customer on customer.customerid=invoice.customerid
group by fullname
order by countalbums desc
limit 10;

-- Q8) Active Customers over time (using join)
select month(invoice.invoicedate) as months,count(customer.customerid)
from invoice
join customer on customer.customerid=invoice.customerid
group by months
order by months;

-- Q9) Top 10 artists by no. of tracks  (using window)
select artist.name,count(track.trackid) as countTracks,
dense_rank()over(order by count(track.trackid) desc) as ranking
from track
join album on album.albumid =track.albumid
join artist on artist.artistid=album.artistid
group by artist.name
order by countTracks desc
limit 10;


-- Q10) top 10 artist by total sales (using window)
SELECT    ar.Name AS ArtistName,
    round(SUM(il.UnitPrice * il.Quantity),0) AS TotalSales,
    rank()over(order by round(SUM(il.UnitPrice * il.Quantity),0)  desc)as ranking
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.Name
ORDER BY TotalSales DESC
limit 10 ;


--  Q11)  #artist with albums for each year (using join)
SELECT YEAR(i.InvoiceDate) AS Year,count(distinct al.ArtistId) AS NumberOfArtists
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
GROUP BY YEAR(i.InvoiceDate)
ORDER BY Year;


-- Q12) Top 3 Artist by Genre  (using join)

select genre.name ,count(distinct album.artistid) as artist from artist ar
join album on album.artistid = ar.artistid
join track on album.albumid = track.albumid
join genre on genre.genreid =track.genreid
group by genre.name 
order by artist desc
limit 3;

-- Q13) Top 3 Genres by # tracks (using Subquery) 
SELECT GenreName, NumberOfTracks
FROM (
    SELECT 
        Genre.Name AS GenreName,
        COUNT(Track.TrackId) AS NumberOfTracks
    FROM Genre
    JOIN Track ON Genre.GenreId = Track.GenreId
    GROUP BY Genre.GenreId, Genre.Name
    ORDER BY NumberOfTracks DESC
    LIMIT 3
) AS TopGenres;


-- Q14) #Track  for each year  (using SubQuery)
with years as (
    select distinct year(Invoice.InvoiceDate) as Year
    from Invoice
)
select years.Year,
       count(distinct InvoiceLine.TrackId) as noTrack
from years
join Invoice on years.Year = year(Invoice.InvoiceDate)
join InvoiceLine on Invoice.InvoiceId = InvoiceLine.InvoiceId
join Track on InvoiceLine.TrackId = Track.TrackId
group by years.Year
order by years.Year;

-- Q15) TOP 5 ALBUM BY #TRACKs     (using window)
select album.title,count(distinct track.trackid) as countTracks,
dense_rank()over(order by count(distinct track.trackid)desc ) as ranking
from track
join album on album.albumid =track.albumid
join artist on artist.artistid=album.artistid
group by album.title
order by countTracks desc
limit 10;

-- Q16) TOP 1 TrackName,AlbumName,Mediatype BY # TRACK (using join)
SELECT track.Name AS trackname, round(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity),0) AS totalrevenue
FROM InvoiceLine 
JOIN track  ON InvoiceLine.trackId = track.trackId
GROUP BY trackname
ORDER BY totalrevenue DESC
limit 1 ;

SELECT MediaType.Name AS MediaTypeName,
    SUM(InvoiceLine.Quantity * InvoiceLine.UnitPrice) AS TotalSales
FROM InvoiceLine
JOIN Track ON InvoiceLine.TrackId = Track.TrackId
JOIN MediaType ON Track.MediaTypeId = MediaType.MediaTypeId
GROUP BY MediaType.MediaTypeId, MediaType.Name
ORDER BY TotalSales DESC
LIMIT 1;

SELECT 
    a.Title AS AlbumTitle,
    SUM(il.Quantity * il.UnitPrice) AS TotalSales
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album a ON t.AlbumId = a.AlbumId
GROUP BY a.AlbumId
ORDER BY TotalSales DESC
LIMIT 1;

-- Q17) Employee Invoice Distribution (using join)
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS SupportEmployee,
       COUNT(i.InvoiceId) AS InvoiceCount
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId
ORDER BY InvoiceCount DESC;

-- Q18) Employee Count by Job Title (using join)
SELECT Title, COUNT(*) AS EmployeeCount
FROM Employee
GROUP BY Title;

-- Q19) Workforce Experience Level (using join)
SELECT Title,
       AVG(TIMESTAMPDIFF(YEAR, HireDate, CURDATE())) AS AvgTenure
FROM Employee
GROUP BY Title
ORDER BY AvgTenure DESC;

-- Q20) # Customers for each employee (using SubQuery)
with customer_count as (
    select customer.supportrepid as employeeid,
           count(customer.customerid) as countcustomer
    from customer
    group by customer.supportrepid
)
select employee.firstname,
       customer_count.countcustomer
from customer_count
join employee on employee.employeeid = customer_count.employeeid
order by customer_count.countcustomer desc;


-- Q21) Total sales by country (using SubQuery)
with total as (
    select invoicelineid,
           SUM(UnitPrice * Quantity) as totalsales
    from invoiceline
    group by invoicelineid
)
select customer.country,
       round(SUM(total.totalsales),0) as totalsales
from invoiceline
join total on total.invoicelineid = invoiceline.invoicelineid
join invoice on invoice.invoiceid = invoiceline.invoiceid
join customer on customer.customerid = invoice.customerid
group by customer.country
order by totalsales desc;

-- Q22) Customers Distribution by Country (using join)
select country,count(firstname)
from customer
group by country
order by count(firstname) desc
limit 5;

-- Q23) invoice Distribution by Country (using SubQuery)
with count_invoices as (
    select customerid,
           count(invoiceid) as invoicescount
    from invoice
    group by customerid
)
select customer.country,
       sum(count_invoices.invoicescount) as invoicescount
from count_invoices
join customer on customer.customerid = count_invoices.customerid
group by customer.country
order by invoicescount desc;

-- Q24) Employee Distribution by City (using join)
select city,count(firstname)
from employee
group by city
order by count(firstname) desc;








