-- Create your database tables here. Alternatively you may use an ORM
-- or whatever approach you prefer to initialize your database.
CREATE TABLE example_table (id SERIAL PRIMARY KEY, some_int INT, some_text TEXT);
INSERT INTO example_table (some_int, some_text) VALUES (123, 'hello');

CREATE TABLE components (id SERIAL PRIMARY KEY, some_int INT, some_text TEXT);
INSERT INTO components (some_int, some_text) VALUES (123, 'hello');

CREATE TYPE dimension_enum AS ENUM ('mt', 'mr', 'mb', 'ml', 'pt', 'pr', 'pb', 'pl');
CREATE TYPE metric_enum AS ENUM ('px', '%');

CREATE TABLE dimensions (
  component_id INT,
  dimension_name dimension_enum,
  value DECIMAL(10, 2),
  metric metric_enum,
  PRIMARY KEY (component_id, dimension_name),
  FOREIGN KEY (component_id) REFERENCES components(id)
);

