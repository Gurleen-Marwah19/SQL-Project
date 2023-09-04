USE Mavenmovies;

-- Information of all staff members for the record.

SELECT first_name,
	last_name,
    email,
    store_id
FROM staff;

-- Count of inventory at each store

SELECT
	store_id,
    COUNT(inventory_id) AS inventory_count
FROM inventory
GROUP BY store_id;

-- Using "Select" & "From" clause to extract information regarding the customers.

SELECT first_name,
	last_name,
    email
FROM customer;

-- Count of active customers at each store
SELECT
	store_id,
    COUNT(customer_id) AS total_customers
FROM customer
WHERE active = 1
GROUP BY store_id;

-- Count of Distinct films for our customers

SELECT
	store_id,
    COUNT(DISTINCT(film_id)) AS total_film_titles
FROM inventory
GROUP BY store_id;

-- Count of distinct category of films

SELECT
	COUNT(DISTINCT(category_id)) AS no_of_categories
FROM film_category;

-- In my "movies rental business", I need the info for the duration for which my company rent the movies to the customers.

SELECT DISTINCT rental_duration
FROM film; 

-- I'd like to look at "payment records" for the first 100 customers (based on the customer_id) to learn about the purchase patterns.

SELECT customer_id,
	rental_id,
    amount,
    payment_date
FROM payment
WHERE customer_id <= 100;

-- I want to dig deep in the data extracted above and would like to know which customer has made payment mopre than $5 since January 1, 2006.

SELECT customer_id,
	rental_id,
    amount,
    payment_date
FROM payment
WHERE customer_id <= 100 
	AND amount > 5
    AND payment_date >= '2006-01-01';
    
-- To understand even further, I'd like to know for how long the movies tend to be rented out for. So for this purpose, I need to pull a count of titles sliced by rental duration.

SELECT rental_duration,
	COUNT(film_id) AS total_films
FROM film
GROUP BY rental_duration
ORDER BY rental_duration;

-- I further need to understand the relationship between rental cost and replacement cost. I'm wondering if we charge more for a rental when the replacement cost is higher.

SELECT replacement_cost,
	COUNT(film_id) AS number_of_movies,
	MIN(rental_rate) AS cheapest_rental,
	MAX(rental_rate) AS expensive_rental,
	AVG(rental_rate) AS average_rental
FROM film
GROUP BY replacement_cost;

-- min, max and avg replacement_cost for films

SELECT
    MIN(replacement_cost) AS least_expensive_to_replace,
    MAX(replacement_cost) AS most_expensive_to_replace,
    AVG(replacement_cost) AS average_cost_to_replace
FROM film;

-- Identify customers with highest volumes

SELECT
	customer_id,
    COUNT(rental_id) AS no_of_rentals
FROM rental
GROUP BY customer_id
ORDER BY (COUNT(rental_id)) DESC;

-- Now, I'd like to communicate with the customers that have not rented less than 15 times to understand if there is something my company could do better for them

SELECT customer_id,
	COUNT(rental_id) AS total_rentals
FROM payment
GROUP BY customer_id
HAVING COUNT(rental_id) < 15;

-- For logistics purpose, I'd like to see if our longest films also tend to be the most expensive ones. 
-- But that is not the case. Length of the film does not necessarily impacts the rental rate.

SELECT title,
	length,
    rental_rate
FROM film
ORDER BY length DESC;

-- In order to understand the foot fall of both the stores, I'd like to know which store each customer goes to, and whether or not they are active.

SELECT first_name,
	last_name,
    CASE
		WHEN store_id = 1 AND active = 1 THEN 'store 1 active'
        WHEN store_id = 1 AND active = 0 THEN 'store 1 inactive'
        WHEN store_id = 2 AND active = 1 THEN 'store 2 active'
        WHEN store_id = 2 AND active = 0 THEN 'store 2 inactive'
        ELSE 'Check the logic'
        END AS store_and_status
FROM customer;

-- I'd like to know the count of active and inactive customers at each store.

SELECT store_id,
	 COUNT(CASE WHEN active = 1 THEN customer_id ELSE NULL END) AS active,
     COUNT(CASE WHEN active = 0 THEN customer_id ELSE NULL END) AS inactive
FROM customer
GROUP BY store_id;

-- I would like to see the film's title, description and the store_id value associated with each item, and its inventory_id.

SELECT
	i.inventory_id,
    i.store_id,
    f.title,
    f.description
FROM inventory AS i
	INNER JOIN film AS f
		ON i.film_id = f.film_id;
        
-- I want to know how many actors are associated with each title

SELECT
	f.title,
    COUNT(actor_id) AS number_of_actors
FROM film AS f
	LEFT JOIN film_actor AS fa
		ON f.film_id = fa.film_id
