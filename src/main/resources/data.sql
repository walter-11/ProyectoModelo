-- Inserción de Categorías
INSERT INTO categorias (descripcion, estado) VALUES ('Tecnología', true);
INSERT INTO categorias (descripcion, estado) VALUES ('Hogar', true);
INSERT INTO categorias (descripcion, estado) VALUES ('Deportes', true);

-- Inserción de Productos
INSERT INTO productos (nombre, id_categoria, codigo_barras, precio_venta, cantidad_stock, estado) 
VALUES ('Teclado Mecánico RGB', 1, '123456789012', 49.99, 15, true);

INSERT INTO productos (nombre, id_categoria, codigo_barras, precio_venta, cantidad_stock, estado) 
VALUES ('Auriculares Gaming', 1, '123456789013', 79.99, 8, true);

INSERT INTO productos (nombre, id_categoria, codigo_barras, precio_venta, cantidad_stock, estado) 
VALUES ('Licuadora Pro', 2, '223456789012', 89.99, 5, true);

INSERT INTO productos (nombre, id_categoria, codigo_barras, precio_venta, cantidad_stock, estado) 
VALUES ('Set de Sartenes Antiadherentes', 2, '223456789013', 59.99, 12, true);

INSERT INTO productos (nombre, id_categoria, codigo_barras, precio_venta, cantidad_stock, estado) 
VALUES ('Mesa de Centro de Madera', 2, '223456789014', 120.00, 3, true);

INSERT INTO productos (nombre, id_categoria, codigo_barras, precio_venta, cantidad_stock, estado) 
VALUES ('Balón de Fútbol N5', 3, '323456789012', 25.00, 20, true);

INSERT INTO productos (nombre, id_categoria, codigo_barras, precio_venta, cantidad_stock, estado) 
VALUES ('Manta de Yoga Antideslizante', 3, '323456789013', 19.99, 15, true);
