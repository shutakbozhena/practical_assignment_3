
create table customers (
    customer_id serial primary key,
    full_name varchar(100) not null,
    email varchar(100) unique not null,
    balance numeric(10,2) default 0
);

create table products (
    product_id serial primary key,
    product_name varchar(100) not null,
    price numeric(10,2) not null,
    stock_quantity int not null
);

create table orders (
    order_id serial primary key,
    customer_id int references customers(customer_id),
    order_date timestamp default current_timestamp,
    total_amount numeric(10,2) default 0
);

create table order_items (
    order_item_id serial primary key,
    order_id int references orders(order_id),
    product_id int references products(product_id),
    quantity int not null,
    price numeric(10,2) not null
);

create table order_log (
    log_id serial primary key,
    order_id int,
    customer_id int,
    action varchar(50),
    log_date timestamp default current_timestamp
);


-- завдання 1
create function calculate_order_total(p_order_id int)
returns numeric(10,2)
as $$
begin
	return (
-- сумуємо вартість усіх товарів у замовленні
		select coalesce(sum(quantity * price), 0)
        from order_items
        where order_id = p_order_id
	);
end; 
$$
language plpgsql;

select calculate_order_total(1);


-- завдання 2
create or replace procedure create_order(p_customer_id int)
language plpgsql
as $$
begin
	-- перевіряємо, чи існує покупець
    if exists (
        select 1
        from customers
        where customer_id = p_customer_id
    ) then
        -- створюємо нове замовлення
        insert into orders (customer_id, order_date, total_amount)
        values (p_customer_id, current_timestamp, 0);

    end if;
end;
$$;

-- викликаємо процедуру
call create_order(1);
-- перевіряємо чи працює
select *
from orders


-- завдання 3
-- завдання 3

-- процедура для додавання товару до замовлення
create or replace procedure add_product_to_order(
    p_order_id int,
    p_product_id int,
    p_quantity int
)
language plpgsql
as $$
declare
    v_price numeric(10,2);
    v_stock int;
begin
-- отримуємо ціну та залишок товару
    select price, stock_quantity
    into v_price, v_stock
    from products
    where product_id = p_product_id;
-- додаємо товар лише якщо кількість коректна і товар є на складі
    if p_quantity > 0 and v_stock >= p_quantity then
-- додаємо товар у замовлення
        insert into order_items (
            order_id,
            product_id,
            quantity,
            price)
        values (
            p_order_id,
            p_product_id,
            p_quantity,
            v_price);
-- зменшуємо залишок товару
        update products
        set stock_quantity = stock_quantity - p_quantity
        where product_id = p_product_id;
    end if;
end;
$$;

call add_product_to_order(1, 2, 3);

select * from order_items


-- завдання 4
create function update_order_total()
returns trigger
as $$
begin
	    if tg_op = 'delete' then
        update orders
        set total_amount = calculate_order_total(old.order_id)
        where order_id = old.order_id;
    else
        update orders
        set total_amount = calculate_order_total(new.order_id)
        where order_id = new.order_id;
    end if;

    return null;
end;
$$
language plpgsql;

-- створюємо тригер для автоматичного оновлення суми замовлення
create trigger trg_update_order_total
after insert or update or delete
on order_items
for each row
execute function update_order_total();

call add_product_to_order(1, 2, 1);

select order_id, total_amount
from orders;


-- завдання 5

-- записуємо інформацію про нове замовлення
create or replace function log_new_order()
returns trigger
as $$
begin
    -- додаємо запис у журнал
    insert into order_log (
        order_id,
        customer_id,
        action,
        log_date
    )
    values (
        new.order_id,
        new.customer_id,
        'created',
        current_timestamp
    );
    return new;
end;
$$
language plpgsql;

-- створюємо тригер
create trigger trg_log_new_order
after insert
on orders
for each row
execute function log_new_order();

call create_order(2);

select *
from order_log;


-- завдання 6

-- створюємо нового покупця
insert into customers (full_name, email, balance)
values ('user task6', 'test@example.com', 1000);

-- створюємо новий товар
insert into products (product_name, price, stock_quantity)
values ('product task6', 100, 10);

-- створюємо замовлення
call create_order(3);

-- перевіряємо замовлення
select *
from orders;

-- додаємо товар у замовлення
call add_product_to_order(15, 2, 4);

-- перевіряємо товари у замовленні
select *
from order_items;

-- перевіряємо суму замовлення
select *
from orders;

-- перевіряємо залишок товару
select *
from products;

-- перевіряємо журнал
select *
from order_log;

-- added procedures
