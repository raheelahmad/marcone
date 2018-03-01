CREATE DATABASE marcone;
\c marcone;

CREATE TABLE podcasts (
  title text,
  author_name text
);
INSERT INTO podcasts (title, author_name) VALUES ('This American Life', 'NPR');
INSERT INTO podcasts (title, author_name) VALUES ('Back to Work', '5by5');
