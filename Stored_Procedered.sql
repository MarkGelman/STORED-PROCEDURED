-- ********************************** Stored Procedured **********************************************************
-- название всех ф-ций Stored Procedured находится справа в дереве БД в папке ROUTINCE
/* **синтаксис Stored Procedured:**
    1.имя функции в Stored Procedured должно начинаться с sp_имя_функции
    2."REPLACE - даёт возможность измянять функционал ф-ции, если она уже создана. Но если нужно изменить часть
               RETURNS то тогда есть один путь - это удаление ф-ции через DROP"

    3. Cинтаксис:

        CREATE or REPLACE FUNCTION имя_фукции (имя_параметра модифаер_параметра)
        returns (то что функция возвращает (таблица и т.д))
        LANGUAGE plpgsql (здесь пишется название языка на котором будет писаться функция) AS
        $$
            DECLEAR - название блока в котором задаются переменные для функции

            BEGIN
                    ТЕЛО ФУНКЦИИ
            END;
        $$;

   4. Действия оперетаров в Stored Procedeure:
               greeting - выводит данные ввиде таблицы;
               concat -> функция которая объединяет строки;
               current_timestamp - выводит текущую дату и время;
               current_date - выводит только текущую дату;
               DECLEAR - позволяет задавать поля
               OUT -> он заменяет в ф-ции RETURN values;
               numeric (к-во цифр до точки, к-во цифр после точки) -> это число с целой и дробной (десятичной) частью;
               avg (age) :: numeric (5,1) -> "::" - это как CASTING в С#;
                        второй способ для CASTING следующий --> cast (avg(age) as numeric (5,1);
               returning id into new_id --> это способ для получения [id] новой записи. Используется в команде INSERT и
                    UPDATE;
               call --> вызывает функцию которая не возвращает значение (функция типа VOID);
               anyelement --> получает любой тип переменной. Фукционирует как OBJECT в C# ;
               WITH имя_ячейки_хранения AS -->  WITH ... AS предназначен для хранения всего, что будет записано в его
                                                теле,включая запросы. Это помогает упорядочить сложные запросы, в
                                                которых очень много подзапросов;

   5. Функция записаная как Stored_Procedured она как функция VOID, т.е не требует RETURNS и RETURN;

   6. Функци которая не возвращает значение вызываетс не через SELECT...FROM, а через СALL;
 */

------------------------------------------------ сoncat and current_timestamp -----------------------------------------
CREATE or REPLACE  FUNCTION sp_hello_world()
RETURNS varchar
LANGUAGE plpgsql AS
    $$
        BEGIN
            RETURN concat('Hello','World!','',current_timestamp);
        END;
    $$;

SELECT HELLO_WORLD greeting FROM hello_world();

CREATE or REPLACE  FUNCTION sp_sum_of_numbers(m double precision, n double precision)
RETURNS double precision
LANGUAGE plpgsql AS
    $$
        BEGIN
            RETURN n+m;
        END;
    $$;

-------------------------------------------- DECLEAR ---------------------------------------------------------------
CREATE or REPLACE  FUNCTION sp_sum_of_numbers_with_declear(m double precision, n double precision)
RETURNS double precision
LANGUAGE plpgsql AS
    $$
        declare
            x integer  = 1;
        BEGIN
            RETURN n+m+x;
        END;
    $$;

SELECT * FROM sp_sum_of_numbers_with_declear(3.5, 4.9);

-------------------------------------------------------------- OUT ----------------------------------------------------

CREATE or REPLACE  FUNCTION sp_sum_n_products(x int, y int, OUT sum int, OUT prod int)
-- RETURNS double precision - при использовании оператора OUT - это строка не нужна
LANGUAGE plpgsql AS
    $$
        BEGIN
            sum := x +y;
            prod := x*y;
        END;
    $$;

SELECT * FROM sp_sum_n_products(10,20);

CREATE or REPLACE  FUNCTION sp_get_movies_price(
        OUT min_price double precision,
        OUT max_price double precision,
        OUT avg_price double precision)
-- RETURNS double precision - при использовании оператора OUT - это строка не нужна
LANGUAGE plpgsql AS
    $$
        BEGIN
            SELECT  min (price),
                    max(price),
                    avg(price)::numeric(5,1)
            INTO min_price,max_price,avg_price
            FROM "Movies";
        END;
    $$;

SELECT * FROM sp_get_movies_price();

---------------------------------------------------Classwork ----------------------------------------------------------
/* stored procedure create or replace --> return using out the name of the most expensive movie
        1. Declare double for most expensive movie -- find the price using select .... into
        2. Use select into .... to populate the movie name (limit 1)

   stored procedere call it : count_sum_records which returns the count of records from movies + count of records
                              from country
*/

