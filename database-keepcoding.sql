CREATE TABLE usuarios (
  id serial PRIMARY KEY,
  email varchar NOT NULL UNIQUE,
  password_hash varchar,
  first_name varchar,
  last_name varchar,
  phone varchar,
  locale varchar,
  timezone varchar,
  is_active boolean DEFAULT true,
  created_at timestamptz,
  updated_at timestamptz
);

CREATE TABLE roles (
  id serial PRIMARY KEY,
  nombre varchar UNIQUE,
  descripcion text
);

CREATE TABLE usuario_roles (
  id serial PRIMARY KEY,
  usuario_id int NOT NULL,
  rol_id int NOT NULL,
  assigned_at timestamptz,
  CONSTRAINT fk_usuario_roles_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  CONSTRAINT fk_usuario_roles_rol FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE
);

CREATE TABLE alumnos (
  id serial PRIMARY KEY,
  usuario_id int UNIQUE NOT NULL,
  nickname varchar,
  bio text,
  linkedin_url varchar,
  github_url varchar,
  resume_url varchar,
  fecha_nacimiento date,
  estado varchar,
  created_at timestamptz,
  updated_at timestamptz,
  CONSTRAINT fk_alumnos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE profesores (
  id serial PRIMARY KEY,
  usuario_id int UNIQUE NOT NULL,
  titulo varchar,
  bio text,
  perfil_publico boolean DEFAULT true,
  tarifa_hora numeric(10,2),
  created_at timestamptz,
  updated_at timestamptz,
  CONSTRAINT fk_profesores_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE programas_bootcamp (
  id serial PRIMARY KEY,
  slug varchar UNIQUE,
  nombre varchar,
  descripcion text,
  nivel varchar,
  duracion_semanas int,
  precio numeric(12,2),
  idioma varchar,
  publicado boolean DEFAULT false,
  created_at timestamptz,
  updated_at timestamptz
);

CREATE TABLE modulos (
  id serial PRIMARY KEY,
  programa_id int NOT NULL,
  titulo varchar,
  descripcion text,
  orden int,
  duracion_semanas int,
  prerequisitos text,
  tipo varchar,
  created_at timestamptz,
  updated_at timestamptz,
  CONSTRAINT fk_modulos_programa FOREIGN KEY (programa_id) REFERENCES programas_bootcamp(id) ON DELETE RESTRICT
);

CREATE TABLE lecciones (
  id serial PRIMARY KEY,
  modulo_id int NOT NULL,
  titulo varchar,
  resumen text,
  contenido_url varchar,
  tipo varchar,
  duracion_minutos int,
  orden int,
  created_at timestamptz,
  updated_at timestamptz,
  CONSTRAINT fk_lecciones_modulo FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE CASCADE
);

CREATE TABLE recursos (
  id serial PRIMARY KEY,
  modulo_id int,
  leccion_id int,
  titulo varchar,
  url varchar,
  tipo varchar,
  obligatorio boolean DEFAULT false,
  created_at timestamptz,
  CONSTRAINT fk_recursos_modulo FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE SET NULL,
  CONSTRAINT fk_recursos_leccion FOREIGN KEY (leccion_id) REFERENCES lecciones(id) ON DELETE SET NULL
);

CREATE TABLE modulos_profesores (
  id serial PRIMARY KEY,
  modulo_id int NOT NULL,
  profesor_id int NOT NULL,
  rol varchar,
  asignado_at timestamptz,
  CONSTRAINT fk_modprof_modulo FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE CASCADE,
  CONSTRAINT fk_modprof_profesor FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE
);

CREATE TABLE inscripciones (
  id serial PRIMARY KEY,
  alumno_id int NOT NULL,
  fecha_inscripcion timestamptz,
  estado varchar,
  fuente varchar,
  plan_pago varchar,
  tuition_pagado boolean DEFAULT false,
  fecha_graduacion date,
  created_at timestamptz,
  updated_at timestamptz,
  CONSTRAINT fk_inscripciones_alumno FOREIGN KEY (alumno_id) REFERENCES alumnos(id) ON DELETE CASCADE
);

CREATE TABLE pagos (
  id serial PRIMARY KEY,
  usuario_id int NOT NULL,
  inscripcion_id int,
  monto numeric(12,2),
  moneda varchar,
  metodo varchar,
  estado varchar,
  fecha_pago timestamptz,
  provider_tx varchar,
  created_at timestamptz,
  CONSTRAINT fk_pagos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL,
  CONSTRAINT fk_pagos_inscripcion FOREIGN KEY (inscripcion_id) REFERENCES inscripciones(id) ON DELETE SET NULL
);

CREATE TABLE facturas (
  id serial PRIMARY KEY,
  pago_id int,
  usuario_id int NOT NULL,
  total numeric(12,2),
  impuesto numeric(12,2),
  fecha_emision date,
  fecha_vencimiento date,
  estado varchar,
  archivo_url varchar,
  CONSTRAINT fk_facturas_pago FOREIGN KEY (pago_id) REFERENCES pagos(id) ON DELETE SET NULL,
  CONSTRAINT fk_facturas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

CREATE TABLE asignaciones (
  id serial PRIMARY KEY,
  modulo_id int NOT NULL,
  titulo varchar,
  descripcion text,
  fecha_entrega timestamptz,
  puntos_max int,
  tipo varchar,
  created_at timestamptz,
  updated_at timestamptz,
  CONSTRAINT fk_asignaciones_modulo FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE CASCADE
);

CREATE TABLE entregas (
  id serial PRIMARY KEY,
  asignacion_id int NOT NULL,
  alumno_id int NOT NULL,
  entregado_at timestamptz,
  repo_url varchar,
  archivos_url text,
  comentario text,
  estado varchar,
  created_at timestamptz,
  CONSTRAINT fk_entregas_asignacion FOREIGN KEY (asignacion_id) REFERENCES asignaciones(id) ON DELETE CASCADE,
  CONSTRAINT fk_entregas_alumno FOREIGN KEY (alumno_id) REFERENCES alumnos(id) ON DELETE CASCADE
);

CREATE TABLE calificaciones (
  id serial PRIMARY KEY,
  entrega_id int NOT NULL,
  profesor_id int NOT NULL,
  puntuacion numeric(5,2),
  feedback text,
  calificado_at timestamptz,
  CONSTRAINT fk_calificaciones_entrega FOREIGN KEY (entrega_id) REFERENCES entregas(id) ON DELETE CASCADE,
  CONSTRAINT fk_calificaciones_profesor FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE SET NULL
);

CREATE TABLE progreso_modulo (
  id serial PRIMARY KEY,
  alumno_id int NOT NULL,
  modulo_id int NOT NULL,
  estado varchar,
  progreso_porcentaje int,
  fecha_inicio timestamptz,
  fecha_completado timestamptz,
  nota_final numeric(5,2),
  updated_at timestamptz,
  CONSTRAINT fk_progreso_alumno FOREIGN KEY (alumno_id) REFERENCES alumnos(id) ON DELETE CASCADE,
  CONSTRAINT fk_progreso_modulo FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE CASCADE
);

CREATE TABLE certificados (
  id serial PRIMARY KEY,
  alumno_id int NOT NULL,
  programa_id int NOT NULL,
  codigo varchar UNIQUE,
  emitido_en date,
  archivo_url varchar,
  valido_hasta date,
  CONSTRAINT fk_certificados_alumno FOREIGN KEY (alumno_id) REFERENCES alumnos(id) ON DELETE CASCADE,
  CONSTRAINT fk_certificados_programa FOREIGN KEY (programa_id) REFERENCES programas_bootcamp(id) ON DELETE CASCADE
);

CREATE TABLE archivos (
  id serial PRIMARY KEY,
  owner_table varchar,
  owner_id int,
  filename varchar,
  url varchar,
  size_bytes int,
  uploaded_by int,
  uploaded_at timestamptz,
  CONSTRAINT fk_archivos_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES usuarios(id) ON DELETE SET NULL
);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_programas_slug ON programas_bootcamp(slug);
CREATE INDEX idx_certificados_codigo ON certificados(codigo);
CREATE INDEX idx_archivos_owner ON archivos(owner_table, owner_id);
