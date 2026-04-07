-- 1. Crea el esquema de la BBDD.
/*
 * MovieStore>Esquemas>public>Click derecho>View diagram>Guardar como
 * */

-- 2. Muestra los nombres de todas las películas con una clasificación por edades de ‘R’.

select f.title as "titulo_pelicula", f.rating as "clasificacion"
from film f 
where f.rating='R'
;

-- 3. Encuentra los nombres de los actores que tengan un “actor_id” entre 30 y 40.

select a.actor_id, concat(a.first_name,' ', a.last_name) as "nombre_actor" 
from actor a 
where a.actor_id between 30 and 40
;

-- 4. Obtén las películas cuyo idioma coincide con el idioma original.

select f.title as "titulo_pelicula", f.language_id as "idioma", f.original_language_id as "idioma_original"
from film f
where f.language_id = f.original_language_id
;

		-- No hay registros en original_language_id (todos NULL), lo compruebo:
		select f.title as "titulo_pelicula", f.language_id as "idioma", f.original_language_id as "idioma_original"
		from film f
		where f.original_language_id is not null
		;
		
-- 5. Ordena las películas por duración de forma ascendente.
		
select f.title as "titulo_pelicula", f.length as "duracion(min)"
from film f 
order by f.length asc
;

-- 6. Encuentra el nombre y apellido de los actores que tengan ‘Allen’ en su apellido.

select concat(a.first_name,' ', a.last_name) as "nombre_actor" 
from actor a 
where a.last_name = 'ALLEN'
;

		-- Por si existiera algún apellido que contenga 'ALLEN' podemos usar 'like' de la siguiente manera:
		select concat(a.first_name,' ', a.last_name) as "nombre_actor" 
		from actor a 
		where a.last_name like '%ALLEN%'
		;
		-- '%'s sirven para representar que puede haber más caracteres por ese lado.
		
-- 7. Encuentra la cantidad total de películas en cada clasificación de la tabla “film” 
-- y muestra la clasificación junto con el recuento.

select count(f.rating) as "total_peliculas" , f.rating as "clasificacion" 
from film f 
group by f.rating
;

-- 8. Encuentra el título de todas las películas que son ‘PG-13’ o tienen una duración mayor a 3 horas en la tabla film.

select f.title as "titulo_pelicula", f.rating as "clasificacion", f.length as "duracion(min)"
from film f 
where f.rating = 'PG-13' or f.length > 180; -- length estás expresado en minutos; 3 horas = 180 min

-- 9. Encuentra la variabilidad de lo que costaría reemplazar las películas.

	-- Como guía añadiré las 5 películas más caras y las 5 más baratas de reemplazar.
	select f.title as "titulo_pelicula", f.replacement_cost as "coste_reemplazo"
	from film f 
	order by "coste_reemplazo" desc
	limit 5
	;
		
	select f.title as "titulo_pelicula", f.replacement_cost as "coste_reemplazo"
	from film f 
	order by "coste_reemplazo" asc
	limit 5
	;
		
	/* 
	 * Aunque se pide variabilidad, añadiré también desviación típica que es más visible
	 * al tener las mismas unidades que los datos originales 
	 */ 
		
select 	variance(f.replacement_cost) as "variabilidad_coste_reemplazo", 
		stddev(F.replacement_cost) as "desviacion_estandar_coste_reemplazo"
from film f 
;

-- 10. Encuentra la mayor y menor duración de una película de nuestra BBDD.

select min(f.length) as "minima_duracion(min)", max(f.length) as "maxima_duracion(min)"
from film f
;

-- 11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.

	-- Opción 1: Entendiendo que se pide el antepenúltimo alquiler de cada día.
	
	/*
	 * Hay varios alquileres que se pagaron en momentos distintos a la hora del alquiler, por tanto, necesitamos
	 * acceder a los datos de la tabla 'rental' para ordenar por día y buscar el antepenúltimo alquiler de ese día.
	 */
	
	select p.rental_id, p.amount, r.rental_date, r.rental_date::date as "fecha"
	from payment p 
	inner join rental r 
		on p.rental_id = r.rental_id
	order by "fecha", r.rental_date desc
	;

	/*
	 * En esta consulta el tercer elemento de cada día es el antepenúltimo alquiler de ese día.
	 */

