create table trame (
id serial,
jour date,
heure numeric,
latitude numeric,
longitude numeric,
geom geometry(Point,4326),
Constraint pk_trame PRIMARY KEY (id)
);

CREATE INDEX index_trame_geom
  ON public.trame
  USING gist
  (geom);
