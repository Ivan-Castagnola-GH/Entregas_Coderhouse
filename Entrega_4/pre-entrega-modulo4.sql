create database pre_entrega_modulo4;

CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    precio NUMERIC(10, 2) NOT NULL,
    categoria_id INT REFERENCES categorias(categoria_id)
);

CREATE TABLE ventas (
    venta_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(cliente_id),
    producto_id INT REFERENCES productos(producto_id),
    cantidad INT NOT NULL,
    fecha_venta DATE NOT NULL
);

-- Inserción de datos de ejemplo
INSERT INTO clientes (cliente_id, nombre, email) VALUES 
(1, 'Ana Pérez', 'ana@email.com'),
(2, 'Carlos Gómez', 'carlos@email.com'),
(3, 'Elena Rodríguez', 'elena@email.com'),
(4, 'Javier Fernández', 'javier@email.com'); -- Cliente sin compras

INSERT INTO categorias (categoria_id, nombre_categoria) VALUES 
(1, 'Electrónica'),
(2, 'Hogar'),
(3, 'Ropa');

INSERT INTO productos (producto_id, nombre_producto, precio, categoria_id) VALUES 
(1, 'Televisor 50"', 450.00, 1),
(2, 'Auriculares Bluetooth', 50.00, 1),
(3, 'Aspiradora Robot', 200.00, 2),
(4, 'Campera de Cuero', 120.00, 3);

INSERT INTO ventas (cliente_id, producto_id, cantidad, fecha_venta) VALUES 
(1, 1, 2, '2026-01-15'), -- Ana compra 2 Televisores
(1, 2, 5, '2026-02-10'), -- Ana compra 5 Auriculares
(2, 3, 1, '2026-02-15'), -- Carlos compra 1 Aspiradora
(3, 4, 3, '2026-03-01'), -- Elena compra 3 Camperas
(2, 2, 2, '2026-03-05'), -- Carlos compra 2 Auriculares
(1, 2, 4, '2026-04-10'),  -- Ana compra 4 Auriculares
(1, 1, 1, '2026-04-15'),  -- Ana compra 1 Televisor
(2, 2, 10, '2026-04-20'), -- Carlos compra 10 Auriculares
(3, 4, 2, '2026-04-25'); -- Elena compra 2 Camperas

-- RENTABILIDAD POR CATEGORÍA
-- Esta consulta permite conocer la cantidad de unidades vendidas y los
-- ingresos totales generados por cada categoría de productos.

-- Se utiliza la tabla categorias como tabla principal y se realizan JOIN
-- con productos y ventas para relacionar cada categoría con sus productos
-- y las respectivas operaciones de venta.

-- SUM(v.cantidad) calcula el total de unidades vendidas por categoría.
-- SUM(v.cantidad * p.precio) calcula los ingresos totales generados.

-- GROUP BY agrupa los registros según el id y el nombre
-- de cada categoría para realizar los cálculos correspondientes.

-- HAVING filtra los grupos obtenidos y muestra únicamente las categorías
-- que superan el umbral definido de 2 unidades vendidas.

select  c.nombre_categoria,
		sum(v.cantidad) as unidades_vendidas,
		sum(v.cantidad * p.precio) as total_ingresos
from categorias c
join productos p on c.categoria_id = p.categoria_id
join ventas v on p.producto_id  = v.producto_id
group by c.categoria_id, c.nombre_categoria
having sum(v.cantidad) > 2; --Umbral definido en 2 por las cantidades pequeñas que se insertaron en ventas

-- CLIENTES SIN COMPRAS
-- Esta consulta permite identificar a los clientes registrados que no
-- poseen ventas asociadas.

-- Se seleccionan el id y el nombre de cada cliente.
-- Mediante COALESCE se reemplazan los valores NULL de venta_id por el
-- mensaje 'No tiene ventas'. Se utiliza CAST para convertir el identificador
-- numérico a VARCHAR y hacerlo compatible con el texto del COALESCE.

-- Se utiliza LEFT JOIN para relacionar clientes con ventas mediante
-- cliente_id, conservando todos los registros de la tabla clientes,
-- incluso aquellos que no poseen ventas relacionadas.

-- Finalmente, WHERE v.venta_id IS NULL filtra los resultados y devuelve
-- únicamente los clientes que no tienen ventas registradas.

select c.cliente_id, c.nombre, coalesce(cast(v.venta_id as varchar), 'No tiene ventas') as ventas_del_cliente
from clientes c
left join ventas v on c.cliente_id = v.cliente_id
where v.venta_id is null;


select 	
		c.cliente_id,
		c.nombre, 
		coalesce(p.nombre_producto, 'No compro productos') as nombre_producto,
		coalesce(sum(v.cantidad),0) as total_unidades_compradas,
		max(v.fecha_venta) as fecha_ultima_transaccion
from clientes c
left join ventas v on c.cliente_id = v.cliente_id
left join productos p on v.producto_id = p.producto_id
group by c.cliente_id, c.nombre, p.nombre_producto

-- TOP DE COMPRAS POR CLIENTE
-- Esta consulta permite identificar, para cada cliente, el producto del que
-- adquirió la mayor cantidad de unidades y la fecha de su última transacción.

-- 1. Primera subconsulta: producto más comprado.
-- Se utiliza la tabla ventas como tabla principal y se realiza un JOIN con
-- productos para obtener el nombre de cada producto.
-- Mediante WHERE se relaciona el cliente de la consulta principal con las
-- ventas correspondientes a su cliente_id. Esto permite que la subconsulta
-- sea correlacionada y analice las compras de cada cliente individualmente.
-- Luego, GROUP BY agrupa las ventas según el id y el nombre del producto.
-- ORDER BY SUM(v.cantidad) DESC ordena los productos de mayor a menor
-- según la cantidad total de unidades adquiridas.
-- LIMIT 1 devuelve únicamente el producto con mayor cantidad de unidades.
-- Finalmente, COALESCE reemplaza el valor NULL por el mensaje
-- 'No realizó compras' cuando el cliente no tiene ventas registradas.

-- 2. Segunda subconsulta: fecha de última transacción.
-- Se utiliza MAX(v.fecha_venta) para obtener la fecha más reciente
-- de las ventas de cada cliente.
-- Mediante WHERE se relacionan las ventas con el cliente correspondiente
-- de la consulta principal.
-- Se convierte el resultado DATE a VARCHAR para poder utilizar COALESCE
-- y reemplazar los valores NULL por el mensaje 'No realizó transacciones'
-- cuando el cliente no tiene ventas registradas.

-- 3. Consulta principal.
-- Se utiliza clientes como tabla principal para incluir a todos los
-- clientes registrados, incluso aquellos que no realizaron compras.
-- Finalmente, ORDER BY c.nombre ordena los resultados alfabéticamente
-- según el nombre de cada cliente.

SELECT
    c.nombre,
    COALESCE(
        (
            SELECT p.nombre_producto
            FROM ventas v
            JOIN productos p
                ON v.producto_id = p.producto_id
            WHERE v.cliente_id = c.cliente_id
            GROUP BY p.producto_id, p.nombre_producto
            ORDER BY SUM(v.cantidad) DESC
            LIMIT 1), 'No realizó compras') AS producto_mas_comprado,
	COALESCE(
	    (
	        SELECT CAST(MAX(v.fecha_venta) AS VARCHAR)
	        FROM ventas v
	        WHERE v.cliente_id = c.cliente_id
	    ),
	    'No realizó transacciones'
	) AS fecha_ultima_transaccion
FROM clientes c
ORDER BY c.nombre;