select *
from (select distinct(rental_date::date) as "fecha" from rental) date	-- Para cada día distinto ('date')...
cross join lateral (	-- ...obtenemos todas las combinaciones con la tabla 'payment' inner join 'rental'...
    select p.rental_id as "ID_alquiler", p.amount as "precio", r2.rental_date "fecha_alquiler"
    from payment p
    inner join rental r2
    	on p.rental_id = r2.rental_id
    where r2.rental_date::date = date."fecha"	-- ...donde date."fecha" coincide con la fecha en 'payment' inner join 'rental'.
    order by rental_date desc	-- De cada día, ordenamos de manera descendente; esto es, el primer elemento es el último alquiler.
    limit 1 offset 2	-- Y saltando 2 elementos y quedándonos con 1 obtenemos el antepenúltimo registro de cada día.
)
;

	-- Opción 2: Entendiendo que se pide el antepenúltimo alquiler de todos los alquileres ordenado por días.

	select r.rental_id, r.rental_date 
	from rental r
	order by r.rental_date desc
	; -- El antepenúltimo alquiler es: rental_id = 11676 y rental_date = 2006-02-14 15:16:03.000
	
select p.rental_id, p.amount, r.rental_date, r.rental_date::date as "fecha"
from rental r 
inner join payment p 
	on r.rental_id = p.rental_id
order by r.rental_date desc
limit 1 offset 2
;

-- 12. Encuentra el título de las películas en la tabla “film” que no sean ni ‘NC-17’ ni ‘G’ en cuanto a su clasificación.

select f.title as "titulo_pelicula", f.rating as "clasificacion"
from film f 
where f.rating not in ('NC-17','G')
;

-- 13. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film 
-- y muestra la clasificación junto con el promedio de duración.

select f.rating as "clasificacion", round(avg(f.length),2) as "duracion(min)"
from film f 
group by f.rating 
;

-- 14. Encuentra el título de todas las películas que tengan una duración mayor a 180 minutos.

select f.title as "titulo_pelicula", f.length as "duracion(min)"
from film f 
where f.length > 180
order by "duracion(min)"
;

-- 15. ¿Cuánto dinero ha generado en total la empresa?

select sum(p.amount) as "beneficio_generado"
from  payment p;

-- 16. Muestra los 10 clientes con mayor valor de id.

select c.customer_id as "ID_cliente", concat(c.first_name,' ',c.last_name) as "nombre_cliente"
from customer c
order by c.customer_id desc
limit 10
;

-- 17. Encuentra el nombre y apellido de los actores que aparecen en la película con título ‘Egg Igby’.

select f.film_id as "ID_pelicula", f.title as "titulo_pelicula", concat(a.first_name,' ', a.last_name) as "nombre_actor"
from film f 
left join film_actor fa 
	on f.film_id = fa.film_id
left join actor a 
	on fa.actor_id = a.actor_id
where f.title = 'EGG IGBY'
;

-- 18. Selecciona todos los nombres de las películas únicos.

select distinct(f.title) as "titulo_pelicula"
from film f
; 

-- 19. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla “film”.

select f.film_id as "ID_pelicula", f.title as "titulo_pelicula", c.name as "categoria"
from film f
left join film_category fc 
	on f.film_id = fc.film_id
left join category c 
	on c.category_id = fc.category_id
where c.name  = 'Comedy'
;

-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 110 minutos 
-- y muestra el nombre de la categoría junto con el promedio de duración.

select c.name as "categoria", round(avg(f.length),2) as "duracion_media(min)"
from film f
inner join film_category fc 
	on f.film_id = fc.film_id
inner join category c 
	on c.category_id = fc.category_id
group by c.category_id
having round(avg(f.length),2) > 110
;

-- 21. ¿Cuál es la media de duración del alquiler de las películas?

select round(avg(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)/(3600*24))),2) as "tiempo_medio_alquiler(dias)"
from rental r
;

	/*
	 * Para favorecer la lectura de la consulta anterior se ha realizado de nuevo pero utilizando una CTE.
	 */

	with dias as (
		select EXTRACT(EPOCH FROM (r.return_date - r.rental_date)/(3600*24)) as "total_dias_alquilado"
		from rental r
	)
	select round(avg(total_dias_alquilado),2) as "tiempo_medio_alquiler(dias)"
	from dias
	;

