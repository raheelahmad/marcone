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

CREATE TABLE categories (
  name text PRIMARY KEY
);

CREATE TABLE podcasts (
  url text PRIMARY KEY,
  title text,
  subtitle text,
  description text,
  summary text,
  author_name text,
  copyright text,
  image_url text,
  categories text,
  type text,

  episode_id text REFERENCES episodes
);


CREATE TABLE podcast_categories (
  category_name text REFERENCES categories (name),
  podcast_url text REFERENCES podcasts (url),

  CONSTRAINT category_podcast_pkey PRIMARY KEY (category_name, podcast_url)
);

-- INSERT INTO podcasts (title, author_name) VALUES ('This American Life', 'NPR');
-- INSERT INTO podcasts (title, author_name) VALUES ('Back to Work', '5by5');
