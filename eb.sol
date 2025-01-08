/*1. Find out how much donors spent on bonds*/
-- include company names in select statement

select d.purchaser , sum(b.denomination) as total_spent
from donordata d
left join bonddata b
on d.Unique_key = b.Unique_key
group by 1 order by 2 desc;
---------------------------------------------------------------------------------------------------------------------------------------------


/*2. Find out total fund politicians got*/
-- include reciver names, group by and order by

select r.partyname, sum(b.denomination) as total_fund
from receiverdata r
left join bonddata b
on r.unique_key = b.unique_key
group by 1
order by 2 desc;
------------------------------------------------------------------------------------------------------------------
/*3. Find out the total amount of unaccounted money received by parties*/

SELECT partyname,sum(b.denomination) as total_amount
FROM receiverdata r
LEFT JOIN donordata d ON r.Unique_key = d.Unique_key
LEFT JOIN bonddata b ON r.Unique_key = b.Unique_key
WHERE d.Unique_key IS NULL
group by 1
order by 2 desc;
---------------------------------------------------------------------------------------------------------------------------------
/*4. Find year wise how much money is spend on bonds*/   

select EXTRACT(YEAR FROM d.purchasedate) AS purchase_year , sum(b.Denomination) as total_money_spent
from donordata d
left join bonddata b
on  d.unique_key = b.unique_key 
group by 1
order by 1 desc;
---------------------------------------------------------------------------------------------------
/*5. In which month most amount is spent on bonds*/

WITH cte1 AS (
    SELECT TO_CHAR(d.JournalDate, 'Month') AS monthname,
           SUM(b.Denomination) AS spend,
           RANK() OVER (ORDER BY SUM(b.Denomination) DESC) AS spend_rank
    FROM donordata d
    INNER JOIN bonddata b 
    ON d.Unique_key = b.Unique_key
    GROUP BY TO_CHAR(d.JournalDate, 'Month')
)
SELECT monthname, spend
FROM cte1
WHERE spend_rank = 1;



----------------------------------------------------------------------------------------------------------------------------------
/*6. Find out which company bought the highest number of bonds.*/

with ctemax as (
	select d.purchaser, count(b.denomination) as no_of_bonds
	from donordata as d
	left join bonddata as b
	on  d.unique_key = b.unique_key
	group by 1
	order by 2 desc) 
select * 
from ctemax 
where no_of_bonds=(select max(no_of_bonds) from ctemax);
-------------------------------------------------------------------------------------------------------------------------------
/*7. Find out which company spent the most on electoral bonds.*/

WITH ctemaxspend AS (
    SELECT d.purchaser, SUM(b.denomination) AS total_spent
    FROM donordata d
    JOIN bonddata b
    ON d.unique_key = b.unique_key
    GROUP BY d.purchaser
    ORDER BY total_spent DESC
)
SELECT * 
FROM ctemaxspend
WHERE total_spent = (SELECT MAX(total_spent) FROM ctemaxspend);


----------------------------------------------------------------------------------------------------------------------------------------
/*8. List companies which paid the least to political parties.*/

select d.purchaser, r.partyname
from donordata d
inner join receiverdata r
on r.unique_key=d.unique_key
group by 1,2
order by 2 asc;
------------------------------------------------------------------------------------------------------------------------------------------------
/*9. Which political party received the highest cash?*/

WITH ctemaxcash AS (
    SELECT r.partyname, SUM(b.denomination) AS highest_cash
    FROM receiverdata AS r
    LEFT JOIN bonddata AS b
    ON r.unique_key = b.unique_key
    GROUP BY 1
    ORDER BY 2 DESC
)
SELECT *
FROM ctemaxcash
WHERE highest_cash = (SELECT MAX(highest_cash) FROM ctemaxcash);


------------------------------------------------------------------------------------------------------------------------------------------------
/*10. Which political party received the highest number of electoral bonds?*/

with ctemax as(
select partyname,count(denomination) highest_electoralbondds
from receiverdata as r
join bonddata as b
on r.unique_key = b.unique_key
group by 1
order by 2 desc) select * from ctemax where highest_electoralbondds =(select max(highest_electoralbondds) from ctemax);

------------------------------------------------------------------------------------------------------------------------------
/*11. Which political party received the least cash?*/

WITH ctemincash AS (
    SELECT r.partyname, SUM(b.denomination) AS lowest_cash
    FROM receiverdata AS r
    LEFT JOIN bonddata AS b
    ON r.unique_key = b.unique_key
    GROUP BY 1
    ORDER BY 2 DESC
)
SELECT *
FROM ctemincash
WHERE lowest_cash = (SELECT min(lowest_cash) FROM ctemincash);

