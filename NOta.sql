-- 1-5. Создание БД и таблиц
CREATE DATABASE IF NOT EXISTS Library_Variant3_Full;
USE Library_Variant3_Full;

CREATE TABLE Books (
    id_book INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    year INT,
    isbn VARCHAR(20) UNIQUE,
    pages INT DEFAULT NULL
);

CREATE TABLE Authors (
    id_author INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

CREATE TABLE BookAuthors (
    id_book INT,
    id_author INT,
    PRIMARY KEY (id_book, id_author),
    FOREIGN KEY (id_book) REFERENCES Books(id_book) ON DELETE CASCADE,
    FOREIGN KEY (id_author) REFERENCES Authors(id_author) ON DELETE CASCADE
);

CREATE TABLE Readers (
    id_reader INT PRIMARY KEY AUTO_INCREMENT,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE Loans (
    id_loan INT PRIMARY KEY AUTO_INCREMENT,
    id_book INT NOT NULL,
    id_reader INT NOT NULL,
    loan_date DATE NOT NULL,
    planned_return_date DATE NOT NULL,
    actual_return_date DATE NULL,
    FOREIGN KEY (id_book) REFERENCES Books(id_book) ON DELETE RESTRICT,
    FOREIGN KEY (id_reader) REFERENCES Readers(id_reader) ON DELETE RESTRICT
);

CREATE TABLE Fines (
    id_fine INT PRIMARY KEY AUTO_INCREMENT,
    id_reader INT NOT NULL,
    id_loan INT NOT NULL,
    amount DECIMAL(8,2) NOT NULL,
    paid BOOLEAN DEFAULT FALSE,
    reason VARCHAR(200),
    FOREIGN KEY (id_reader) REFERENCES Readers(id_reader),
    FOREIGN KEY (id_loan) REFERENCES Loans(id_loan)
);

-- 6. Вставка книг
INSERT INTO Books (title, year, isbn) VALUES
('Война и мир', 1869, '978-5-17-096789-0'),
('Преступление и наказание', 1866, '978-5-04-108456-7'),
('Мастер и Маргарита', 1967, '978-5-17-118123-4'),
('1984', 1949, '978-5-04-101234-5'),
('Маленький принц', 1943, '978-5-17-089123-4');

-- 7. Вставка авторов
INSERT INTO Authors (first_name, last_name) VALUES
('Лев', 'Толстой'),
('Фёдор', 'Достоевский'),
('Михаил', 'Булгаков'),
('Джордж', 'Оруэлл');

-- 8. Связи книг с авторами
INSERT INTO BookAuthors (id_book, id_author) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4);

-- 9. Вставка читателей
INSERT INTO Readers (last_name, first_name, phone, email) VALUES
('Иванов', 'Сергей', '+7-915-123-45-67', 'ivanov@mail.ru'),
('Петрова', 'Анна', '+7-916-234-56-78', 'petrova@yandex.ru'),
('Сидоров', 'Алексей', '+7-903-345-67-89', 'sidorov@gmail.com');

-- 10. Выдача книг
INSERT INTO Loans (id_book, id_reader, loan_date, planned_return_date, actual_return_date) VALUES
(1, 1, '2025-05-01', '2025-05-15', '2025-05-14'),
(2, 2, '2025-05-10', '2025-05-24', '2025-05-28'),
(3, 3, '2025-05-15', '2025-05-29', NULL),
(1, 2, '2025-05-20', '2025-06-03', NULL),
(4, 1, '2025-05-25', '2025-06-08', '2025-06-07');

-- 11. Штрафы
INSERT INTO Fines (id_reader, id_loan, amount, paid, reason) VALUES
(2, 2, 100.00, FALSE, 'Просрочка возврата на 4 дня'),
(3, 3, 50.00, FALSE, 'Просрочка возврата');

-- 12-25. Запросы (выполняйте по очереди)
SELECT * FROM Books WHERE year > 2000;
SELECT * FROM Readers ORDER BY last_name;
SELECT * FROM Books WHERE title LIKE '%мир%';

SELECT l.id_loan, r.last_name, b.title, l.loan_date, l.planned_return_date, l.actual_return_date
FROM Loans l
JOIN Readers r ON l.id_reader = r.id_reader
JOIN Books b ON l.id_book = b.id_book;

SELECT b.title, COUNT(l.id_loan) AS loan_count
FROM Books b
LEFT JOIN Loans l ON b.id_book = l.id_book
GROUP BY b.id_book
HAVING loan_count > 0;

SELECT r.last_name, r.first_name, COUNT(l.id_loan) AS total_loans
FROM Readers r
JOIN Loans l ON r.id_reader = l.id_reader
GROUP BY r.id_reader
ORDER BY total_loans DESC
LIMIT 1;

SELECT AVG(DATEDIFF(actual_return_date, loan_date)) FROM Loans WHERE actual_return_date IS NOT NULL;

SELECT YEAR(loan_date) AS year, MONTH(loan_date) AS month, COUNT(*) FROM Loans GROUP BY year, month;

SELECT b.* FROM Books b LEFT JOIN Loans l ON b.id_book = l.id_book WHERE l.id_loan IS NULL;

UPDATE Fines SET amount = 50.00 WHERE paid = FALSE;

ALTER TABLE Books ADD COLUMN pages INT;

CREATE VIEW OverdueLoans AS
SELECT r.last_name, r.first_name, b.title, l.planned_return_date, DATEDIFF(CURDATE(), l.planned_return_date) AS overdue_days
FROM Loans l
JOIN Readers r ON l.id_reader = r.id_reader
JOIN Books b ON l.id_book = b.id_book
WHERE l.planned_return_date < CURDATE() AND l.actual_return_date IS NULL;

SELECT a.last_name, a.first_name, 
       COUNT(DISTINCT ba.id_book) AS books_written,
       COUNT(l.id_loan) AS total_loans,
       AVG(CASE WHEN l.actual_return_date IS NOT NULL THEN DATEDIFF(l.actual_return_date, l.loan_date) ELSE NULL END) AS avg_reading_days
FROM Authors a
LEFT JOIN BookAuthors ba ON a.id_author = ba.id_author
LEFT JOIN Books b ON ba.id_book = b.id_book
LEFT JOIN Loans l ON b.id_book = l.id_book
GROUP BY a.id_author;