-- 22. Crea una columna con el nombre y apellidos de todos los actores y actrices.

	/*	Comprobación si todos los nombres son DISTINTOS, si NO añadimos el ID en la consulta.	*/
 
	select count(concat(a.first_name,' ', a.last_name)) as "nombre_actor"	-- 200 nombres
	from actor a;

	select count(distinct(concat(a.first_name,' ', a.last_name))) as "nombre_actor"	-- 199 nombres
	from actor a;
	
	/*
	 *	Se repite un nombre, luego añadimos el ID del actor o actriz.
	 *	SUSAN DAVIS aparece dos veces, dos actrices tienen el mismo nombre y primer apellido (ID: 101 y 110).
	 */

select actor_id, concat(a.first_name,' ', a.last_name) as "nombre_actor"
from actor a
;

-- 23. Números de alquiler por día, ordenados por cantidad de alquiler de forma descendente.

	/*
	 * Necesito convertir la fecha en formato TIMESTAMP en otro que me indique el día concreto 
	 * para hacer distinción por días.
	 */

	-- Opción 1 (TO_CHAR, convierte un TIMESTAMP en un STRING.)
select to_char(r.rental_date, 'DD-MM-YYYY') as "fecha", count(r.rental_date::date) as "total_alquileres"
from rental r 
group by to_char(r.rental_date, 'DD-MM-YYYY') 
order by "total_alquileres" desc
;
	
	-- Opción 2 (CAST o  ::, convierte un valor de un tipo a OTRO tipo de dato)
select r.rental_date::date as "fecha", count(r.rental_date::date) as "total_alquileres"
from rental r 
group by r.rental_date::date 
order by total_alquileres desc
;

-- 24. Encuentra las películas con una duración superior al promedio.

select avg(f.length) as "duracion_media(min)"	-- 115,272 min.
from film f
;

select f.title as "titulo_pelicula", f.length as "duracion(min)"
from film f
where f.length > (
	select avg(f.length) as "duracion_media(min)"
	from film f 
)
order by "duracion(min)"
;

-- 25. Averigua el número de alquileres registrados por mes.

select * from rental r;

select to_char(r.rental_date, 'Month YYYY') AS "mes_y_año", count(*) AS "total_alquileres"
from rental r 
group by to_char(r.rental_date , 'Month YYYY')
;

-- 26. Encuentra el promedio, la desviación estándar y varianza del total pagado.

select 	round(avg(p.amount),2) as pago_medio,
		round(variance(p.amount),2) as varianza_pagos, 
		round(stddev(p.amount),2) as "desviacion_estandar_pagos"
from payment p
;

-- 27. ¿Qué películas se alquilan por encima del precio medio?

select avg(p.amount) as "precio_medio"		-- 4,2006673313
	from payment p;

select f.film_id as "ID_pelicula", f.title as "titulo_pelicula", p.amount as "precio"	-- 7746 peliculas
from payment p 
inner join rental r 
	on p.rental_id = r.rental_id 
inner join inventory i
	on r.inventory_id = i.inventory_id
inner join film f 
	on i.film_id = f.film_id
where p.amount > (
	select avg(p.amount) as "precio_medio"
	from payment p
	)
;

	/*
	 * En principio no importaría si usar INNER, LEFT o FULL JOIN porque no hay registros que alquileres sin pagos
	 * o no asociados a un inventario o película.
	 * 
	 * Comprobación:
	 */
	
	select f.film_id as "ID_pelicula", f.title as "titulo_pelicula", p.amount as "precio"	-- 7746 peliculas
	from payment p 
	full join rental r 
		on p.rental_id = r.rental_id 
	full join inventory i
		on r.inventory_id = i.inventory_id
	full join film f 
		on i.film_id = f.film_id
	where p.amount > (
		select avg(p.amount) as "precio_medio"
		from payment p
		)
	;
	
-- 28. Muestra el id de los actores que hayan participado en más de 40 películas.

select 	a.actor_id as "ID_actor", 
		concat(a.first_name,' ', a.last_name) as "nombre_actor", 
		count(a.actor_id) as "total_participaciones"
from actor a
inner join film_actor fa
	on a.actor_id = fa.actor_id
group by a.actor_id
having count(a.actor_id) > 40
;

-- 29. Obtener todas las películas y, si están disponibles en el inventario, mostrar la cantidad disponible.

	/*
	 * film > inventory > rental > IF return_date is NULL THEN no disponible (una de la cantidad total de ellas).
	 * Contar cantidad de NOT NULL.
	 * Las películas pueden estar en distintas tiendas luego deberemos agrupar por 'store_id' y 'film_id'.
	 * y consultar 'store_id', 'film_id' y 'title_id'.
	 */
	
select	i.store_id as "ID_tienda", i.film_id as "ID_pelicula", f.title as "titulo_pelicula",
		count(*) as "total_disponibles"
