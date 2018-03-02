CREATE DATABASE marcone;
\c marcone;

CREATE TABLE episodes (
  episode_id text PRIMARY KEY,
  title text,
  description text,
  pub_date date,
  guid text,
  image_url text,
  duration integer,
  enclosure_type text,
  enclosure_length text,
  enclosure_url text
);

CREATE TABLE podcasts (
  url text PRIMARY KEY,
  title text,
  description text,
  author_name text,
  copyright text,
  image_url text,
  author text,
  category text,
  type text,

  episode_id text REFERENCES episodes
);

-- INSERT INTO podcasts (title, author_name) VALUES ('This American Life', 'NPR');
-- INSERT INTO podcasts (title, author_name) VALUES ('Back to Work', '5by5');
