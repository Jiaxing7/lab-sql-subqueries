USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film_id, COUNT(inventory_id) AS copy
FROM inventory
WHERE film_id IN
   (SELECT film_id
   FROM film
   WHERE title = 'Hunchback Impossible');


-- 2.List all films whose length is longer than the average of all the films.
SELECT title AS film
FROM film
WHERE length > (SELECT avg(length) AS average
FROM film);

-- 3.Use subqueries to display all actors who appear in the film Alone Trip.
SELECT CONCAT(first_name, last_name) AS actor 
FROM actor
WHERE actor_id IN
(SELECT actor_id FROM film_actor
WHERE film_id IN
    (SELECT film_id
    FROM film
    WHERE title = 'ALONE TRIP'));
    
-- 4 Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title AS film FROM film
WHERE film_id IN
    (SELECT film_id FROM film_category
    WHERE category_id IN
        (SELECT category_id
		FROM category
	    WHERE name = 'family'));
        

-- 5 Get name and email from customers from Canada using subqueries.
SELECT first_name, last_name, email FROM customer
WHERE address_id IN(
  SELECT address_id FROM address
  WHERE city_id IN(
     SELECT city_id FROM city
     WHERE country_id IN
        (SELECT country_id FROM country
	    WHERE country = 'Canada')));


-- join
SELECT first_name, last_name, email
FROM country c
JOIN city ci
USING(country_id)
JOIN address
USING(city_id)
JOIN customer
USING(address_id)
WHERE COUNTRY = 'Canada';


-- 6 Which are films starred by the most prolific actor? 
SELECT title AS film, first_name, last_name, COUNT(film_id) AS num_film 
FROM actor a
JOIN film_actor fa
USING(actor_id)
JOIN film
USING(film_id)
GROUP BY actor_id
ORDER BY num_film DESC
LIMIT 1;

-- 7 Films rented by most profitable customer. 
SELECT customer_id, first_name, last_name FROM customer
WHERE customer_id = (SELECT customer_id FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
limit 1);


SELECT title AS film FROM film
WHERE film_id IN (
  SELECT film_id FROM inventory
  WHERE inventory_id IN
    (SELECT inventory_id FROM rental
     WHERE customer_id IN
       (SELECT customer_id FROM customer
       WHERE customer_id = (SELECT customer_id FROM payment
       GROUP BY customer_id
       ORDER BY SUM(amount) DESC
       limit 1))));


     
-- 8. Customers who spent more than the average payments.

CREATE TEMPORARY TABLE sum_each_payment AS (
SELECT distinct customer_id, SUM(amount) AS payment FROM payment GROUP BY customer_id);

SELECT * FROM sum_each_payment;

SELECT distinct(p.customer_id), c.first_name, c.last_name, sum(p.amount) FROM payment p
JOIN customer c
USING(customer_id)
GROUP BY p.customer_id
HAVING sum(p.amount) > (SELECT avg(payment) from sum_each_payment)
ORDER BY sum(p.amount) ASC;