from inventory i
inner join rental r 
	on i.inventory_id = r.inventory_id
inner join film f 
	on i.film_id = f.film_id 
where r.return_date is not null -- aquellas disponibles
group by i.store_id, i.film_id, f.title 
order by "titulo_pelicula" 
;

-- 30. Obtener los actores y el número de películas en las que ha actuado.

select 	a.actor_id as "ID_actor", 
		concat(a.first_name,' ', a.last_name) as "nombre_actor", 
		count(a.actor_id) as "total_participaciones"
from actor a
inner join film_actor fa
	on a.actor_id = fa.actor_id
group by a.actor_id
;

-- 31. Obtener todas las películas y mostrar los actores que han actuado en ellas, 
-- incluso si algunas películas no tienen actores asociados.

select 	f.film_id as "ID_pelicula", f.title as "titulo_pelicula",
		a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor"
from film f 
left join film_actor fa 
	on f.film_id = fa.film_id
left join actor a 
	on fa.actor_id = a.actor_id
order by f.film_id, a.actor_id
;

	/*
	 * Con LEFT JOIN nos aseguramos que si no hay coincidencia entonces rellena los registros de actores con NULL.
	 * 
	 * Comprobación de si hay alguna película sin registro de actores (NULL):
	 */

	with cte1 as (
		select f.film_id as "ID_pelicula", f.title as "titulo_pelicula",
		a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor"
		from film f 
		left join film_actor fa 
			on f.film_id = fa.film_id
		left join actor a 
			on fa.actor_id = a.actor_id
		order by f.film_id
	)
	select * 
	from cte1
	where cte1."ID_actor" is null
	;
	
	/*
	 * Hay 3 películas sin actores registrados. Se han añadido correctamente en la consulta.
	 */

-- 32. Obtener todos los actores y mostrar las películas en las que han actuado, 
-- incluso si algunos actores no han actuado en ninguna película.

	/*	Con LEFT JOIN nos aseguramos que si no hay coincidencia entonces rellena los registros de la tabla 'film' con NULL.	*/
	
select 	a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor", 
		f.film_id as "ID_pelicula", f.title as "titulo_pelicula"
from actor a
left join film_actor fa
	on a.actor_id = fa.actor_id 
left join film f 
	on fa.film_id = f.film_id
order by a.actor_id, f.film_id
;

-- 33.  Obtener todas las películas que tenemos y todos los registros de alquiler.
	
	/*
	 * Como nos interesan los registros de alquiler usaremos INNER JOIN para que muestre
	 * solo las peliculas registradas como alquiladas.
	 */
	
	select 	f.film_id as "ID_pelicula", f.title as "titulo_pelicula", 
			r.rental_id as "ID_alquiler", r.rental_date as "fecha_alquiler", r.customer_id as "ID_cliente"
	from film f 
	inner join inventory i 
		on f.film_id = i.film_id 
	inner join rental r 
		on i.inventory_id = r.inventory_id
	order by "ID_pelicula";
	
-- 34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.

select 	c.customer_id as "ID_cliente", concat(c.first_name,' ', c.last_name) as "nombre_cliente", c.store_id as "ID_tienda",
		sum(p.amount) as "total_gastado"
from customer c 
inner join payment p 
	on c.customer_id = p.customer_id
group by c.customer_id
order by "total_gastado" desc 
limit 5
;

-- 35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.

select a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor"
from actor a
where a.first_name = 'JOHNNY'
;

-- 36. Renombra la columna “first_name” como Nombre y “last_name” como Apellido.

select a.first_name as "Nombre", a.last_name as "Apellido"
from actor a;

-- 37. Encuentra el ID del actor más bajo y más alto en la tabla actor.

select a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor"
from actor a 
where a.actor_id IN (
	(select min(a.actor_id) from actor a),
	(select max(a.actor_id) from actor a)
)
;

-- 38. Cuenta cuántos actores hay en la tabla “actor”.

select count(*) as "total_actores"
from actor a
;

-- 39. Selecciona todos los actores y ordénalos por apellido en orden ascendente.

select a.first_name as "Nombre", a.last_name as "Apellido"
from actor a
order by "Apellido" asc
;

-- 40. Selecciona las primeras 5 películas de la tabla “film”.

select *
from film f
limit 5
;

