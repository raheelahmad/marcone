CREATE DATABASE marcone;
\c marcone;

CREATE TABLE categories (
  name text PRIMARY KEY
);

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
  pub_date date,
  guid text UNIQUE,
  image_url text,
  duration text,
  enclosure_type text,
  enclosure_length text,
  enclosure_url text,

  podcast_id SERIAL REFERENCES podcasts (id),
  unique (podcast_id, guid)
);

CREATE TABLE podcast_categories (
  category_name text REFERENCES categories (name),
  podcast_id SERIAL REFERENCES podcasts (id),

  CONSTRAINT category_podcast_pkey PRIMARY KEY (category_name, podcast_id)
);