--------------------------------------------------------------------------------------------------------------------------------------------
/*12. Which political party received the least number of electoral bonds?*/

with ctemin as(
select partyname,count(denomination) lowest_electoralbondds
from receiverdata as r
join bonddata as b
on r.unique_key = b.unique_key
group by 1
order by 2 desc) select * from ctemin where lowest_electoralbondds =(select min(lowest_electoralbondds) from ctemin);

---------------------------------------------------------------------------------------------------------------------------------------------\
/*13. Find the 2nd highest donor in terms of amount he paid?*/

WITH ranked_donors AS (
    SELECT d.purchaser, 
           SUM(b.Denomination) AS total_paid,
           ROW_NUMBER() OVER (ORDER BY SUM(b.Denomination) DESC) AS rank
    FROM donordata AS d
    LEFT JOIN bonddata AS b
    ON d.unique_key = b.unique_key
    GROUP BY 1
)
SELECT purchaser, total_paid
FROM ranked_donors
WHERE rank = 2;


----------------------------------------------------------------------------------------------------------------------------------------------
/*14. Find the party which received the second highest donations?*/

WITH ranked_parties AS (
    SELECT r.partyname, 
           SUM(b.denomination) AS total_donations,
           RANK() OVER (ORDER BY SUM(b.denomination) DESC) AS donation_rank
    FROM receiverdata AS r
    LEFT JOIN bonddata AS b
    ON r.unique_key = b.unique_key
    GROUP BY 1
)
SELECT partyname, total_donations
FROM ranked_parties
WHERE donation_rank = 2;



-- ----------------------------------------------------------------------------------------------------------------------------------
/*15. Find the party which received the second highest number of bonds?*/

WITH party_bond_counts AS (
    SELECT partyname, COUNT(PayBranchCode) AS bond_count,
           ROW_NUMBER() OVER (ORDER BY COUNT(PayBranchCode) DESC) AS row_num
    FROM receiverdata
    GROUP BY 1
)
SELECT partyname, bond_count
FROM party_bond_counts
WHERE row_num = 2;


-------------------------------------------------------------------------------------------------------------------------------------
/*16. In which city were the most number of bonds purchased?*/ 

WITH ranked_cities AS (
    SELECT b.city, 
           COUNT(bd.denomination) AS bond_count,
           RANK() OVER (ORDER BY COUNT(bd.denomination) DESC) AS city_rank
    FROM bankdata AS b
    LEFT JOIN receiverdata AS r 
    ON b.branchcodeno = r.paybranchcode
    LEFT JOIN bonddata AS bd 
    ON r.unique_key = bd.unique_key
    GROUP BY 1
)
SELECT city, bond_count
FROM ranked_cities
WHERE city_rank = 1;


------------------------------------------------------------------------------------------------------------------------------------------
/*17. In which city was the highest amount spent on electoral bonds?*/

WITH ctemax AS (
    SELECT b.city, 
           SUM(bd.denomination) AS total_amount
    FROM bankdata AS b
    LEFT JOIN receiverdata AS r 
    ON b.branchcodeno = r.paybranchcode
    LEFT JOIN bonddata AS bd 
    ON r.unique_key = bd.unique_key
    GROUP BY 1
    ORDER BY 2 DESC
)
SELECT *
FROM ctemax
WHERE total_amount = (
    SELECT MAX(total_amount) 
    FROM ctemax
);




-----------------------------------------------------------------------------------------------------------------------------------------
/*18. In which city were the least number of bonds purchased?*/

WITH ranked_cities AS (
    SELECT b.city, 
           COUNT(bd.denomination) AS bond_count,
           RANK() OVER (ORDER BY COUNT(bd.denomination) ASC) AS city_rank
    FROM bankdata AS b
    LEFT JOIN receiverdata AS r 
    ON b.branchcodeno = r.paybranchcode
    LEFT JOIN bonddata AS bd 
    ON r.unique_key = bd.unique_key
    GROUP BY 1
)
SELECT city, bond_count
FROM ranked_cities
WHERE city_rank = 1;


-----------------------------------------------------------------------------------------------------------------------------------------
/*19. In which city were the most number of bonds enchased?*/