CREATE OR REPLACE FUNCTION sp_price_most_expensive_movie()
RETURNS double precision
LANGUAGE plpgsql AS
    $$
        DECLARE
            max_price double precision;
        BEGIN
             SELECT max(price)
                    INTO max_price
                    FROM "Movies";
             RETURN max_price;

           --SELECT max(price) INTO max_price FROM "Movies";
        end;
    $$;

SELECT * FROM sp_price_most_expensive_movie();

CREATE OR REPLACE FUNCTION sp_name_most_expensive_movie(
        out movie_name text,
        out max_price double precision)
LANGUAGE plpgsql AS
    $$
        BEGIN
           -- SELECT max(price),title
           -- INTO max_price,movie_name
           -- FROM "Movies"
           -- WHERE price = (select max(price) FROM "Movies");
           SELECT price,title INTO max_price,movie_name FROM "Movies" WHERE price = (select max(price) FROM "Movies");
        end;
    $$;

SELECT * FROM sp_name_most_expensive_movie();

CREATE OR REPLACE FUNCTION sp_count_records_country_movies()
RETURNS int
LANGUAGE plpgsql AS
    $$
        DECLARE
            count_all_records int;
        BEGIN
            count_all_records := (SELECT Count (*) FROM "Movies") +  (SELECT Count (*) FROM country);
            return count_all_records;
        end;
    $$;

select * FROM sp_count_records_country_movies()

-------------------------------------------------- INSERT and RETURNING ... INTO ----------------------------------

CREATE OR REPLACE FUNCTION sp_insert_movie(_title text,_release_date timestamp,_price double precision,_country_id bigint)
RETURNS bigint
LANGUAGE plpgsql AS
    $$
        DECLARE
            new_Id bigint;
        BEGIN
          INSERT  INTO  "Movies" (title, release_date, price,country_id)
          VALUES (_title,_release_date,_price,_country_id)
          RETURNING id INTO new_Id;

          return new_Id;
        end;
    $$;

select * FROM sp_insert_movie('Superman returns','2021-05-09 22:00:00',75.4);
select * FROM sp_insert_movie('Queens gambit','2022-03-10 21:21:33',175.4,2);
select*from "Movies";

------------------------------------------------- CLASSWORK -----------------------------------------------------------
/*
    create update function sp --> procedure

    works also with update
    update movies set country_id=2
    where country_id=2
    returning id
*/

CREATE OR REPLACE  PROCEDURE sp_insert_movie_with_stored_procedured(_id bigint,_title text,_release_date timestamp,
            _price double precision,_country_id bigint)
LANGUAGE plpgsql AS
    $$
        BEGIN
            UPDATE  "Movies"
            SET title = _title,
                release_date = _release_date,
                price = _price,
                country_id = _country_id
            WHERE id = _id;
        end;
    $$;

CALL sp_insert_movie_with_stored_procedured (1,'batman returns','2020-12-16 20:21:30.500000',
                                            19.5,1);

CREATE OR REPLACE FUNCTION sp_get_movies_in_range (min_price double precision,max_price double precision)
RETURNS TABLE (id bigint,title text,release_date timestamp,price double precision,country_id bigint) -->
 LANGUAGE plpgsql AS
    $$
        BEGIN
            RETURN QUERY --> означает, что функция вернёт результат запроса
            SELECT  * FROM "Movies"
            WHERE "Movies".price BETWEEN min_price and max_price;
        END;
    $$;

SELECT * FROM sp_get_movies_in_range(50,80);

--------------------------------------------------- WITH -------------------------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_movies_between_maxPrice_to_minPrice ()
RETURNS TABLE (id bigint,title text,release_date timestamp,price double precision,country_id bigint) -->
 LANGUAGE plpgsql AS
    $$
        BEGIN
            RETURN QUERY
            WITH cheapes_movie AS --> WITH предназначен для хранения всего, что будет записано в его теле, включая
                                        -- запросы. Это помогает упорядочить сложные запросы, в которых очень много
                                        -- подзапросов;
                     (
                         SELECT  * FROM  "Movies" m
                         WHERE  m.price = (select min(m.price) FROM "Movies" m)
                     ),
                  expensive_movie AS
                     (
                         SELECT  * FROM  "Movies" m
                         WHERE  m.price = (select max(m.price) FROM "Movies" m)
                     )
            SELECT  * FROM "Movies" m
            WHERE m.id <> (select cm.id from cheapes_movie cm) AND m.id <> (select em.id from expensive_movie em);
        END;
    $$;

SELECT * FROM sp_get_movies_between_maxPrice_to_minPrice();

----------------------------------------------------- CLASSWORK -------------------------------------------------------

