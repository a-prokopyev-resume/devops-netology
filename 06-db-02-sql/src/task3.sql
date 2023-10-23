SELECT current_user;
SELECT session_user;
SELECT current_database();

INSERT INTO public.Orders(Name, Price) VALUES
    ('Шоколад', 10),
    ('Принтер', 3000),
    ('Книга', 500),
    ('Монитор', 7000),
    ('Гитара', 4000);

SELECT count(*) FROM Orders;    


INSERT INTO public.Clients(Name, Country, Order_ID) VALUES
    ('Иванов Иван Иванович', 'USA', null),
    ('Петров Петр Петрович', 'Canada', null),
    ('Иоганн Себастьян Бах', 'Japan', null),
    ('Ронни Джеймс Дио', 'Russia', null),
    ('Ritchie Blackmore', 'Russia', null);

SELECT count(*) FROM Clients;