WITH ranked_cities AS (
    SELECT b.city, 
           COUNT(bd.denomination) AS bond_encash_count,
           RANK() OVER (ORDER BY COUNT(bd.denomination) DESC) AS city_rank
    FROM bankdata AS b
    LEFT JOIN receiverdata AS r 
    ON b.branchcodeno = r.paybranchcode
    LEFT JOIN bonddata AS bd 
    ON r.unique_key = bd.unique_key
    GROUP BY 1
)
SELECT city, bond_encash_count
FROM ranked_cities
WHERE city_rank = 1;

---------------------------------------------------------------------------------------------------------------------------------------------
/*20. In which city were the least number of bonds enchased?*/ 

WITH ranked_cities AS (
    SELECT b.city, 
           COUNT(bd.denomination) AS bond_encash_count,
           RANK() OVER (ORDER BY COUNT(bd.denomination) ASC) AS city_rank
    FROM bankdata AS b
    LEFT JOIN receiverdata AS r 
    ON b.branchcodeno = r.paybranchcode
    LEFT JOIN bonddata AS bd 
    ON r.unique_key = bd.unique_key
    GROUP BY 1
)
SELECT city, bond_encash_count
FROM ranked_cities
WHERE city_rank = 1;

-----------------------------------------------------------------------------------------------------------------------------------------------
/*21. List the branches where no electoral bonds were bought; if none, mention it as null.*/

SELECT bd.Address
FROM bankdata AS bd
LEFT JOIN receiverdata AS r
ON bd.branchcodeno = r.paybranchcode
LEFT JOIN donordata d 
ON r.Unique_key = d.Unique_key
LEFT JOIN bonddata b 
ON r.Unique_key = b.Unique_key
WHERE b.Unique_key IS NULL
GROUP BY 1;

-----------------------------------------------------------------------------------------------------------------------------------------------

/*22. Break down how much money is spent on electoral bonds for each year.*/

SELECT EXTRACT(YEAR FROM d.JournalDate) AS year, 
       SUM(b.Denomination) AS spend 
FROM donordata AS d
INNER JOIN bonddata AS b 
ON d.Unique_key = b.Unique_key
GROUP BY 1
ORDER BY 1;


-----------------------------------------------------------------------------------------------------------------------------------------------

/*23. Break down how much money is spent on electoral bonds for each year and provide the year and the amount. Provide values
for the highest and least year and amount.*/

SELECT 
    EXTRACT(YEAR FROM d.PurchaseDate) AS YEARLY, 
    MAX(b.Denomination) AS highest, 
    MIN(b.Denomination) AS lowest
FROM bonddata b
JOIN donordata d ON b.Unique_key = d.Unique_key
GROUP BY EXTRACT(YEAR FROM d.PurchaseDate)
ORDER BY YEARLY DESC;


 
--------------------------------------------------------------------------------------------------------------------------------------------

/*24. Find out how many donors bought the bonds but did not donate to any political party*/

SELECT COUNT(d.unique_key) AS not_donated
FROM donordata AS d
LEFT JOIN receiverdata AS r
ON d.unique_key = r.unique_key
WHERE r.partyname IS NULL;

--------------------------------------------------------------------------------------------------------------------------------------------

/*25. Find out the money that could have gone to the PM Office, assuming the above question assumption (Domain Knowledge)*/

SELECT SUM(b.denomination) AS pm_off
FROM bonddata AS b
LEFT JOIN donordata AS d
ON b.unique_key = d.unique_key
LEFT JOIN receiverdata AS r
ON r.unique_key = b.unique_key
WHERE r.partyname IS NULL;


--------------------------------------------------------------------------------------------------------------------------------------------
/*26. Find out how many bonds don't have donors associated with them.*/

SELECT COUNT(*)
FROM bonddata AS b
LEFT JOIN donordata AS d
ON b.unique_key = d.unique_key
WHERE d.purchaser IS NULL;

--------------------------------------------------------------------------------------------------------------------------------------------
/*27. Pay Teller is the employee ID who either created the bond or redeemed it. So find the employee ID who issued the highest
number of bonds.*/

WITH teller_bonds AS (
    SELECT payteller, 
           COUNT(unique_key) AS bond_count,
           RANK() OVER (ORDER BY COUNT(unique_key) DESC) AS teller_rank
    FROM donordata 
    GROUP BY 1
)
SELECT payteller, bond_count
FROM teller_bonds
WHERE teller_rank = 1;

--------------------------------------------------------------------------------------------------------------------------------------------

/*28. Find the employee ID who issued the least number of bonds.*/