-- 41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el mismo nombre. ¿Cuál es el nombre más repetido?
	
	/*
	 * Agrupación de actores y contador de nombres:
	 */

	select a.first_name as "Nombre", count(*) as "veces_repetido(nombre)"
	from actor a
	group by a.first_name
	order by "veces_repetido(nombre)" desc;

	/*
	 * Los nombres más repetidos son 'KENNETH', 'PENELOPE' y 'JULIA'.
	 * 
	 * Tabla con nombres más repetidos:
	 */

with cte1 as (
	select a.first_name as "Nombre", count(*) as "veces_repetido(nombre)"
	from actor a
	group by a.first_name
	order by "veces_repetido(nombre)" desc
)
select *
from cte1
where "veces_repetido(nombre)" = (select max("veces_repetido(nombre)") from cte1);

-- 42. Encuentra todos los alquileres y los nombres de los clientes que los realizaron.

	/*
	 * Utilizamos LEFT JOIN porque aunque no encuentre ID_película, título o cliente sabemos que hay un alquiler.
	 * 
	 * Para dar contexto al alquiler añadimos los títulos de películas.
	 */

select r.rental_id as "ID_alquiler", i.film_id as "ID_pelicula", f.title as "titulo_pelicula",
r.customer_id as "ID_cliente", concat(c."first_name",' ', c."last_name") as "nombre_cliente" 
from rental r
left join customer c 
	on r.customer_id = c.customer_id
left join inventory i 
	on r.inventory_id = i.inventory_id
left join film f 
	on i.film_id = f.film_id;

-- 43. Muestra todos los clientes y sus alquileres si existen, incluyendo aquellos que no tienen alquileres.

select concat(c.first_name,' ', c.last_name) as "nombre_cliente", 
r.rental_id as "ID_alquiler", f.film_id as "ID_pelicula", f.title as "titulo_pelicula" 
from rental r 
right join customer c 
	on r.customer_id = c.customer_id
left join inventory i 
	on r.inventory_id = i.inventory_id 
left join film f 
	on i.film_id = f.film_id
order by "nombre_cliente", "ID_alquiler"
;

	/*
	 * Comprobación de que no hay clientes sin alquilar al menos una vez:
	 */

	select * from (
		select concat(c.first_name,' ', c.last_name) as "nombre_cliente", 
		r.rental_id as "ID_alquiler", f.film_id as "ID_pelicula", f.title as "titulo_pelicula" 
		from rental r 
		right join customer c 
			on r.customer_id = c.customer_id
		left join inventory i 
			on r.inventory_id = i.inventory_id 
		left join film f 
			on i.film_id = f.film_id
		order by "nombre_cliente", "ID_alquiler"
		)
		where "ID_pelicula" is null
	;

-- 44. Realiza un CROSS JOIN entre las tablas film y category. 
-- ¿Aporta valor esta consulta? ¿Por qué? Deja después de la consulta la contestación.

select *
from film f 
cross join category c;

/*
 * Esta consulta no aporta ningún valor ya que muestra todas las posibles combinaciones entre peliculas y
 * categorías. Esta consulta crea películas NO EXISTENTES con el mismo título y con categorías distintas.
 * */

-- 45. Encuentra los actores que han participado en películas de la categoría 'Action'.

select concat(a.first_name,' ', a.last_name) as "nombre_actor"
from actor a 
left join film_actor fa 
	on a.actor_id = fa.actor_id
left join film f 
	on fa.film_id = f.film_id 
left join film_category fc 
	on f.film_id = fc.film_id
left join category c 
	on fc.category_id = c.category_id
where c.name = 'Action'
group by a.actor_id
;

	/*
	 * Añado una consulta más con algunos datos extra para dar contexto: Qué actores en qué películas de 'Action' participaron.
	 * (sin GROUP BY)
	 */

	select concat(a.first_name,' ', a.last_name) as "nombre_actor", 
	f.film_id as "ID_pelicula", f.title as "titulo_pelicula", c.name as "categoria"
	from actor a 
	left join film_actor fa 
		on a.actor_id = fa.actor_id
	left join film f 
		on fa.film_id = f.film_id 
	left join film_category fc 
		on f.film_id = fc.film_id
	left join category c 
		on fc.category_id = c.category_id
	where c.name = 'Action'
	;

-- 46. Encuentra todos los actores que no han participado en películas.

select concat(a.first_name,' ', a.last_name) as "nombre_actor",
f.film_id as "ID_pelicula", f.title as "titulo_pelicula", c.name as "categoria"
from actor a 
left join film_actor fa 
	on a.actor_id = fa.actor_id
