CALL UpdateClient('Иванов Иван Иванович', 'Книга');
CALL UpdateClient('Петров Петр Петрович', 'Монитор');
CALL UpdateClient('Иоганн Себастьян Бах', 'Гитара');
CREATE OR REPLACE VIEW OrderingClients AS SELECT C.*, O.Name OrderName, O.Price FROM Clients C LEFT JOIN Orders O ON C.Order_ID = O.ID WHERE C.Order_ID is not null;
SELECT * FROM OrderingClients;
