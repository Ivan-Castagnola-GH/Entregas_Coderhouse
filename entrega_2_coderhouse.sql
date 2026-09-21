create database retail_project;

create table clientes (
	id_cliente serial primary key not null,
	nombre varchar(50),
	email varchar(50) not null,
	edad int not null check (edad >= 18)
);

create table productos(
	id_producto serial primary key not null,
	nombre varchar(50) not null,
	categoria varchar(50) not null,
	precio_unitario decimal(10, 2) not null check (precio_unitario > 0),
	stock int not null check (stock >= 0)
);

create table ventas(
	id_venta serial primary key not null,
	id_cliente int not null references clientes(id_cliente),
	id_producto int not null references productos(id_producto),
	cantidad int not null check (cantidad > 0),
	fecha_venta timestamp not null
);

begin;

insert into clientes(nombre, email, edad) values
	('Cristian Perez', 'perezc@gmail.com', 20),
	('Daniela Sanchez', 'danielasanchez12@gmail.com', 34),
	('Maria Pereira', 'mariaper2001@gmail.com', 25),
	('Lucas Dominguez', 'ldom@gmail.com', 18),
	('Micaela Martinez', 'martinezm@gmail.com', 30);

insert into productos(nombre, categoria, precio_unitario, stock) values
	('Microondas', 'Electronica', 180000.00, 230),
	('Pelota de futbol', 'Deportes', 45500.00, 30),
	('Escritorio para computadora', 'Muebles', 130000.00, 55),
	('Parlante para salon', 'Electronica', 230000.00, 15),
	('Playstation 5', 'Electronica', 1700000.00, 300);

insert into ventas(id_cliente, id_producto, cantidad, fecha_venta) values
	(1, 1, 2, '2026-09-20'),
	(2, 4, 1, '2026-08-08'),
	(3, 5, 1, '2025-04-29'),
	(2, 5, 1, '2026-06-15'),
	(5, 2, 3, '2024-01-01');

commit;

update productos 
set precio_unitario = precio_unitario * 1.10 
where categoria = 'Electronica';

delete from ventas 
where id_cliente = 2;