GROUP BY f.title;

-- It would be great to have a list of all actors, with each title that they appear in. Customers can ask which films their favorite actors appear in.

SELECT
	a.first_name,
    a.last_name,
    f.title
FROM actor AS a
	INNER JOIN film_actor AS fa
		ON fa.actor_id = a.actor_id
	INNER JOIN film AS f
		ON fa.film_id = f.film_id
ORDER BY 
	a.first_name,
    a.last_name;

-- The manager of store 2 is working on expanding the film collection, so he wants to pull a list of distinct titles and their descriptions currently available at store 2.

SELECT 
	film.title,
    film.description
FROM film
	INNER JOIN inventory
		ON film.film_id = inventory.film_id
WHERE inventory.store_id = 2;

-- Our company will be hosting a meeting with all of the staff and advisors soon. So, I need to pull a list of all staff and advisor names.
SELECT
	first_name,
    last_name,
    'Advisor' AS type
FROM advisor

UNION

SELECT
	first_name,
    last_name,
    'Staff' AS type
FROM staff;

/* Now, Martin Moneybags want to acquire the maven movies business and he is really excited about the potential acquisition and need to 
learn more about the rental business. Following will be some of the queries for Martin to understand variety of stuff about the stores, inventory etc*/

-- My partner and I (Martin) want to come by each of the stores in person andmeet the managers. For that, I need to have the names of managers at each store with the full address of each property.
-- Complex Joins- (Bridging 2 or more tables)

SELECT
	staff.store_id,
    'Manager' AS type,
	staff.first_name,
    staff.last_name,
    address.address,
    address.district,
    city.city,
    country.country
FROM staff
	INNER JOIN address
		ON staff.address_id = address.address_id
	INNER JOIN city
		ON address.city_id = city.city_id
	INNER JOIN country
		ON city.country_id = country.country_id;
        
/* Martin would like to get a better understanding of all the inventory that would come along with the business. 
   below query is to pull a list of each inventory item slocked in the store, including the store_id number, the inventory_id , the title of the film, the film's rating,
   its rental rate and replacement cost*/
   
SELECT
	inventory.store_id,
    inventory.inventory_id,
    film.title,
    film.rating,
    film.rental_rate,
    film.replacement_cost
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id;
    
    
-- Summary level overview of the inventory (inventory items with each rating at each store)  

SELECT
	inventory.store_id,
    film.rating,
	COUNT(inventory_id) AS total_films
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
GROUP BY
	inventory.store_id,
    film.rating;


-- My partner and I, we want to understand how diversified the inventory is in terms of relacement cost.

SELECT
	inventory.store_id,
    category.name,
    COUNT(inventory.inventory_id) AS no_of_films,
    avg(replacement_cost) AS avg_replacement_cost,
    sum(replacement_cost) AS total_replacement_cost
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
	LEFT JOIN film_category
		ON film.film_id = film_category.film_id
	LEFT JOIN category
		ON film_category.category_id = category.category_id
GROUP BY
	inventory.store_id,
    category.name
ORDER BY sum(replacement_cost);


-- Full fledged information about the customers.

SELECT
	customer.store_id,
    customer.first_name AS customer_first_name,
    customer.last_name AS customer_last_name,
    customer.active,
    address.address,
    address.district,
    city.city,
    country.country
FROM customer
	LEFT JOIN address
		ON customer.address_id = address.address_id
	LEFT JOIN city
		ON address.city_id = city.city_id
	LEFT JOIN country
		ON city.country_id = country.country_id
ORDER BY store_id;

-- Customers spending patterns

SELECT
	customer.first_name AS customer_first_name,
    customer.last_name AS customer_last_name,
    COUNT(rental.rental_id) AS total_rentals,
    SUM(payment.amount) AS total_amount
FROM customer
	LEFT JOIN rental
		ON customer.customer_id = rental.customer_id
	LEFT JOIN payment
		ON rental.rental_id = payment.rental_id
GROUP BY customer.first_name,
    customer.last_name
ORDER BY SUM(payment.amount) DESC;


-- List of investors and advisors

SELECT
	'Advisor' AS type,
    first_name AS advisor_first_name,
    last_name AS advisor_last_name,
    Null
FROM advisor
UNION
SELECT
	'Investor' AS type,
    first_name AS investor_first_name,
    last_name AS investor_last_name,
    company_name
FROM investor;

-- Of all the actors with three types of awards, for what % ofthem do we carry a film.

SELECT
	CASE
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
        ELSE '1 award'
	END AS number_of_awards,
    AVG (CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS percentage_with_one_movie
FROM actor_award
GROUP BY
	CASE
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
        ELSE '1 award'
	END;