WITH ranked_tellers AS (
    SELECT payteller, 
           COUNT(unique_key) AS bond_count,
           RANK() OVER (ORDER BY COUNT(unique_key) ASC) AS teller_rank
    FROM donordata 
    GROUP By 1
)
SELECT payteller, bond_count
FROM ranked_tellers
WHERE teller_rank = 1;

--------------------------------------------------------------------------------------------------------------------------------------------
/*29. Find the employee ID who assisted in redeeming or enchasing bonds the most.*/

 WITH ranked_redeemers AS (
    SELECT payteller, 
           COUNT(unique_key) AS redemption_count,
           RANK() OVER (ORDER BY COUNT(unique_key) DESC) AS redeemer_rank
    FROM receiverdata
    GROUP BY 1
)
SELECT payteller, redemption_count
FROM ranked_redeemers
WHERE redeemer_rank = 1;

--------------------------------------------------------------------------------------------------------------------------------------------
/*30. Find the employee ID who assisted in redeeming or enchasing bonds the least*/


 WITH ranked_enchasing AS (
    SELECT payteller, 
           COUNT(unique_key) AS redemption_count,
           RANK() OVER (ORDER BY COUNT(unique_key) ASC) AS enchasing_rank
    FROM receiverdata
    GROUP BY 1
)
SELECT payteller, redemption_count
FROM ranked_enchasing
WHERE enchasing_rank = 1;

 







-----------------------------------------
-- 1Tell me total how many bonds are created?

SELECT COUNT(*) AS total_bonds_created
FROM bonddata;

-- .2 Find the count of Unique Denominations provided by SBI?

SELECT COUNT(DISTINCT Denomination) AS unique_denominations
FROM bonddata;

-- 3 List all the unique denominations that are available?

SELECT DISTINCT Denomination
FROM bonddata
ORDER BY Denomination;

-- 4 Total money received by the bank for selling bonds

SELECT SUM(Denomination) AS total_money_received
FROM bonddata;

-- 5. Find the count of bonds for each denominations that are created.

SELECT Denomination, COUNT(*) AS bond_count
FROM bonddata
GROUP BY Denomination
ORDER BY Denomination;

-- 6. Find the count and Amount or Valuation of electoral bonds for each denominations.

SELECT Denomination, COUNT(*) AS bond_count, SUM(Denomination) AS total_valuation
FROM bonddata
GROUP BY Denomination
ORDER BY Denomination;

-- 7. Number of unique bank branches where we can buy electoral bond?

SELECT COUNT(DISTINCT branchcodeno) AS unique_branches
FROM bankdata;

-- 8. How many companies bought electoral bonds

SELECT COUNT(DISTINCT unique_key) AS companies_count
FROM donordata;

-- 9. How many companies made political donations

SELECT COUNT(DISTINCT d.unique_key) AS companies_donated
FROM donordata d
JOIN receiverdata r ON d.unique_key = r.unique_key
WHERE r.partyname IS NOT NULL;

-- 10. How many number of parties received donations

SELECT COUNT(DISTINCT partyname) AS number_of_parties
FROM receiverdata
WHERE partyname IS NOT NULL;

-- 11. List all the political parties that received donations

SELECT DISTINCT partyname
FROM receiverdata
WHERE partyname IS NOT NULL
ORDER BY partyname;

-- 12. What is the average amount that each political party received

SELECT partyname, AVG(Denomination) AS average_amount
FROM receiverdata r
JOIN bonddata b ON r.unique_key = b.unique_key
WHERE r.partyname IS NOT NULL
GROUP BY  partyname
ORDER BY  average_amount DESC;

-- 13. What is the average bond value produced by bank

SELECT AVG(Denomination) AS average_bond_value
FROM bonddata;

-- 14. List the political parties which have enchased bonds in different cities?

SELECT DISTINCT r.partyname, bs.city, COUNT(b.denomination) AS no_of_enchaded
FROM receiverdata r
JOIN bonddata b ON r.unique_key = b.unique_key
JOIN bankdata bs ON b.unique_key = r.unique_key
GROUP BY r.partyname, bs.city
order by 1 DESC;


-- 15. List the political parties which have enchased bonds in different cities and list the cities in which the bonds have enchased as well?

SELECT r.partyname, bs.city, COUNT(b.unique_key)
FROM receiverdata r
LEFT JOIN bonddata b ON r.unique_key = b.unique_key
LEFT JOIN bankdata bs ON bs.branchcodeno = r.paybranchcode
GROUP BY r.partyname, bs.city;