left join film f 
	on fa.film_id = f.film_id 
left join film_category fc 
	on f.film_id = fc.film_id
left join category c 
	on fc.category_id = c.category_id
where f.film_id is null
;

	/*
	 * Usamos LEFT JOIN para que si hay actores que no hayan participado en películas se rellene con NULL
	 * en los registros de la tabla 'film'. Comprobamos si se encuentran NULL en la tabla 'film'.
	 */

-- 47. Selecciona el nombre de los actores y la cantidad de películas en las que han participado.

select a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor", count(*) as "total_participaciones"
from actor a 
inner join film_actor fa
	on a.actor_id = fa.actor_id
inner join film f 
	on fa.film_id = f.film_id 
group by a.actor_id 
;

	/*
	 * Comprobación de que no faltan actores, si faltasen es que no han participado en películas
	 */

	select * 
	from actor a 
	where a.actor_id not in (
		select a.actor_id as "ID_actor"
		from actor a 
		left join film_actor fa
			on a.actor_id = fa.actor_id
		left join film f 
			on fa.film_id = f.film_id 
		where f.film_id is not null
		group by a.actor_id 
		)
	;
	
	/*
	 * Si faltara alguno porque no ha participado podriamos añadirlo a una tabla conjunta de la siguiente manera:
	 */
	
(select a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor", count(*) as "total_participaciones"
from actor a 
left join film_actor fa
	on a.actor_id = fa.actor_id
left join film f 
	on fa.film_id = f.film_id 
where f.film_id is not null
group by a.actor_id) 
union
(select a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor", 0 as "total_participaciones" 
from actor a 
where a.actor_id not in (
	select a.actor_id as "ID_actor"
	from actor a 
	left join film_actor fa
		on a.actor_id = fa.actor_id
	left join film f 
		on fa.film_id = f.film_id 
	where f.film_id is not null
	group by a.actor_id 
	))
;
	
-- 48. Crea una vista llamada “actor_num_peliculas” que muestre los nombres de los actores
-- y el número de películas en las que han participado.

drop view if exists actor_num_peliculas;

create view actor_num_peliculas as
select concat(a.first_name,' ', a.last_name) as "nombre_actor", count(*) as "total_participaciones"
from actor a 
inner join film_actor fa 
	on a.actor_id = fa.actor_id
inner join film f 
	on fa.film_id = f.film_id 
group by concat(a.first_name,' ', a.last_name)
;

	select * from actor_num_peliculas;

-- 49. Calcula el número total de alquileres realizados por cada cliente.

	/*
	 * Como nos interesan los alquileres totales de cada cliente usaremos INNER JOIN para buscar solo las coincidencias.
	 */
	
select c.customer_id as "ID_cliente", concat(c.first_name,' ', c.last_name) as "nombre_cliente", count(*) as "total_alquileres"
from rental r 
inner join customer c 
	on r.customer_id = c.customer_id
inner join inventory i 
	on r.inventory_id = i.inventory_id 
inner join film f 
	on i.film_id = f.film_id
group by c.customer_id 
;

-- 50. Calcula la duración total de las películas en la categoría 'Action'.

select c.name as "categoria", sum(f.length) as "duracion_total_x_categorias(min)"
from film f 
left join film_category fc 
	on f.film_id = fc.film_id 
left join category c 
	on fc.category_id = c.category_id
where c.name = 'Action'
group by c.category_id
; 

-- 51. Crea una tabla temporal llamada “cliente_rentas_temporal” para almacenar el total de alquileres por cliente.

with clientes_rentas_temporal as (
	select c.customer_id as "ID_cliente", concat(c.first_name,' ', c.last_name) as "nombre_cliente", count(*) as "total_alquileres"
	from rental r 
	inner join customer c 
		on r.customer_id = c.customer_id
	inner join inventory i 
		on r.inventory_id = i.inventory_id 
	inner join film f 
		on i.film_id = f.film_id
	group by c.customer_id 
	)
select *
from clientes_rentas_temporal;

-- 52. Crea una tabla temporal llamada “peliculas_alquiladas” que almacene 
-- las películas que han sido alquiladas al menos 10 veces.

drop table if exists peliculas_alquiladas;

create temporary table peliculas_alquiladas as 
	select f.title as "titulo_pelicula", count(*) as "veces_alquilada"
	from film f 
	inner join inventory i 
		on f.film_id = i.film_id 
	inner join rental r  
		on i.inventory_id = r.inventory_id
	group by f.film_id, f.title
	having count(*) >= 10
