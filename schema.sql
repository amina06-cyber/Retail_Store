CREATE TABLE retail_store.customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE retail_store.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2),
    stock_quantity INT
);

CREATE TABLE retail_store.orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES retail_store.customers(customer_id),
    order_date DATE,
    status VARCHAR(20),
    total_amount NUMERIC(10,2)
);

CREATE TABLE retail_store.payments (
    payment_id INT PRIMARY KEY,
    order_id INT REFERENCES retail_store.orders(order_id),
    payment_date DATE,
    amount NUMERIC(10,2),
    method VARCHAR(30)
);