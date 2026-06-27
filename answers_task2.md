# Bonus task 2

1. What is the difference between a function and a procedure in PostgreSQL?

A function and a procedure are similar because both contain SQL code and perform operations 
in the database. The main difference is that function always returns a value and can be used 
inside SQL queries. A procedure does not have to return a value and is executed using the 
CALL statement. Procedures are usually used for more complex tasks, such as creating an 
order or updating data

2. Can a trigger be executed manually? Why or why not?

No, trigger can't be executed manually. It is automatically executed when a specific event (for example 
insert, update or delete) occurs in the database. It helps user to do some action without interaction. 
We can see an example in assignment 3, where trigger updates the order total or creates a log record 
after a new order is created

3. What are the advantages and disadvantages of storing business logic inside the database?

So one advantage of storing business logic is that all business rules can be placed in one place,
which helps different applications work with the data in the same way and reduces the chance of 
errors or mistakes. Also it can improve performance because some operations are executed directly 
by the database, which makes the process faster. But the disadvantage is that if there is 
too much business logic, the database becomes more difficult to maintain, update, and debug.


# bonus task 3

PostgreSQL починає виконання запиту зі зчитування даних із таблиць order_items та products.
Для читання записів використовується Sequential Scan, оскільки таблиці містять невелику 
кількість рядків, і повне сканування є ефективним. Після цього PostgreSQL створює хеш-таблицю 
та використовує Hash Join для швидкого об'єднання даних за полем product_id. Далі 
застосовується умова WHERE order_id = 1, після чого обчислюється значення item_total і 
повертаються всі товари, що належать цьому замовленню. Для невеликих таблиць такий план 
виконання забезпечує хорошу продуктивність.