;

select *
from peliculas_alquiladas
;

-- 53. Encuentra el título de las películas que han sido alquiladas por el cliente
-- con el nombre ‘Tammy Sanders’ y que aún no se han devuelto. Ordena
-- los resultados alfabéticamente por título de película.

	/*
	 * Las películas no devueltas aparecen como NULL en 'return_date'.
	 */
	
select concat(c.first_name,' ', c.last_name) as "nombre_cliente", 
f.title as "titulo_pelicula", r.return_date as "fecha_devolucion" 
from customer c  
left join rental r 
	on c.customer_id = r.customer_id 
left join inventory i
	on r.inventory_id = i.inventory_id 
left join film f 
	on i.film_id = f.film_id
where concat(c.first_name,' ', c.last_name) = 'TAMMY SANDERS' and r.return_date is null
;

-- 54. Encuentra los nombres de los actores que han actuado en al menos una
-- película que pertenece a la categoría ‘Sci-Fi’. Ordena los resultados
-- alfabéticamente por apellido.

select a.actor_id as "ID_actor", concat(a."first_name",' ', a."last_name") as "nombre_actor"
from actor a 
inner join film_actor fa 
	on a.actor_id = fa.actor_id
inner join film f 
	on fa.film_id = f.film_id 
inner join film_category fc 
	on f.film_id = fc.film_id
inner join category c 
	on fc.category_id = c.category_id
where c.name = 'Sci-Fi'
group by a.actor_id -- Hay dos actrices que se llaman igual como ya vimos anteriormente (Consulta 22).
order by a.last_name asc
;

-- 55. Encuentra el nombre y apellido de los actores que han actuado en
-- películas que se alquilaron después de que la película ‘Spartacus Cheaper’
-- se alquilara por primera vez. Ordena los resultados alfabéticamente por apellido.

	/*
	 * Fecha en la que ‘Spartacus Cheaper’ se alquiló por primera vez:
	 */

	select f.title as "titulo_pelicula", r.rental_date as "fecha_alquiler" 
	from rental r  
	left join inventory i
		on r.inventory_id = i.inventory_id 
	left join film f 
		on i.film_id = f.film_id
	where f.title = 'SPARTACUS CHEAPER'
	order by "fecha_alquiler" asc
	limit 1
	;

	/*
	 * La primera fecha de alquiler de 'Spartacus Cheaper' es '2005-07-08 06:43:42.000'.
	 * Añadimos esta consulta como subconsulta en WHERE.
	 */

select a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor"	-- Actores que actuaron en ...
from actor a 
left join film_actor fa 
	on a.actor_id = fa.actor_id
left join film f 
	on fa.film_id = f.film_id 
left join inventory i 
	on f.film_id = i.film_id
left join rental r 
	on i.inventory_id = r.inventory_id
where r.rental_date > (		-- ... películas que se alquilaron después de ...
		select r.rental_date as "fecha_alquiler" 
		from rental r  
		left join inventory i
			on r.inventory_id = i.inventory_id 
		left join film f 
			on i.film_id = f.film_id
		where f.title = 'SPARTACUS CHEAPER'
		order by "fecha_alquiler" asc 	-- ... la primera fecha de alquiler de ‘Spartacus Cheaper’, ...
		limit 1
)
group by "ID_actor"
order by a.last_name asc -- ... ordenado alfabéticamente por apellido.
;

-- 56. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría ‘Music’.

	/*
	 * Esta primera consulta muestra los actores que han hecho al menos una película de categoria 'Music'.
	 * Añadimos el ID del actor porque hay dos actores que se llaman igual.
	 */

	select a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor"
	from actor a 
	inner join film_actor fa 
		on a.actor_id = fa.actor_id
	inner join film f 
		on fa.film_id = f.film_id 
	inner join film_category fc 
		on f.film_id = fc.film_id
	inner join category c 
		on fc.category_id = c.category_id
	where c.name = 'Music'
	group by a.actor_id
	order by a.first_name, a.last_name -- no hace falta pero la utilicé para comprobar.
	;
	

	
	
	/*
	 * Utilizamos esta consulta como subconsulta en WHERE para seleccionar aquellos actores que no están
	 * en los resultados de la consulta anterior.
	 */
	
