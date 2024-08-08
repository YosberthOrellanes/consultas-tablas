--1. Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo pedido--
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    rol VARCHAR(50) CHECK (rol IN ('administrador', 'usuario')) NOT NULL
);

INSERT INTO usuarios (email, nombre, apellido, rol) VALUES
('juan.perez@example.com', 'Juan', 'Pérez', 'usuario'),
('maria.gonzalez@example.com', 'María', 'González', 'usuario'),
('pedro.sanchez@example.com', 'Pedro', 'Sánchez', 'administrador'),
('luisa.martinez@example.com', 'Luisa', 'Martínez', 'usuario'),
('carlos.fernandez@example.com', 'Carlos', 'Fernández', 'usuario');

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    destacado BOOLEAN DEFAULT FALSE,
    usuario_id BIGINT
);

INSERT INTO posts (titulo, contenido, fecha_creacion, fecha_actualizacion, destacado, usuario_id) VALUES
('Post de Administrador 1', 'Contenido del post de administrador 1.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, 1),
('Post de Administrador 2', 'Contenido del post de administrador 2.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE, 1),
('Post de Usuario Normal 1', 'Contenido del post de usuario normal 1.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE, 2),
('Post de Usuario Normal 2', 'Contenido del post de usuario normal 2.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE, 2),
('Post sin Usuario', 'Contenido del post sin usuario asignado.', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE, NULL);

CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT REFERENCES usuarios(id),
    post_id BIGINT REFERENCES posts(id)
);

INSERT INTO comentarios (contenido, fecha_creacion, usuario_id, post_id) VALUES
('Comentario 1 para el post 1', CURRENT_TIMESTAMP, 1, 1),
('Comentario 2 para el post 1', CURRENT_TIMESTAMP, 2, 1),
('Comentario 3 para el post 1', CURRENT_TIMESTAMP, 3, 1),
('Comentario 4 para el post 2', CURRENT_TIMESTAMP, 1, 2),
('Comentario 5 para el post 2', CURRENT_TIMESTAMP, 2, 2);

-- 2. Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas: nombre y email del usuario junto al título y contenido del post.--
SELECT 
    u.nombre, 
    u.email, 
    p.titulo, 
    p.contenido
FROM 
    posts p
JOIN 
    usuarios u
ON 
    p.usuario_id = u.id;

--3. Muestra el id, título y contenido de los posts de los administradores. El administrador puede ser cualquier id.--
SELECT 
    p.id, 
    p.titulo, 
    p.contenido
FROM 
    posts p
JOIN 
    usuarios u
ON 
    p.usuario_id = u.id
WHERE 
    u.rol = 'administrador';

--4. Cuenta la cantidad de posts de cada usuario. La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario.
SELECT 
    u.id, 
    u.email, 
    COUNT(p.id) AS cantidad_posts
FROM 
    usuarios u
LEFT JOIN 
    posts p
ON 
    u.id = p.usuario_id
GROUP BY 
    u.id, 
    u.email;

--5. Muestra el email del usuario que ha creado más posts. Aquí la tabla resultante tiene un único registro y muestra solo el email.--
SELECT 
    u.email
FROM 
    usuarios u
JOIN 
    posts p
ON 
    u.id = p.usuario_id
GROUP BY 
    u.email
ORDER BY 
    COUNT(p.id) DESC
LIMIT 1;

--6. Muestra la fecha del último post de cada usuario
SELECT 
    u.id, 
    u.email, 
    MAX(p.fecha_creacion) AS fecha_ultimo_post
FROM 
    usuarios u
LEFT JOIN 
    posts p
ON 
    u.id = p.usuario_id
GROUP BY 
    u.id, 
    u.email;

--7. Muestra el título y contenido del post (artículo) con más comentarios.
WITH ComentariosCount AS (
    SELECT 
        p.id,
        p.titulo,
        p.contenido,
        COUNT(c.id) AS cantidad_comentarios
    FROM 
        posts p
    LEFT JOIN 
        comentarios c
    ON 
        p.id = c.post_id
    GROUP BY 
        p.id, 
        p.titulo, 
        p.contenido
)
SELECT 
    titulo, 
    contenido
FROM 
    ComentariosCount
ORDER BY 
    cantidad_comentarios DESC
LIMIT 1;

--8. Muestra en una tabla el título de cada post, el contenido de cada post y el contenido de cada comentario asociado a los posts mostrados, junto con el email del usuario que lo escribió.
SELECT 
    p.titulo AS post_titulo,
    p.contenido AS post_contenido,
    c.contenido AS comentario_contenido,
    u.email AS usuario_email
FROM 
    posts p
JOIN 
    comentarios c
ON 
    p.id = c.post_id
JOIN 
    usuarios u
ON 
    c.usuario_id = u.id
ORDER BY 
    p.id, c.id;

--9.Muestra el contenido del último comentario de cada usuario.
WITH UltimosComentarios AS (
    SELECT 
        c.usuario_id,
        MAX(c.fecha_creacion) AS fecha_ultimo_comentario
    FROM 
        comentarios c
    GROUP BY 
        c.usuario_id
)
SELECT 
    u.id AS usuario_id,
    u.email,
    c.contenido AS comentario_contenido
FROM 
    UltimosComentarios uc
JOIN 
    comentarios c
ON 
    uc.usuario_id = c.usuario_id AND uc.fecha_ultimo_comentario = c.fecha_creacion
JOIN 
    usuarios u
ON 
    u.id = c.usuario_id;

--10. Muestra los emails de los usuarios que no han escrito ningún comentario
SELECT 
    u.email
FROM 
    usuarios u
LEFT JOIN 
    comentarios c
ON 
    u.id = c.usuario_id
GROUP BY 
    u.id, u.email
HAVING 
    COUNT(c.id) = 0;