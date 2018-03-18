CREATE DATABASE marcone;
\c marcone;

CREATE TABLE podcasts (
  id SERIAL PRIMARY KEY,
  url text UNIQUE,
  all_urls text[],
  title text,
  subtitle text,
  description text,
  summary text,
  author_name text,
  copyright text,
  image_url text,
  categories text,
  type text
);


CREATE TABLE episodes (
  title text,
  description text,
  link text,
  keywords text,
  author text,
  pub_date timestamp,
  guid text UNIQUE,
  image_url text,
  duration int,
  enclosure_type text,
  enclosure_length text,
  enclosure_url text,

  podcast_id SERIAL REFERENCES podcasts (id),
  unique (podcast_id, guid)
);