select a.actor_id as "ID_actor", concat(a.first_name,' ', a.last_name) as "nombre_actor"
from actor a 
where a.actor_id not in (
	select a.actor_id
	from actor a 
	inner join film_actor fa 
		on a.actor_id = fa.actor_id
	inner join film f 
		on fa.film_id = f.film_id 
	inner join film_category fc 
		on f.film_id = fc.film_id
	inner join category c 
		on fc.category_id = c.category_id
	where c.name = 'Music'
	group by a.actor_id
)
order by a.first_name, a.last_name
;
	
-- 57. Encuentra el título de todas las películas que fueron alquiladas por más de 8 días.

/*
 * Opción 1. Usando EXTRACT(DAY FROM...).
 */

select f.film_id as "ID_pelicula", f.title as "titulo_pelicula", max(r.return_date - r.rental_date) as "max_tiempo_alquilada" 
from film f 
left join inventory i 
	on f.film_id = i.film_id
left join rental r 
	on i.inventory_id = r.inventory_id
where extract(day from (r.return_date - r.rental_date)) >= 8
group by f.film_id
order by "titulo_pelicula"
;

/*
 * Opción 2. Usando EXTRACT(EPOCH FROM ...).
 */

select f.film_id as "ID_pelicula", f.title as "titulo_pelicula", max(r.return_date - r.rental_date) as "max_tiempo_alquilada" 
from film f 
left join inventory i 
	on f.film_id = i.film_id
left join rental r 
	on i.inventory_id = r.inventory_id
where extract(epoch from (r.return_date - r.rental_date))/(3600*24) >= 8
group by f.film_id
order by "titulo_pelicula"
;

-- 58. Encuentra el título de todas las películas que son de la misma categoría que ‘Animation’.

select f.film_id as "ID_pelicula", f.title as "Titulo_pelicula", c.name as "categoria"
from film f 
left join film_category fc 
	on f.film_id = fc.film_id
left join category c 
	on fc.category_id = c.category_id
where c.name = 'Animation'
;

-- 59. Encuentra los nombres de las películas que tienen la misma duración
-- que la película con el título ‘Dancing Fever’. 
-- Ordena los resultados alfabéticamente por título de película.

select f.film_id as "ID_pelicula", f.title as "titulo_pelicula", f.length as "duracion" 
from film f
where f.length = (
	select f.length
	from film f 
	where f.title = 'DANCING FEVER'
	)
order by "titulo_pelicula" asc 
;

-- 60. Encuentra los nombres de los clientes que han alquilado al menos 7
-- películas distintas. Ordena los resultados alfabéticamente por apellido.

select c.customer_id as "ID_cliente", concat(c.first_name,' ', c.last_name) as "nombre_cliente",
count(distinct(i.film_id)) as "peliculas_distintas_alquiladas"
from customer c 
left join rental r 
	on c.customer_id = r.customer_id
left join inventory i 
	on r.inventory_id = i.inventory_id
group by c.customer_id
order by c.last_name
;

-- 61. Encuentra la cantidad total de películas alquiladas por categoría y
-- muestra el nombre de la categoría junto con el recuento de alquileres.

select c.name as "categoria", count (*) as "total_alquiladas"
from rental r 
left join inventory i 
	on r.inventory_id = i.inventory_id
left join film f 
	on i.film_id = f.film_id
left join film_category fc 
	on f.film_id = fc.film_id
left join category c 
	on fc.category_id = c.category_id
group by c.category_id
;

-- 62. Encuentra el número de películas por categoría estrenadas en 2006.

select c.name as "Categoria", count(f.film_id) as "total_peliculas_2006"
from film f 
left join film_category fc 
	on f.film_id = fc.film_id
left join category c 
	on fc.category_id = c.category_id
where f.release_year = 2006
group by c.name
;

-- 63. Obtén todas las combinaciones posibles de trabajadores con las tiendas que tenemos.

select s.staff_id as "ID_trabajador", concat(s.first_name,' ', s.last_name) as "nombre_trabajador",
s2.store_id as "ID_tienda" 
from staff s 
cross join store s2
;

-- 64. Encuentra la cantidad total de películas alquiladas por cada cliente y 
-- muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.

select c.customer_id as "ID_cliente", concat(c.first_name,' ', c.last_name) as "nombre_cliente", 
count(*) as "num_peliculas_alquiladas"
from rental r 
inner join customer c -- Usamos INNER JOIN porque nos interesan los alquileres con registro de clientes para contar.
	on r.customer_id = c.customer_id  
group by c.customer_id
;
	
	/*
	 * Anteriormente ya comprobamos que no hay clientes sin haber alquilado al menos una vez (Consulta 43).
	 */