-- use WITH and return all movies which costs more than average and it`s not the last movie (timestamp)

CREATE OR REPLACE FUNCTION sp_get_movies_id_avarage_price ()
RETURNS TABLE (id bigint,title text,release_date timestamp,price double precision,country_id bigint) -->
 LANGUAGE plpgsql AS
    $$
        BEGIN
            RETURN QUERY
            WITH avarage_price AS
                     (
                         SELECT  avg(m.price)  avg1 FROM "Movies" m
                     ),
                  last_Date AS
                     (
                         SELECT  * FROM  "Movies" m
                         WHERE  m.release_date = (select max(m.release_date) FROM "Movies" m)
                     )
            SELECT  * FROM "Movies" m
            WHERE m.release_date < (select lD.release_date from last_Date lD) AND m.price > (select ap.avg1 from
                                                                                                    avarage_price ap);
        END;
    $$;

SELECT * FROM sp_get_movies_id_avarage_price();

--------------------------------------------------- IF... ELSE --------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_if_else (x integer,y integer)
RETURNS integer
 LANGUAGE plpgsql AS
    $$
        BEGIN
                IF x > y THEN
                    RETURN x;
                ELSE
                    RETURN y;

                end if;
        END;
    $$;

CREATE OR REPLACE FUNCTION sp_if_elseif (x integer,y integer,z integer)
RETURNS integer
 LANGUAGE plpgsql AS
    $$
        BEGIN
                IF x > y AND x > z THEN
                    RETURN x;
                ELSEIF y>z THEN
                    RETURN y;
                ELSE
                    RETURN z;
                end if;
        END;
    $$;

-- ****************************************************** 23.12.2020 *************************************************

----------------------------------------------------- CASE WHEN ------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_case (x integer,y integer,z integer)
RETURNS integer
 LANGUAGE plpgsql AS
    $$
        BEGIN
                CASE
                    WHEN x > y AND  x > z THEN
                        RETURN x;
                    WHEN x > y AND  x > z THEN
                        RETURN y;
                ELSE
                    RETURN z;
                END CASE ;
        END;
    $$;
select * from sp_case (5,100,17)
-- Преимущество CASE WITH над IF...ELSE в том, что CASE WITH можно использовать непосредственно после SELECT,чтобы
-- задать нужное для выборки поле через условие. Как в примере прведённом ниже:

CREATE OR REPLACE FUNCTION sp_movie_id (_id_type text)
RETURNS TABLE (ids bigint,title text)
 LANGUAGE plpgsql AS
    $$
        BEGIN
                RETURN QUERY
                SELECT case when _id_type = 'M' then m.id else m.country_id END, m.title FROM "Movies" m;
        END;
    $$;

select * from sp_movie_id ('M')

----------------------------------------------------- Classwork ------------------------------------------------------
-- 1. get two numbers x,b (int) and operation (text) rerutns float
        -- if operation '+' return a+b if '-' a-b '*' a*b '/' a/b
-- 2. solve 1 using case
-- 3. return movie price as is or pow2 depends on sent boolean argument

--                                       *** ОТВЕТ НАХОДИТСЯ НА 01:20 ЛЕКЦИИ ***

------------------------------------------------ WHILE ... LOOP and FOR .... LOOP and RANDOMS-------------------------
CREATE OR REPLACE FUNCTION sp_get_randoms (_max integer)
RETURNS integer AS
    $$
        BEGIN
                return (random () * (_max - 1))+1; --> RANDOM включает 0 и поэтому мы отнимаем 1, а потом добавляем
        END ;
    $$ language plpgsql;

CREATE OR REPLACE FUNCTION sp_loop1 ()
RETURNS integer AS
    $$
        DECLARE
            sum int := 0;
        BEGIN
               FOR i IN 1 ..(SELECT count (*) FROM country) --> число обозначающее требуемое к-во итераций цикла;
                    loop
                            sum := sum + (SELECT id FROM country WHERE id = i); --> то что хотим сделать во время
                                                                                    -- каждой итерации цикла;
                   end loop;
               RETURN sum;
        END ;
    $$ language plpgsql;

select * from sp_loop1();

------------------------------------------------------ Classwork ----------------------------------------------------
--grades
--grade -in [PK AI], class-id, student0id, grade (double)
-- for --> class 1-5, students 1-30, grade random 0-100

CREATE OR REPLACE FUNCTION sp_populate_grade (_classes int, _students int)
RETURNS integer AS
    $$
        DECLARE
            counter int := 0; --> для пересчёта вносимых записей
            _grade double precision :=0;
        BEGIN
               FOR i IN 1 .._classes
                    loop
                            FOR j IN 1 .._students
                                loop
                                     counter := counter + 1;
                                     _grade = random() * 100;
                                     INSERT INTO  grades (class_id, student_id, grade)
                                     VALUES (i,j,_grade);
                                end loop ;
                   end loop;
               RETURN counter;
        END ;
    $$ language plpgsql;

select * from sp_populate_grade (5,30);